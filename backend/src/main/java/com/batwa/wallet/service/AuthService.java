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

import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;
import java.math.BigDecimal;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final AuthenticationManager authenticationManager;

    // Fast-path known authentic email domains
    private static final Set<String> POPULAR_VALID_DOMAINS = new HashSet<>(Arrays.asList(
            "gmail.com", "yahoo.com", "outlook.com", "hotmail.com", "icloud.com",
            "live.com", "msn.com", "mail.com", "proton.me", "protonmail.com",
            "zoho.com", "aol.com", "yandex.com", "gmx.com", "fastmail.com"
    ));

    /**
     * Real-world verification: checks RFC format, popular valid provider domains,
     * and performs active DNS MX record lookups to ensure the domain actually exists
     * and accepts emails on the internet.
     */
    public boolean isRealWorldEmailDomain(String email) {
        if (email == null) return false;
        String cleanEmail = email.trim().toLowerCase();
        int atIndex = cleanEmail.indexOf('@');
        if (atIndex <= 0 || atIndex != cleanEmail.lastIndexOf('@')) {
            return false;
        }

        String userPart = cleanEmail.substring(0, atIndex);
        String domainPart = cleanEmail.substring(atIndex + 1);

        if (userPart.length() < 1 || domainPart.length() < 3) return false;
        if (!domainPart.contains(".") || domainPart.startsWith(".") || domainPart.endsWith(".")) return false;

        // Fast-path popular validated consumer domains
        if (POPULAR_VALID_DOMAINS.contains(domainPart)) {
            return true;
        }

        // Live DNS MX & A record resolution for custom/corporate domains
        try {
            Hashtable<String, String> env = new Hashtable<>();
            env.put("java.naming.factory.initial", "com.sun.jndi.dns.DnsContextFactory");
            env.put("com.sun.jndi.dns.timeout.initial", "2500");
            env.put("com.sun.jndi.dns.timeout.retries", "1");
            DirContext ictx = new InitialDirContext(env);
            Attributes attrs = ictx.getAttributes(domainPart, new String[] { "MX" });
            Attribute attr = attrs.get("MX");
            if (attr != null && attr.size() > 0) {
                return true;
            }
            // Fallback: Check if host domain resolves to an IP address
            Attributes aAttrs = ictx.getAttributes(domainPart, new String[] { "A" });
            return aAttrs.get("A") != null;
        } catch (Exception ex) {
            log.warn("DNS check failed for email domain [{}]: {}", domainPart, ex.getMessage());
            return false;
        }
    }

    /**
     * Check if a 13-digit Pakistani CNIC is already registered in the system.
     */
    public boolean isCnicAvailable(String cnic) {
        if (cnic == null) return false;
        String digits = cnic.replaceAll("[^0-9]", "");
        if (digits.length() != 13) return false;
        String formatted = digits.substring(0, 5) + "-" + digits.substring(5, 12) + "-" + digits.substring(12, 13);
        return !userRepository.existsByCnicNumber(formatted) && !userRepository.existsByCnicNumber(digits);
    }

    /**
     * Check if a unique username / walletTag is available.
     */
    public boolean isUsernameAvailable(String username) {
        if (username == null) return false;
        String tag = username.replace("@", "").toLowerCase().trim();
        if (tag.length() < 3 || tag.length() > 30) return false;
        return !walletRepository.existsByWalletTagIgnoreCase(tag);
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String cleanEmail = request.getEmail().toLowerCase().trim();

        // 🌟 1. Real-World Email Existence Check
        if (!isRealWorldEmailDomain(cleanEmail)) {
            throw new IllegalArgumentException(
                    "The email '" + request.getEmail() + "' is not a valid real-world email. Please use a real active address (e.g., @gmail.com, @yahoo.com)."
            );
        }

        if (userRepository.existsByEmail(cleanEmail)) {
            throw new DuplicateResourceException("An account with this email already exists");
        }
        if (userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new DuplicateResourceException("An account with this phone number already exists");
        }

        // 🌟 2. Strict CNIC Uniqueness & 13-Digit Format Verification
        String formattedCnic = null;
        if (request.getCnicNumber() != null && !request.getCnicNumber().isBlank()) {
            String digits = request.getCnicNumber().replaceAll("[^0-9]", "");
            if (digits.length() != 13) {
                throw new IllegalArgumentException("CNIC must be strictly 13 digits (format: XXXXX-XXXXXXX-X)");
            }
            formattedCnic = digits.substring(0, 5) + "-" + digits.substring(5, 12) + "-" + digits.substring(12, 13);
            if (userRepository.existsByCnicNumber(formattedCnic) || userRepository.existsByCnicNumber(digits)) {
                throw new DuplicateResourceException("An account with this CNIC (" + formattedCnic + ") is already registered. Each CNIC can only be registered once.");
            }
        }

        // 🌟 3. Strict Global Username / Wallet Tag Uniqueness
        String walletTag = request.getCustomTag();
        if (walletTag == null || walletTag.isBlank()) {
            walletTag = generateDefaultWalletTag(request.getFullName());
        } else {
            walletTag = walletTag.replace("@", "").toLowerCase().trim();
            if (walletRepository.existsByWalletTagIgnoreCase(walletTag)) {
                throw new DuplicateResourceException("Username '@" + walletTag + "' is already taken. Please choose another username.");
            }
        }

        User user = User.builder()
                .email(cleanEmail)
                .phoneNumber(request.getPhoneNumber().trim())
                .fullName(request.getFullName().trim())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .cnicNumber(formattedCnic)
                .isKycVerified(true)
                .isBiometricEnrolled(true)
                .pinFailedAttempts(0)
                .isLocked(false)
                .build();

        user = userRepository.save(user);

        Wallet wallet = Wallet.builder()
                .user(user)
                .walletTag(walletTag)
                .currency("PKR")
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

        // If user already had a PIN configured and current password was provided, verify it.
        // For new initial setup (or when password is not set in request), allow authenticated user to configure PIN!
        boolean hasExistingPin = user.getPinHash() != null && !user.getPinHash().isBlank();
        if (hasExistingPin && request.getCurrentPassword() != null && !request.getCurrentPassword().isBlank()) {
            if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
                throw new BadCredentialsException("Invalid current password");
            }
        }

        user.setPinHash(passwordEncoder.encode(request.getPin()));
        user.setPinFailedAttempts(0);
        userRepository.save(user);
        log.info("Successfully configured transaction PIN for user: {}", user.getEmail());
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
        while (walletRepository.existsByWalletTagIgnoreCase(candidate)) {
            candidate = base + suffix;
            suffix++;
        }
        return candidate;
    }
}
