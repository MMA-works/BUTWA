package com.batwa.wallet.service;

import com.batwa.wallet.dto.merchant.*;
import com.batwa.wallet.entity.*;
import com.batwa.wallet.repository.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.time.*;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class MerchantService {

    private final MerchantProfileRepository merchantProfileRepository;
    private final InvoiceRepository invoiceRepository;
    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final TransactionRepository transactionRepository;
    private final PasswordEncoder passwordEncoder;
    private final ObjectMapper objectMapper;
    private final SecureRandom secureRandom = new SecureRandom();

    @Transactional
    public MerchantProfileResponse registerOrUpdateMerchant(User user, RegisterMerchantRequest request) {
        MerchantProfile profile = merchantProfileRepository.findByUser(user)
                .orElse(MerchantProfile.builder()
                        .user(user)
                        .build());

        profile.setBusinessName(request.getBusinessName().trim());
        profile.setBusinessCategory(request.getBusinessCategory().trim().toUpperCase());
        profile.setTaxId(request.getTaxId() != null ? request.getTaxId().trim() : null);
        profile.setStoreAddress(request.getStoreAddress() != null ? request.getStoreAddress().trim() : null);
        profile.setIsActive(true);

        MerchantProfile saved = merchantProfileRepository.save(profile);
        return mapToProfileResponse(saved);
    }

    @Transactional(readOnly = true)
    public MerchantProfileResponse getMerchantProfile(User user) {
        MerchantProfile profile = merchantProfileRepository.findByUser(user)
                .orElseThrow(() -> new RuntimeException("Merchant profile not registered for this account"));
        return mapToProfileResponse(profile);
    }

    @Transactional
    public InvoiceResponse createInvoice(User merchantUser, CreateInvoiceRequest request) {
        MerchantProfile profile = merchantProfileRepository.findByUser(merchantUser)
                .orElseGet(() -> {
                    // Auto-provision merchant profile if not explicitly registered
                    return merchantProfileRepository.save(MerchantProfile.builder()
                            .user(merchantUser)
                            .businessName(merchantUser.getFullName() + "'s Store")
                            .businessCategory("RETAIL")
                            .build());
                });

        Wallet merchantWallet = walletRepository.findByUserId(merchantUser.getId())
                .orElseThrow(() -> new RuntimeException("Merchant wallet not found"));

        BigDecimal subtotal = BigDecimal.ZERO;
        List<InvoiceItem> items = new ArrayList<>();

        for (InvoiceItemDto itemDto : request.getItems()) {
            BigDecimal lineTotal = itemDto.getUnitPrice().multiply(BigDecimal.valueOf(itemDto.getQuantity()));
            subtotal = subtotal.add(lineTotal);

            InvoiceItem item = InvoiceItem.builder()
                    .itemName(itemDto.getItemName().trim())
                    .quantity(itemDto.getQuantity())
                    .unitPrice(itemDto.getUnitPrice().setScale(2, RoundingMode.HALF_UP))
                    .totalPrice(lineTotal.setScale(2, RoundingMode.HALF_UP))
                    .build();
            items.add(item);
        }

        BigDecimal taxRate = request.getTaxRatePercentage() != null ? request.getTaxRatePercentage() : BigDecimal.ZERO;
        BigDecimal taxAmount = subtotal.multiply(taxRate).divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        BigDecimal grandTotal = subtotal.add(taxAmount).setScale(2, RoundingMode.HALF_UP);

        String invoiceNumber = generateInvoiceNumber("INV");

        // Try lookup customer user if identifier provided
        User customerUser = null;
        if (request.getCustomerIdentifier() != null && !request.getCustomerIdentifier().trim().isEmpty()) {
            String clean = request.getCustomerIdentifier().trim().replace("@", "");
            customerUser = userRepository.findByEmail(clean)
                    .or(() -> userRepository.findByPhoneNumber(clean))
                    .or(() -> walletRepository.findByWalletTagIgnoreCase(clean).map(Wallet::getUser))
                    .orElse(null);
        }

        String qrPayload = generateInvoiceQrPayload(invoiceNumber, grandTotal, merchantWallet.getWalletTag(), profile.getBusinessName());

        Invoice invoice = Invoice.builder()
                .invoiceNumber(invoiceNumber)
                .merchantUser(merchantUser)
                .customerUser(customerUser)
                .customerName(request.getCustomerName() != null ? request.getCustomerName().trim() : (customerUser != null ? customerUser.getFullName() : null))
                .customerIdentifier(request.getCustomerIdentifier())
                .subtotal(subtotal.setScale(2, RoundingMode.HALF_UP))
                .taxRatePercentage(taxRate)
                .taxAmount(taxAmount)
                .grandTotal(grandTotal)
                .currency("USD")
                .status(InvoiceStatus.PENDING)
                .description(request.getDescription())
                .qrCodePayload(qrPayload)
                .dueDate(ZonedDateTime.now().plusDays(30))
                .build();

        for (InvoiceItem item : items) {
            invoice.addItem(item);
        }

        Invoice saved = invoiceRepository.save(invoice);
        log.info("Created merchant invoice #{} for {} total {}", saved.getInvoiceNumber(), profile.getBusinessName(), grandTotal);
        return mapToInvoiceResponse(saved);
    }

    @Transactional
    public InvoiceResponse createPosOrder(User merchantUser, CreatePosOrderRequest request) {
        CreateInvoiceRequest invoiceRequest = CreateInvoiceRequest.builder()
                .description(request.getNote() != null ? request.getNote() : "POS Quick Checkout")
                .taxRatePercentage(BigDecimal.ZERO)
                .items(List.of(
                        InvoiceItemDto.builder()
                                .itemName(request.getNote() != null && !request.getNote().isEmpty() ? request.getNote() : "POS Sale")
                                .quantity(1)
                                .unitPrice(request.getAmount())
                                .build()
                ))
                .build();

        return createInvoice(merchantUser, invoiceRequest);
    }

    @Transactional
    public InvoiceResponse payInvoice(User customerUser, PayInvoiceRequest request) {
        Invoice invoice;
        try {
            UUID id = UUID.fromString(request.getInvoiceIdentifier().trim());
            invoice = invoiceRepository.findById(id)
                    .or(() -> invoiceRepository.findByInvoiceNumber(request.getInvoiceIdentifier().trim()))
                    .orElseThrow(() -> new RuntimeException("Invoice not found"));
        } catch (IllegalArgumentException e) {
            invoice = invoiceRepository.findByInvoiceNumber(request.getInvoiceIdentifier().trim())
                    .orElseThrow(() -> new RuntimeException("Invoice not found"));
        }

        if (invoice.getStatus() != InvoiceStatus.PENDING) {
            throw new RuntimeException("Invoice cannot be paid because it is currently " + invoice.getStatus());
        }

        if (invoice.getMerchantUser().getId().equals(customerUser.getId())) {
            throw new RuntimeException("Merchant cannot pay their own invoice");
        }

        // Verify MPIN
        if (customerUser.getPinHash() == null || !passwordEncoder.matches(request.getPin(), customerUser.getPinHash())) {
            throw new RuntimeException("Invalid 4-digit MPIN");
        }

        Wallet customerWallet = walletRepository.findByUserId(customerUser.getId())
                .orElseThrow(() -> new RuntimeException("Customer wallet not found"));

        Wallet merchantWallet = walletRepository.findByUserId(invoice.getMerchantUser().getId())
                .orElseThrow(() -> new RuntimeException("Merchant wallet not found"));

        BigDecimal amount = invoice.getGrandTotal();
        if (customerWallet.getBalance().compareTo(amount) < 0) {
            throw new RuntimeException("Insufficient wallet balance for invoice payment");
        }

        // Debit Customer & Credit Merchant
        customerWallet.setBalance(customerWallet.getBalance().subtract(amount));
        merchantWallet.setBalance(merchantWallet.getBalance().add(amount));
        walletRepository.save(customerWallet);
        walletRepository.save(merchantWallet);

        String txRef = generateInvoiceNumber("TX-POS");

        TransactionCategory cat = TransactionCategory.SHOPPING;
        MerchantProfile profile = merchantProfileRepository.findByUser(invoice.getMerchantUser()).orElse(null);
        if (profile != null && "RESTAURANT".equalsIgnoreCase(profile.getBusinessCategory())) {
            cat = TransactionCategory.FOOD;
        }

        TransactionLedger ledger = TransactionLedger.builder()
                .referenceNumber(txRef)
                .sourceWallet(customerWallet)
                .destinationWallet(merchantWallet)
                .transactionType(TransactionType.P2P_TRANSFER)
                .status(TransactionStatus.SUCCESS)
                .amount(amount)
                .fee(BigDecimal.ZERO)
                .currency(invoice.getCurrency())
                .category(cat)
                .description("Invoice Payment #" + invoice.getInvoiceNumber())
                .build();

        transactionRepository.save(ledger);

        // Update Invoice
        invoice.setStatus(InvoiceStatus.PAID);
        invoice.setCustomerUser(customerUser);
        invoice.setCustomerName(customerUser.getFullName());
        invoice.setCustomerIdentifier(customerWallet.getWalletTag());
        invoice.setTransactionReference(txRef);
        invoice.setPaidAt(ZonedDateTime.now());

        Invoice saved = invoiceRepository.save(invoice);
        log.info("Invoice #{} successfully paid by {}! Ref: {}", saved.getInvoiceNumber(), customerUser.getEmail(), txRef);
        return mapToInvoiceResponse(saved);
    }

    @Transactional(readOnly = true)
    public InvoiceResponse getInvoiceByNumber(String invoiceNumber) {
        Invoice invoice = invoiceRepository.findByInvoiceNumber(invoiceNumber.trim())
                .orElseThrow(() -> new RuntimeException("Invoice not found: " + invoiceNumber));
        return mapToInvoiceResponse(invoice);
    }

    @Transactional(readOnly = true)
    public List<InvoiceResponse> getMerchantInvoices(User merchantUser) {
        return invoiceRepository.findAllByMerchantUserOrderByCreatedAtDesc(merchantUser)
                .stream()
                .map(this::mapToInvoiceResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public MerchantDashboardResponse getMerchantDashboard(User merchantUser) {
        MerchantProfile profile = merchantProfileRepository.findByUser(merchantUser)
                .orElse(null);

        MerchantProfileResponse profileResponse = profile != null ? mapToProfileResponse(profile) : null;

        List<Invoice> allInvoices = invoiceRepository.findAllByMerchantUserOrderByCreatedAtDesc(merchantUser);

        LocalDate today = LocalDate.now();
        ZonedDateTime startOfToday = today.atStartOfDay(ZoneId.systemDefault());
        YearMonth currentMonth = YearMonth.now();
        ZonedDateTime startOfMonth = currentMonth.atDay(1).atStartOfDay(ZoneId.systemDefault());

        BigDecimal todayGross = BigDecimal.ZERO;
        long todayOrders = 0;
        BigDecimal monthGross = BigDecimal.ZERO;
        long monthOrders = 0;
        long pendingInvoices = 0;

        for (Invoice inv : allInvoices) {
            if (inv.getStatus() == InvoiceStatus.PAID && inv.getPaidAt() != null) {
                if (!inv.getPaidAt().isBefore(startOfMonth)) {
                    monthGross = monthGross.add(inv.getGrandTotal());
                    monthOrders++;
                }
                if (!inv.getPaidAt().isBefore(startOfToday)) {
                    todayGross = todayGross.add(inv.getGrandTotal());
                    todayOrders++;
                }
            } else if (inv.getStatus() == InvoiceStatus.PENDING) {
                pendingInvoices++;
            }
        }

        BigDecimal avgTicket = BigDecimal.ZERO;
        if (monthOrders > 0) {
            avgTicket = monthGross.divide(BigDecimal.valueOf(monthOrders), 2, RoundingMode.HALF_UP);
        }

        List<InvoiceResponse> recent = allInvoices.stream()
                .limit(10)
                .map(this::mapToInvoiceResponse)
                .collect(Collectors.toList());

        return MerchantDashboardResponse.builder()
                .profile(profileResponse)
                .todayGrossSales(todayGross.setScale(2, RoundingMode.HALF_UP))
                .todayOrdersCount(todayOrders)
                .monthGrossSales(monthGross.setScale(2, RoundingMode.HALF_UP))
                .monthOrdersCount(monthOrders)
                .averageTicketSize(avgTicket)
                .pendingInvoicesCount(pendingInvoices)
                .recentInvoices(recent)
                .build();
    }

    private String generateInvoiceNumber(String prefix) {
        long timestamp = System.currentTimeMillis() / 1000;
        int randomDigits = secureRandom.nextInt(900000) + 100000;
        return String.format("%s-%d-%d", prefix, timestamp, randomDigits);
    }

    private String generateInvoiceQrPayload(String invoiceNumber, BigDecimal amount, String merchantTag, String businessName) {
        try {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("schema", "BATWA-QR-v1");
            map.put("type", "DYNAMIC_MERCHANT");
            map.put("invoiceNumber", invoiceNumber);
            map.put("recipientTag", merchantTag);
            map.put("merchantName", businessName);
            map.put("amount", amount.setScale(2, RoundingMode.HALF_UP).doubleValue());
            map.put("currency", "USD");
            return objectMapper.writeValueAsString(map);
        } catch (Exception e) {
            return "BATWA:PAY:" + merchantTag + ":" + amount + ":" + invoiceNumber;
        }
    }

    public MerchantProfileResponse mapToProfileResponse(MerchantProfile profile) {
        Wallet wallet = walletRepository.findByUserId(profile.getUser().getId()).orElse(null);
        return MerchantProfileResponse.builder()
                .id(profile.getId())
                .userId(profile.getUser().getId())
                .businessName(profile.getBusinessName())
                .businessCategory(profile.getBusinessCategory())
                .taxId(profile.getTaxId())
                .storeAddress(profile.getStoreAddress())
                .merchantWalletTag(wallet != null ? wallet.getWalletTag() : null)
                .merchantFullName(profile.getUser().getFullName())
                .isActive(profile.getIsActive())
                .createdAt(profile.getCreatedAt())
                .build();
    }

    public InvoiceResponse mapToInvoiceResponse(Invoice invoice) {
        Wallet merchantWallet = walletRepository.findByUserId(invoice.getMerchantUser().getId()).orElse(null);
        MerchantProfile profile = merchantProfileRepository.findByUser(invoice.getMerchantUser()).orElse(null);

        List<InvoiceResponse.InvoiceItemResponse> items = invoice.getItems().stream()
                .map(i -> InvoiceResponse.InvoiceItemResponse.builder()
                        .id(i.getId())
                        .itemName(i.getItemName())
                        .quantity(i.getQuantity())
                        .unitPrice(i.getUnitPrice())
                        .totalPrice(i.getTotalPrice())
                        .build())
                .collect(Collectors.toList());

        return InvoiceResponse.builder()
                .id(invoice.getId())
                .invoiceNumber(invoice.getInvoiceNumber())
                .merchantUserId(invoice.getMerchantUser().getId())
                .merchantBusinessName(profile != null ? profile.getBusinessName() : invoice.getMerchantUser().getFullName())
                .merchantWalletTag(merchantWallet != null ? merchantWallet.getWalletTag() : null)
                .customerUserId(invoice.getCustomerUser() != null ? invoice.getCustomerUser().getId() : null)
                .customerName(invoice.getCustomerName())
                .customerIdentifier(invoice.getCustomerIdentifier())
                .subtotal(invoice.getSubtotal())
                .taxRatePercentage(invoice.getTaxRatePercentage())
                .taxAmount(invoice.getTaxAmount())
                .grandTotal(invoice.getGrandTotal())
                .currency(invoice.getCurrency())
                .status(invoice.getStatus())
                .description(invoice.getDescription())
                .qrCodePayload(invoice.getQrCodePayload())
                .transactionReference(invoice.getTransactionReference())
                .paidAt(invoice.getPaidAt())
                .dueDate(invoice.getDueDate())
                .createdAt(invoice.getCreatedAt())
                .items(items)
                .build();
    }
}
