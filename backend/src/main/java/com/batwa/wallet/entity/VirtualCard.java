package com.batwa.wallet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "virtual_cards")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VirtualCard {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @Column(name = "card_number", nullable = false, unique = true, length = 19)
    private String cardNumber; // Format: 4532 XXXX XXXX 1234

    @Column(name = "card_holder_name", nullable = false, length = 100)
    private String cardHolderName;

    @Column(name = "expiry_month", nullable = false, length = 2)
    private String expiryMonth;

    @Column(name = "expiry_year", nullable = false, length = 4)
    private String expiryYear;

    @Column(name = "cvv", nullable = false, length = 4)
    private String cvv;

    @Column(name = "card_network", nullable = false, length = 20)
    @Builder.Default
    private String cardNetwork = "VISA_PLATINUM"; // VISA_PLATINUM, MASTERCARD_BLACK

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private CardStatus status = CardStatus.ACTIVE;

    @Column(name = "is_online_enabled", nullable = false)
    @Builder.Default
    private boolean isOnlineEnabled = true;

    @Column(name = "is_international_enabled", nullable = false)
    @Builder.Default
    private boolean isInternationalEnabled = false;

    @Column(name = "monthly_limit", precision = 19, scale = 4)
    @Builder.Default
    private BigDecimal monthlyLimit = new BigDecimal("5000.0000");

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private ZonedDateTime updatedAt;
}
