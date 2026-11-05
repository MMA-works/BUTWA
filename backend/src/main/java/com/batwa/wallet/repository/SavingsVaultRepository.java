package com.batwa.wallet.repository;

import com.batwa.wallet.entity.SavingsVault;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SavingsVaultRepository extends JpaRepository<SavingsVault, UUID> {
    List<SavingsVault> findAllByUserIdOrderByCreatedAtDesc(UUID userId);
    Optional<SavingsVault> findByIdAndUserId(UUID id, UUID userId);
}
