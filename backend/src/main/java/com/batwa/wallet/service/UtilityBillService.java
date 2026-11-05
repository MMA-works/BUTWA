package com.batwa.wallet.service;

import com.batwa.wallet.dto.request.PayBillRequest;
import com.batwa.wallet.dto.response.BillCompanyResponse;
import com.batwa.wallet.dto.response.BillInquiryResponse;
import com.batwa.wallet.dto.response.BillPaymentResponse;
import com.batwa.wallet.entity.*;
import com.batwa.wallet.exception.*;
import com.batwa.wallet.repository.*;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class UtilityBillService {

    private final UtilityCompanyRepository companyRepository;
    private final UtilityBillRepository billRepository;
    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final TransactionRepository transactionRepository;
    private final PasswordEncoder passwordEncoder;

    @PostConstruct
    @Transactional
    public void seedInitialUtilityData() {
        if (companyRepository.count() > 0) {
            return;
        }

        log.info("Seeding initial mock utility companies and bills...");

        // 1. Electricity
        UtilityCompany ke = companyRepository.save(UtilityCompany.builder()
                .companyCode("KE")
                .companyName("K-Electric (Karachi)")
                .category(BillCategory.ELECTRICITY)
                .consumerNoLength(13)
                .iconCode("bolt")
                .isActive(true)
                .build());

        UtilityCompany lesco = companyRepository.save(UtilityCompany.builder()
                .companyCode("LESCO")
                .companyName("Lahore Electric Supply Company")
                .category(BillCategory.ELECTRICITY)
                .consumerNoLength(14)
                .iconCode("bolt")
                .isActive(true)
                .build());

        // 2. Gas
        UtilityCompany sngpl = companyRepository.save(UtilityCompany.builder()
                .companyCode("SNGPL")
                .companyName("Sui Northern Gas Pipelines")
                .category(BillCategory.GAS)
                .consumerNoLength(11)
                .iconCode("local_fire_department")
                .isActive(true)
                .build());

        // 3. Internet
        UtilityCompany nayatel = companyRepository.save(UtilityCompany.builder()
                .companyCode("NAYATEL")
                .companyName("Nayatel Fiber Internet")
                .category(BillCategory.INTERNET)
                .consumerNoLength(10)
                .iconCode("wifi")
                .isActive(true)
                .build());

        // 4. Water
        UtilityCompany kwsb = companyRepository.save(UtilityCompany.builder()
                .companyCode("KWSB")
                .companyName("Karachi Water & Sewerage Board")
                .category(BillCategory.WATER)
                .consumerNoLength(10)
                .iconCode("water_drop")
                .isActive(true)
                .build());

        // Pre-seed sample bills for testing
        billRepository.save(UtilityBill.builder()
                .company(ke)
                .consumerNumber("1234567890123")
                .consumerName("Muhammad Usman")
                .billingMonth("September 2026")
                .amount(new BigDecimal("78.5000"))
                .lateAmount(new BigDecimal("85.0000"))
                .dueDate(LocalDate.now().plusDays(10))
                .isPaid(false)
                .build());

        billRepository.save(UtilityBill.builder()
                .company(sngpl)
                .consumerNumber("98765432101")
                .consumerName("Ali Khan")
                .billingMonth("September 2026")
                .amount(new BigDecimal("34.2000"))
                .lateAmount(new BigDecimal("38.0000"))
                .dueDate(LocalDate.now().plusDays(5))
                .isPaid(false)
                .build());

        billRepository.save(UtilityBill.builder()
                .company(nayatel)
                .consumerNumber("5551234567")
                .consumerName("Tech Hub Office")
                .billingMonth("September 2026")
                .amount(new BigDecimal("49.9900"))
                .lateAmount(new BigDecimal("55.0000"))
                .dueDate(LocalDate.now().plusDays(15))
                .isPaid(false)
                .build());

        log.info("Mock utilities successfully seeded.");
    }

    @Transactional(readOnly = true)
    public List<BillCompanyResponse> getCompanies(BillCategory category) {
        List<UtilityCompany> list = (category != null)
                ? companyRepository.findAllByCategoryAndIsActiveTrue(category)
                : companyRepository.findAll();

        return list.stream()
                .map(c -> BillCompanyResponse.builder()
                        .id(c.getId())
                        .companyCode(c.getCompanyCode())
                        .companyName(c.getCompanyName())
                        .category(c.getCategory())
                        .consumerNoLength(c.getConsumerNoLength())
                        .iconCode(c.getIconCode())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public BillInquiryResponse inquireBill(String companyCode, String consumerNumber) {
        String cleanCode = companyCode.trim().toUpperCase();
        String cleanNum = consumerNumber.trim();

        UtilityBill bill = billRepository.findByCompanyCompanyCodeAndConsumerNumber(cleanCode, cleanNum)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "No bill record found for " + cleanCode + " with Consumer Number: " + cleanNum +
                        ". (Tip: Try sample consumer number '1234567890123' for KE or '98765432101' for SNGPL)"
                ));

        boolean isOverdue = LocalDate.now().isAfter(bill.getDueDate());
        BigDecimal payableAmount = isOverdue && bill.getLateAmount() != null
                ? bill.getLateAmount()
                : bill.getAmount();

        return BillInquiryResponse.builder()
                .billId(bill.getId())
                .companyCode(bill.getCompany().getCompanyCode())
                .companyName(bill.getCompany().getCompanyName())
                .consumerNumber(bill.getConsumerNumber())
                .consumerName(bill.getConsumerName())
                .billingMonth(bill.getBillingMonth())
                .amount(payableAmount.setScale(2, RoundingMode.HALF_UP))
                .lateAmount(bill.getLateAmount() != null ? bill.getLateAmount().setScale(2, RoundingMode.HALF_UP) : null)
                .dueDate(bill.getDueDate())
                .isPaid(bill.isPaid())
                .isOverdue(isOverdue)
                .build();
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public BillPaymentResponse payBill(UUID userId, PayBillRequest request, String idempotencyKey) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.isLocked()) {
            throw new AccountLockedException("Account is locked. Please contact support.");
        }

        if (user.getPinHash() == null || !passwordEncoder.matches(request.getPin(), user.getPinHash())) {
            throw new InvalidPinException("Invalid transaction PIN.");
        }

        UtilityBill bill = billRepository.findById(request.getBillId())
                .orElseThrow(() -> new ResourceNotFoundException("Bill not found"));

        if (bill.isPaid()) {
            throw new IllegalStateException("This utility bill has already been paid on " + bill.getPaidAt());
        }

        boolean isOverdue = LocalDate.now().isAfter(bill.getDueDate());
        BigDecimal amountToDebit = isOverdue && bill.getLateAmount() != null
                ? bill.getLateAmount().setScale(4, RoundingMode.HALF_UP)
                : bill.getAmount().setScale(4, RoundingMode.HALF_UP);

        // Lock wallet for balance mutation
        Wallet wallet = walletRepository.findByUserIdForUpdate(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found"));

        if (wallet.getBalance().compareTo(amountToDebit) < 0) {
            throw new InsufficientFundsException(
                    "Insufficient balance. Required: " + amountToDebit.setScale(2, RoundingMode.HALF_UP) +
                    " " + wallet.getCurrency() + ", Available: " + wallet.getBalance().setScale(2, RoundingMode.HALF_UP)
            );
        }

        // Debit wallet
        wallet.debit(amountToDebit);
        walletRepository.save(wallet);

        // Mark bill paid
        String refNum = "BILL-" + System.currentTimeMillis() / 1000 + "-" + (Math.abs(new SecureRandom().nextInt(900000) + 100000));
        bill.setPaid(true);
        bill.setPaidAt(ZonedDateTime.now());
        bill.setPaymentReference(refNum);
        bill.setPaidByUser(user);
        bill = billRepository.save(bill);

        // Record in audit ledger
        TransactionLedger ledger = TransactionLedger.builder()
                .referenceNumber(refNum)
                .sourceWallet(wallet)
                .transactionType(TransactionType.TRANSFER_OUT)
                .status(TransactionStatus.SUCCESS)
                .amount(amountToDebit)
                .fee(BigDecimal.ZERO.setScale(4))
                .currency(wallet.getCurrency())
                .description("Utility Bill: " + bill.getCompany().getCompanyName() + " (" + bill.getConsumerNumber() + ")")
                .idempotencyKey(idempotencyKey)
                .build();

        transactionRepository.save(ledger);

        log.info("Bill payment completed. Ref: {}, Amount: {}, Company: {}", refNum, amountToDebit, bill.getCompany().getCompanyCode());

        return BillPaymentResponse.builder()
                .billId(bill.getId())
                .paymentReference(refNum)
                .companyName(bill.getCompany().getCompanyName())
                .consumerNumber(bill.getConsumerNumber())
                .consumerName(bill.getConsumerName())
                .billingMonth(bill.getBillingMonth())
                .amountPaid(amountToDebit.setScale(2, RoundingMode.HALF_UP))
                .currency(wallet.getCurrency())
                .paidAt(bill.getPaidAt())
                .transactionStatus("SUCCESS")
                .build();
    }
}
