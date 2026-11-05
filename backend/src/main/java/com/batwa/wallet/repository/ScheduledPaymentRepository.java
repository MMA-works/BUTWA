package com.batwa.wallet.repository;

import com.batwa.wallet.entity.ScheduledPayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface ScheduledPaymentRepository extends JpaRepository<ScheduledPayment, UUID> {

    @Query("SELECT s FROM ScheduledPayment s WHERE s.sourceWallet.user.id = :userId ORDER BY s.createdAt DESC")
    List<ScheduledPayment> findByUserId(@Param("userId") UUID userId);

    @Query("SELECT s FROM ScheduledPayment s WHERE s.status = 'ACTIVE' AND s.nextExecutionDate <= :cutoffTime")
    List<ScheduledPayment> findDuePayments(@Param("cutoffTime") ZonedDateTime cutoffTime);
}
