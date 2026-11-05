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
public class BillPaymentResponse {
    private UUID billId;
    private String paymentReference;
    private String companyName;
    private String consumerNumber;
    private String consumerName;
    private String billingMonth;
    private BigDecimal amountPaid;
    private String currency;
    private ZonedDateTime paidAt;
    private String transactionStatus;
}
