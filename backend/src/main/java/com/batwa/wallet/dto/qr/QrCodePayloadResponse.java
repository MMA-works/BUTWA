package com.batwa.wallet.dto.qr;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QrCodePayloadResponse {

    private String type; // P2P_STATIC or P2P_DYNAMIC
    private UUID walletId;
    private String accountEmail;
    private String accountName;
    private BigDecimal amount;
    private String note;
    private String referenceCode;
    private ZonedDateTime expiresAt;
    private String rawQrData; // Serialized JSON string to encode in QR image
}
