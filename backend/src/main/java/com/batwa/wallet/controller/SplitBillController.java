package com.batwa.wallet.controller;

import com.batwa.wallet.dto.request.CreateSplitBillRequest;
import com.batwa.wallet.dto.request.SettleSplitRequest;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.dto.response.PendingSplitResponse;
import com.batwa.wallet.dto.response.SplitBillResponse;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.SplitBillService;
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
@RequestMapping("/splits")
@RequiredArgsConstructor
public class SplitBillController {

    private final SplitBillService splitBillService;

    @PostMapping
    public ResponseEntity<ApiResponse<SplitBillResponse>> createSplitBill(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreateSplitBillRequest request) {
        SplitBillResponse response = splitBillService.createSplitBill(userDetails.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Split bill created and requests dispatched"));
    }

    @GetMapping("/my-splits")
    public ResponseEntity<ApiResponse<List<SplitBillResponse>>> getMyCreatedSplits(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<SplitBillResponse> response = splitBillService.getMyCreatedSplits(userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @GetMapping("/pending")
    public ResponseEntity<ApiResponse<List<PendingSplitResponse>>> getPendingSplits(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<PendingSplitResponse> response = splitBillService.getPendingSplits(userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PostMapping("/{id}/settle")
    public ResponseEntity<ApiResponse<SplitBillResponse>> settleSplit(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable("id") UUID splitBillId,
            @Valid @RequestBody SettleSplitRequest request) {
        SplitBillResponse response = splitBillService.settleSplit(userDetails.getId(), splitBillId, request);
        return ResponseEntity.ok(ApiResponse.ok(response, "Split bill settled successfully"));
    }
}
