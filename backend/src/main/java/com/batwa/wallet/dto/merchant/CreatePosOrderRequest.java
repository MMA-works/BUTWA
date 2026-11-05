package com.batwa.wallet.dto.merchant;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreatePosOrderRequest {

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.10", message = "Amount must be at least 0.10")
    private BigDecimal amount;

    private String note;
    private String orderReference;
}
