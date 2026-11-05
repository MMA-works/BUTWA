package com.batwa.wallet.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ResetPinRequest {

    @NotBlank(message = "Account password is required")
    private String accountPassword;

    @NotBlank(message = "New PIN is required")
    @Pattern(regexp = "^[0-9]{4,6}$", message = "PIN must be strictly 4 to 6 numeric digits")
    private String newPin;
}