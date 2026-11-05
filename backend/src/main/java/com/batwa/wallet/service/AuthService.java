package com.batwa.wallet.service;

import com.batwa.wallet.dto.request.AuthRequest;
import com.batwa.wallet.dto.request.RegisterRequest;
import com.batwa.wallet.dto.request.SetPinRequest;
import com.batwa.wallet.dto.response.AuthResponse;
import com.batwa.wallet.dto.response.UserResponse;
import com.batwa.wallet.dto.response.WalletResponse;
import com.batwa.wallet.entity.User;
import com.batwa.wallet.entity.Wallet;
import com.batwa.wallet.exception.AccountLockedException;
import com.batwa.wallet.exception.DuplicateResourceException;
import com.batwa.wallet.exception.InvalidPinException;
import com.batwa.wallet.exception.ResourceNotFoundException;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.repository.WalletRepository;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("An account with this email already exists");
        }
        if (userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new DuplicateResourceException("An account with this phone number already exists");
        }

        String walletTag = request.getCustomTag();
        if (walletTag == null || walletTag.isBlank()) {
            walletTag = generateDefaultWalletTag(request.getFullName());
        } else {
            walletTag = walletTag.toLowerCase().trim();
            if (walletRepository.existsByWalletTag(walletTag)) {
                throw new DuplicateResourceException("Wallet tag '@" + walletTag + "' is already taken");
            }
        }

        User user = User.builder()
                .email(request.getEmail().toLowerCase().trim())
                .phoneNumber(request.getPhoneNumber().trim())
                .fullName(request.getFullName().trim())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .pinFailedAttempts(0)
                .isLocked(false)
                .build();

        user = userRepository.save(user);

        Wallet wallet = Wallet.builder()
                .user(user)
                .walletTag(walletTag)
                .currency("USD")
                .balance(BigDecimal.ZERO.setScale(4))
                .isActive(true)
                .build();

        wallet = walletRepository.save(wallet);
        user.setWallet(wallet);

        CustomUserDetails userDetails = new CustomUserDetails(user);
        Authentication authentication = new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

        String accessToken = tokenProvider.generateAccessToken(authentication);
        String refreshToken = tokenProvider.generateRefreshToken(authentication);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresInMs(tokenProvider.getExpirationMs())
                .user(mapToUserResponse(user))
                .wallet(mapToWalletResponse(wallet))
                .build();
    }

    @Transactional(readOnly = true)
    public AuthResponse login(AuthRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getIdentifier(), request.getPassword())
        );

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.isLocked()) {
            throw new AccountLockedException("Your account is locked due to security reasons. Please contact support.");
        }

        Wallet wallet = walletRepository.findByUserId(user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Associated wallet not found"));

        String accessToken = tokenProvider.generateAccessToken(authentication);
        String refreshToken = tokenProvider.generateRefreshToken(authentication);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresInMs(tokenProvider.getExpirationMs())
                .user(mapToUserResponse(user))
                .wallet(mapToWalletResponse(wallet))
                .build();
    }

    @Transactional
    public void setPin(UUID userId, SetPinRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new BadCredentialsException("Invalid current password");
        }

        user.setPinHash(passwordEncoder.encode(request.getPin()));
        user.setPinFailedAttempts(0);
        userRepository.save(user);
    }

    @Transactional(readOnly = true)
    public UserResponse getCurrentUser(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return mapToUserResponse(user);
    }

    public UserResponse mapToUserResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .fullName(user.getFullName())
                .hasPinConfigured(user.getPinHash() != null && !user.getPinHash().isBlank())
                .isLocked(user.isLocked())
                .createdAt(user.getCreatedAt())
                .build();
    }

    public WalletResponse mapToWalletResponse(Wallet wallet) {
        return WalletResponse.builder()
                .id(wallet.getId())
                .walletTag(wallet.getWalletTag())
                .currency(wallet.getCurrency())
                .balance(wallet.getBalance().setScale(2, java.math.RoundingMode.HALF_UP))
                .isActive(wallet.isActive())
                .qrCodeData("batwa://transfer?tag=" + wallet.getWalletTag())
                .updatedAt(wallet.getUpdatedAt())
                .build();
    }

    private String generateDefaultWalletTag(String fullName) {
        String base = fullName.toLowerCase().replaceAll("[^a-z0-9]", "");
        if (base.length() < 3) {
            base = "user" + base;
        }
        String candidate = base;
        int suffix = 1;
        while (walletRepository.existsByWalletTag(candidate)) {
            candidate = base + suffix;
            suffix++;
        }
        return candidate;
    }
}
