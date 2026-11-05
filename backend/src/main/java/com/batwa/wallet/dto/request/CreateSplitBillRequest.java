package com.batwa.wallet.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateSplitBillRequest {

    @NotBlank(message = "Title is required")
    private String title;

    @NotNull(message = "Total amount is required")
    @DecimalMin(value = "1.00", message = "Total amount must be at least 1.00")
    private BigDecimal totalAmount;

    @NotEmpty(message = "At least one participant is required")
    @Valid
    private List<SplitParticipantRequest> participants;
}
