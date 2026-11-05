package com.batwa.wallet.service;

import com.batwa.wallet.dto.response.TransactionResponse;
import com.batwa.wallet.entity.TransactionLedger;
import com.batwa.wallet.entity.Wallet;
import com.batwa.wallet.exception.ResourceNotFoundException;
import com.batwa.wallet.repository.TransactionRepository;
import com.batwa.wallet.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final WalletRepository walletRepository;
    private final WalletService walletService;

    @Transactional(readOnly = true)
    public Page<TransactionResponse> getTransactionsForUser(UUID userId, Pageable pageable) {
        Wallet wallet = walletRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found"));

        return transactionRepository.findAllByWalletId(wallet.getId(), pageable)
                .map(walletService::mapToTransactionResponse);
    }

    @Transactional(readOnly = true)
    public TransactionResponse getTransactionByReference(String referenceNumber, UUID currentUserId) {
        TransactionLedger ledger = transactionRepository.findByReferenceNumber(referenceNumber)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction receipt not found: " + referenceNumber));

        // Ensure user is authorized to view this transaction
        boolean isAuthorized = (ledger.getSourceWallet() != null && ledger.getSourceWallet().getUser().getId().equals(currentUserId))
                || (ledger.getDestinationWallet() != null && ledger.getDestinationWallet().getUser().getId().equals(currentUserId));

        if (!isAuthorized) {
            throw new ResourceNotFoundException("Transaction receipt not found");
        }

        return walletService.mapToTransactionResponse(ledger);
    }
}
