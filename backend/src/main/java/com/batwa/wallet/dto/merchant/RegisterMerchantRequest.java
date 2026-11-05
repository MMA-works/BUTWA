package com.batwa.wallet.dto.merchant;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RegisterMerchantRequest {

    @NotBlank(message = "Business name is required")
    private String businessName;

    @NotBlank(message = "Business category is required")
    private String businessCategory; // RESTAURANT, RETAIL, GROCERY, SERVICES, TECH

    private String taxId;
    private String storeAddress;
}
