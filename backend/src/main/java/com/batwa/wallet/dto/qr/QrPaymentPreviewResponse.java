package com.batwa.wallet.dto.qr;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QrPaymentPreviewResponse {

    private boolean isValid;
    private String validationMessage;
    private String type; // P2P_STATIC or P2P_DYNAMIC
    private UUID recipientWalletId;
    private String recipientName;
    private String recipientEmail;
    private BigDecimal amount;
    private boolean isAmountEditable;
    private String note;
    private String referenceCode;
}
