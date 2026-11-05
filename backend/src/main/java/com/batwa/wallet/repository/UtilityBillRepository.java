package com.batwa.wallet.repository;

import com.batwa.wallet.entity.UtilityBill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UtilityBillRepository extends JpaRepository<UtilityBill, UUID> {
    Optional<UtilityBill> findByCompanyCompanyCodeAndConsumerNumber(String companyCode, String consumerNumber);
    Optional<UtilityBill> findByPaymentReference(String paymentReference);
}
