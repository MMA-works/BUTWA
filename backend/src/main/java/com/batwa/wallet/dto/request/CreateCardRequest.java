package com.batwa.wallet.dto.request;

import jakarta.validation.constraints.Pattern;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateCardRequest {

    @Pattern(regexp = "^(VISA_PLATINUM|MASTERCARD_BLACK)$", message = "Network must be VISA_PLATINUM or MASTERCARD_BLACK")
    @Builder.Default
    private String cardNetwork = "VISA_PLATINUM";

    private String customAlias;
}
