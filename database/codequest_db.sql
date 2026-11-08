-- ========================================================
-- CodeQuest: Game-Based Programming Arena Database Schema
-- Database: codequest_db (MySQL 8.0+ / InnoDB)
-- Standard: OWASP Hardened, PBKDF2 Password Hashing, Dual-Mode Quests
-- ========================================================

CREATE DATABASE IF NOT EXISTS codequest_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE codequest_db;

-- Drop in foreign-key dependency order for clean recreation
DROP TABLE IF EXISTS mission_submissions;
DROP TABLE IF EXISTS missions;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS admins;

-- 1. Users Table (Cadets)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Standard PBKDF2$65536$[salt]$[hash]
    xp INT NOT NULL DEFAULT 0,
    level INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_users_xp (xp DESC),
    INDEX idx_users_level (level DESC)
) ENGINE=InnoDB;

-- 2. Administrators Table
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Standard PBKDF2$65536$[salt]$[hash]
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Programming Missions Table (Supports Mode A Coding Arena & Mode B Concept Checks)
CREATE TABLE IF NOT EXISTS missions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('code', 'mcq') NOT NULL DEFAULT 'mcq',
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,       -- 'DSA', 'Java', 'SQL', 'Algorithms'
    difficulty VARCHAR(20) NOT NULL,     -- 'Easy', 'Medium', 'Hard'
    xp_reward INT NOT NULL DEFAULT 50,
    
    -- Mode A: Coding Arena Fields
    function_name VARCHAR(100) NULL,
    language VARCHAR(50) DEFAULT 'javascript',
    starter_code TEXT NULL,
    test_cases TEXT NULL,                -- Valid JSON array of input/expected objects
    
    -- Mode B: MCQ Concept Check Fields
    option_a VARCHAR(255) NULL,
    option_b VARCHAR(255) NULL,
    option_c VARCHAR(255) NULL,
    option_d VARCHAR(255) NULL,
    correct_option CHAR(1) NULL,         -- 'A', 'B', 'C', or 'D'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_missions_type (type),
    INDEX idx_missions_cat_diff (category, difficulty)
) ENGINE=InnoDB;

-- 4. Mission Submissions Table (One official attempt per mission enforced via UNIQUE constraint)
CREATE TABLE IF NOT EXISTS mission_submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    mission_id INT NOT NULL,
    type ENUM('code', 'mcq') NOT NULL DEFAULT 'mcq',
    selected_option CHAR(1) NULL,
    submitted_code TEXT NULL,
    execution_time_ms DOUBLE NULL,
    is_correct BOOLEAN NOT NULL,
    xp_awarded INT NOT NULL DEFAULT 0,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_mission UNIQUE (user_id, mission_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE CASCADE,
    INDEX idx_submissions_user_date (user_id, submitted_at DESC)
) ENGINE=InnoDB;

-- ========================================================
-- Seed Initial Data
-- ========================================================

-- Seed Default Administrator (Credentials: admin / admin123, pre-hashed with standard PBKDF2)
INSERT INTO admins (username, password, full_name, email)
SELECT 'admin', 'PBKDF2$65536$vh0v23OvKWBCGqoPGFf22w==$yHInlVZLv5tmmpl4m2w0FA0UbKporwLrCvu09mMmGfk=', 'Chief Game Master', 'admin@codequest.dev'
WHERE NOT EXISTS (SELECT 1 FROM admins WHERE username = 'admin');

