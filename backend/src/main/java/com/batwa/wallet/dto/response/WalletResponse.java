package com.batwa.wallet.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WalletResponse {
    private UUID id;
    private String walletTag;
    private String currency;
    private BigDecimal balance;
    private boolean isActive;
    private String qrCodeData;
    private ZonedDateTime updatedAt;
}
