package com.batwa.wallet.dto.response;

import com.batwa.wallet.entity.SplitBillStatus;
import lombok.*;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SplitBillResponse {

    private UUID id;
    private String title;
    private BigDecimal totalAmount;
    private String currency;
    private SplitBillStatus status;
    private String creatorName;
    private String creatorTag;
    private BigDecimal totalCollected;
    private int participantsCount;
    private int paidCount;
    private List<SplitParticipantResponse> participants;
    private ZonedDateTime createdAt;
}
