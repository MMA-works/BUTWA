package com.batwa.wallet.dto.recurring;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
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
public class CreateScheduledPaymentRequest {

    @NotBlank(message = "Recipient identifier (email, phone, or tag) is required")
    private String recipientIdentifier;

    @NotBlank(message = "Title is required")
    private String title;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "1.00", message = "Minimum amount is 1.00")
    private BigDecimal amount;

    @NotBlank(message = "Frequency is required (DAILY, WEEKLY, MONTHLY)")
    private String frequency;

    @NotBlank(message = "Transaction MPIN is required to authorize recurring auto-debit")
    private String pin;
}
