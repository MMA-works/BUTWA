package com.batwa.wallet.controller;

import com.batwa.wallet.dto.request.PayBillRequest;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.dto.response.BillCompanyResponse;
import com.batwa.wallet.dto.response.BillInquiryResponse;
import com.batwa.wallet.dto.response.BillPaymentResponse;
import com.batwa.wallet.entity.BillCategory;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.UtilityBillService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/bills")
@RequiredArgsConstructor
public class UtilityBillController {

    private final UtilityBillService billService;

    @GetMapping("/companies")
    public ResponseEntity<ApiResponse<List<BillCompanyResponse>>> getCompanies(
            @RequestParam(value = "category", required = false) BillCategory category) {
        List<BillCompanyResponse> companies = billService.getCompanies(category);
        return ResponseEntity.ok(ApiResponse.ok(companies));
    }

    @GetMapping("/inquiry")
    public ResponseEntity<ApiResponse<BillInquiryResponse>> inquireBill(
            @RequestParam("companyCode") String companyCode,
            @RequestParam("consumerNumber") String consumerNumber) {
        BillInquiryResponse inquiry = billService.inquireBill(companyCode, consumerNumber);
        return ResponseEntity.ok(ApiResponse.ok(inquiry));
    }

    @PostMapping("/pay")
    public ResponseEntity<ApiResponse<BillPaymentResponse>> payBill(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @Valid @RequestBody PayBillRequest request) {
        BillPaymentResponse response = billService.payBill(userDetails.getId(), request, idempotencyKey);
        return ResponseEntity.ok(ApiResponse.ok(response, "Bill paid successfully"));
    }
}
