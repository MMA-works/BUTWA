package com.batwa.wallet.controller;

import com.batwa.wallet.dto.request.TopUpRequest;
import com.batwa.wallet.dto.request.TransferRequest;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.dto.response.RecipientLookupResponse;
import com.batwa.wallet.dto.response.TransactionResponse;
import com.batwa.wallet.dto.response.WalletResponse;
import com.batwa.wallet.entity.IdempotencyRecord;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.IdempotencyService;
import com.batwa.wallet.service.WalletService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@Slf4j
@RestController
@RequestMapping("/wallets")
@RequiredArgsConstructor
public class WalletController {

    private final WalletService walletService;
    private final IdempotencyService idempotencyService;
    private final ObjectMapper objectMapper;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<WalletResponse>> getMyWallet(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        WalletResponse wallet = walletService.getWalletByUserId(userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(wallet));
    }

    @GetMapping("/lookup")
    public ResponseEntity<ApiResponse<RecipientLookupResponse>> lookupRecipient(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam("identifier") String identifier) {
        RecipientLookupResponse recipient = walletService.lookupRecipient(identifier, userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(recipient));
    }

    @PostMapping("/topup")
    public ResponseEntity<ApiResponse<TransactionResponse>> topUp(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @Valid @RequestBody TopUpRequest request) {

        String requestHash = idempotencyService.computePayloadHash(request);

        // Check if cached response exists
        if (idempotencyKey != null && !idempotencyKey.isBlank()) {
            Optional<IdempotencyRecord> cached = idempotencyService.checkIdempotency(idempotencyKey, userDetails.getId(), requestHash);
            if (cached.isPresent()) {
                try {
                    TransactionResponse data = objectMapper.readValue(cached.get().getResponseBody(), TransactionResponse.class);
                    return ResponseEntity.status(cached.get().getHttpStatus()).body(ApiResponse.ok(data, "Top-Up processed (idempotent replay)"));
                } catch (Exception ignored) {}
            }
        }

        TransactionResponse response = walletService.topUp(userDetails.getId(), request, idempotencyKey);

        if (idempotencyKey != null && !idempotencyKey.isBlank()) {
            try {
                String responseBodyJson = objectMapper.writeValueAsString(response);
                idempotencyService.recordResponse(idempotencyKey, userDetails.getId(), "/api/v1/wallets/topup", requestHash, HttpStatus.OK.value(), responseBodyJson);
            } catch (Exception ex) {
                log.error("Failed to record idempotency response", ex);
            }
        }

        return ResponseEntity.ok(ApiResponse.ok(response, "Top-Up successful"));
    }

    @PostMapping("/transfer")
    public ResponseEntity<ApiResponse<TransactionResponse>> transfer(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @Valid @RequestBody TransferRequest request) {

        String requestHash = idempotencyService.computePayloadHash(request);

        // Check for cached idempotent response
        if (idempotencyKey != null && !idempotencyKey.isBlank()) {
            Optional<IdempotencyRecord> cached = idempotencyService.checkIdempotency(idempotencyKey, userDetails.getId(), requestHash);
            if (cached.isPresent()) {
                try {
                    TransactionResponse data = objectMapper.readValue(cached.get().getResponseBody(), TransactionResponse.class);
                    return ResponseEntity.status(cached.get().getHttpStatus()).body(ApiResponse.ok(data, "Transfer processed (idempotent replay)"));
                } catch (Exception ignored) {}
            }
        }

        TransactionResponse response = walletService.transferFunds(userDetails.getId(), request, idempotencyKey);

        if (idempotencyKey != null && !idempotencyKey.isBlank()) {
            try {
                String responseBodyJson = objectMapper.writeValueAsString(response);
                idempotencyService.recordResponse(idempotencyKey, userDetails.getId(), "/api/v1/wallets/transfer", requestHash, HttpStatus.OK.value(), responseBodyJson);
            } catch (Exception ex) {
                log.error("Failed to record idempotency response", ex);
            }
        }

        return ResponseEntity.ok(ApiResponse.ok(response, "Transfer completed successfully"));
    }
}
