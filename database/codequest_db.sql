-- ========================================================
-- CodeQuest: Programming Learning Game Database Schema
-- Database: codequest_db
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

-- 1. Users Table (Students)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    xp INT NOT NULL DEFAULT 0,
    level INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Administrators Table
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Programming Missions Table
CREATE TABLE IF NOT EXISTS missions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,       -- 'Java', 'SQL', 'DSA'
    difficulty VARCHAR(20) NOT NULL,     -- 'Easy', 'Medium', 'Hard'
    option_a VARCHAR(255) NOT NULL,
    option_b VARCHAR(255) NOT NULL,
    option_c VARCHAR(255) NOT NULL,
    option_d VARCHAR(255) NOT NULL,
    correct_option CHAR(1) NOT NULL,     -- 'A', 'B', 'C', or 'D'
    xp_reward INT NOT NULL DEFAULT 50,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. Mission Submissions Table (One-attempt-per-mission enforced via UNIQUE constraint)
CREATE TABLE IF NOT EXISTS mission_submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    mission_id INT NOT NULL,
    selected_option CHAR(1) NOT NULL,
    is_correct BOOLEAN NOT NULL,
    xp_awarded INT NOT NULL DEFAULT 0,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_mission UNIQUE (user_id, mission_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ========================================================
-- Seed Initial Data
-- ========================================================

-- Seed Default Administrator (Credentials: admin / admin123)
INSERT INTO admins (username, password, full_name, email)
SELECT 'admin', 'admin123', 'Chief Game Master', 'admin@codequest.dev'
WHERE NOT EXISTS (SELECT 1 FROM admins WHERE username = 'admin');

-- Seed Initial Diverse Programming Missions
INSERT INTO missions (title, description, category, difficulty, option_a, option_b, option_c, option_d, correct_option, xp_reward)
VALUES 
-- Java Missions
(
    'String Immutability Protocol', 
    'In Java, what occurs in memory when you execute the statement: `String str = "Code"; str = str + "Quest";`?', 
    'Java', 
    'Easy', 
    'The existing String object in the string pool is modified in-place', 
    'A new String object is allocated on the heap, and the original "Code" remains unchanged', 
    'The JVM throws an UnsupportedOperationException at runtime', 
    'A compile-time error occurs because strings cannot use the + operator', 
    'B', 
    50
),
(
    'JVM Memory Segments', 
    'Where are Java object instances and their non-primitive instance variables stored at runtime?', 
    'Java', 
    'Medium', 
    'In the Metaspace exclusively', 
    'In the Thread Execution Stack', 
    'In the Heap Memory space', 
    'In the CPU Cache registers directly', 
    'C', 
    75
),
(
    'Servlet Lifecycle Invariant', 
    'Which lifecycle method of a Jakarta/Java Servlet is invoked exactly once per servlet instance during its lifecycle?', 
    'Java', 
    'Easy', 
    'service()', 
    'doGet()', 
    'init()', 
    'destroy() is called before init()', 
    'C', 
    60
),

-- SQL Missions
(
    'Relational Isolation Anomalies', 
    'Which ACID transaction isolation level completely prevents Dirty Reads, Non-repeatable Reads, and Phantom Reads?', 
    'SQL', 
    'Hard', 
    'READ COMMITTED', 
    'READ UNCOMMITTED', 
    'REPEATABLE READ', 
    'SERIALIZABLE', 
    'D', 
    100
),
(
    'Aggregation Filtering Boundary', 
    'In an SQL query, which clause must be utilized to filter records based on the result of an aggregate function such as COUNT() or AVG()?', 
    'SQL', 
    'Easy', 
    'WHERE clause', 
    'HAVING clause', 
    'GROUP BY condition', 
    'ORDER BY filter', 
    'B', 
    50
),
(
    'Indexing B-Tree Mechanics', 
    'Why does a clustered index in MySQL InnoDB provide faster primary key lookups compared to secondary indexes?', 
    'SQL', 
    'Medium', 
    'Because the leaf nodes of the clustered index contain the actual row data pages directly', 
    'Because clustered indexes are held entirely in volatile CPU registers', 
    'Because secondary indexes bypass disk reads completely', 
    'Because clustered indexes use linear search rather than B+ Trees', 
    'A', 
    80
),

-- DSA Missions
(
    'Dynamic Array Resizing Analysis', 
    'What is the amortized time complexity of inserting n elements into an initially empty dynamic array (such as Java ArrayList)?', 
    'DSA', 
    'Medium', 
    'O(n^2) due to continuous array reallocations', 
    'O(1) amortized time per insertion, O(n) total for n elements', 
    'O(log n) per insertion', 
    'O(n) per insertion in all scenarios', 
    'B', 
    70
),
(
    'Graph Shortest Path Constraints', 
    'Which algorithm finds the single-source shortest path in a weighted directed graph that may contain negative edge weights (assuming no negative cycles)?', 
    'DSA', 
    'Hard', 
    'Dijkstra\'s Algorithm with a Fibonacci Heap', 
    'Breadth-First Search (BFS)', 
    'Bellman-Ford Algorithm', 
    'Kruskal\'s Minimum Spanning Tree Algorithm', 
    'C', 
    120
),
(
    'Binary Search Tree In-Order Traversal', 
    'Performing an in-order traversal (Left, Root, Right) on a valid Binary Search Tree produces values in which order?', 
    'DSA', 
    'Easy', 
    'Random order depending on heap memory allocation', 
    'Strictly ascending (sorted) order', 
    'Strictly descending order', 
    'Level-by-level breadth-first order', 
    'B', 
    50
);

-- Seed Sample Demo Students for Leaderboard Realism
INSERT INTO users (username, email, password, xp, level)
VALUES 
('CyberKnight', 'knight@matrix.io', 'pass123', 320, 3),
('NeonCoder', 'neon@byte.dev', 'pass123', 250, 3),
('BinaryPhantom', 'phantom@kernel.org', 'pass123', 180, 2),
('ZeroDay', 'zeroday@sec.net', 'pass123', 110, 2),
('AlgoWiz', 'algowiz@code.edu', 'pass123', 50, 1)
ON DUPLICATE KEY UPDATE xp = VALUES(xp);
