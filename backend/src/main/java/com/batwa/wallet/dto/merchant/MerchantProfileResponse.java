package com.batwa.wallet.dto.merchant;

import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MerchantProfileResponse {
    private UUID id;
    private UUID userId;
    private String businessName;
    private String businessCategory;
    private String taxId;
    private String storeAddress;
    private String merchantWalletTag;
    private String merchantFullName;
    private Boolean isActive;
    private ZonedDateTime createdAt;
}
