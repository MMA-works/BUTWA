package com.batwa.wallet.service;

import com.batwa.wallet.dto.recurring.CreateScheduledPaymentRequest;
import com.batwa.wallet.dto.recurring.ScheduledPaymentResponse;
import com.batwa.wallet.dto.request.TransferRequest;
import com.batwa.wallet.dto.response.TransactionResponse;
import com.batwa.wallet.entity.ScheduledPayment;
import com.batwa.wallet.entity.User;
import com.batwa.wallet.entity.Wallet;
import com.batwa.wallet.exception.InvalidPinException;
import com.batwa.wallet.exception.ResourceNotFoundException;
import com.batwa.wallet.repository.ScheduledPaymentRepository;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@EnableScheduling
@RequiredArgsConstructor
public class ScheduledPaymentService {

    private final ScheduledPaymentRepository scheduledPaymentRepository;
    private final WalletRepository walletRepository;
    private final UserRepository userRepository;
    private final com.batwa.wallet.repository.TransactionRepository transactionRepository;
    private final WalletService walletService;
    private final PasswordEncoder passwordEncoder;
    private final java.security.SecureRandom secureRandom = new java.security.SecureRandom();

    @Transactional
    public ScheduledPaymentResponse createSchedule(UUID userId, CreateScheduledPaymentRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.getPinHash() == null || !passwordEncoder.matches(request.getPin(), user.getPinHash())) {
            throw new InvalidPinException("Invalid transaction MPIN", 3);
        }

        Wallet sourceWallet = walletRepository.findByUserId(user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Source wallet not found"));

        ScheduledPayment.Frequency frequency;
        try {
            frequency = ScheduledPayment.Frequency.valueOf(request.getFrequency().toUpperCase());
        } catch (Exception e) {
            frequency = ScheduledPayment.Frequency.MONTHLY;
        }

        ZonedDateTime nextExecution = calculateNextDate(ZonedDateTime.now(), frequency);

        ScheduledPayment schedule = ScheduledPayment.builder()
                .sourceWallet(sourceWallet)
                .recipientIdentifier(request.getRecipientIdentifier())
                .title(request.getTitle())
                .amount(request.getAmount())
                .frequency(frequency)
                .status(ScheduledPayment.Status.ACTIVE)
                .nextExecutionDate(nextExecution)
                .build();

        schedule = scheduledPaymentRepository.save(schedule);
        log.info("Created scheduled payment ID: {} for user: {}", schedule.getId(), user.getEmail());
        return mapToResponse(schedule);
    }

