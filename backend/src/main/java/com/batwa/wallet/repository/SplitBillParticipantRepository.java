package com.batwa.wallet.repository;

import com.batwa.wallet.entity.SplitBillParticipant;
import com.batwa.wallet.entity.SplitParticipantStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SplitBillParticipantRepository extends JpaRepository<SplitBillParticipant, UUID> {
    List<SplitBillParticipant> findAllByUserIdAndStatusOrderBySplitBillCreatedAtDesc(UUID userId, SplitParticipantStatus status);
    List<SplitBillParticipant> findAllBySplitBillId(UUID splitBillId);
    Optional<SplitBillParticipant> findBySplitBillIdAndUserId(UUID splitBillId, UUID userId);
}
