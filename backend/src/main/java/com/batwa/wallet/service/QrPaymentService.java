package com.batwa.wallet.service;

import com.batwa.wallet.dto.qr.*;
import com.batwa.wallet.dto.request.TransferRequest;
import com.batwa.wallet.dto.response.TransactionResponse;
import com.batwa.wallet.entity.DynamicQrRequest;
import com.batwa.wallet.entity.User;
import com.batwa.wallet.entity.Wallet;
import com.batwa.wallet.exception.ResourceNotFoundException;
import com.batwa.wallet.repository.DynamicQrRequestRepository;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.repository.WalletRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.ZonedDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class QrPaymentService {

    private final WalletRepository walletRepository;
    private final UserRepository userRepository;
    private final DynamicQrRequestRepository dynamicQrRequestRepository;
    private final WalletService walletService;
    private final ObjectMapper objectMapper;

    private static final String QR_SECRET_SALT = "BATWA_INHOUSE_SECURE_QR_SALT_2026";

    @Transactional(readOnly = true)
    public QrCodePayloadResponse getMyStaticQrCode(User user) {
        Wallet wallet = walletRepository.findByUserId(user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found for user: " + user.getEmail()));

        Map<String, Object> payload = new HashMap<>();
        payload.put("version", 1);
        payload.put("type", "P2P_STATIC");
        payload.put("walletId", wallet.getId().toString());
        payload.put("accountEmail", user.getEmail());
        payload.put("accountName", user.getFullName());
        payload.put("walletTag", wallet.getWalletTag());
        payload.put("timestamp", System.currentTimeMillis());

        String signature = generateSignature(wallet.getId().toString(), "P2P_STATIC", user.getEmail(), "");
        payload.put("sig", signature);

        String rawJson;
        try {
            rawJson = objectMapper.writeValueAsString(payload);
        } catch (Exception e) {
            throw new RuntimeException("Failed to serialize QR payload", e);
        }

        return QrCodePayloadResponse.builder()
                .type("P2P_STATIC")
                .walletId(wallet.getId())
                .accountEmail(user.getEmail())
                .accountName(user.getFullName())
                .amount(null)
                .note("Static Profile QR")
                .referenceCode(null)
                .expiresAt(null)
                .rawQrData(rawJson)
                .build();
    }

    @Transactional
    public QrCodePayloadResponse generateDynamicQrCode(User user, GenerateDynamicQrRequest request) {
        Wallet wallet = walletRepository.findByUserId(user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found for user: " + user.getEmail()));

        String refCode = "QR-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        int expiryMins = request.getExpiryMinutes() != null && request.getExpiryMinutes() > 0 ? request.getExpiryMinutes() : 60;
        ZonedDateTime expiresAt = ZonedDateTime.now().plusMinutes(expiryMins);

        DynamicQrRequest dynamicReq = DynamicQrRequest.builder()
                .referenceCode(refCode)
                .creatorWallet(wallet)
                .amount(request.getAmount())
                .note(request.getNote())
                .status(DynamicQrRequest.DynamicQrStatus.PENDING)
                .expiresAt(expiresAt)
                .build();

        dynamicQrRequestRepository.save(dynamicReq);

        Map<String, Object> payload = new HashMap<>();
        payload.put("version", 1);
        payload.put("type", "P2P_DYNAMIC");
        payload.put("walletId", wallet.getId().toString());
        payload.put("accountEmail", user.getEmail());
        payload.put("accountName", user.getFullName());
        payload.put("walletTag", wallet.getWalletTag());
        payload.put("amount", request.getAmount());
        payload.put("note", request.getNote());
        payload.put("ref", refCode);
        payload.put("expiresAt", expiresAt.toInstant().toEpochMilli());
        payload.put("timestamp", System.currentTimeMillis());

        String signature = generateSignature(wallet.getId().toString(), "P2P_DYNAMIC", user.getEmail(), refCode);
        payload.put("sig", signature);

        String rawJson;
        try {
            rawJson = objectMapper.writeValueAsString(payload);
        } catch (Exception e) {
            throw new RuntimeException("Failed to serialize Dynamic QR payload", e);
        }

        return QrCodePayloadResponse.builder()
                .type("P2P_DYNAMIC")
                .walletId(wallet.getId())
                .accountEmail(user.getEmail())
                .accountName(user.getFullName())
                .amount(request.getAmount())
                .note(request.getNote())
                .referenceCode(refCode)
                .expiresAt(expiresAt)
                .rawQrData(rawJson)
                .build();
    }

    @Transactional
    public QrPaymentPreviewResponse parseAndValidateQr(User currentUser, ParseQrRequest request) {
        try {
            Map<String, Object> map = objectMapper.readValue(request.getRawQrData(), new TypeReference<>() {});
            String type = (String) map.get("type");
            String walletIdStr = (String) map.get("walletId");
            String email = (String) map.get("accountEmail");
            String name = (String) map.get("accountName");
            String ref = (String) map.get("ref");
            Object amountObj = map.get("amount");
            String note = (String) map.get("note");

            if (walletIdStr == null) {
                return QrPaymentPreviewResponse.builder()
                        .isValid(false)
                        .validationMessage("Invalid QR code format: Missing wallet ID")
                        .build();
            }

            UUID recipientWalletId = UUID.fromString(walletIdStr);
            Wallet recipientWallet = walletRepository.findByIdWithUser(recipientWalletId)
                    .orElse(null);

            if (recipientWallet == null || !recipientWallet.isActive()) {
                return QrPaymentPreviewResponse.builder()
                        .isValid(false)
                        .validationMessage("Recipient wallet is invalid or inactive")
                        .build();
            }

            // Check self-transfer
            if (recipientWallet.getUser().getId().equals(currentUser.getId())) {
                return QrPaymentPreviewResponse.builder()
                        .isValid(false)
                        .validationMessage("You cannot make a payment to your own wallet")
                        .build();
            }

            BigDecimal amount = null;
            if (amountObj != null) {
                amount = new BigDecimal(amountObj.toString());
            }

            boolean isAmountEditable = true;

            if ("P2P_DYNAMIC".equalsIgnoreCase(type) && ref != null) {
                DynamicQrRequest dynamicReq = dynamicQrRequestRepository.findByReferenceCode(ref).orElse(null);
                if (dynamicReq == null) {
                    return QrPaymentPreviewResponse.builder()
                            .isValid(false)
                            .validationMessage("Payment request not found or has been cancelled")
                            .build();
                }

                if (dynamicReq.getStatus() == DynamicQrRequest.DynamicQrStatus.COMPLETED) {
                    return QrPaymentPreviewResponse.builder()
                            .isValid(false)
                            .validationMessage("This QR payment request has already been paid")
                            .build();
                }

                if (dynamicReq.getExpiresAt().isBefore(ZonedDateTime.now()) || dynamicReq.getStatus() == DynamicQrRequest.DynamicQrStatus.EXPIRED) {
                    dynamicReq.setStatus(DynamicQrRequest.DynamicQrStatus.EXPIRED);
                    dynamicQrRequestRepository.save(dynamicReq);
                    return QrPaymentPreviewResponse.builder()
                            .isValid(false)
                            .validationMessage("This QR payment request has expired")
                            .build();
                }

                amount = dynamicReq.getAmount();
                note = dynamicReq.getNote();
                isAmountEditable = false;
            }

            return QrPaymentPreviewResponse.builder()
                    .isValid(true)
                    .validationMessage("Verified BATWA QR Code")
                    .type(type != null ? type : "P2P_STATIC")
                    .recipientWalletId(recipientWallet.getId())
                    .recipientName(recipientWallet.getUser().getFullName())
                    .recipientEmail(recipientWallet.getUser().getEmail())
                    .amount(amount)
                    .isAmountEditable(isAmountEditable)
                    .note(note)
                    .referenceCode(ref)
                    .build();

        } catch (Exception e) {
            log.warn("Failed to parse QR data: {}", e.getMessage());
            return QrPaymentPreviewResponse.builder()
                    .isValid(false)
                    .validationMessage("Unrecognized or malformed QR Code")
                    .build();
        }
    }

    @Transactional
    public TransactionResponse payQr(User sender, PayQrRequest request) {
        Wallet recipientWallet = walletRepository.findById(request.getRecipientWalletId())
                .orElseThrow(() -> new ResourceNotFoundException("Recipient wallet not found"));

        // If dynamic request, mark as completed
        if (request.getReferenceCode() != null && !request.getReferenceCode().isBlank()) {
            dynamicQrRequestRepository.findByReferenceCode(request.getReferenceCode()).ifPresent(dyn -> {
                if (dyn.getStatus() == DynamicQrRequest.DynamicQrStatus.COMPLETED) {
                    throw new IllegalStateException("This dynamic QR code has already been paid");
                }
                dyn.setStatus(DynamicQrRequest.DynamicQrStatus.COMPLETED);
                dynamicQrRequestRepository.save(dyn);
            });
        }

        String noteText = request.getNote() != null && !request.getNote().isBlank()
                ? "QR Payment: " + request.getNote()
                : "Instant QR Payment";

        TransferRequest transferRequest = TransferRequest.builder()
                .recipientIdentifier(recipientWallet.getUser().getEmail())
                .amount(request.getAmount())
                .note(noteText)
                .pin(request.getPin())
                .build();

        String idempotencyKey = "QR-" + UUID.randomUUID();
        return walletService.transferFunds(sender.getId(), transferRequest, idempotencyKey);
    }

    private String generateSignature(String walletId, String type, String email, String ref) {
        try {
            String raw = walletId + ":" + type + ":" + email + ":" + ref + ":" + QR_SECRET_SALT;
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(raw.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString().substring(0, 16);
        } catch (Exception e) {
            return "SIG_ERR";
        }
    }
}
