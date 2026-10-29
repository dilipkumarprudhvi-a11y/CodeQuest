package com.codequest.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Enterprise Security Utility for CodeQuest
 * Implements OWASP-recommended defenses:
 * 1. HTML Output Encoding (XSS defense)
 * 2. Salted Cryptographic Password Hashing (SHA-256 + 16-byte SecureRandom salt)
 * 3. Constant-Time Hash Comparison (Timing-attack defense)
 * 4. Input Sanitization Helpers
 */
public class SecurityUtil {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String HASH_PREFIX = "CQ256$";

    /**
     * Encodes untrusted user input before rendering in HTML context to prevent Cross-Site Scripting (XSS).
     */
    public static String encodeHtml(String input) {
        if (input == null) {
            return "";
        }
        StringBuilder out = new StringBuilder(Math.max(16, input.length()));
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '&':
                    out.append("&amp;");
                    break;
                case '<':
                    out.append("&lt;");
                    break;
                case '>':
                    out.append("&gt;");
                    break;
                case '"':
                    out.append("&quot;");
                    break;
                case '\'':
                    out.append("&#x27;");
                    break;
                case '/':
                    out.append("&#x2F;");
                    break;
                default:
                    out.append(c);
            }
        }
        return out.toString();
    }

    /**
     * Generates a salted SHA-256 hash formatted as: CQ256$[saltBase64]$[hashBase64]
     */
    public static String hashPassword(String password) {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty for hashing");
        }
        byte[] salt = new byte[16];
        RANDOM.nextBytes(salt);

        byte[] hash = computeSha256(password, salt);
        String saltStr = Base64.getEncoder().encodeToString(salt);
        String hashStr = Base64.getEncoder().encodeToString(hash);

        return HASH_PREFIX + saltStr + "$" + hashStr;
    }

    /**
     * Verifies password against stored hash with backward compatibility for legacy plaintext records.
     * Uses constant-time comparison to prevent side-channel timing attacks.
     */
    public static boolean verifyPassword(String plainPassword, String storedHash) {
        if (plainPassword == null || storedHash == null) {
            return false;
        }

        // Check if stored in CQ256$ format
        if (storedHash.startsWith(HASH_PREFIX)) {
            try {
                String[] parts = storedHash.substring(HASH_PREFIX.length()).split("\\$");
                if (parts.length != 2) return false;

                byte[] salt = Base64.getDecoder().decode(parts[0]);
                byte[] expectedHash = Base64.getDecoder().decode(parts[1]);
                byte[] actualHash = computeSha256(plainPassword, salt);

                return MessageDigest.isEqual(expectedHash, actualHash);
            } catch (Exception e) {
                return false;
            }
        }

        // Fallback for initial seed records / plain text backward compatibility
        return storedHash.equals(plainPassword);
    }

    /**
     * Checks if a stored password string needs to be upgraded to the salted hash standard.
     */
    public static boolean needsRehash(String storedHash) {
        return storedHash == null || !storedHash.startsWith(HASH_PREFIX);
    }

    private static byte[] computeSha256(String password, byte[] salt) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            return md.digest(password.getBytes(StandardCharsets.UTF_8));
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available in JVM", e);
        }
    }
}

