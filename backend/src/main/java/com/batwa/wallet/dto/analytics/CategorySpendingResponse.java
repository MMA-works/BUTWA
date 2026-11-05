package com.batwa.wallet.dto.analytics;

import com.batwa.wallet.entity.TransactionCategory;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategorySpendingResponse {
    private TransactionCategory category;
    private String categoryName;
    private BigDecimal totalAmount;
    private Double percentageOfTotal;
    private Long transactionCount;
}
