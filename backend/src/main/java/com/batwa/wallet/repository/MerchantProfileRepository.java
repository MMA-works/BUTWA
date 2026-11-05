package com.batwa.wallet.repository;

import com.batwa.wallet.entity.MerchantProfile;
import com.batwa.wallet.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface MerchantProfileRepository extends JpaRepository<MerchantProfile, UUID> {
    Optional<MerchantProfile> findByUser(User user);
    Optional<MerchantProfile> findByUserId(UUID userId);
    boolean existsByUser(User user);
}
