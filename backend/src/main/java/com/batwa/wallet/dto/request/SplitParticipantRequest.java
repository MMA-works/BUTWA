package com.batwa.wallet.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SplitParticipantRequest {

    @NotBlank(message = "Participant identifier (wallet tag, email, or phone) is required")
    private String identifier;

    private BigDecimal amount;
}
