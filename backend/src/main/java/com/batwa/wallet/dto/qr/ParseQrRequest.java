package com.batwa.wallet.dto.qr;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ParseQrRequest {

    @NotBlank(message = "QR data is required")
    private String rawQrData;
}
