package com.batwa.wallet.controller;

import com.batwa.wallet.dto.merchant.*;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.entity.User;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.MerchantService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/merchant")
@RequiredArgsConstructor
public class MerchantController {

    private final MerchantService merchantService;
    private final UserRepository userRepository;

    @PostMapping("/profile")
    public ResponseEntity<ApiResponse<MerchantProfileResponse>> registerOrUpdate(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody RegisterMerchantRequest request) {
        User user = getUser(userDetails);
        MerchantProfileResponse response = merchantService.registerOrUpdateMerchant(user, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Merchant profile registered successfully"));
    }

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<MerchantProfileResponse>> getProfile(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        User user = getUser(userDetails);
        MerchantProfileResponse response = merchantService.getMerchantProfile(user);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<MerchantDashboardResponse>> getDashboard(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        User user = getUser(userDetails);
        MerchantDashboardResponse response = merchantService.getMerchantDashboard(user);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PostMapping("/invoices")
    public ResponseEntity<ApiResponse<InvoiceResponse>> createInvoice(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreateInvoiceRequest request) {
        User user = getUser(userDetails);
        InvoiceResponse response = merchantService.createInvoice(user, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Invoice generated successfully"));
    }

    @PostMapping("/pos-order")
    public ResponseEntity<ApiResponse<InvoiceResponse>> createPosOrder(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreatePosOrderRequest request) {
        User user = getUser(userDetails);
        InvoiceResponse response = merchantService.createPosOrder(user, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "POS Order created successfully"));
    }

    @GetMapping("/invoices")
    public ResponseEntity<ApiResponse<List<InvoiceResponse>>> getMerchantInvoices(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        User user = getUser(userDetails);
        List<InvoiceResponse> response = merchantService.getMerchantInvoices(user);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @GetMapping("/invoices/{invoiceNumber}")
    public ResponseEntity<ApiResponse<InvoiceResponse>> getInvoiceByNumber(
            @PathVariable String invoiceNumber) {
        InvoiceResponse response = merchantService.getInvoiceByNumber(invoiceNumber);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PostMapping("/invoices/pay")
    public ResponseEntity<ApiResponse<InvoiceResponse>> payInvoice(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody PayInvoiceRequest request) {
        User user = getUser(userDetails);
        InvoiceResponse response = merchantService.payInvoice(user, request);
        return ResponseEntity.ok(ApiResponse.ok(response, "Invoice paid successfully"));
    }

    private User getUser(CustomUserDetails userDetails) {
        return userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
