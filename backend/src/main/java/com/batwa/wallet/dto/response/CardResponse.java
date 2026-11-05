package com.batwa.wallet.dto.response;

import com.batwa.wallet.entity.CardStatus;
import lombok.*;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CardResponse {
    private UUID id;
    private String cardNumber; // Masked e.g. 4532 •••• •••• 8912
    private String fullCardNumber; // Full for card details modal
    private String cardHolderName;
    private String expiryMonth;
    private String expiryYear;
    private String cvv;
    private String cardNetwork;
    private CardStatus status;
    private boolean isOnlineEnabled;
    private boolean isInternationalEnabled;
    private BigDecimal monthlyLimit;
    private ZonedDateTime createdAt;
}
