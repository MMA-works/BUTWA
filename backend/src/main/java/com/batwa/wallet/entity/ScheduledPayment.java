package com.batwa.wallet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "scheduled_payments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScheduledPayment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "source_wallet_id", nullable = false)
    private Wallet sourceWallet;

    @Column(name = "recipient_identifier", nullable = false, length = 100)
    private String recipientIdentifier;

    @Column(name = "title", nullable = false, length = 100)
    private String title;

    @Column(name = "amount", nullable = false, precision = 19, scale = 4)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(name = "frequency", nullable = false, length = 32)
    private Frequency frequency;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 32)
    @Builder.Default
    private Status status = Status.ACTIVE;

    @Column(name = "next_execution_date", nullable = false)
    private ZonedDateTime nextExecutionDate;

    @Column(name = "last_execution_date")
    private ZonedDateTime lastExecutionDate;

    @Column(name = "execution_count", nullable = false)
    @Builder.Default
    private int executionCount = 0;

    @Column(name = "failure_count", nullable = false)
    @Builder.Default
    private int failureCount = 0;

    @Column(name = "last_failure_reason", length = 255)
    private String lastFailureReason;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private ZonedDateTime updatedAt;

    public enum Frequency {
        DAILY,
        WEEKLY,
        MONTHLY
    }

    public enum Status {
        ACTIVE,
        PAUSED,
        CANCELLED
    }
}
