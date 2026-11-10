package com.batwa.wallet.service;

import com.batwa.wallet.dto.request.TopUpRequest;
import com.batwa.wallet.dto.request.TransferRequest;
import com.batwa.wallet.dto.response.RecipientLookupResponse;
import com.batwa.wallet.dto.response.TransactionResponse;
import com.batwa.wallet.dto.response.WalletResponse;
import com.batwa.wallet.entity.*;
import com.batwa.wallet.exception.*;
import com.batwa.wallet.repository.TransactionRepository;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.repository.UserSecuritySettingsRepository;
import com.batwa.wallet.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class WalletService {

    private final WalletRepository walletRepository;
    private final UserRepository userRepository;
    private final TransactionRepository transactionRepository;
    private final UserSecuritySettingsRepository settingsRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;
    private final NotificationService notificationService;

    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${app.wallet.transfer-fee-percentage:0.0}")
    private BigDecimal transferFeePercentage;

    @Value("${app.wallet.max-pin-attempts:5}")
    private int maxPinAttempts;

    @Transactional(readOnly = true)
    public WalletResponse getWalletByUserId(UUID userId) {
        Wallet wallet = walletRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found for user"));
        return authService.mapToWalletResponse(wallet);
    }

    public Optional<User> findUserByIdentifier(String identifier) {
        if (identifier == null || identifier.isBlank()) return Optional.empty();

        String trimmed = identifier.trim();
        String lower = trimmed.toLowerCase();
        String cleanTag = trimmed.replace("@", "").toLowerCase();

        // 1. Check wallet tag case-insensitively
        Optional<Wallet> byTag = walletRepository.findByWalletTagIgnoreCase(cleanTag);
        if (byTag.isPresent() && byTag.get().getUser() != null) {
            return Optional.of(byTag.get().getUser());
        }

        // 2. Check email
        Optional<User> byEmail = userRepository.findByEmail(lower);
        if (byEmail.isPresent()) {
            return byEmail;
        }

        // 3. Check phone number (exact, +92 variant, 0 variant)
        Optional<User> byPhone = userRepository.findByPhoneNumber(trimmed);
        if (byPhone.isPresent()) {
            return byPhone;
        }
        String digitsOnly = trimmed.replaceAll("[^0-9]", "");
        if (digitsOnly.length() >= 10) {
            String suffix10 = digitsOnly.substring(digitsOnly.length() - 10);
            String variant1 = "0" + suffix10;
            String variant2 = "+92" + suffix10;
            Optional<User> byPhoneVar = userRepository.findByPhoneNumber(variant1)
                    .or(() -> userRepository.findByPhoneNumber(variant2));
            if (byPhoneVar.isPresent()) {
                return byPhoneVar;
            }
        }

        // 4. Check CNIC number (exact and 13 digits)
        Optional<User> byCnic = userRepository.findByCnicNumber(trimmed);
        if (byCnic.isPresent()) {
            return byCnic;
        }
        if (digitsOnly.length() == 13) {
            String formattedCnic = digitsOnly.substring(0, 5) + "-" + digitsOnly.substring(5, 12) + "-" + digitsOnly.substring(12, 13);
            Optional<User> byFormattedCnic = userRepository.findByCnicNumber(formattedCnic);
            if (byFormattedCnic.isPresent()) {
                return byFormattedCnic;
            }
        }

        return Optional.empty();
    }

    @Transactional(readOnly = true)
    public RecipientLookupResponse lookupRecipient(String identifier, UUID currentUserId) {
        String cleanId = identifier.trim().replace("@", "");
        
        Optional<User> optionalUser = findUserByIdentifier(identifier);

        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            if (currentUserId != null && user.getId().equals(currentUserId)) {
                throw new SelfTransferException("You cannot send money to yourself");
            }
            Wallet recipientWallet = user.getWallet();
            if (recipientWallet == null) {
                recipientWallet = walletRepository.findByUserId(user.getId())
                        .orElseThrow(() -> new ResourceNotFoundException("Wallet not found for recipient"));
            }

            String rawPhone = user.getPhoneNumber();
            String maskedPhone = rawPhone != null && rawPhone.length() > 4
                    ? rawPhone.substring(0, rawPhone.length() - 4).replaceAll(".", "*") + rawPhone.substring(rawPhone.length() - 4)
                    : rawPhone;

            return RecipientLookupResponse.builder()
                    .walletTag(recipientWallet.getWalletTag())
                    .recipientFullName(user.getFullName())
                    .maskedPhoneNumber(maskedPhone)
                    .currency(recipientWallet.getCurrency())
                    .build();
        }

        // Check if identifier looks like a Bank Account / IBAN
        String lower = identifier.toLowerCase();
        if (cleanId.matches("\\d{8,24}") || cleanId.toUpperCase().startsWith("PK") || lower.contains("razi") || cleanId.contains("meezan") || cleanId.contains("bank")) {
            String[] demoTitles = {"MUHAMMAD RAZI", "MUHAMMAD USMAN TARIQ", "SYED HAMZA ALI", "FATIMA BATOOL", "BILAL KHAN", "AYESHA SIDDIQUI"};
            int idx = Math.abs(cleanId.hashCode()) % demoTitles.length;
            String title = demoTitles[idx];
            String tag = "bank." + cleanId.substring(Math.max(0, cleanId.length() - 4));
            String maskedPhone = "0300****123";

            return RecipientLookupResponse.builder()
                    .walletTag(tag)
                    .recipientFullName(title)
                    .maskedPhoneNumber(maskedPhone)
                    .currency("PKR")
                    .build();
        }

        // If it was a Batwa tag, username or phone that doesn't exist:
        throw new ResourceNotFoundException("No Batwa wallet account found for '" + identifier + "'. Please check the tag or mobile number.");
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public TransactionResponse topUp(UUID userId, TopUpRequest request, String idempotencyKey) {
        BigDecimal amount = request.getAmount().setScale(4, RoundingMode.HALF_UP);
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Top-up amount must be greater than zero");
        }

        // Lock wallet for update
        Wallet wallet = walletRepository.findByUserIdForUpdate(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found"));

        if (!wallet.isActive()) {
            throw new IllegalStateException("Wallet is currently inactive");
        }

        // Credit balance
        wallet.credit(amount);
        walletRepository.save(wallet);

        // Record immutable ledger entry
        String refNum = generateReferenceNumber("TOP");
        TransactionLedger ledger = TransactionLedger.builder()
                .referenceNumber(refNum)
                .destinationWallet(wallet)
                .transactionType(TransactionType.TOPUP)
                .status(TransactionStatus.SUCCESS)
                .amount(amount)
                .fee(BigDecimal.ZERO.setScale(4))
                .currency(wallet.getCurrency())
                .description("Top-Up via " + request.getPaymentMethod() + (request.getDescription() != null ? " - " + request.getDescription() : ""))
                .idempotencyKey(idempotencyKey)
                .build();

        ledger = transactionRepository.save(ledger);

        try {
            notificationService.createNotification(
                    wallet.getUser(),
                    "Wallet Topped Up 💰",
                    String.format("Rs. %s loaded successfully into your Batwa Wallet via %s",
                            amount.setScale(2, RoundingMode.HALF_UP),
                            request.getPaymentMethod()),
                    "TOPUP",
                    amount,
                    refNum
            );
        } catch (Exception e) {
            log.warn("Failed to create topup notification: {}", e.getMessage());
        }

        log.info("Top-Up successful. Wallet: {}, Amount: {}, Ref: {}", wallet.getWalletTag(), amount, refNum);
        return mapToTransactionResponse(ledger);
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public TransactionResponse transferFunds(UUID sourceUserId, TransferRequest request, String idempotencyKey) {
        // 1. Fetch source user and validate PIN & account status
        User sourceUser = userRepository.findById(sourceUserId)
                .orElseThrow(() -> new ResourceNotFoundException("Source user not found"));

        if (sourceUser.isLocked()) {
            throw new AccountLockedException("Your account is locked. Please contact support.");
        }

        if (sourceUser.getPinHash() == null || sourceUser.getPinHash().isBlank()) {
            throw new InvalidPinException("Transaction PIN is not configured. Please set up a PIN before transferring.");
        }

        // Validate PIN
        if (!passwordEncoder.matches(request.getPin(), sourceUser.getPinHash())) {
            int failedAttempts = sourceUser.getPinFailedAttempts() + 1;
            sourceUser.setPinFailedAttempts(failedAttempts);

            if (failedAttempts >= maxPinAttempts) {
                sourceUser.setLocked(true);
                userRepository.save(sourceUser);
                throw new AccountLockedException("Maximum PIN attempts exceeded. Your account has been locked for security.");
            }

            userRepository.save(sourceUser);
            int remaining = maxPinAttempts - failedAttempts;
            throw new InvalidPinException("Invalid transaction PIN. " + remaining + " attempts remaining.", remaining);
        }

        // Reset failed PIN attempts on successful verification
        if (sourceUser.getPinFailedAttempts() > 0) {
            sourceUser.setPinFailedAttempts(0);
            userRepository.save(sourceUser);
        }

        // 2. Identify destination wallet
        Optional<User> optionalDestUser = findUserByIdentifier(request.getRecipientIdentifier());
        Wallet destinationWallet;

        if (optionalDestUser.isPresent()) {
            User destUser = optionalDestUser.get();
            destinationWallet = destUser.getWallet();
            if (destinationWallet == null) {
                destinationWallet = walletRepository.findByUserId(destUser.getId())
                        .orElseThrow(() -> new ResourceNotFoundException("Destination wallet not found for user: " + destUser.getFullName()));
            }
        } else {
            // Settle external bank/Raast transfers into a settlement ledger account
            destinationWallet = walletRepository.findByWalletTag("system.settlement")
                    .orElseGet(() -> {
                        User sysUser = userRepository.save(User.builder()
                                .email("settlement@batwa.wallet")
                                .phoneNumber("03000000000")
                                .passwordHash("$2a$10$dummySettlementHashN/A")
                                .fullName("1Link / Raast Settlement")
                                .build());
                        return walletRepository.save(Wallet.builder()
                                .user(sysUser)
                                .walletTag("system.settlement")
                                .balance(BigDecimal.ZERO.setScale(4))
                                .currency("PKR")
                                .build());
                    });
        }

        Wallet sourceWallet = walletRepository.findByUserId(sourceUserId)
                .orElseThrow(() -> new ResourceNotFoundException("Source wallet not found"));

        if (sourceWallet.getId().equals(destinationWallet.getId())) {
            throw new SelfTransferException("You cannot transfer funds to your own wallet");
        }

        // 3. Amount & Fee Calculation (Batwa & Raast P2P transfers are 100% Free / Zero Fee)
        BigDecimal transferAmount = request.getAmount().setScale(4, RoundingMode.HALF_UP);
        BigDecimal fee = BigDecimal.ZERO.setScale(4, RoundingMode.HALF_UP);
        if (transferFeePercentage != null && transferFeePercentage.compareTo(BigDecimal.ZERO) > 0) {
            fee = transferAmount.multiply(transferFeePercentage).setScale(4, RoundingMode.HALF_UP);
        }
        BigDecimal totalDebit = transferAmount.add(fee);

        // 4. Daily Spending Limit Check
        settingsRepository.findByUserId(sourceUserId).ifPresent(settings -> {
            if (settings.getDailySpendingLimit() != null && settings.getDailySpendingLimit().compareTo(BigDecimal.ZERO) > 0) {
                ZonedDateTime startOfDay = LocalDate.now().atStartOfDay(ZoneId.systemDefault());
                BigDecimal todaySpent = transactionRepository.sumSpentSince(sourceWallet.getId(), startOfDay);

                if (todaySpent.add(transferAmount).compareTo(settings.getDailySpendingLimit()) > 0) {
                    throw new IllegalArgumentException(String.format("Daily spending limit of Rs. %s exceeded. Already spent today: Rs. %s",
                            settings.getDailySpendingLimit().setScale(2, RoundingMode.HALF_UP),
                            todaySpent.setScale(2, RoundingMode.HALF_UP)));
                }
            }
        });

        // 5. Deadlock-free Pessimistic Locking: Lock in consistent global order (by ID)
        UUID id1 = sourceWallet.getId();
        UUID id2 = destinationWallet.getId();
        Wallet lockedSourceWallet;
        Wallet lockedDestinationWallet;

        if (id1.compareTo(id2) < 0) {
            lockedSourceWallet = walletRepository.findByIdForUpdate(id1)
                    .orElseThrow(() -> new ResourceNotFoundException("Source wallet not found"));
            lockedDestinationWallet = walletRepository.findByIdForUpdate(id2)
                    .orElseThrow(() -> new ResourceNotFoundException("Destination wallet not found"));
        } else {
            lockedDestinationWallet = walletRepository.findByIdForUpdate(id2)
                    .orElseThrow(() -> new ResourceNotFoundException("Destination wallet not found"));
            lockedSourceWallet = walletRepository.findByIdForUpdate(id1)
                    .orElseThrow(() -> new ResourceNotFoundException("Source wallet not found"));
        }

        // 6. Check balance invariant
        if (lockedSourceWallet.getBalance().compareTo(totalDebit) < 0) {
            throw new InsufficientFundsException(
                    String.format("Insufficient funds. Available: %s %s, Required: %s %s (including %s fee)",
                            lockedSourceWallet.getBalance().setScale(2, RoundingMode.HALF_UP),
                            lockedSourceWallet.getCurrency(),
                            totalDebit.setScale(2, RoundingMode.HALF_UP),
                            lockedSourceWallet.getCurrency(),
                            fee.setScale(2, RoundingMode.HALF_UP))
            );
        }

        // 7. Atomic Balance Mutation
        lockedSourceWallet.debit(totalDebit);
        lockedDestinationWallet.credit(transferAmount);

        walletRepository.save(lockedSourceWallet);
        walletRepository.save(lockedDestinationWallet);

        // 8. Create Audit Ledger Record
        String refNum = generateReferenceNumber("TXN");
        TransactionLedger ledger = TransactionLedger.builder()
                .referenceNumber(refNum)
                .sourceWallet(lockedSourceWallet)
                .destinationWallet(lockedDestinationWallet)
                .transactionType(TransactionType.P2P_TRANSFER)
                .status(TransactionStatus.SUCCESS)
                .amount(transferAmount)
                .fee(fee)
                .currency(lockedSourceWallet.getCurrency())
                .description(request.getNote() != null && !request.getNote().isBlank()
                        ? request.getNote()
                        : "P2P Transfer to @" + lockedDestinationWallet.getWalletTag())
                .idempotencyKey(idempotencyKey)
                .build();

        ledger = transactionRepository.save(ledger);

        try {
            // Notification for Sender (Debit)
            notificationService.createNotification(
                    lockedSourceWallet.getUser(),
                    "Money Sent 💸",
                    String.format("Rs. %s sent to %s (@%s)",
                            transferAmount.setScale(2, RoundingMode.HALF_UP),
                            lockedDestinationWallet.getUser().getFullName(),
                            lockedDestinationWallet.getWalletTag()),
                    "TRANSFER_SENT",
                    transferAmount,
                    refNum
            );

            // Notification for Recipient (Credit / Payment Received)
            notificationService.createNotification(
                    lockedDestinationWallet.getUser(),
                    "Payment Received! 🎉",
                    String.format("Rs. %s received from %s (@%s) in your Batwa Wallet",
                            transferAmount.setScale(2, RoundingMode.HALF_UP),
                            lockedSourceWallet.getUser().getFullName(),
                            lockedSourceWallet.getWalletTag()),
                    "TRANSFER_RECEIVED",
                    transferAmount,
                    refNum
            );
        } catch (Exception e) {
            log.warn("Failed to create in-app notification: {}", e.getMessage());
        }

        log.info("P2P Transfer successful. From: {} to {}, Amount: {}, Fee: {}, Ref: {}",
                lockedSourceWallet.getWalletTag(), lockedDestinationWallet.getWalletTag(), transferAmount, fee, refNum);

        return mapToTransactionResponse(ledger);
    }

    private String generateReferenceNumber(String prefix) {
        long timestamp = System.currentTimeMillis() / 1000;
        int randomDigits = secureRandom.nextInt(900000000) + 100000000;
        return String.format("%s-%d-%d", prefix, timestamp, randomDigits);
    }

    public TransactionResponse mapToTransactionResponse(TransactionLedger ledger) {
        return TransactionResponse.builder()
                .id(ledger.getId())
                .referenceNumber(ledger.getReferenceNumber())
                .transactionType(ledger.getTransactionType())
                .status(ledger.getStatus())
                .amount(ledger.getAmount().setScale(2, RoundingMode.HALF_UP))
                .fee(ledger.getFee().setScale(2, RoundingMode.HALF_UP))
                .currency(ledger.getCurrency())
                .description(ledger.getDescription())
                .category(ledger.getCategory() != null ? ledger.getCategory().name() : "GENERAL")
                .sourceWalletTag(ledger.getSourceWallet() != null ? ledger.getSourceWallet().getWalletTag() : null)
                .destinationWalletTag(ledger.getDestinationWallet() != null ? ledger.getDestinationWallet().getWalletTag() : null)
                .createdAt(ledger.getCreatedAt())
                .build();
    }
}
