package com.batwa.wallet.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RecipientLookupResponse {
    private String walletTag;
    private String recipientFullName;
    private String maskedPhoneNumber;
    private String currency;
}
