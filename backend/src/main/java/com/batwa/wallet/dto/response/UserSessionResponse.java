package com.batwa.wallet.dto.response;

import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSessionResponse {

    private UUID id;
    private String deviceId;
    private String deviceName;
    private String osVersion;
    private String ipAddress;
    private boolean isCurrent;
    private ZonedDateTime lastActiveAt;
    private ZonedDateTime createdAt;
}