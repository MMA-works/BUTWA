package com.batwa.wallet.controller;

import com.batwa.wallet.dto.request.CreateVaultRequest;
import com.batwa.wallet.dto.request.VaultFundRequest;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.dto.response.VaultResponse;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.SavingsVaultService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/vaults")
@RequiredArgsConstructor
public class SavingsVaultController {

    private final SavingsVaultService vaultService;

    @PostMapping
    public ResponseEntity<ApiResponse<VaultResponse>> createVault(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreateVaultRequest request) {
        VaultResponse response = vaultService.createVault(userDetails.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Savings pot created successfully"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<VaultResponse>>> getMyVaults(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<VaultResponse> response = vaultService.getMyVaults(userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PostMapping("/{id}/deposit")
    public ResponseEntity<ApiResponse<VaultResponse>> deposit(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable("id") UUID vaultId,
            @Valid @RequestBody VaultFundRequest request) {
        VaultResponse response = vaultService.deposit(userDetails.getId(), vaultId, request);
        return ResponseEntity.ok(ApiResponse.ok(response, "Funds deposited to savings pot"));
    }

    @PostMapping("/{id}/withdraw")
    public ResponseEntity<ApiResponse<VaultResponse>> withdraw(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable("id") UUID vaultId,
            @Valid @RequestBody VaultFundRequest request) {
        VaultResponse response = vaultService.withdraw(userDetails.getId(), vaultId, request);
        return ResponseEntity.ok(ApiResponse.ok(response, "Funds withdrawn to main balance"));
    }

    @PatchMapping("/{id}/toggle-lock")
    public ResponseEntity<ApiResponse<VaultResponse>> toggleLock(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable("id") UUID vaultId) {
        VaultResponse response = vaultService.toggleLock(userDetails.getId(), vaultId);
        return ResponseEntity.ok(ApiResponse.ok(response, "Savings pot lock setting updated"));
    }
}
