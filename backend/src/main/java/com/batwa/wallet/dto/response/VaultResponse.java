package com.batwa.wallet.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VaultResponse {

    private UUID id;
    private String name;
    private BigDecimal targetAmount;
    private BigDecimal currentAmount;
    private double progressPercentage;
    private String icon;
    private String colorHex;
    private LocalDate targetDate;
    private boolean isLocked;
    private ZonedDateTime createdAt;
}
