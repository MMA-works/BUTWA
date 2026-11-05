package com.batwa.wallet.dto.response;

import com.batwa.wallet.entity.BillCategory;
import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillCompanyResponse {
    private UUID id;
    private String companyCode;
    private String companyName;
    private BillCategory category;
    private int consumerNoLength;
    private String iconCode;
}
