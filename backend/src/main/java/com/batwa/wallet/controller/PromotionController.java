package com.batwa.wallet.controller;

import com.batwa.wallet.dto.response.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/promotions")
public class PromotionController {

    @GetMapping("/active")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getActivePromotions() {
        List<Map<String, Object>> deals = List.of(
            Map.of(
                "id", "deal-1",
                "tag", "HOT DEAL • FOODPANDA",
                "title", "Flat 40% OFF on Food Orders",
                "subTitle", "Pay via Batwa QR & get instant Rs 350 cashback",
                "discountPercent", 40,
                "voucherCode", "BATWAFOOD",
                "type", "FOOD",
                "themeColor", "#031E14",
                "accentColor", "#F3D602"
            ),
            Map.of(
                "id", "deal-2",
                "tag", "SUPER CASHBACK • BILLS",
                "title", "25% Cashback on Electric Bills",
                "subTitle", "Zero fee on K-Electric, LESCO & SNGPL",
                "discountPercent", 25,
                "voucherCode", "BILLFREE25",
                "type", "UTILITY",
                "themeColor", "#F3D602",
                "accentColor", "#031E14"
            ),
            Map.of(
                "id", "deal-3",
                "tag", "MEGA SAVINGS • SHOPPING",
                "title", "Up to 35% OFF on Top Brands",
                "subTitle", "Exclusive discount with Batwa Virtual Visa Card",
                "discountPercent", 35,
                "voucherCode", "BATWASHOP",
                "type", "SHOPPING",
                "themeColor", "#053A26",
                "accentColor", "#00D2D3"
            )
        );
        return ResponseEntity.ok(ApiResponse.ok(deals, "Active promotional deals retrieved successfully"));
    }
}
