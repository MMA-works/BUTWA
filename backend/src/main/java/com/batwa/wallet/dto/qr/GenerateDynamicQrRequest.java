package com.batwa.wallet.dto.qr;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GenerateDynamicQrRequest {

    @NotNull(message = "Amount is required for dynamic QR code")
    @DecimalMin(value = "1.00", message = "Minimum dynamic request amount is 1.00")
    private BigDecimal amount;

    private String note;

    @Builder.Default
    private Integer expiryMinutes = 60;
}
