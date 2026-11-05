package com.batwa.wallet.dto.merchant;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateInvoiceRequest {

    private String customerIdentifier; // Optional: wallet tag, email, or phone
    private String customerName;
    private String description;

    @Builder.Default
    private BigDecimal taxRatePercentage = BigDecimal.ZERO; // e.g. 5.0 for 5%

    @NotEmpty(message = "Invoice must contain at least one item")
    @Valid
    private List<InvoiceItemDto> items;
}
