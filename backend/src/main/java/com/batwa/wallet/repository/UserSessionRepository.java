package com.batwa.wallet.repository;

import com.batwa.wallet.entity.UserSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserSessionRepository extends JpaRepository<UserSession, UUID> {

    List<UserSession> findAllByUserIdAndIsRevokedFalseOrderByLastActiveAtDesc(UUID userId);

    Optional<UserSession> findByIdAndUserId(UUID id, UUID userId);

    Optional<UserSession> findByUserIdAndDeviceIdAndIsRevokedFalse(UUID userId, String deviceId);

    @Modifying
    @Query("UPDATE UserSession s SET s.isRevoked = true, s.updatedAt = :now WHERE s.user.id = :userId AND s.id <> :currentSessionId AND s.isRevoked = false")
    int revokeAllOtherSessions(@Param("userId") UUID userId, @Param("currentSessionId") UUID currentSessionId, @Param("now") ZonedDateTime now);

    @Modifying
    @Query("UPDATE UserSession s SET s.isRevoked = true, s.updatedAt = :now WHERE s.user.id = :userId AND s.isRevoked = false")
    int revokeAllSessions(@Param("userId") UUID userId, @Param("now") ZonedDateTime now);
}