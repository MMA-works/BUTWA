package com.batwa.wallet.dto.merchant;

import com.batwa.wallet.entity.InvoiceStatus;
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
public class InvoiceResponse {
    private UUID id;
    private String invoiceNumber;
    private UUID merchantUserId;
    private String merchantBusinessName;
    private String merchantWalletTag;
    private UUID customerUserId;
    private String customerName;
    private String customerIdentifier;
    private BigDecimal subtotal;
    private BigDecimal taxRatePercentage;
    private BigDecimal taxAmount;
    private BigDecimal grandTotal;
    private String currency;
    private InvoiceStatus status;
    private String description;
    private String qrCodePayload;
    private String transactionReference;
    private ZonedDateTime paidAt;
    private ZonedDateTime dueDate;
    private ZonedDateTime createdAt;
    private List<InvoiceItemResponse> items;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class InvoiceItemResponse {
        private UUID id;
        private String itemName;
        private Integer quantity;
        private BigDecimal unitPrice;
        private BigDecimal totalPrice;
    }
}
