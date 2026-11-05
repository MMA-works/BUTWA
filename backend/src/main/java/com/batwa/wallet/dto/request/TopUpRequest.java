package com.batwa.wallet.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TopUpRequest {

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "1.00", message = "Minimum top-up amount is 1.00")
    @Digits(integer = 15, fraction = 2, message = "Amount can have up to 2 decimal places")
    private BigDecimal amount;

    @NotBlank(message = "Payment method source is required (e.g., MOCK_CARD, BANK_TRANSFER)")
    private String paymentMethod;

    private String description;
}
