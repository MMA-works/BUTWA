package com.batwa.wallet.exception;

import lombok.Getter;

@Getter
public class InvalidPinException extends RuntimeException {
    private final int remainingAttempts;

    public InvalidPinException(String message, int remainingAttempts) {
        super(message);
        this.remainingAttempts = remainingAttempts;
    }

    public InvalidPinException(String message) {
        super(message);
        this.remainingAttempts = 0;
    }
}