    @Transactional(readOnly = true)
    public List<ScheduledPaymentResponse> getSchedules(UUID userId) {
        return scheduledPaymentRepository.findByUserId(userId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public ScheduledPaymentResponse toggleSchedule(UUID userId, UUID scheduleId) {
        ScheduledPayment schedule = scheduledPaymentRepository.findById(scheduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Scheduled payment not found"));

        if (!schedule.getSourceWallet().getUser().getId().equals(userId)) {
            throw new IllegalArgumentException("Unauthorized to modify this schedule");
        }

        if (schedule.getStatus() == ScheduledPayment.Status.ACTIVE) {
            schedule.setStatus(ScheduledPayment.Status.PAUSED);
        } else if (schedule.getStatus() == ScheduledPayment.Status.PAUSED) {
            schedule.setStatus(ScheduledPayment.Status.ACTIVE);
            if (schedule.getNextExecutionDate().isBefore(ZonedDateTime.now())) {
                schedule.setNextExecutionDate(calculateNextDate(ZonedDateTime.now(), schedule.getFrequency()));
            }
        }

        schedule = scheduledPaymentRepository.save(schedule);
        return mapToResponse(schedule);
    }

    @Transactional
    public void deleteSchedule(UUID userId, UUID scheduleId) {
        ScheduledPayment schedule = scheduledPaymentRepository.findById(scheduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Scheduled payment not found"));

        if (!schedule.getSourceWallet().getUser().getId().equals(userId)) {
            throw new IllegalArgumentException("Unauthorized to delete this schedule");
        }

        schedule.setStatus(ScheduledPayment.Status.CANCELLED);
        scheduledPaymentRepository.delete(schedule);
    }

    @Transactional
    public TransactionResponse executeNow(UUID userId, UUID scheduleId) {
        ScheduledPayment schedule = scheduledPaymentRepository.findById(scheduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Scheduled payment not found"));

        if (!schedule.getSourceWallet().getUser().getId().equals(userId)) {
            throw new IllegalArgumentException("Unauthorized to execute this schedule");
        }

        return executeSinglePayment(schedule);
    }

    /**
     * In-House Background Cron Engine: runs every 60 seconds to process due auto-debits.
     */
    @Scheduled(fixedRate = 60000)
    @Transactional
    public void processDuePayments() {
        ZonedDateTime now = ZonedDateTime.now();
        List<ScheduledPayment> dueList = scheduledPaymentRepository.findDuePayments(now);
        if (dueList.isEmpty()) return;

        log.info("Processing {} due scheduled payments at {}", dueList.size(), now);
        for (ScheduledPayment schedule : dueList) {
            try {
                executeSinglePayment(schedule);
            } catch (Exception e) {
                log.error("Failed to execute scheduled payment ID: {}. Error: {}", schedule.getId(), e.getMessage());
                schedule.setFailureCount(schedule.getFailureCount() + 1);
                schedule.setLastFailureReason(e.getMessage());
                scheduledPaymentRepository.save(schedule);
            }
        }
    }

    private TransactionResponse executeSinglePayment(ScheduledPayment schedule) {
        User sourceUser = schedule.getSourceWallet().getUser();

        TransferRequest transferRequest = TransferRequest.builder()
                .recipientIdentifier(schedule.getRecipientIdentifier())
                .amount(schedule.getAmount())
                .note("Auto-Debit: " + schedule.getTitle())
                .pin("BYPASS_CRON")
                .build();

        String idempotencyKey = "SCHED-" + schedule.getId() + "-" + System.currentTimeMillis();

        TransactionResponse tx = executeDirectLedgerTransfer(sourceUser.getId(), transferRequest, idempotencyKey);

        schedule.setLastExecutionDate(ZonedDateTime.now());
        schedule.setExecutionCount(schedule.getExecutionCount() + 1);
        schedule.setNextExecutionDate(calculateNextDate(schedule.getNextExecutionDate(), schedule.getFrequency()));
        schedule.setLastFailureReason(null);
        scheduledPaymentRepository.save(schedule);

        return tx;
    }

    private TransactionResponse executeDirectLedgerTransfer(UUID sourceUserId, TransferRequest request, String idempotencyKey) {
        // Find destination wallet
        String cleanId = request.getRecipientIdentifier().trim().replace("@", "");
        Wallet destinationWallet = walletRepository.findByWalletTag(cleanId)
                .or(() -> userRepository.findByPhoneNumber(request.getRecipientIdentifier()).map(User::getWallet))
                .or(() -> userRepository.findByEmail(request.getRecipientIdentifier()).map(User::getWallet))
                .orElseThrow(() -> new ResourceNotFoundException("Recipient wallet not found: " + request.getRecipientIdentifier()));

        Wallet sourceWallet = walletRepository.findByUserIdForUpdate(sourceUserId)
                .orElseThrow(() -> new ResourceNotFoundException("Source wallet not found"));

        // Debit & Credit
        sourceWallet.debit(request.getAmount());
        destinationWallet.credit(request.getAmount());

        walletRepository.save(sourceWallet);
        walletRepository.save(destinationWallet);

        String refNum = "SCHED-" + (System.currentTimeMillis() / 1000) + "-" + (secureRandom.nextInt(900000) + 100000);
        com.batwa.wallet.entity.TransactionLedger ledger = com.batwa.wallet.entity.TransactionLedger.builder()
                .referenceNumber(refNum)
                .sourceWallet(sourceWallet)
                .destinationWallet(destinationWallet)
                .transactionType(com.batwa.wallet.entity.TransactionType.P2P_TRANSFER)
                .status(com.batwa.wallet.entity.TransactionStatus.SUCCESS)
                .amount(request.getAmount())
                .fee(java.math.BigDecimal.ZERO)
                .currency(sourceWallet.getCurrency())
                .description(request.getNote())
                .idempotencyKey(idempotencyKey)
                .build();

        ledger = transactionRepository.save(ledger);

        return walletService.mapToTransactionResponse(ledger);
    }

    private ZonedDateTime calculateNextDate(ZonedDateTime from, ScheduledPayment.Frequency frequency) {
        return switch (frequency) {
            case DAILY -> from.plusDays(1);
            case WEEKLY -> from.plusWeeks(1);
            case MONTHLY -> from.plusMonths(1);
        };
    }

    private ScheduledPaymentResponse mapToResponse(ScheduledPayment s) {
        return ScheduledPaymentResponse.builder()
                .id(s.getId())
                .recipientIdentifier(s.getRecipientIdentifier())
                .recipientName(s.getRecipientIdentifier())
                .title(s.getTitle())
                .amount(s.getAmount())
                .frequency(s.getFrequency().name())
                .status(s.getStatus().name())
                .nextExecutionDate(s.getNextExecutionDate())
                .lastExecutionDate(s.getLastExecutionDate())
                .executionCount(s.getExecutionCount())
                .failureCount(s.getFailureCount())
                .lastFailureReason(s.getLastFailureReason())
                .createdAt(s.getCreatedAt())
                .build();
    }
}
