package com.batwa.wallet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "user_security_settings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSecuritySettings {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "daily_spending_limit", nullable = false, precision = 19, scale = 4)
    @Builder.Default
    private BigDecimal dailySpendingLimit = new BigDecimal("50000.0000");

    @Column(name = "monthly_spending_limit", nullable = false, precision = 19, scale = 4)
    @Builder.Default
    private BigDecimal monthlySpendingLimit = new BigDecimal("500000.0000");

    @Column(name = "login_alerts_enabled", nullable = false)
    @Builder.Default
    private boolean loginAlertsEnabled = true;

    @Column(name = "require_pin_for_all_transfers", nullable = false)
    @Builder.Default
    private boolean requirePinForAllTransfers = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private ZonedDateTime updatedAt;
}