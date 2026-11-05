package com.batwa.wallet.dto.analytics;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DailySpendingResponse {
    private LocalDate date;
    private BigDecimal inflow;
    private BigDecimal outflow;
}
