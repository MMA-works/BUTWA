package com.batwa.wallet.repository;

import com.batwa.wallet.entity.SecurityAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SecurityAuditLogRepository extends JpaRepository<SecurityAuditLog, UUID> {

    List<SecurityAuditLog> findTop50ByUserIdOrderByCreatedAtDesc(UUID userId);
}