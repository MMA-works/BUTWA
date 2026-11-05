package com.batwa.wallet.service;

import com.batwa.wallet.dto.request.CreateVaultRequest;
import com.batwa.wallet.dto.request.VaultFundRequest;
import com.batwa.wallet.dto.response.VaultResponse;
import com.batwa.wallet.entity.*;
import com.batwa.wallet.exception.InsufficientFundsException;
import com.batwa.wallet.exception.InvalidPinException;
import com.batwa.wallet.exception.ResourceNotFoundException;
import com.batwa.wallet.repository.SavingsVaultRepository;
import com.batwa.wallet.repository.TransactionRepository;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SavingsVaultService {

    private final SavingsVaultRepository vaultRepository;
    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final TransactionRepository transactionRepository;
    private final PasswordEncoder passwordEncoder;
    private final SecureRandom random = new SecureRandom();

    @Transactional
    public VaultResponse createVault(UUID userId, CreateVaultRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Wallet wallet = walletRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found"));

        SavingsVault vault = SavingsVault.builder()
                .user(user)
                .wallet(wallet)
                .name(request.getName().trim())
                .targetAmount(request.getTargetAmount().setScale(4, RoundingMode.HALF_UP))
                .currentAmount(BigDecimal.ZERO.setScale(4, RoundingMode.HALF_UP))
                .icon(request.getIcon() != null && !request.getIcon().isBlank() ? request.getIcon() : "savings")
                .colorHex(request.getColorHex() != null && !request.getColorHex().isBlank() ? request.getColorHex() : "#10B981")
                .targetDate(request.getTargetDate())
                .isLocked(request.isLocked())
                .build();

        vault = vaultRepository.save(vault);
        log.info("Created new savings vault: '{}' for user: {}", vault.getName(), user.getEmail());

        return mapToVaultResponse(vault);
    }

    @Transactional(readOnly = true)
    public List<VaultResponse> getMyVaults(UUID userId) {
        return vaultRepository.findAllByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::mapToVaultResponse)
                .collect(Collectors.toList());
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public VaultResponse deposit(UUID userId, UUID vaultId, VaultFundRequest request) {
        BigDecimal amount = request.getAmount().setScale(4, RoundingMode.HALF_UP);
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Deposit amount must be greater than 0");
        }

        SavingsVault vault = vaultRepository.findByIdAndUserId(vaultId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Savings vault not found"));

        Wallet wallet = walletRepository.findByUserIdForUpdate(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found"));

        if (wallet.getBalance().compareTo(amount) < 0) {
            throw new InsufficientFundsException(
                    "Insufficient balance. Available: $" + wallet.getBalance().setScale(2, RoundingMode.HALF_UP) +
                    ", Required: $" + amount.setScale(2, RoundingMode.HALF_UP)
            );
        }

        // Debit main wallet
        wallet.debit(amount);
        walletRepository.save(wallet);

        // Credit vault
        vault.setCurrentAmount(vault.getCurrentAmount().add(amount));
        vault = vaultRepository.save(vault);

        // Record audit ledger
        String ref = "VAULT-DEP-" + (System.currentTimeMillis() / 1000) + "-" + (random.nextInt(9000) + 1000);
        TransactionLedger ledger = TransactionLedger.builder()
                .referenceNumber(ref)
                .sourceWallet(wallet)
                .transactionType(TransactionType.TRANSFER_OUT)
                .status(TransactionStatus.SUCCESS)
                .amount(amount)
                .fee(BigDecimal.ZERO.setScale(4))
                .currency(wallet.getCurrency())
                .description("Deposit to Savings Pot: " + vault.getName())
                .build();
        transactionRepository.save(ledger);

        log.info("Deposited ${} to vault '{}' (ID: {}) by user: {}", amount, vault.getName(), vault.getId(), userId);

        return mapToVaultResponse(vault);
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public VaultResponse withdraw(UUID userId, UUID vaultId, VaultFundRequest request) {
        BigDecimal amount = request.getAmount().setScale(4, RoundingMode.HALF_UP);
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Withdrawal amount must be greater than 0");
        }

        SavingsVault vault = vaultRepository.findByIdAndUserId(vaultId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Savings vault not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // If vault is locked, verify MPIN
        if (vault.isLocked() || (request.getPin() != null && !request.getPin().isBlank())) {
            if (request.getPin() == null || request.getPin().isBlank()) {
                throw new InvalidPinException("This savings pot is locked. Transaction MPIN is required to withdraw.");
            }
            if (user.getPinHash() == null || !passwordEncoder.matches(request.getPin(), user.getPinHash())) {
                throw new InvalidPinException("Invalid transaction PIN.");
            }
        }

        if (vault.getCurrentAmount().compareTo(amount) < 0) {
            throw new InsufficientFundsException(
                    "Insufficient vault balance. Available in pot: $" + vault.getCurrentAmount().setScale(2, RoundingMode.HALF_UP) +
                    ", Requested: $" + amount.setScale(2, RoundingMode.HALF_UP)
            );
        }

        Wallet wallet = walletRepository.findByUserIdForUpdate(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found"));

        // Debit vault
        vault.setCurrentAmount(vault.getCurrentAmount().subtract(amount));
        vault = vaultRepository.save(vault);

        // Credit main wallet
        wallet.credit(amount);
        walletRepository.save(wallet);

        // Record audit ledger
        String ref = "VAULT-WTH-" + (System.currentTimeMillis() / 1000) + "-" + (random.nextInt(9000) + 1000);
        TransactionLedger ledger = TransactionLedger.builder()
                .referenceNumber(ref)
                .destinationWallet(wallet)
                .transactionType(TransactionType.TRANSFER_IN)
                .status(TransactionStatus.SUCCESS)
                .amount(amount)
                .fee(BigDecimal.ZERO.setScale(4))
                .currency(wallet.getCurrency())
                .description("Withdrawal from Savings Pot: " + vault.getName())
                .build();
        transactionRepository.save(ledger);

        log.info("Withdrew ${} from vault '{}' (ID: {}) by user: {}", amount, vault.getName(), vault.getId(), userId);

        return mapToVaultResponse(vault);
    }

    @Transactional
    public VaultResponse toggleLock(UUID userId, UUID vaultId) {
        SavingsVault vault = vaultRepository.findByIdAndUserId(vaultId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Savings vault not found"));

        vault.setLocked(!vault.isLocked());
        vault = vaultRepository.save(vault);
        return mapToVaultResponse(vault);
    }

    private VaultResponse mapToVaultResponse(SavingsVault vault) {
        double progress = 0.0;
        if (vault.getTargetAmount().compareTo(BigDecimal.ZERO) > 0) {
            progress = vault.getCurrentAmount()
                    .divide(vault.getTargetAmount(), 4, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100"))
                    .doubleValue();
            if (progress > 100.0) progress = 100.0;
        }

        return VaultResponse.builder()
                .id(vault.getId())
                .name(vault.getName())
                .targetAmount(vault.getTargetAmount().setScale(2, RoundingMode.HALF_UP))
                .currentAmount(vault.getCurrentAmount().setScale(2, RoundingMode.HALF_UP))
                .progressPercentage(Math.round(progress * 10.0) / 10.0)
                .icon(vault.getIcon())
                .colorHex(vault.getColorHex())
                .targetDate(vault.getTargetDate())
                .isLocked(vault.isLocked())
                .createdAt(vault.getCreatedAt())
                .build();
    }
}
