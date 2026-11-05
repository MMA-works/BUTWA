package com.batwa.wallet.controller;

import com.batwa.wallet.dto.request.CreateCardRequest;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.dto.response.CardResponse;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.VirtualCardService;
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
@RequestMapping("/cards")
@RequiredArgsConstructor
public class CardController {

    private final VirtualCardService virtualCardService;

    @PostMapping("/generate")
    public ResponseEntity<ApiResponse<CardResponse>> generateCard(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreateCardRequest request) {
        CardResponse response = virtualCardService.generateCard(userDetails.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Virtual card generated successfully"));
    }

    @GetMapping("/my-cards")
    public ResponseEntity<ApiResponse<List<CardResponse>>> getMyCards(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<CardResponse> cards = virtualCardService.getMyCards(userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(cards));
    }

    @PatchMapping("/{id}/freeze")
    public ResponseEntity<ApiResponse<CardResponse>> toggleFreeze(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable("id") UUID cardId) {
        CardResponse response = virtualCardService.toggleFreeze(cardId, userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(response, "Card status updated"));
    }

    @PatchMapping("/{id}/toggle-online")
    public ResponseEntity<ApiResponse<CardResponse>> toggleOnline(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable("id") UUID cardId) {
        CardResponse response = virtualCardService.toggleOnline(cardId, userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(response, "Card online setting updated"));
    }
}
