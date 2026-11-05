package com.batwa.wallet.repository;

import com.batwa.wallet.entity.TransactionLedger;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TransactionRepository extends JpaRepository<TransactionLedger, UUID> {

    Optional<TransactionLedger> findByReferenceNumber(String referenceNumber);

    List<TransactionLedger> findAllBySourceWalletIdOrderByCreatedAtDesc(UUID sourceWalletId);

    @Query("SELECT t FROM TransactionLedger t " +
           "WHERE t.sourceWallet.id = :walletId OR t.destinationWallet.id = :walletId " +
           "ORDER BY t.createdAt DESC")
    Page<TransactionLedger> findAllByWalletId(@Param("walletId") UUID walletId, Pageable pageable);

    @Query("SELECT t FROM TransactionLedger t " +
           "WHERE (t.sourceWallet.id = :walletId OR t.destinationWallet.id = :walletId) " +
           "AND t.createdAt >= :startDate AND t.createdAt < :endDate " +
           "ORDER BY t.createdAt ASC")
    List<TransactionLedger> findAllByWalletIdAndDateRange(
            @Param("walletId") UUID walletId,
            @Param("startDate") java.time.ZonedDateTime startDate,
            @Param("endDate") java.time.ZonedDateTime endDate);
}