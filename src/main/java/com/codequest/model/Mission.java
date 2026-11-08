package com.codequest.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Mission implements Serializable {
    private static final long serialVersionUID = 2L;

    private int id;
    private String title;
    private String description;
    private String category;    // Java, SQL, DSA, Algorithms
    private String difficulty;  // Easy, Medium, Hard
    private String type = "mcq"; // "code" or "mcq"
    private String functionName;
    private String language = "javascript";
    private String starterCode;
    private String testCases;
    private String optionA;
    private String optionB;
    private String optionC;
    private String optionD;
    private String correctOption; // 'A', 'B', 'C', 'D' (omitted from student presentation)
    private int xpReward;
    private Timestamp createdAt;

    // Additional transient/helper fields for display
    private boolean solved;
    private String userChoice;
    private String submittedCode;

    public Mission() {
    }

    // Legacy constructor for MCQ missions
    public Mission(int id, String title, String description, String category, String difficulty,
                   String optionA, String optionB, String optionC, String optionD,
                   String correctOption, int xpReward, Timestamp createdAt) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.category = category;
        this.difficulty = difficulty;
        this.type = "mcq";
        this.optionA = optionA;
        this.optionB = optionB;
        this.optionC = optionC;
        this.optionD = optionD;
        this.correctOption = correctOption;
        this.xpReward = xpReward;
        this.createdAt = createdAt;
    }

    // Full constructor supporting dual-mode (coding arena + MCQs)
    public Mission(int id, String title, String description, String category, String difficulty,
                   String type, String functionName, String language, String starterCode, String testCases,
                   String optionA, String optionB, String optionC, String optionD,
                   String correctOption, int xpReward, Timestamp createdAt) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.category = category;
        this.difficulty = difficulty;
        this.type = (type != null && !type.trim().isEmpty()) ? type.trim().toLowerCase() : "mcq";
        this.functionName = functionName;
        this.language = (language != null && !language.trim().isEmpty()) ? language.trim().toLowerCase() : "javascript";
        this.starterCode = starterCode;
        this.testCases = testCases;
        this.optionA = optionA;
        this.optionB = optionB;
        this.optionC = optionC;
        this.optionD = optionD;
        this.correctOption = correctOption;
        this.xpReward = xpReward;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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

    public String getType() {
        return type != null ? type : "mcq";
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getFunctionName() {
        return functionName;
    }

    public void setFunctionName(String functionName) {
        this.functionName = functionName;
    }

    public String getLanguage() {
        return language != null ? language : "javascript";
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getStarterCode() {
        return starterCode;
    }

    public void setStarterCode(String starterCode) {
        this.starterCode = starterCode;
    }

    public String getTestCases() {
        return testCases;
    }

    public void setTestCases(String testCases) {
        this.testCases = testCases;
    }

    public String getOptionA() {
        return optionA;
    }

    public void setOptionA(String optionA) {
        this.optionA = optionA;
    }

    public String getOptionB() {
        return optionB;
    }

    public void setOptionB(String optionB) {
        this.optionB = optionB;
    }

    public String getOptionC() {
        return optionC;
    }

    public void setOptionC(String optionC) {
        this.optionC = optionC;
    }

    public String getOptionD() {
        return optionD;
    }

    public void setOptionD(String optionD) {
        this.optionD = optionD;
    }

    public String getCorrectOption() {
        return correctOption;
    }

    public void setCorrectOption(String correctOption) {
        this.correctOption = correctOption;
    }

    public int getXpReward() {
        return xpReward;
    }

    public void setXpReward(int xpReward) {
        this.xpReward = xpReward;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isSolved() {
        return solved;
    }

    public void setSolved(boolean solved) {
        this.solved = solved;
    }

    public String getUserChoice() {
        return userChoice;
    }

    public void setUserChoice(String userChoice) {
        this.userChoice = userChoice;
    }

    public String getSubmittedCode() {
        return submittedCode;
    }

    public void setSubmittedCode(String submittedCode) {
        this.submittedCode = submittedCode;
    }
}
