package com.batwa.wallet.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "utility_companies")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UtilityCompany {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "company_code", nullable = false, unique = true, length = 30)
    private String companyCode; // e.g. KE, LESCO, SNGPL, NAYATEL

    @Column(name = "company_name", nullable = false, length = 100)
    private String companyName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private BillCategory category;

    @Column(name = "consumer_no_length", nullable = false)
    @Builder.Default
    private int consumerNoLength = 13;

    @Column(name = "icon_code", length = 50)
    private String iconCode;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private boolean isActive = true;
}
