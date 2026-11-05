package com.batwa.wallet.dto.response;

import com.batwa.wallet.entity.TransactionStatus;
import com.batwa.wallet.entity.TransactionType;
import lombok.*;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionResponse {
    private UUID id;
    private String referenceNumber;
    private String sourceWalletTag;
    private String sourceUserFullName;
    private String destinationWalletTag;
    private String destinationUserFullName;
    private TransactionType transactionType;
    private String category;
    private TransactionStatus status;
    private BigDecimal amount;
    private BigDecimal fee;
    private BigDecimal totalDebited;
    private String currency;
    private String description;
    private String failureReason;
    private ZonedDateTime createdAt;
}
