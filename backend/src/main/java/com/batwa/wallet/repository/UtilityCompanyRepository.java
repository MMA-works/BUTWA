package com.batwa.wallet.repository;

import com.batwa.wallet.entity.BillCategory;
import com.batwa.wallet.entity.UtilityCompany;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UtilityCompanyRepository extends JpaRepository<UtilityCompany, UUID> {
    List<UtilityCompany> findAllByCategoryAndIsActiveTrue(BillCategory category);
    Optional<UtilityCompany> findByCompanyCode(String companyCode);
    boolean existsByCompanyCode(String companyCode);
}
