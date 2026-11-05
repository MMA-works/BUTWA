package com.batwa.wallet.service;

import com.batwa.wallet.entity.IdempotencyRecord;
import com.batwa.wallet.exception.IdempotencyConflictException;
import com.batwa.wallet.repository.IdempotencyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.ZonedDateTime;
import java.util.HexFormat;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class IdempotencyService {

    private final IdempotencyRepository idempotencyRepository;

    public String computePayloadHash(Object payload) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(String.valueOf(payload).getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }

    @Transactional(readOnly = true)
    public Optional<IdempotencyRecord> checkIdempotency(String idempotencyKey, UUID userId, String requestHash) {
        if (idempotencyKey == null || idempotencyKey.isBlank()) {
            return Optional.empty();
        }

        Optional<IdempotencyRecord> recordOpt = idempotencyRepository.findByIdempotencyKeyAndUserId(idempotencyKey, userId);
        if (recordOpt.isPresent()) {
            IdempotencyRecord record = recordOpt.get();
            if (!record.getRequestHash().equals(requestHash)) {
                throw new IdempotencyConflictException(
                        "Idempotency key '" + idempotencyKey + "' was already used with a different request payload."
                );
            }
            return Optional.of(record);
        }
        return Optional.empty();
    }

    @Transactional
    public void recordResponse(String idempotencyKey, UUID userId, String requestUri,
                               String requestHash, int httpStatus, String responseBodyJson) {
        if (idempotencyKey == null || idempotencyKey.isBlank()) {
            return;
        }

        IdempotencyRecord record = IdempotencyRecord.builder()
                .idempotencyKey(idempotencyKey)
                .userId(userId)
                .requestUri(requestUri)
                .requestHash(requestHash)
                .httpStatus(httpStatus)
                .responseBody(responseBodyJson)
                .expiresAt(ZonedDateTime.now().plusHours(24))
                .build();

        idempotencyRepository.save(record);
    }
}
