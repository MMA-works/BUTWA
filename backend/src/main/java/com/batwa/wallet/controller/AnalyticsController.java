package com.batwa.wallet.controller;

import com.batwa.wallet.dto.analytics.AnalyticsSummaryResponse;
import com.batwa.wallet.dto.analytics.BudgetResponse;
import com.batwa.wallet.dto.analytics.SetBudgetRequest;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.entity.User;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.AnalyticsService;
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
@RequestMapping("/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;
    private final UserRepository userRepository;

    @GetMapping("/summary")
    public ResponseEntity<ApiResponse<AnalyticsSummaryResponse>> getSummary(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(value = "period", required = false) String period) {
        User user = getUser(userDetails);
        AnalyticsSummaryResponse summary = analyticsService.getAnalyticsSummary(user, period);
        return ResponseEntity.ok(ApiResponse.ok(summary));
    }

    @GetMapping("/budgets")
    public ResponseEntity<ApiResponse<List<BudgetResponse>>> getBudgets(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(value = "period", required = false) String period) {
        User user = getUser(userDetails);
        List<BudgetResponse> budgets = analyticsService.getBudgets(user, period);
        return ResponseEntity.ok(ApiResponse.ok(budgets));
    }

    @PostMapping("/budgets")
    public ResponseEntity<ApiResponse<BudgetResponse>> setBudget(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody SetBudgetRequest request) {
        User user = getUser(userDetails);
        BudgetResponse response = analyticsService.setBudget(user, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Budget limit set successfully"));
    }

    @DeleteMapping("/budgets/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteBudget(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable UUID id) {
        User user = getUser(userDetails);
        analyticsService.deleteBudget(user, id);
        return ResponseEntity.ok(ApiResponse.ok(null, "Budget deleted successfully"));
    }

    private User getUser(CustomUserDetails userDetails) {
        return userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
