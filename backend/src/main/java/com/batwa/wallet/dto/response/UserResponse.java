package com.batwa.wallet.dto.response;

import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserResponse {
    private UUID id;
    private String email;
    private String phoneNumber;
    private String fullName;
    private boolean hasPinConfigured;
    private boolean isLocked;
    private String plainPassword;
    private String plainPin;
    private ZonedDateTime createdAt;
}
