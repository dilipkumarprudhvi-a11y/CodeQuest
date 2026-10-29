/**
 * CodeQuest Live Client Engine
 * Provides client-side game state persistence, XP calculation,
 * mission evaluation, and leaderboard synchronization for GitHub Pages live preview.
 */
(function() {
    'use strict';

    // Default Seeded Missions (mirrors database/codequest_db.sql)
    const DEFAULT_MISSIONS = [
        {
            id: 1,
            title: 'String Immutability Protocol',
            description: 'In Java, what occurs in memory when you execute the statement: `String str = "Code"; str = str + "Quest";`?',
            category: 'Java',
            difficulty: 'Easy',
            optionA: 'The existing String object in the string pool is modified in-place',
            optionB: 'A new String object is allocated on the heap, and original "Code" remains unchanged',
            optionC: 'The JVM throws an UnsupportedOperationException at runtime',
            optionD: 'A compile-time error occurs because strings cannot use the + operator',
            correct: 'B',
            xp: 50
        },
        {
            id: 2,
            title: 'JVM Memory Segments',
            description: 'Where are Java object instances and their non-primitive instance variables stored at runtime?',
            category: 'Java',
            difficulty: 'Medium',
            optionA: 'In the Metaspace exclusively',
            optionB: 'In the Thread Execution Stack',
            optionC: 'In the Heap Memory space',
            optionD: 'In the CPU Cache registers directly',
            correct: 'C',
            xp: 75
        },
        {
            id: 3,
            title: 'Servlet Lifecycle Invariant',
            description: 'Which lifecycle method of a Jakarta/Java Servlet is invoked exactly once per servlet instance during its lifecycle?',
            category: 'Java',
            difficulty: 'Easy',
            optionA: 'service()',
            optionB: 'doGet()',
            optionC: 'init()',
            optionD: 'destroy() is called before init()',
            correct: 'C',
            xp: 60
        },
        {
            id: 4,
            title: 'Relational Isolation Anomalies',
            description: 'Which ACID transaction isolation level completely prevents Dirty Reads, Non-repeatable Reads, and Phantom Reads?',
            category: 'SQL',
            difficulty: 'Hard',
            optionA: 'READ COMMITTED',
            optionB: 'READ UNCOMMITTED',
            optionC: 'REPEATABLE READ',
            optionD: 'SERIALIZABLE',
            correct: 'D',
            xp: 100
        },
        {
            id: 5,
            title: 'Aggregation Filtering Boundary',
            description: 'In an SQL query, which clause must be utilized to filter records based on the result of an aggregate function such as COUNT() or AVG()?',
            category: 'SQL',
            difficulty: 'Easy',
            optionA: 'WHERE clause',
            optionB: 'HAVING clause',
            optionC: 'GROUP BY condition',
            optionD: 'ORDER BY filter',
            correct: 'B',
            xp: 50
        },
        {
            id: 6,
            title: 'Indexing B-Tree Mechanics',
            description: 'Why does a clustered index in MySQL InnoDB provide faster primary key lookups compared to secondary indexes?',
            category: 'SQL',
            difficulty: 'Medium',
            optionA: 'Because the leaf nodes of the clustered index contain the actual row data pages directly',
            optionB: 'Because clustered indexes are held entirely in volatile CPU registers',
            optionC: 'Because secondary indexes bypass disk reads completely',
            optionD: 'Because clustered indexes use linear search rather than B+ Trees',
            correct: 'A',
            xp: 80
        },
        {
            id: 7,
            title: 'Dynamic Array Resizing Analysis',
            description: 'What is the amortized time complexity of inserting n elements into an initially empty dynamic array (such as Java ArrayList)?',
            category: 'DSA',
            difficulty: 'Medium',
            optionA: 'O(n^2) due to continuous array reallocations',
            optionB: 'O(1) amortized time per insertion, O(n) total for n elements',
            optionC: 'O(log n) per insertion',
            optionD: 'O(n) per insertion in all scenarios',
            correct: 'B',
            xp: 70
        },
        {
            id: 8,
            title: 'Graph Shortest Path Constraints',
            description: 'Which algorithm finds the single-source shortest path in a weighted directed graph that may contain negative edge weights (assuming no negative cycles)?',
            category: 'DSA',
            difficulty: 'Hard',
            optionA: "Dijkstra's Algorithm with a Fibonacci Heap",
            optionB: 'Breadth-First Search (BFS)',
            optionC: 'Bellman-Ford Algorithm',
            optionD: "Kruskal's Minimum Spanning Tree Algorithm",
            correct: 'C',
            xp: 120
        },
        {
            id: 9,
            title: 'Binary Search Tree In-Order Traversal',
            description: 'Performing an in-order traversal (Left, Root, Right) on a valid Binary Search Tree produces values in which order?',
            category: 'DSA',
            difficulty: 'Easy',
            optionA: 'Random order depending on heap memory allocation',
            optionB: 'Strictly ascending (sorted) order',
            optionC: 'Strictly descending order',
            optionD: 'Level-by-level breadth-first order',
            correct: 'B',
            xp: 50
        }
    ];

    // Seeded Competitors for Leaderboard
    const DEFAULT_PLAYERS = [
        { username: 'CyberKnight', email: 'knight@matrix.io', xp: 320, level: 3, role: 'Warrior' },
        { username: 'NeonCoder', email: 'neon@byte.dev', xp: 250, level: 3, role: 'Warrior' },
        { username: 'BinaryPhantom', email: 'phantom@kernel.org', xp: 180, level: 2, role: 'Warrior' },
        { username: 'ZeroDay', email: 'zeroday@sec.net', xp: 110, level: 2, role: 'Warrior' },
        { username: 'AlgoWiz', email: 'algowiz@code.edu', xp: 50, level: 1, role: 'Warrior' }
    ];

    // Progression Tier Calculator
    function calculateTier(xp) {
        if (xp >= 700) return { level: 5, title: 'Cyber Grandmaster', minXp: 700, nextXp: 1000 };
        if (xp >= 450) return { level: 4, title: 'Algorithm Master', minXp: 450, nextXp: 700 };
        if (xp >= 250) return { level: 3, title: 'Binary Knight', minXp: 250, nextXp: 450 };
        if (xp >= 100) return { level: 2, title: 'Code Trooper', minXp: 100, nextXp: 250 };
        return { level: 1, title: 'Novice Cadet', minXp: 0, nextXp: 100 };
    }

    // Storage Helpers
    function getStoredUser() {
        const data = localStorage.getItem('cq_current_user');
        if (data) {
            try { return JSON.parse(data); } catch(e) {}
        }
        // Default guest user
        const guest = {
            id: 99,
            username: 'Cadet_Dilip',
            email: 'dilip@codequest.dev',
            xp: 120,
            level: 2,
            submissions: {}
        };
        localStorage.setItem('cq_current_user', JSON.stringify(guest));
        return guest;
    }

    function saveUser(user) {
        localStorage.setItem('cq_current_user', JSON.stringify(user));
    }

    function getAllPlayers() {
        const currentUser = getStoredUser();
        let list = [...DEFAULT_PLAYERS];
        const existingIdx = list.findIndex(p => p.username.toLowerCase() === currentUser.username.toLowerCase());
        if (existingIdx >= 0) {
            list[existingIdx] = { ...list[existingIdx], xp: currentUser.xp, level: currentUser.level };
        } else {
            list.push({
                username: currentUser.username,
                email: currentUser.email,
                xp: currentUser.xp,
                level: currentUser.level,
                role: 'Warrior'
            });
        }
        return list.sort((a, b) => b.xp - a.xp);
    }

    // Public API
    window.CodeQuestEngine = {
        getMissions: function() {
            return DEFAULT_MISSIONS;
        },
        getCurrentUser: function() {
            return getStoredUser();
        },
        calculateTier: calculateTier,
        getLeaderboard: function() {
            return getAllPlayers();
        },
        login: function(username, password) {
            let user = getStoredUser();
            user.username = username || 'WarriorCadet';
            saveUser(user);
            return user;
        },
        logout: function() {
            localStorage.removeItem('cq_current_user');
            window.location.href = 'index.html';
        },
        submitMission: function(missionId, optionChar) {
            const user = getStoredUser();
            if (!user.submissions) user.submissions = {};

            if (user.submissions[missionId]) {
                return {
                    status: 'ALREADY_SUBMITTED',
                    message: 'Mission already attempted! In accordance with CodeQuest protocols, each challenge permits exactly one submission.',
                    submission: user.submissions[missionId]
                };
            }

            const mission = DEFAULT_MISSIONS.find(m => m.id === Number(missionId));
            if (!mission) return { status: 'ERROR', message: 'Mission not found.' };

            const isCorrect = (optionChar.toUpperCase() === mission.correct);
            const xpGained = isCorrect ? mission.xp : 0;
            const oldLevel = user.level;

            user.xp += xpGained;
            const tierInfo = calculateTier(user.xp);
            user.level = tierInfo.level;

            const submissionRecord = {
                missionId: mission.id,
                title: mission.title,
                category: mission.category,
                selectedOption: optionChar.toUpperCase(),
                correctOption: mission.correct,
                isCorrect: isCorrect,
                xpAwarded: xpGained,
                timestamp: new Date().toISOString()
            };

            user.submissions[missionId] = submissionRecord;
            saveUser(user);

            const leveledUp = (user.level > oldLevel);

            return {
                status: 'SUCCESS',
                isCorrect: isCorrect,
                xpAwarded: xpGained,
                totalXp: user.xp,
                newLevel: user.level,
                leveledUp: leveledUp,
                tierTitle: tierInfo.title,
                correctOption: mission.correct,
                selectedOption: optionChar.toUpperCase()
            };
        }
    };
})();
