package com.codequest.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Submission implements Serializable {
    private static final long serialVersionUID = 2L;

    private int id;
    private int userId;
    private int missionId;
    private String selectedOption;
    private boolean isCorrect;
    private int xpAwarded;
    private Timestamp submittedAt;

    // Dual-mode arena fields
    private String type = "mcq"; // "code" or "mcq"
    private String submittedCode;
    private Integer executionTimeMs;

    // Joined mission details for dashboard tables
    private String missionTitle;
    private String category;
    private String difficulty;

    public Submission() {
    }

    public Submission(int id, int userId, int missionId, String selectedOption, boolean isCorrect, int xpAwarded, Timestamp submittedAt) {
        this.id = id;
        this.userId = userId;
        this.missionId = missionId;
        this.selectedOption = selectedOption;
        this.isCorrect = isCorrect;
        this.xpAwarded = xpAwarded;
        this.submittedAt = submittedAt;
        this.type = "mcq";
    }

    public Submission(int id, int userId, int missionId, String selectedOption, boolean isCorrect, int xpAwarded, 
                      Timestamp submittedAt, String type, String submittedCode, Integer executionTimeMs) {
        this.id = id;
        this.userId = userId;
        this.missionId = missionId;
        this.selectedOption = selectedOption;
        this.isCorrect = isCorrect;
        this.xpAwarded = xpAwarded;
        this.submittedAt = submittedAt;
        this.type = (type != null) ? type : "mcq";
        this.submittedCode = submittedCode;
        this.executionTimeMs = executionTimeMs;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getMissionId() {
        return missionId;
    }

    public void setMissionId(int missionId) {
        this.missionId = missionId;
    }

    public String getSelectedOption() {
        return selectedOption;
    }

    public void setSelectedOption(String selectedOption) {
        this.selectedOption = selectedOption;
    }

    public boolean isCorrect() {
        return isCorrect;
    }

    public void setCorrect(boolean isCorrect) {
        this.isCorrect = isCorrect;
    }

    public int getXpAwarded() {
        return xpAwarded;
    }

    public void setXpAwarded(int xpAwarded) {
        this.xpAwarded = xpAwarded;
    }

    public Timestamp getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(Timestamp submittedAt) {
        this.submittedAt = submittedAt;
    }

    public String getType() {
        return type != null ? type : "mcq";
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getSubmittedCode() {
        return submittedCode;
    }

    public void setSubmittedCode(String submittedCode) {
        this.submittedCode = submittedCode;
    }

    public Integer getExecutionTimeMs() {
        return executionTimeMs;
    }

    public void setExecutionTimeMs(Integer executionTimeMs) {
        this.executionTimeMs = executionTimeMs;
    }

    public String getMissionTitle() {
        return missionTitle;
    }

    public void setMissionTitle(String missionTitle) {
        this.missionTitle = missionTitle;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }
}
