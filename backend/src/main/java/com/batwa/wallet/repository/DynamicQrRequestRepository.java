package com.batwa.wallet.repository;

import com.batwa.wallet.entity.DynamicQrRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface DynamicQrRequestRepository extends JpaRepository<DynamicQrRequest, UUID> {
    Optional<DynamicQrRequest> findByReferenceCode(String referenceCode);
}
