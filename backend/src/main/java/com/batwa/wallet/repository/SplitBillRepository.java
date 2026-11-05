package com.batwa.wallet.repository;

import com.batwa.wallet.entity.SplitBill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SplitBillRepository extends JpaRepository<SplitBill, UUID> {
    List<SplitBill> findAllByCreatorIdOrderByCreatedAtDesc(UUID creatorId);
    Optional<SplitBill> findByIdAndCreatorId(UUID id, UUID creatorId);
}
