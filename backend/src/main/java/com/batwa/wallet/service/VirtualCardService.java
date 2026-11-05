package com.batwa.wallet.service;

import com.batwa.wallet.dto.request.CreateCardRequest;
import com.batwa.wallet.dto.response.CardResponse;
import com.batwa.wallet.entity.*;
import com.batwa.wallet.exception.ResourceNotFoundException;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.repository.VirtualCardRepository;
import com.batwa.wallet.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class VirtualCardService {

    private final VirtualCardRepository cardRepository;
    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final SecureRandom random = new SecureRandom();

    @Transactional
    public CardResponse generateCard(UUID userId, CreateCardRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Wallet wallet = walletRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found"));

        String prefix = "MASTERCARD_BLACK".equalsIgnoreCase(request.getCardNetwork()) ? "5425" : "4532";
        String cardNumber = generateLuhnCompliantCardNumber(prefix);
        
        LocalDate now = LocalDate.now();
        String expiryMonth = String.format("%02d", now.getMonthValue());
        String expiryYear = String.valueOf(now.getYear() + 3);
        String cvv = String.format("%03d", random.nextInt(900) + 100);

        VirtualCard card = VirtualCard.builder()
                .user(user)
                .wallet(wallet)
                .cardNumber(cardNumber)
                .cardHolderName(user.getFullName().toUpperCase())
                .expiryMonth(expiryMonth)
                .expiryYear(expiryYear)
                .cvv(cvv)
                .cardNetwork(request.getCardNetwork())
                .status(CardStatus.ACTIVE)
                .isOnlineEnabled(true)
                .isInternationalEnabled(false)
                .build();

        card = cardRepository.save(card);
        log.info("Generated new virtual card: {} for user: {}", maskCardNumber(cardNumber), user.getEmail());

        return mapToCardResponse(card);
    }

    @Transactional(readOnly = true)
    public List<CardResponse> getMyCards(UUID userId) {
        return cardRepository.findAllByUserId(userId)
                .stream()
                .map(this::mapToCardResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public CardResponse toggleFreeze(UUID cardId, UUID userId) {
        VirtualCard card = cardRepository.findByIdAndUserId(cardId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Virtual card not found"));

        if (card.getStatus() == CardStatus.ACTIVE) {
            card.setStatus(CardStatus.FROZEN);
        } else if (card.getStatus() == CardStatus.FROZEN) {
            card.setStatus(CardStatus.ACTIVE);
        }

        card = cardRepository.save(card);
        return mapToCardResponse(card);
    }

    @Transactional
    public CardResponse toggleOnline(UUID cardId, UUID userId) {
        VirtualCard card = cardRepository.findByIdAndUserId(cardId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Virtual card not found"));

        card.setOnlineEnabled(!card.isOnlineEnabled());
        card = cardRepository.save(card);
        return mapToCardResponse(card);
    }

    public CardResponse mapToCardResponse(VirtualCard card) {
        return CardResponse.builder()
                .id(card.getId())
                .cardNumber(maskCardNumber(card.getCardNumber()))
                .fullCardNumber(card.getCardNumber())
                .cardHolderName(card.getCardHolderName())
                .expiryMonth(card.getExpiryMonth())
                .expiryYear(card.getExpiryYear())
                .cvv(card.getCvv())
                .cardNetwork(card.getCardNetwork())
                .status(card.getStatus())
                .isOnlineEnabled(card.isOnlineEnabled())
                .isInternationalEnabled(card.isInternationalEnabled())
                .monthlyLimit(card.getMonthlyLimit())
                .createdAt(card.getCreatedAt())
                .build();
    }

    /**
     * Implements the Luhn (Mod 10) algorithm to generate a mathematically valid 16-digit card number.
     */
    private String generateLuhnCompliantCardNumber(String prefix) {
        String candidate;
        do {
            StringBuilder sb = new StringBuilder(prefix);
            // 16 digits total: prefix (4 digits) + 11 random digits + 1 checksum digit
            while (sb.length() < 15) {
                sb.append(random.nextInt(10));
            }
            int checkDigit = calculateLuhnCheckDigit(sb.toString());
            sb.append(checkDigit);
            candidate = sb.toString();
        } while (cardRepository.existsByCardNumber(candidate));

        return candidate;
    }

    private int calculateLuhnCheckDigit(String numberWithoutCheck) {
        int sum = 0;
        boolean alternate = true;
        for (int i = numberWithoutCheck.length() - 1; i >= 0; i--) {
            int n = Integer.parseInt(numberWithoutCheck.substring(i, i + 1));
            if (alternate) {
                n *= 2;
                if (n > 9) {
                    n = (n % 10) + 1;
                }
            }
            sum += n;
            alternate = !alternate;
        }
        int mod = sum % 10;
        return (mod == 0) ? 0 : 10 - mod;
    }

    private String maskCardNumber(String raw) {
        if (raw == null || raw.length() < 16) return "**** **** **** ****";
        return raw.substring(0, 4) + " •••• •••• " + raw.substring(12);
    }
}
