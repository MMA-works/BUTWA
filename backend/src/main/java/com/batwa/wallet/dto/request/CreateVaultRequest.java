package com.batwa.wallet.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateVaultRequest {

    @NotBlank(message = "Vault name is required")
    private String name;

    @NotNull(message = "Target amount is required")
    @DecimalMin(value = "1.00", message = "Target amount must be at least 1.00")
    private BigDecimal targetAmount;

    @Builder.Default
    private String icon = "savings";

    @Builder.Default
    private String colorHex = "#10B981";

    private LocalDate targetDate;

    @Builder.Default
    private boolean isLocked = false;
}
