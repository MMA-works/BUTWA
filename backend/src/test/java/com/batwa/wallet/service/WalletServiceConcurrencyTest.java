package com.batwa.wallet.service;

import com.batwa.wallet.dto.request.TransferRequest;
import com.batwa.wallet.dto.response.TransactionResponse;
import com.batwa.wallet.entity.User;
import com.batwa.wallet.entity.Wallet;
import com.batwa.wallet.exception.InsufficientFundsException;
import com.batwa.wallet.repository.TransactionRepository;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.repository.WalletRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class WalletServiceConcurrencyTest {

    @Mock
    private WalletRepository walletRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private AuthService authService;

    @InjectMocks
    private WalletService walletService;

    private User sourceUser;
    private Wallet sourceWallet;
    private Wallet destWallet;
    private final UUID sourceUserId = UUID.randomUUID();
    private final UUID sourceWalletId = UUID.randomUUID();
    private final UUID destWalletId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(walletService, "transferFeePercentage", new BigDecimal("0.005"));
        ReflectionTestUtils.setField(walletService, "maxPinAttempts", 3);

        sourceUser = User.builder()
                .id(sourceUserId)
                .fullName("Alice Walker")
                .email("alice@batwa.com")
                .phoneNumber("+1234567890")
                .pinHash("hashedPin")
                .pinFailedAttempts(0)
                .isLocked(false)
                .build();

        sourceWallet = Wallet.builder()
                .id(sourceWalletId)
                .user(sourceUser)
                .walletTag("alice")
                .balance(new BigDecimal("100.0000"))
                .currency("USD")
                .isActive(true)
                .build();

        destWallet = Wallet.builder()
                .id(destWalletId)
                .user(User.builder().id(UUID.randomUUID()).fullName("Bob").phoneNumber("+1987654321").build())
                .walletTag("bob")
                .balance(new BigDecimal("50.0000"))
                .currency("USD")
                .isActive(true)
                .build();
    }

    @Test
    @DisplayName("Should successfully transfer funds with fee and atomic balance mutation")
    void testSuccessfulTransfer() {
        TransferRequest request = TransferRequest.builder()
                .recipientIdentifier("bob")
                .amount(new BigDecimal("20.00"))
                .pin("1234")
                .note("Dinner split")
                .build();

        when(userRepository.findById(sourceUserId)).thenReturn(Optional.of(sourceUser));
        when(passwordEncoder.matches("1234", "hashedPin")).thenReturn(true);
        when(walletRepository.findByWalletTag("bob")).thenReturn(Optional.of(destWallet));
        when(walletRepository.findByUserId(sourceUserId)).thenReturn(Optional.of(sourceWallet));

        when(walletRepository.findByIdForUpdate(sourceWalletId)).thenReturn(Optional.of(sourceWallet));
        when(walletRepository.findByIdForUpdate(destWalletId)).thenReturn(Optional.of(destWallet));
        when(transactionRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        TransactionResponse response = walletService.transferFunds(sourceUserId, request, "idem-123");

        assertNotNull(response);
        // Balance after debit: 100 - (20 + 0.10) = 79.90
        assertEquals(new BigDecimal("79.9000"), sourceWallet.getBalance());
        // Balance after credit: 50 + 20 = 70.00
        assertEquals(new BigDecimal("70.0000"), destWallet.getBalance());
    }

    @Test
    @DisplayName("Should reject transfer when balance is insufficient to cover amount + fee")
    void testInsufficientBalanceRejection() {
        TransferRequest request = TransferRequest.builder()
                .recipientIdentifier("bob")
                .amount(new BigDecimal("150.00"))
                .pin("1234")
                .build();

        when(userRepository.findById(sourceUserId)).thenReturn(Optional.of(sourceUser));
        when(passwordEncoder.matches("1234", "hashedPin")).thenReturn(true);
        when(walletRepository.findByWalletTag("bob")).thenReturn(Optional.of(destWallet));
        when(walletRepository.findByUserId(sourceUserId)).thenReturn(Optional.of(sourceWallet));
        when(walletRepository.findByIdForUpdate(any())).thenReturn(Optional.of(sourceWallet), Optional.of(destWallet));

        assertThrows(InsufficientFundsException.class, () ->
                walletService.transferFunds(sourceUserId, request, "idem-123")
        );
    }
}
