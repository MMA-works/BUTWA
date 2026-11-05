package com.batwa.wallet.dto.response;

import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SecurityAuditLogResponse {

    private UUID id;
    private String eventType;
    private String description;
    private String ipAddress;
    private String deviceInfo;
    private ZonedDateTime timestamp;
}