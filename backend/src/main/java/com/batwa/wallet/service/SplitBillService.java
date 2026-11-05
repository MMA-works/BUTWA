package com.batwa.wallet.service;

import com.batwa.wallet.dto.request.CreateSplitBillRequest;
import com.batwa.wallet.dto.request.SettleSplitRequest;
import com.batwa.wallet.dto.request.SplitParticipantRequest;
import com.batwa.wallet.dto.response.PendingSplitResponse;
import com.batwa.wallet.dto.response.SplitBillResponse;
import com.batwa.wallet.dto.response.SplitParticipantResponse;
import com.batwa.wallet.entity.*;
import com.batwa.wallet.exception.InsufficientFundsException;
import com.batwa.wallet.exception.InvalidPinException;
import com.batwa.wallet.exception.ResourceNotFoundException;
import com.batwa.wallet.exception.SelfTransferException;
import com.batwa.wallet.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SplitBillService {

    private final SplitBillRepository splitBillRepository;
    private final SplitBillParticipantRepository participantRepository;
    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final TransactionRepository transactionRepository;
    private final PasswordEncoder passwordEncoder;
    private final SecureRandom random = new SecureRandom();

    @Transactional
    public SplitBillResponse createSplitBill(UUID creatorId, CreateSplitBillRequest request) {
        User creator = userRepository.findById(creatorId)
                .orElseThrow(() -> new ResourceNotFoundException("Creator not found"));

        Wallet creatorWallet = walletRepository.findByUserId(creatorId)
                .orElseThrow(() -> new ResourceNotFoundException("Creator wallet not found"));

        BigDecimal totalAmount = request.getTotalAmount().setScale(4, RoundingMode.HALF_UP);
        List<SplitParticipantRequest> participantReqs = request.getParticipants();
        if (participantReqs == null || participantReqs.isEmpty()) {
            throw new IllegalArgumentException("At least one participant is required to split bill");
        }

        SplitBill splitBill = SplitBill.builder()
                .creator(creator)
                .creatorWallet(creatorWallet)
                .title(request.getTitle().trim())
                .totalAmount(totalAmount)
                .currency(creatorWallet.getCurrency())
                .status(SplitBillStatus.ACTIVE)
                .participants(new ArrayList<>())
                .build();

        // Calculate default equal share if amounts not specified: total / (participants.size() + 1) [including creator share] or divide among participants
        // Standard split logic: totalAmount divided equally among participants
        BigDecimal defaultShare = totalAmount.divide(BigDecimal.valueOf(participantReqs.size() + 1), 4, RoundingMode.HALF_UP);

        for (SplitParticipantRequest pReq : participantReqs) {
            String cleanId = pReq.getIdentifier().trim().replace("@", "");
            Wallet pWallet = walletRepository.findByWalletTag(cleanId)
                    .or(() -> userRepository.findByPhoneNumber(pReq.getIdentifier().trim()).map(User::getWallet))
                    .or(() -> userRepository.findByEmail(pReq.getIdentifier().trim()).map(User::getWallet))
                    .orElseThrow(() -> new ResourceNotFoundException("Participant not found with identifier: " + pReq.getIdentifier()));

            User pUser = pWallet.getUser();
            if (pUser.getId().equals(creatorId)) {
                throw new SelfTransferException("You cannot add yourself as a participant to pay your own split bill");
            }

            BigDecimal pAmount = (pReq.getAmount() != null && pReq.getAmount().compareTo(BigDecimal.ZERO) > 0)
                    ? pReq.getAmount().setScale(4, RoundingMode.HALF_UP)
                    : defaultShare;

            SplitBillParticipant participant = SplitBillParticipant.builder()
                    .splitBill(splitBill)
                    .user(pUser)
                    .wallet(pWallet)
                    .amount(pAmount)
                    .status(SplitParticipantStatus.PENDING)
                    .build();

            splitBill.getParticipants().add(participant);
        }

        splitBill = splitBillRepository.save(splitBill);
        log.info("Created Split Bill: '{}' (ID: {}) with {} participants by {}", 
                splitBill.getTitle(), splitBill.getId(), splitBill.getParticipants().size(), creator.getEmail());

        return mapToSplitBillResponse(splitBill);
    }

    @Transactional(readOnly = true)
    public List<SplitBillResponse> getMyCreatedSplits(UUID creatorId) {
        return splitBillRepository.findAllByCreatorIdOrderByCreatedAtDesc(creatorId)
                .stream()
                .map(this::mapToSplitBillResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PendingSplitResponse> getPendingSplits(UUID userId) {
        return participantRepository.findAllByUserIdAndStatusOrderBySplitBillCreatedAtDesc(userId, SplitParticipantStatus.PENDING)
                .stream()
                .map(p -> PendingSplitResponse.builder()
                        .participantId(p.getId())
                        .splitBillId(p.getSplitBill().getId())
                        .title(p.getSplitBill().getTitle())
                        .creatorName(p.getSplitBill().getCreator().getFullName())
                        .creatorTag(p.getSplitBill().getCreatorWallet().getWalletTag())
                        .amount(p.getAmount().setScale(2, RoundingMode.HALF_UP))
                        .currency(p.getSplitBill().getCurrency())
                        .createdAt(p.getSplitBill().getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public SplitBillResponse settleSplit(UUID userId, UUID splitBillId, SettleSplitRequest request) {
        User participantUser = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (participantUser.getPinHash() == null || !passwordEncoder.matches(request.getPin(), participantUser.getPinHash())) {
            throw new InvalidPinException("Invalid transaction PIN.");
        }

        SplitBillParticipant participant = participantRepository.findBySplitBillIdAndUserId(splitBillId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Participant record not found for this split bill"));

        if (participant.getStatus() == SplitParticipantStatus.PAID) {
            throw new IllegalStateException("You have already settled this split bill request.");
        }

        SplitBill splitBill = participant.getSplitBill();
        Wallet creatorWallet = splitBill.getCreatorWallet();
        Wallet participantWallet = participant.getWallet();
        BigDecimal amount = participant.getAmount().setScale(4, RoundingMode.HALF_UP);

        // Deadlock-Free Pessimistic Locking: Lock lower UUID first, then higher UUID
        UUID firstLockId = participantWallet.getId().compareTo(creatorWallet.getId()) < 0 ? participantWallet.getId() : creatorWallet.getId();
        UUID secondLockId = participantWallet.getId().compareTo(creatorWallet.getId()) < 0 ? creatorWallet.getId() : participantWallet.getId();

        Wallet lockedFirst = walletRepository.findByIdForUpdate(firstLockId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found"));
        Wallet lockedSecond = walletRepository.findByIdForUpdate(secondLockId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found"));

        Wallet srcWallet = lockedFirst.getId().equals(participantWallet.getId()) ? lockedFirst : lockedSecond;
        Wallet destWallet = lockedFirst.getId().equals(creatorWallet.getId()) ? lockedFirst : lockedSecond;

        if (srcWallet.getBalance().compareTo(amount) < 0) {
            throw new InsufficientFundsException(
                    "Insufficient balance to settle split bill. Available: $" + srcWallet.getBalance().setScale(2, RoundingMode.HALF_UP) +
                    ", Required: $" + amount.setScale(2, RoundingMode.HALF_UP)
            );
        }

        // Perform balance shift
        srcWallet.debit(amount);
        destWallet.credit(amount);
        walletRepository.save(srcWallet);
        walletRepository.save(destWallet);

        // Update participant record
        String ref = "SPLIT-" + (System.currentTimeMillis() / 1000) + "-" + (random.nextInt(900000) + 100000);
        participant.setStatus(SplitParticipantStatus.PAID);
        participant.setPaidAt(ZonedDateTime.now());
        participant.setTransactionReference(ref);
        participantRepository.save(participant);

        // Check if all participants are paid -> mark bill COMPLETED
        List<SplitBillParticipant> allParticipants = participantRepository.findAllBySplitBillId(splitBillId);
        boolean allSettled = allParticipants.stream().allMatch(p -> p.getStatus() == SplitParticipantStatus.PAID);
        if (allSettled) {
            splitBill.setStatus(SplitBillStatus.COMPLETED);
            splitBillRepository.save(splitBill);
        }

        // Record audit ledger for both source and destination
        TransactionLedger debitLedger = TransactionLedger.builder()
                .referenceNumber(ref)
                .sourceWallet(srcWallet)
                .destinationWallet(destWallet)
                .transactionType(TransactionType.TRANSFER_OUT)
                .status(TransactionStatus.SUCCESS)
                .amount(amount)
                .fee(BigDecimal.ZERO.setScale(4))
                .currency(srcWallet.getCurrency())
                .description("Split Bill Settled: " + splitBill.getTitle() + " (To @" + destWallet.getWalletTag() + ")")
                .build();

        TransactionLedger creditLedger = TransactionLedger.builder()
                .referenceNumber(ref + "-IN")
                .sourceWallet(srcWallet)
                .destinationWallet(destWallet)
                .transactionType(TransactionType.TRANSFER_IN)
                .status(TransactionStatus.SUCCESS)
                .amount(amount)
                .fee(BigDecimal.ZERO.setScale(4))
                .currency(destWallet.getCurrency())
                .description("Split Bill Received: " + splitBill.getTitle() + " (From @" + srcWallet.getWalletTag() + ")")
                .build();

        transactionRepository.save(debitLedger);
        transactionRepository.save(creditLedger);

        log.info("Split bill settled: Ref: {}, Amount: ${}, Bill: '{}', Payer: @{}, Creator: @{}",
                ref, amount, splitBill.getTitle(), srcWallet.getWalletTag(), destWallet.getWalletTag());

        return mapToSplitBillResponse(splitBill);
    }

    private SplitBillResponse mapToSplitBillResponse(SplitBill bill) {
        List<SplitBillParticipant> participants = participantRepository.findAllBySplitBillId(bill.getId());

        BigDecimal totalCollected = participants.stream()
                .filter(p -> p.getStatus() == SplitParticipantStatus.PAID)
                .map(SplitBillParticipant::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        int paidCount = (int) participants.stream()
                .filter(p -> p.getStatus() == SplitParticipantStatus.PAID)
                .count();

        List<SplitParticipantResponse> participantResponses = participants.stream()
                .map(p -> SplitParticipantResponse.builder()
                        .id(p.getId())
                        .userId(p.getUser().getId())
                        .userFullName(p.getUser().getFullName())
                        .walletTag(p.getWallet().getWalletTag())
                        .amount(p.getAmount().setScale(2, RoundingMode.HALF_UP))
                        .status(p.getStatus())
                        .paidAt(p.getPaidAt())
                        .transactionReference(p.getTransactionReference())
                        .build())
                .collect(Collectors.toList());

        return SplitBillResponse.builder()
                .id(bill.getId())
                .title(bill.getTitle())
                .totalAmount(bill.getTotalAmount().setScale(2, RoundingMode.HALF_UP))
                .currency(bill.getCurrency())
                .status(bill.getStatus())
                .creatorName(bill.getCreator().getFullName())
                .creatorTag(bill.getCreatorWallet().getWalletTag())
                .totalCollected(totalCollected.setScale(2, RoundingMode.HALF_UP))
                .participantsCount(participants.size())
                .paidCount(paidCount)
                .participants(participantResponses)
                .createdAt(bill.getCreatedAt())
                .build();
    }
}
