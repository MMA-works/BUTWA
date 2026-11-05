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

    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${app.wallet.transfer-fee-percentage:0.005}")
    private BigDecimal transferFeePercentage;

    @Value("${app.wallet.max-pin-attempts:3}")
    private int maxPinAttempts;

    @Transactional(readOnly = true)
    public WalletResponse getWalletByUserId(UUID userId) {
        Wallet wallet = walletRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found for user"));
        return authService.mapToWalletResponse(wallet);
    }

    @Transactional(readOnly = true)
    public RecipientLookupResponse lookupRecipient(String identifier, UUID currentUserId) {
        String cleanId = identifier.trim().replace("@", "");
        
        Wallet recipientWallet = walletRepository.findByWalletTag(cleanId)
                .or(() -> userRepository.findByPhoneNumber(identifier).map(User::getWallet))
                .or(() -> userRepository.findByEmail(identifier).map(User::getWallet))
                .orElseThrow(() -> new ResourceNotFoundException("Recipient not found with identifier: " + identifier));

        if (recipientWallet.getUser().getId().equals(currentUserId)) {
            throw new SelfTransferException("You cannot send money to yourself");
        }

        String rawPhone = recipientWallet.getUser().getPhoneNumber();
        String maskedPhone = rawPhone != null && rawPhone.length() > 4
                ? rawPhone.substring(0, rawPhone.length() - 4).replaceAll(".", "*") + rawPhone.substring(rawPhone.length() - 4)
                : rawPhone;

        return RecipientLookupResponse.builder()
                .walletTag(recipientWallet.getWalletTag())
                .recipientFullName(recipientWallet.getUser().getFullName())
                .maskedPhoneNumber(maskedPhone)
                .currency(recipientWallet.getCurrency())
                .build();
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
        String cleanId = request.getRecipientIdentifier().trim().replace("@", "");
        Wallet destinationWallet = walletRepository.findByWalletTag(cleanId)
                .or(() -> userRepository.findByPhoneNumber(request.getRecipientIdentifier()).map(User::getWallet))
                .or(() -> userRepository.findByEmail(request.getRecipientIdentifier()).map(User::getWallet))
                .orElseThrow(() -> new ResourceNotFoundException("Recipient wallet not found"));

        Wallet sourceWallet = walletRepository.findByUserId(sourceUserId)
                .orElseThrow(() -> new ResourceNotFoundException("Source wallet not found"));

        if (sourceWallet.getId().equals(destinationWallet.getId())) {
            throw new SelfTransferException("You cannot transfer funds to your own wallet");
        }

        // 3. Amount & Fee Calculation
        BigDecimal transferAmount = request.getAmount().setScale(4, RoundingMode.HALF_UP);
        BigDecimal fee = transferAmount.multiply(transferFeePercentage).setScale(4, RoundingMode.HALF_UP);
        BigDecimal totalDebit = transferAmount.add(fee);

        // 4. Daily Spending Limit Check
        settingsRepository.findByUserId(sourceUserId).ifPresent(settings -> {
            ZonedDateTime startOfDay = LocalDate.now().atStartOfDay(ZoneId.systemDefault());
            List<TransactionLedger> todayTxns = transactionRepository.findAllBySourceWalletIdOrderByCreatedAtDesc(sourceWallet.getId());
            BigDecimal todaySpent = todayTxns.stream()
                    .filter(t -> t.getStatus() == TransactionStatus.SUCCESS && t.getCreatedAt().isAfter(startOfDay))
                    .map(TransactionLedger::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            if (todaySpent.add(transferAmount).compareTo(settings.getDailySpendingLimit()) > 0) {
                throw new IllegalArgumentException(String.format("Daily spending limit exceeded. Daily limit: $%s, Already spent today: $%s",
                        settings.getDailySpendingLimit().setScale(2, RoundingMode.HALF_UP),
                        todaySpent.setScale(2, RoundingMode.HALF_UP)));
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