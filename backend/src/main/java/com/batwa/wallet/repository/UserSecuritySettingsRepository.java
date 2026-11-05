package com.batwa.wallet.repository;

import com.batwa.wallet.entity.UserSecuritySettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserSecuritySettingsRepository extends JpaRepository<UserSecuritySettings, UUID> {

    Optional<UserSecuritySettings> findByUserId(UUID userId);
}