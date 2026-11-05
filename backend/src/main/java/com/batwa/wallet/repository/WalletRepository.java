package com.batwa.wallet.repository;

import com.batwa.wallet.entity.Wallet;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, UUID> {

    Optional<Wallet> findByUserId(UUID userId);

    @Query("SELECT w FROM Wallet w JOIN FETCH w.user WHERE w.id = :id")
    Optional<Wallet> findByIdWithUser(@Param("id") UUID id);

    @Query("SELECT w FROM Wallet w JOIN FETCH w.user WHERE w.user.id = :userId")
    Optional<Wallet> findByUserIdWithUser(@Param("userId") UUID userId);

    Optional<Wallet> findByWalletTag(String walletTag);
    Optional<Wallet> findByWalletTagIgnoreCase(String walletTag);

    boolean existsByWalletTag(String walletTag);

    /**
     * Pessimistic write lock on single wallet by ID to prevent race conditions during updates.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT w FROM Wallet w WHERE w.id = :id")
    Optional<Wallet> findByIdForUpdate(@Param("id") UUID id);

    /**
     * Pessimistic write lock on single wallet by User ID.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT w FROM Wallet w WHERE w.user.id = :userId")
    Optional<Wallet> findByUserIdForUpdate(@Param("userId") UUID userId);

    /**
     * Pessimistic write lock by tag.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT w FROM Wallet w WHERE w.walletTag = :tag")
    Optional<Wallet> findByWalletTagForUpdate(@Param("tag") String tag);
}
