package com.batwa.wallet.dto.recurring;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScheduledPaymentResponse {

    private UUID id;
    private String recipientIdentifier;
    private String recipientName;
    private String title;
    private BigDecimal amount;
    private String frequency;
    private String status;
    private ZonedDateTime nextExecutionDate;
    private ZonedDateTime lastExecutionDate;
    private int executionCount;
    private int failureCount;
    private String lastFailureReason;
    private ZonedDateTime createdAt;
}
