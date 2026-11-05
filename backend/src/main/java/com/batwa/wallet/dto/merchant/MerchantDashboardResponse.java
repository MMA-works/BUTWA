package com.batwa.wallet.dto.merchant;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MerchantDashboardResponse {
    private MerchantProfileResponse profile;
    private BigDecimal todayGrossSales;
    private Long todayOrdersCount;
    private BigDecimal monthGrossSales;
    private Long monthOrdersCount;
    private BigDecimal averageTicketSize;
    private Long pendingInvoicesCount;
    private List<InvoiceResponse> recentInvoices;
}
