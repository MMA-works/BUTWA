package com.batwa.wallet.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransferRequest {

    @NotBlank(message = "Recipient identifier is required (Wallet Tag, Phone, or Email)")
    private String recipientIdentifier;

    @NotNull(message = "Transfer amount is required")
    @DecimalMin(value = "0.01", message = "Minimum transfer amount is 0.01")
    @Digits(integer = 15, fraction = 2, message = "Amount can have up to 2 decimal places")
    private BigDecimal amount;

    @NotBlank(message = "Transaction PIN is required")
    @Pattern(regexp = "^[0-9]{4,6}$", message = "PIN must be 4 to 6 numeric digits")
    private String pin;

    @Size(max = 255, message = "Note cannot exceed 255 characters")
    private String note;
}
