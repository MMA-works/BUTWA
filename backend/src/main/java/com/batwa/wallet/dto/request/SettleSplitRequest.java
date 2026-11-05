package com.batwa.wallet.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SettleSplitRequest {

    @NotBlank(message = "Transaction PIN is required")
    @Size(min = 4, max = 4, message = "PIN must be exactly 4 digits")
    private String pin;
}