-- Seed Mode A: Interactive Coding Challenges
INSERT INTO missions (id, type, title, description, category, difficulty, xp_reward, function_name, language, starter_code, test_cases)
VALUES 
(
    101,
    'code',
    'Two Sum Problem',
    'Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.\n\nYou may assume that each input would have exactly one solution, and you may not use the same element twice.\nReturn the answer with indices sorted in ascending order.',
    'DSA',
    'Easy',
    75,
    'twoSum',
    'javascript',
    'function twoSum(nums, target) {\n    // Write an optimal O(n) solution using a Hash Map\n    const map = new Map();\n    for (let i = 0; i < nums.length; i++) {\n        const complement = target - nums[i];\n        if (map.has(complement)) {\n            return [map.get(complement), i];\n        }\n        map.set(nums[i], i);\n    }\n    return [];\n}',
    '[{"input": [[2, 7, 11, 15], 9], "expected": [0, 1], "label": "Example 1: Basic pair [2, 7]"}, {"input": [[3, 2, 4], 6], "expected": [1, 2], "label": "Example 2: Non-zero index [2, 4]"}, {"input": [[3, 3], 6], "expected": [0, 1], "label": "Example 3: Duplicate values [3, 3]"}]'
),
(
    102,
    'code',
    'Reverse String In-Place',
    'Write a function that reverses a string array in-place with O(1) extra memory.\n\nThe input string is given as an array of characters s. You must do this by modifying the input array in-place with O(1) extra memory.',
    'Algorithms',
    'Easy',
    50,
    'reverseString',
    'javascript',
    'function reverseString(s) {\n    // Two-pointer in-place reversal\n    let left = 0, right = s.length - 1;\n    while (left < right) {\n        const tmp = s[left];\n        s[left] = s[right];\n        s[right] = tmp;\n        left++;\n        right--;\n    }\n    return s;\n}',
    '[{"input": [["h","e","l","l","o"]], "expected": ["o","l","l","e","h"], "label": "Standard word: hello"}, {"input": [["H","a","n","n","a","h"]], "expected": ["h","a","n","n","a","H"], "label": "Palindromic name: Hannah"}]'
),
(
    103,
    'code',
    'Valid Anagram Verification',
    'Given two strings s and t, return true if t is an anagram of s, and false otherwise.\n\nAn Anagram is a word formed by rearranging the letters of a different word using all the original letters exactly once.',
    'DSA',
    'Medium',
    80,
    'isAnagram',
    'javascript',
    'function isAnagram(s, t) {\n    if (s.length !== t.length) return false;\n    const counts = {};\n    for (const c of s) counts[c] = (counts[c] || 0) + 1;\n    for (const c of t) {\n        if (!counts[c]) return false;\n        counts[c]--;\n    }\n    return true;\n}',
    '[{"input": ["anagram", "nagaram"], "expected": true, "label": "Valid anagram: anagram"}, {"input": ["rat", "car"], "expected": false, "label": "Invalid anagram: rat/car"}, {"input": ["aacc", "ccac"], "expected": false, "label": "Frequency mismatch: aacc/ccac"}]'
),
(
    104,
    'code',
    'N-th Fibonacci Number',
    'The Fibonacci numbers form a sequence where F(0) = 0, F(1) = 1, and F(n) = F(n - 1) + F(n - 2) for n > 1.\n\nGiven n, compute F(n) in O(n) time and O(1) space.',
    'Algorithms',
    'Medium',
    90,
    'fib',
    'javascript',
    'function fib(n) {\n    if (n <= 0) return 0;\n    if (n === 1) return 1;\n    let prev2 = 0, prev1 = 1;\n    for (let i = 2; i <= n; i++) {\n        const curr = prev1 + prev2;\n        prev2 = prev1;\n        prev1 = curr;\n    }\n    return prev1;\n}',
    '[{"input": [0], "expected": 0, "label": "Base case: F(0) = 0"}, {"input": [1], "expected": 1, "label": "Base case: F(1) = 1"}, {"input": [4], "expected": 3, "label": "F(4) = 3"}, {"input": [10], "expected": 55, "label": "F(10) = 55"}]'
);

