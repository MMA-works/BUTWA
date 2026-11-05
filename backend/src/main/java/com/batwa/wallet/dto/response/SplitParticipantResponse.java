package com.batwa.wallet.dto.response;

import com.batwa.wallet.entity.SplitParticipantStatus;
import lombok.*;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SplitParticipantResponse {

    private UUID id;
    private UUID userId;
    private String userFullName;
    private String walletTag;
    private BigDecimal amount;
    private SplitParticipantStatus status;
    private ZonedDateTime paidAt;
    private String transactionReference;
}
