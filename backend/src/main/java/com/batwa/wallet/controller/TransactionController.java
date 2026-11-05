package com.batwa.wallet.controller;

import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.dto.response.TransactionResponse;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionService transactionService;

    @GetMapping
    public ResponseEntity<ApiResponse<Page<TransactionResponse>>> getTransactions(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<TransactionResponse> transactions = transactionService.getTransactionsForUser(userDetails.getId(), pageable);
        return ResponseEntity.ok(ApiResponse.ok(transactions));
    }

    @GetMapping("/{referenceNumber}")
    public ResponseEntity<ApiResponse<TransactionResponse>> getTransactionReceipt(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable String referenceNumber) {
        TransactionResponse transaction = transactionService.getTransactionByReference(referenceNumber, userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(transaction));
    }
}
