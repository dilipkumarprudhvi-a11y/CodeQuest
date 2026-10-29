package com.codequest.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String username;
    private String email;
    private String password;
    private int xp;
    private int level;
    private Timestamp createdAt;

    public User() {
    }

    public User(int id, String username, String email, String password, int xp, int level, Timestamp createdAt) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.xp = xp;
        this.level = level;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getXp() {
        return xp;
    }

    public void setXp(int xp) {
        this.xp = xp;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Calculates the XP needed to reach the next level
     */
    public int getNextLevelThreshold() {
        if (level <= 1) return 100;
        if (level == 2) return 250;
        if (level == 3) return 450;
        if (level == 4) return 700;
        return (level * 200);
    }

    /**
     * Calculates progress percentage towards next level (0 - 100%)
     */
    public int getLevelProgressPercent() {
        int prevThreshold = 0;
        if (level == 2) prevThreshold = 100;
        else if (level == 3) prevThreshold = 250;
        else if (level == 4) prevThreshold = 450;
        else if (level >= 5) prevThreshold = 700;

        int nextThreshold = getNextLevelThreshold();
        if (xp >= nextThreshold) return 100;
        if (xp <= prevThreshold) return 0;

        int range = nextThreshold - prevThreshold;
        if (range <= 0) return 100;
        return (int) (((double) (xp - prevThreshold) / range) * 100.0);
    }
}
