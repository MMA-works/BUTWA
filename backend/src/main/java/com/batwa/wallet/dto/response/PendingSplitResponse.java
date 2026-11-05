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
public class PendingSplitResponse {

    private UUID participantId;
    private UUID splitBillId;
    private String title;
    private String creatorName;
    private String creatorTag;
    private BigDecimal amount;
    private String currency;
    private ZonedDateTime createdAt;
}
