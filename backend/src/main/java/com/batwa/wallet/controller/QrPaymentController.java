package com.batwa.wallet.controller;

import com.batwa.wallet.dto.qr.*;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.dto.response.TransactionResponse;
import com.batwa.wallet.entity.User;
import com.batwa.wallet.exception.ResourceNotFoundException;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.QrPaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/qr")
@RequiredArgsConstructor
public class QrPaymentController {

    private final QrPaymentService qrPaymentService;
    private final UserRepository userRepository;

    @GetMapping("/my-code")
    public ResponseEntity<ApiResponse<QrCodePayloadResponse>> getMyStaticQrCode(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        User user = getUser(userDetails);
        QrCodePayloadResponse response = qrPaymentService.getMyStaticQrCode(user);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PostMapping("/generate-dynamic")
    public ResponseEntity<ApiResponse<QrCodePayloadResponse>> generateDynamicQrCode(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody GenerateDynamicQrRequest request) {
        User user = getUser(userDetails);
        QrCodePayloadResponse response = qrPaymentService.generateDynamicQrCode(user, request);
        return ResponseEntity.ok(ApiResponse.ok(response, "Dynamic QR request generated"));
    }

    @PostMapping("/parse")
    public ResponseEntity<ApiResponse<QrPaymentPreviewResponse>> parseQrCode(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody ParseQrRequest request) {
        User user = getUser(userDetails);
        QrPaymentPreviewResponse preview = qrPaymentService.parseAndValidateQr(user, request);
        return ResponseEntity.ok(ApiResponse.ok(preview));
    }

    @PostMapping("/pay")
    public ResponseEntity<ApiResponse<TransactionResponse>> payQr(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody PayQrRequest request) {
        User user = getUser(userDetails);
        TransactionResponse tx = qrPaymentService.payQr(user, request);
        return ResponseEntity.ok(ApiResponse.ok(tx, "QR payment processed successfully"));
    }

    private User getUser(CustomUserDetails userDetails) {
        return userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userDetails.getUsername()));
    }
}
