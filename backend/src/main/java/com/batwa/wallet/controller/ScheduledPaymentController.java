package com.batwa.wallet.controller;

import com.batwa.wallet.dto.recurring.CreateScheduledPaymentRequest;
import com.batwa.wallet.dto.recurring.ScheduledPaymentResponse;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.dto.response.TransactionResponse;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.ScheduledPaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/recurring")
@RequiredArgsConstructor
public class ScheduledPaymentController {

    private final ScheduledPaymentService scheduledPaymentService;

    @PostMapping
    public ResponseEntity<ApiResponse<ScheduledPaymentResponse>> createSchedule(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreateScheduledPaymentRequest request) {
        ScheduledPaymentResponse response = scheduledPaymentService.createSchedule(userDetails.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Scheduled payment created successfully"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ScheduledPaymentResponse>>> getSchedules(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<ScheduledPaymentResponse> response = scheduledPaymentService.getSchedules(userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PutMapping("/{id}/toggle")
    public ResponseEntity<ApiResponse<ScheduledPaymentResponse>> toggleSchedule(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable("id") UUID scheduleId) {
        ScheduledPaymentResponse response = scheduledPaymentService.toggleSchedule(userDetails.getId(), scheduleId);
        return ResponseEntity.ok(ApiResponse.ok(response, "Schedule status updated"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteSchedule(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable("id") UUID scheduleId) {
        scheduledPaymentService.deleteSchedule(userDetails.getId(), scheduleId);
        return ResponseEntity.ok(ApiResponse.ok(null, "Schedule deleted successfully"));
    }

    @PostMapping("/{id}/execute-now")
    public ResponseEntity<ApiResponse<TransactionResponse>> executeNow(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable("id") UUID scheduleId) {
        TransactionResponse response = scheduledPaymentService.executeNow(userDetails.getId(), scheduleId);
        return ResponseEntity.ok(ApiResponse.ok(response, "Payment executed immediately"));
    }
}