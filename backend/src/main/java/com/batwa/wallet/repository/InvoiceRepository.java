package com.batwa.wallet.repository;

import com.batwa.wallet.entity.Invoice;
import com.batwa.wallet.entity.InvoiceStatus;
import com.batwa.wallet.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, UUID> {
    Optional<Invoice> findByInvoiceNumber(String invoiceNumber);
    List<Invoice> findAllByMerchantUserOrderByCreatedAtDesc(User merchantUser);
    List<Invoice> findAllByCustomerUserOrderByCreatedAtDesc(User customerUser);
    Page<Invoice> findAllByMerchantUserOrderByCreatedAtDesc(User merchantUser, Pageable pageable);

    @Query("SELECT i FROM Invoice i WHERE i.merchantUser = :merchant " +
           "AND i.status = :status AND i.paidAt >= :since " +
           "ORDER BY i.paidAt DESC")
    List<Invoice> findPaidInvoicesSince(
            @Param("merchant") User merchant,
            @Param("status") InvoiceStatus status,
            @Param("since") ZonedDateTime since);
}