-- Seed Mode B: Rapid Concept Boss Checks (Multiple Choice)
INSERT INTO missions (id, type, title, description, category, difficulty, xp_reward, option_a, option_b, option_c, option_d, correct_option)
VALUES 
(
    1,
    'mcq',
    'String Immutability Protocol', 
    'In Java, what occurs in memory when you execute: `String str = "Code"; str = str + "Quest";`?', 
    'Java', 
    'Easy', 
    50,
    'The existing String object in the string pool is modified in-place', 
    'A new String object is allocated on the heap, and original "Code" remains unchanged', 
    'The JVM throws an UnsupportedOperationException at runtime', 
    'A compile-time error occurs because strings cannot use the + operator', 
    'B'
),
(
    2,
    'mcq',
    'JVM Memory Segments', 
    'Where are Java object instances and their non-primitive instance variables stored at runtime?', 
    'Java', 
    'Medium', 
    75,
    'In the Metaspace exclusively', 
    'In the Thread Execution Stack', 
    'In the Heap Memory space', 
    'In the CPU Cache registers directly', 
    'C'
),
(
    3,
    'mcq',
    'Servlet Lifecycle Invariant', 
    'Which lifecycle method of a Jakarta/Java Servlet is invoked exactly once per servlet instance during its lifecycle?', 
    'Java', 
    'Easy', 
    60,
    'service()', 
    'doGet()', 
    'init()', 
    'destroy() is called before init()', 
    'C'
),
(
    4,
    'mcq',
    'Relational Isolation Anomalies', 
    'Which ACID transaction isolation level completely prevents Dirty Reads, Non-repeatable Reads, and Phantom Reads?', 
    'SQL', 
    'Hard', 
    100,
    'READ COMMITTED', 
    'READ UNCOMMITTED', 
    'REPEATABLE READ', 
    'SERIALIZABLE', 
    'D'
),
(
    5,
    'mcq',
    'Aggregation Filtering Boundary', 
    'In an SQL query, which clause must be utilized to filter records based on the result of an aggregate function such as COUNT() or AVG()?', 
    'SQL', 
    'Easy', 
    50,
    'WHERE clause', 
    'HAVING clause', 
    'GROUP BY condition', 
    'ORDER BY filter', 
    'B'
),
(
    6,
    'mcq',
    'Indexing B-Tree Mechanics', 
    'Why does a clustered index in MySQL InnoDB provide faster primary key lookups compared to secondary indexes?', 
    'SQL', 
    'Medium', 
    80,
    'Because the leaf nodes of the clustered index contain the actual row data pages directly', 
    'Because clustered indexes are held entirely in volatile CPU registers', 
    'Because secondary indexes bypass disk reads completely', 
    'Because clustered indexes use linear search rather than B+ Trees', 
    'A'
),
(
    7,
    'mcq',
    'Dynamic Array Resizing Analysis', 
    'What is the amortized time complexity of inserting n elements into an initially empty dynamic array (such as Java ArrayList)?', 
    'DSA', 
    'Medium', 
    70,
    'O(n^2) due to continuous array reallocations', 
    'O(1) amortized time per insertion, O(n) total for n elements', 
    'O(log n) per insertion', 
    'O(n) per insertion in all scenarios', 
    'B'
),
(
    8,
    'mcq',
    'Graph Shortest Path Constraints', 
    'Which algorithm finds the single-source shortest path in a weighted directed graph that may contain negative edge weights (assuming no negative cycles)?', 
    'DSA', 
    'Hard', 
    120,
    'Dijkstra\'s Algorithm with a Fibonacci Heap', 
    'Breadth-First Search (BFS)', 
    'Bellman-Ford Algorithm', 
    'Kruskal\'s Minimum Spanning Tree Algorithm', 
    'C'
),
(
    9,
    'mcq',
    'Binary Search Tree In-Order Traversal', 
    'Performing an in-order traversal (Left, Root, Right) on a valid Binary Search Tree produces values in which order?', 
    'DSA', 
    'Easy', 
    50,
    'Random order depending on heap memory allocation', 
    'Strictly ascending (sorted) order', 
    'Strictly descending order', 
    'Level-by-level breadth-first order', 
    'B'
);

-- Seed Sample Demo Cadets with PBKDF2 Hashed Passwords ('pass123')
INSERT INTO users (username, email, password, xp, level)
VALUES 
('CyberKnight', 'knight@matrix.io', 'PBKDF2$65536$+4iEAU9r3r1tBRpSmaEy9Q==$6dT4eDC1b9/wn6qGy6nZTQTXxhpH467oR5X48nP0nL0=', 420, 5),
('NeonCoder', 'neon@byte.dev', 'PBKDF2$65536$+4iEAU9r3r1tBRpSmaEy9Q==$6dT4eDC1b9/wn6qGy6nZTQTXxhpH467oR5X48nP0nL0=', 350, 4),
('BinaryPhantom', 'phantom@kernel.org', 'PBKDF2$65536$+4iEAU9r3r1tBRpSmaEy9Q==$6dT4eDC1b9/wn6qGy6nZTQTXxhpH467oR5X48nP0nL0=', 220, 3),
('ZeroDay', 'zeroday@sec.net', 'PBKDF2$65536$+4iEAU9r3r1tBRpSmaEy9Q==$6dT4eDC1b9/wn6qGy6nZTQTXxhpH467oR5X48nP0nL0=', 140, 2),
('AlgoWiz', 'algowiz@code.edu', 'PBKDF2$65536$+4iEAU9r3r1tBRpSmaEy9Q==$6dT4eDC1b9/wn6qGy6nZTQTXxhpH467oR5X48nP0nL0=', 60, 1)
ON DUPLICATE KEY UPDATE xp = VALUES(xp);
