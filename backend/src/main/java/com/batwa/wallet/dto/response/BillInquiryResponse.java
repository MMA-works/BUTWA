package com.batwa.wallet.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillInquiryResponse {
    private UUID billId;
    private String companyCode;
    private String companyName;
    private String consumerNumber;
    private String consumerName;
    private String billingMonth;
    private BigDecimal amount;
    private BigDecimal lateAmount;
    private LocalDate dueDate;
    private boolean isPaid;
    private boolean isOverdue;
}
