package com.batwa.wallet.dto.qr;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
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
public class PayQrRequest {

    @NotNull(message = "Recipient wallet ID is required")
    private UUID recipientWalletId;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "1.00", message = "Minimum transaction amount is 1.00")
    private BigDecimal amount;

    private String note;

    private String referenceCode; // Dynamic QR reference if applicable

    @NotBlank(message = "Transaction MPIN is required")
    private String pin;
}
