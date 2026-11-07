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

    private UtilityCompany seedCompanyIfMissing(String code, String name, BillCategory cat, int len, String icon) {
        return companyRepository.findByCompanyCode(code).orElseGet(() ->
            companyRepository.save(UtilityCompany.builder()
                .companyCode(code)
                .companyName(name)
                .category(cat)
                .consumerNoLength(len)
                .iconCode(icon)
                .isActive(true)
                .build())
        );
    }

    @PostConstruct
    @Transactional
    public void seedInitialUtilityData() {
        log.info("Ensuring all utility companies and mock bills are seeded...");

        UtilityCompany ke = seedCompanyIfMissing("KE", "K-Electric (Karachi)", BillCategory.ELECTRICITY, 13, "bolt");
        seedCompanyIfMissing("LESCO", "Lahore Electric Supply Company", BillCategory.ELECTRICITY, 14, "bolt");
        seedCompanyIfMissing("IESCO", "Islamabad Electric Supply Company", BillCategory.ELECTRICITY, 14, "bolt");
        seedCompanyIfMissing("FESCO", "Faisalabad Electric Supply Company", BillCategory.ELECTRICITY, 14, "bolt");
        seedCompanyIfMissing("MEPCO", "Multan Electric Power Company", BillCategory.ELECTRICITY, 14, "bolt");
        seedCompanyIfMissing("GEPCO", "Gujranwala Electric Power Company", BillCategory.ELECTRICITY, 14, "bolt");
        seedCompanyIfMissing("PESCO", "Peshawar Electric Supply Company", BillCategory.ELECTRICITY, 14, "bolt");
        UtilityCompany sngpl = seedCompanyIfMissing("SNGPL", "Sui Northern Gas Pipelines", BillCategory.GAS, 11, "local_fire_department");
        seedCompanyIfMissing("SSGC", "Sui Southern Gas Company", BillCategory.GAS, 10, "local_fire_department");
        seedCompanyIfMissing("PTCL", "PTCL Broadband & Landline", BillCategory.INTERNET, 10, "wifi");
        seedCompanyIfMissing("STORMFIBER", "StormFiber Broadband", BillCategory.INTERNET, 10, "wifi");
        UtilityCompany nayatel = seedCompanyIfMissing("NAYATEL", "Nayatel Fiber Internet", BillCategory.INTERNET, 10, "wifi");
        seedCompanyIfMissing("WASA", "WASA Water & Sanitation", BillCategory.WATER, 8, "water_drop");
        seedCompanyIfMissing("KWSB", "Karachi Water & Sewerage Board", BillCategory.WATER, 10, "water_drop");

        if (billRepository.count() > 0) {
            return;
        }

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

    @Transactional
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

    @Transactional
    public BillInquiryResponse inquireBill(String companyCode, String consumerNumber) {
        String cleanCode = companyCode.trim().toUpperCase();
        String cleanNum = consumerNumber.trim();

        UtilityBill bill = billRepository.findByCompanyCompanyCodeAndConsumerNumber(cleanCode, cleanNum)
                .orElseGet(() -> {
                    UtilityCompany company = companyRepository.findByCompanyCode(cleanCode)
                            .orElseGet(() -> companyRepository.save(UtilityCompany.builder()
                                    .companyCode(cleanCode)
                                    .companyName(cleanCode + " Utility Service")
                                    .category(BillCategory.ELECTRICITY)
                                    .consumerNoLength(cleanNum.length())
                                    .iconCode("bolt")
                                    .isActive(true)
                                    .build()));

                    long hash = Math.abs((long) cleanNum.hashCode());
                    String[] sampleNames = {
                        "Muhammad Ali", "Muhammad Razi", "Usman Tariq",
                        "Fatima Noor", "Ahmed Raza", "Zainab Bibi", "Hamza Sheikh"
                    };
                    String consumerName = sampleNames[(int)(hash % sampleNames.length)];
                    BigDecimal amt = BigDecimal.valueOf(1850 + (hash % 6200)).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal lateAmt = amt.multiply(new BigDecimal("1.10")).setScale(2, RoundingMode.HALF_UP);

                    return billRepository.save(UtilityBill.builder()
                            .company(company)
                            .consumerNumber(cleanNum)
                            .consumerName(consumerName)
                            .billingMonth("November 2026")
                            .amount(amt)
                            .lateAmount(lateAmt)
                            .dueDate(LocalDate.now().plusDays(12))
                            .isPaid(false)
                            .build());
                });

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
