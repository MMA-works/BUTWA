package com.batwa.wallet.dto.merchant;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PayInvoiceRequest {

    @NotBlank(message = "Invoice number or ID is required")
    private String invoiceIdentifier;

    @NotBlank(message = "MPIN is required")
    @Pattern(regexp = "^[0-9]{4}$", message = "MPIN must be exactly 4 digits")
    private String pin;
}
