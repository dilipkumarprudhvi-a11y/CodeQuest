package com.codequest.filter;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Enterprise HTTP Security Headers Filter for CodeQuest
 * Defends against:
 * 1. MIME-type sniffing (X-Content-Type-Options: nosniff)
 * 2. Clickjacking attacks (X-Frame-Options: SAMEORIGIN)
 * 3. Cross-Site Scripting (X-XSS-Protection: 1; mode=block)
 * 4. Insecure Referrer leakage (Referrer-Policy: strict-origin-when-cross-origin)
 * 5. Insecure HTTP assets (Content-Security-Policy & HSTS when on HTTPS)
 */
public class SecurityHeadersFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        if (response instanceof HttpServletResponse) {
            HttpServletResponse httpResp = (HttpServletResponse) response;
            HttpServletRequest httpReq = (HttpServletRequest) request;

            // Enforce standard enterprise defense headers
            httpResp.setHeader("X-Content-Type-Options", "nosniff");
            httpResp.setHeader("X-Frame-Options", "SAMEORIGIN");
            httpResp.setHeader("X-XSS-Protection", "1; mode=block");
            httpResp.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
            
            // Content-Security-Policy supporting local execution, fonts, canvas particles, and audio
            httpResp.setHeader("Content-Security-Policy", 
                "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob:; " +
                "img-src 'self' data: https: blob:; " +
                "font-src 'self' data: https:; " +
                "media-src 'self' data: blob:; " +
                "connect-src 'self' data: blob:;");

            // If running on HTTPS, enforce Strict-Transport-Security (HSTS)
            if (httpReq.isSecure()) {
                httpResp.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}

