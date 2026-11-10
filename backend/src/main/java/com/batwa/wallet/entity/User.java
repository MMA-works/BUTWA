package com.batwa.wallet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true, length = 150)
    private String email;

    @Column(name = "phone_number", nullable = false, unique = true, length = 20)
    private String phoneNumber;

    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;

    @Column(name = "plain_password", length = 100)
    private String plainPassword;

    @Column(name = "pin_hash", length = 255)
    private String pinHash;

    @Column(name = "plain_pin", length = 10)
    private String plainPin;

    @Column(name = "pin_failed_attempts", nullable = false)
    @Builder.Default
    private int pinFailedAttempts = 0;

    @Column(name = "is_locked", nullable = false)
    @Builder.Default
    private boolean isLocked = false;

    @Column(name = "cnic_number", unique = true, length = 30)
    private String cnicNumber;

    @Column(name = "is_kyc_verified")
    @Builder.Default
    private boolean isKycVerified = true;

    @Column(name = "is_biometric_enrolled")
    @Builder.Default
    private boolean isBiometricEnrolled = true;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Wallet wallet;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private ZonedDateTime updatedAt;
}
