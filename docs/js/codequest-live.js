/**
 * CodeQuest Live Client Engine & Code Execution Sandboxing
 * Full-featured client runtime for CodeQuest: Game-Based Programming Arena.
 * Supports:
 * - Mode A: Interactive Coding Arena with Sandboxed Web Worker & 2000ms loop-guard
 * - Mode B: Rapid Concept MCQ Boss Checks
 * - Strict XP & Level (Level = Math.floor(xp / 100) + 1)
 * - Single-Attempt First-Time XP Bounty with Repeat Practice Mode
 * - Client-Side SHA-256 Authentication & Leaderboard Deterministic Tie-Breaking
 */
(function (window) {
    'use strict';

    // ----------------------------------------------------
    // XSS Sanitization & Utility Helpers
    // ----------------------------------------------------
    function escapeHTML(str) {
        if (str === null || str === undefined) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    async function hashPassword(plainText) {
        if (!plainText) return '';
        try {
            const encoder = new TextEncoder();
            const data = encoder.encode(plainText);
            const hashBuffer = await crypto.subtle.digest('SHA-256', data);
            const hashArray = Array.from(new Uint8Array(hashBuffer));
            return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
        } catch (e) {
            // Fallback for non-secure contexts (e.g. file:// without subtle crypto)
            let hash = 0;
            for (let i = 0; i < plainText.length; i++) {
                hash = ((hash << 5) - hash) + plainText.charCodeAt(i);
                hash |= 0;
            }
            return 'h_' + Math.abs(hash).toString(16);
        }
    }

    // ----------------------------------------------------
    // Default Missions: Mode A (Coding) & Mode B (MCQ)
    // ----------------------------------------------------
    const DEFAULT_MISSIONS = [
        // --- MODE A: CODING CHALLENGES ---
        {
            id: 101,
            type: 'code',
            title: 'Two Sum Algorithm',
            category: 'DSA',
            difficulty: 'Easy',
            xp: 80,
            language: 'javascript',
            functionName: 'twoSum',
            description: 'Given an array of integers `nums` and an integer `target`, return indices of the two numbers such that they add up to `target`. Assume exactly one valid solution exists.',
            starterCode: `function twoSum(nums, target) {
    // Write your solution here
    const map = new Map();
    for (let i = 0; i < nums.length; i++) {
        const complement = target - nums[i];
        if (map.has(complement)) {
            return [map.get(complement), i];
        }
        map.set(nums[i], i);
    }
    return [];
}`,
            testCases: [
                { input: [[2, 7, 11, 15], 9], expected: [0, 1], label: 'nums = [2,7,11,15], target = 9' },
                { input: [[3, 2, 4], 6], expected: [1, 2], label: 'nums = [3,2,4], target = 6' },
                { input: [[3, 3], 6], expected: [0, 1], label: 'nums = [3,3], target = 6' }
            ]
        },
        {
            id: 102,
            type: 'code',
            title: 'Reverse String In-Place',
            category: 'Algorithms',
            difficulty: 'Easy',
            xp: 60,
            language: 'javascript',
            functionName: 'reverseString',
            description: 'Write a function that accepts a string `str` and returns the string reversed. Maintain algorithmic efficiency.',
            starterCode: `function reverseString(str) {
    // Return the reversed string
    return str.split('').reverse().join('');
}`,
            testCases: [
                { input: ['hello'], expected: 'olleh', label: 'str = "hello"' },
                { input: ['CodeQuest'], expected: 'tseuQedoC', label: 'str = "CodeQuest"' },
                { input: ['algorithm'], expected: 'mhtirogla', label: 'str = "algorithm"' }
            ]
        },
        {
            id: 103,
            type: 'code',
            title: 'Valid Anagram Check',
            category: 'DSA',
            difficulty: 'Medium',
            xp: 90,
            language: 'javascript',
            functionName: 'isAnagram',
            description: 'Given two strings `s` and `t`, return `true` if `t` is an anagram of `s`, and `false` otherwise. An Anagram uses the exact same letters.',
            starterCode: `function isAnagram(s, t) {
    if (s.length !== t.length) return false;
    const sortedS = s.split('').sort().join('');
    const sortedT = t.split('').sort().join('');
    return sortedS === sortedT;
}`,
            testCases: [
                { input: ['anagram', 'nagaram'], expected: true, label: 's = "anagram", t = "nagaram"' },
                { input: ['rat', 'car'], expected: false, label: 's = "rat", t = "car"' },
                { input: ['listen', 'silent'], expected: true, label: 's = "listen", t = "silent"' }
            ]
        },
        {
            id: 104,
            type: 'code',
            title: 'Fibonacci Memoization',
            category: 'DSA',
            difficulty: 'Medium',
            xp: 100,
            language: 'javascript',
            functionName: 'fibonacci',
            description: 'Compute the n-th Fibonacci number where F(0)=0, F(1)=1, and F(n)=F(n-1)+F(n-2) for n > 1 in O(n) linear time.',
            starterCode: `function fibonacci(n) {
    if (n <= 0) return 0;
    if (n === 1) return 1;
    let prev = 0, curr = 1;
    for (let i = 2; i <= n; i++) {
        let next = prev + curr;
        prev = curr;
        curr = next;
    }
    return curr;
}`,
            testCases: [
                { input: [2], expected: 1, label: 'n = 2' },
                { input: [6], expected: 8, label: 'n = 6' },
                { input: [10], expected: 55, label: 'n = 10' }
            ]
        },

        // --- MODE B: RAPID CONCEPT BOSS CHECKS (MCQ) ---
        {
            id: 1,
            type: 'mcq',
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
            type: 'mcq',
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
            type: 'mcq',
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
            type: 'mcq',
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
            type: 'mcq',
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
            type: 'mcq',
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
            type: 'mcq',
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
            type: 'mcq',
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
            type: 'mcq',
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

    // Seed Competitor Roster for Global Leaderboard
    const DEFAULT_PLAYERS = [
        { username: 'CyberKnight', email: 'knight@matrix.io', xp: 420, completedMissions: [1, 2, 4, 101, 102], role: 'Warrior' },
        { username: 'NeonCoder', email: 'neon@byte.dev', xp: 330, completedMissions: [1, 5, 101, 103], role: 'Warrior' },
        { username: 'BinaryPhantom', email: 'phantom@kernel.org', xp: 240, completedMissions: [3, 9, 102], role: 'Warrior' },
        { username: 'ZeroDay', email: 'zeroday@sec.net', xp: 170, completedMissions: [7, 101], role: 'Warrior' },
        { username: 'AlgoWiz', email: 'algowiz@code.edu', xp: 80, completedMissions: [101], role: 'Warrior' }
    ];

    // ----------------------------------------------------
    // Strict Progression Engine: Level = Math.floor(xp / 100) + 1
    // ----------------------------------------------------
    function calculateTier(xp) {
        const numericXp = Math.max(0, Number(xp) || 0);
        const level = Math.floor(numericXp / 100) + 1;
        const currentLevelXp = numericXp % 100;
        const xpToNext = 100 - currentLevelXp;
        const progressPercent = currentLevelXp;

        let title = 'Novice Cadet';
        if (level >= 5) title = 'Cyber Grandmaster';
        else if (level === 4) title = 'Algorithm Master';
        else if (level === 3) title = 'Binary Knight';
        else if (level === 2) title = 'Code Trooper';

        return {
            level: level,
            title: title,
            currentLevelXp: currentLevelXp,
            xpToNext: xpToNext,
            progressPercent: progressPercent,
            totalXp: numericXp
        };
    }

    // ----------------------------------------------------
    // Storage Persistence
    // ----------------------------------------------------
    function getStoredMissions() {
        try {
            const raw = localStorage.getItem('codequest_missions') || localStorage.getItem('cq_missions');
            if (raw) {
                const parsed = JSON.parse(raw);
                if (Array.isArray(parsed) && parsed.length > 0) return parsed;
            }
        } catch (e) { }
        saveMissions(DEFAULT_MISSIONS);
        return DEFAULT_MISSIONS;
    }

    function saveMissions(list) {
        try {
            const json = JSON.stringify(list);
            localStorage.setItem('codequest_missions', json);
            localStorage.setItem('cq_missions', json);
        } catch (e) { }
    }

    function getStoredUser() {
        try {
            const raw = localStorage.getItem('codequest_user') || localStorage.getItem('cq_current_user');
            if (raw) {
                const u = JSON.parse(raw);
                if (u && u.username) {
                    u.xp = Number(u.xp) || 0;
                    u.level = Math.floor(u.xp / 100) + 1;
                    u.completedMissions = Array.isArray(u.completedMissions) ? u.completedMissions : [];
                    u.submissions = (u.submissions && typeof u.submissions === 'object') ? u.submissions : {};
                    u.history = Array.isArray(u.history) ? u.history : [];
                    return u;
                }
            }
        } catch (e) { }

        const defaultGuest = {
            id: 1,
            username: 'Cadet_Dilip',
            email: 'dilip@codequest.dev',
            xp: 120,
            level: 2,
            completedMissions: [101, 1],
            submissions: {
                '101': { missionId: 101, isCorrect: true, xpAwarded: 80, timestamp: new Date().toISOString() },
                '1': { missionId: 1, isCorrect: true, xpAwarded: 50, selectedOption: 'B', timestamp: new Date().toISOString() }
            },
            history: [
                { missionId: 101, title: 'Two Sum Algorithm', category: 'DSA', isCorrect: true, xpAwarded: 80, timestamp: new Date().toISOString() },
                { missionId: 1, title: 'String Immutability Protocol', category: 'Java', isCorrect: true, xpAwarded: 50, timestamp: new Date().toISOString() }
            ]
        };
        saveUser(defaultGuest);
        return defaultGuest;
    }

    function saveUser(user) {
        try {
            user.xp = Number(user.xp) || 0;
            user.level = Math.floor(user.xp / 100) + 1;
            const json = JSON.stringify(user);
            localStorage.setItem('codequest_user', json);
            localStorage.setItem('cq_current_user', json);

            // Synchronize with registered users directory
            const regUsers = getRegisteredUsers();
            const idx = regUsers.findIndex(u => u.username.toLowerCase() === user.username.toLowerCase());
            if (idx >= 0) {
                regUsers[idx].xp = user.xp;
                regUsers[idx].level = user.level;
                regUsers[idx].completedMissions = user.completedMissions || [];
            } else {
                regUsers.push({
                    username: user.username,
                    email: user.email,
                    xp: user.xp,
                    level: user.level,
                    completedMissions: user.completedMissions || []
                });
            }
            localStorage.setItem('codequest_registered_users', JSON.stringify(regUsers));
        } catch (e) { }
    }

    function getRegisteredUsers() {
        try {
            const raw = localStorage.getItem('codequest_registered_users');
            if (raw) {
                const list = JSON.parse(raw);
                if (Array.isArray(list)) return list;
            }
        } catch (e) { }
        return [];
    }

    // ----------------------------------------------------
    // Leaderboard Aggregation & Deterministic Tie-Breaking
    // ----------------------------------------------------
    function getLeaderboard() {
        const currentUser = getStoredUser();
        const registered = getRegisteredUsers();

        // Merge defaults, registered users, and active cadet
        const map = new Map();
        DEFAULT_PLAYERS.forEach(p => {
            map.set(p.username.toLowerCase(), {
                username: p.username,
                email: p.email,
                xp: p.xp,
                level: Math.floor(p.xp / 100) + 1,
                completedMissions: p.completedMissions || [],
                role: 'Warrior'
            });
        });

        registered.forEach(r => {
            const existing = map.get(r.username.toLowerCase());
            if (existing) {
                existing.xp = Math.max(existing.xp, r.xp || 0);
                existing.level = Math.floor(existing.xp / 100) + 1;
                existing.completedMissions = r.completedMissions || existing.completedMissions;
            } else {
                map.set(r.username.toLowerCase(), {
                    username: r.username,
                    email: r.email,
                    xp: r.xp || 0,
                    level: Math.floor((r.xp || 0) / 100) + 1,
                    completedMissions: r.completedMissions || [],
                    role: 'Warrior'
                });
            }
        });

        // Always ensure active user is up to date
        map.set(currentUser.username.toLowerCase(), {
            username: currentUser.username,
            email: currentUser.email,
            xp: currentUser.xp,
            level: currentUser.level,
            completedMissions: currentUser.completedMissions || [],
            role: 'Cadet',
            isCurrent: true
        });

        const list = Array.from(map.values());

        // Deterministic sorting:
        // 1. xp DESC
        // 2. completedMissions.length DESC
        // 3. username ASC
        list.sort((a, b) => {
            if (b.xp !== a.xp) return b.xp - a.xp;
            const aComp = (a.completedMissions && a.completedMissions.length) || 0;
            const bComp = (b.completedMissions && b.completedMissions.length) || 0;
            if (bComp !== aComp) return bComp - aComp;
            return a.username.localeCompare(b.username);
        });

        // Assign ranks
        list.forEach((p, idx) => {
            p.rank = idx + 1;
        });

        return list;
    }

    // ----------------------------------------------------
    // Safe In-Browser Sandboxed Web Worker Code Runner
    // ----------------------------------------------------
    function runCodeSandboxed(userCode, functionName, testCases, timeoutMs = 2000) {
        return new Promise((resolve) => {
            const workerCode = `
                function deepEqual(a, b) {
                    if (a === b) return true;
                    if (typeof a !== typeof b) return false;
                    if (typeof a !== 'object' || a === null || b === null) return false;
                    if (Array.isArray(a) !== Array.isArray(b)) return false;
                    const keysA = Object.keys(a), keysB = Object.keys(b);
                    if (keysA.length !== keysB.length) return false;
                    for (let i = 0; i < keysA.length; i++) {
                        const k = keysA[i];
                        if (!deepEqual(a[k], b[k])) return false;
                    }
                    return true;
                }

                // Strip ambient network and storage access from Web Worker environment
    try {
        self.fetch = undefined;
        self.XMLHttpRequest = undefined;
        self.WebSocket = undefined;
        self.EventSource = undefined;
        self.importScripts = undefined;
        self.indexedDB = undefined;
        self.caches = undefined;
    } catch (sandboxErr) {}

    self.onmessage = function(e) {
                    const { code, fnName, testCases } = e.data;
                    const results = [];
                    try {
                        // Safe evaluation of the user's function code
                        const factory = new Function(code + '; if (typeof ' + fnName + ' !== "function") throw new Error("Function ' + fnName + ' is not defined."); return ' + fnName + ';');
                        const userFn = factory();

                        for (let i = 0; i < testCases.length; i++) {
                            const tc = testCases[i];
                            const args = Array.isArray(tc.input) ? tc.input : [tc.input];
                            const tStart = performance.now();
                            // Clone input arguments to prevent mutation interference across test cases
                            const clonedArgs = JSON.parse(JSON.stringify(args));
                            const actual = userFn.apply(null, clonedArgs);
                            const duration = Math.round((performance.now() - tStart) * 100) / 100;
                            const passed = deepEqual(actual, tc.expected);

                            results.push({
                                index: i + 1,
                                label: tc.label || ('Test Case ' + (i + 1)),
                                passed: passed,
                                input: JSON.stringify(tc.input),
                                expected: JSON.stringify(tc.expected),
                                actual: JSON.stringify(actual),
                                timeMs: duration
                            });
                        }
                        self.postMessage({ success: true, results: results });
                    } catch (err) {
                        self.postMessage({ success: false, error: err.message || String(err), results: [] });
                    }
                };
            `;

            let blob;
            try {
                blob = new Blob([workerCode], { type: 'application/javascript' });
            } catch (e) {
                // Inline execution fallback if Blob URL is blocked
                return resolve(runInlineFallback(userCode, functionName, testCases));
            }

            const workerUrl = URL.createObjectURL(blob);
            let worker;
            try {
                worker = new Worker(workerUrl);
            } catch (e) {
                URL.revokeObjectURL(workerUrl);
                return resolve(runInlineFallback(userCode, functionName, testCases));
            }

            let finished = false;
            const timer = setTimeout(() => {
                if (!finished) {
                    finished = true;
                    worker.terminate();
                    URL.revokeObjectURL(workerUrl);
                    resolve({
                        success: false,
                        error: 'Execution Timed Out (2000ms limit). Possible infinite loop or deep recursion detected.',
                        results: []
                    });
                }
            }, timeoutMs);

            worker.onmessage = function (e) {
                if (!finished) {
                    finished = true;
                    clearTimeout(timer);
                    worker.terminate();
                    URL.revokeObjectURL(workerUrl);
                    resolve(e.data);
                }
            };

            worker.onerror = function (err) {
                if (!finished) {
                    finished = true;
                    clearTimeout(timer);
                    worker.terminate();
                    URL.revokeObjectURL(workerUrl);
                    resolve({
                        success: false,
                        error: err.message || 'Worker syntax or runtime evaluation error',
                        results: []
                    });
                }
            };

            worker.postMessage({
                code: userCode,
                fnName: functionName,
                testCases: testCases
            });
        });
    }

    function runInlineFallback(userCode, functionName, testCases) {
        function deepEqual(a, b) {
            if (a === b) return true;
            if (typeof a !== typeof b) return false;
            if (typeof a !== 'object' || a === null || b === null) return false;
            if (Array.isArray(a) !== Array.isArray(b)) return false;
            const keysA = Object.keys(a), keysB = Object.keys(b);
            if (keysA.length !== keysB.length) return false;
            for (let i = 0; i < keysA.length; i++) {
                const k = keysA[i];
                if (!deepEqual(a[k], b[k])) return false;
            }
            return true;
        }

        const results = [];
        try {
            const factory = new Function(userCode + '; if (typeof ' + functionName + ' !== "function") throw new Error("Function ' + functionName + ' is not defined."); return ' + functionName + ';');
            const userFn = factory();
            for (let i = 0; i < testCases.length; i++) {
                const tc = testCases[i];
                const args = Array.isArray(tc.input) ? tc.input : [tc.input];
                const tStart = performance.now();
                const clonedArgs = JSON.parse(JSON.stringify(args));
                const actual = userFn.apply(null, clonedArgs);
                const duration = Math.round((performance.now() - tStart) * 100) / 100;
                const passed = deepEqual(actual, tc.expected);
                results.push({
                    index: i + 1,
                    label: tc.label || ('Test Case ' + (i + 1)),
                    passed: passed,
                    input: JSON.stringify(tc.input),
                    expected: JSON.stringify(tc.expected),
                    actual: JSON.stringify(actual),
                    timeMs: duration
                });
            }
            return { success: true, results: results };
        } catch (err) {
            return { success: false, error: err.message || String(err), results: [] };
        }
    }

    // ----------------------------------------------------
    // Public CodeQuest Engine API
    // ----------------------------------------------------
    window.CodeQuestEngine = {
        escapeHTML: escapeHTML,
        hashPassword: hashPassword,
        calculateTier: calculateTier,

        getMissions: function () {
            return getStoredMissions();
        },

        getCurrentUser: function () {
            return getStoredUser();
        },

        getLeaderboard: function () {
            return getLeaderboard();
        },

        getCurrentUserRank: function () {
            const list = getLeaderboard();
            const current = getStoredUser();
            const found = list.find(p => p.username.toLowerCase() === current.username.toLowerCase());
            return found ? found.rank : list.length;
        },

        login: async function (username, rawPassword) {
            const cleanUser = (username || 'WarriorCadet').trim();
            const user = getStoredUser();
            user.username = cleanUser;
            user.email = `${cleanUser.toLowerCase()}@codequest.dev`;

            // If registered, restore their XP & history
            const regList = getRegisteredUsers();
            const match = regList.find(u => u.username.toLowerCase() === cleanUser.toLowerCase());
            if (match) {
                user.xp = match.xp || 0;
                user.level = Math.floor(user.xp / 100) + 1;
                user.completedMissions = match.completedMissions || [];
            }

            saveUser(user);
            return user;
        },

        register: async function (username, email, rawPassword) {
            const cleanUser = (username || '').trim();
            const cleanEmail = (email || '').trim().toLowerCase();
            const passwordHash = await hashPassword(rawPassword);

            const regList = getRegisteredUsers();
            if (regList.some(u => u.username.toLowerCase() === cleanUser.toLowerCase())) {
                throw new Error('Call-sign already registered! Please choose a unique cadet name.');
            }

            const newUserRecord = {
                id: Date.now(),
                username: cleanUser,
                email: cleanEmail,
                passwordHash: passwordHash,
                xp: 0,
                level: 1,
                completedMissions: []
            };
            regList.push(newUserRecord);
            localStorage.setItem('codequest_registered_users', JSON.stringify(regList));

            const activeUser = {
                id: newUserRecord.id,
                username: cleanUser,
                email: cleanEmail,
                xp: 0,
                level: 1,
                completedMissions: [],
                submissions: {},
                history: []
            };
            saveUser(activeUser);
            return activeUser;
        },

        logout: function () {
            localStorage.removeItem('codequest_user');
            localStorage.removeItem('cq_current_user');
            window.location.href = 'login.html';
        },

        resetProgress: function () {
            const user = getStoredUser();
            user.xp = 0;
            user.level = 1;
            user.completedMissions = [];
            user.submissions = {};
            user.history = [];
            saveUser(user);
            saveMissions(DEFAULT_MISSIONS);
            return user;
        },

        // Mode B: Rapid Concept MCQ Boss Check
        submitMissionMCQ: function (missionId, optionChar) {
            const user = getStoredUser();
            const missions = getStoredMissions();
            const mission = missions.find(m => m.id === Number(missionId));
            if (!mission) return { status: 'ERROR', message: 'Mission protocol not found.' };

            const isAlreadySolved = user.completedMissions.includes(mission.id);
            const isCorrect = (String(optionChar).toUpperCase() === String(mission.correct).toUpperCase());
            const oldLevel = user.level;

            let xpAwarded = 0;
            let message = '';

            if (isCorrect) {
                if (isAlreadySolved) {
                    xpAwarded = 0;
                    message = 'PRACTICE COMPLETE (XP ALREADY CLAIMED)';
                } else {
                    xpAwarded = mission.xp;
                    user.completedMissions.push(mission.id);
                    user.xp = (Number(user.xp) || 0) + xpAwarded;
                    user.level = Math.floor(user.xp / 100) + 1;
                    message = 'FIRST-TIME PROTOCOL CLEARED';
                }
            } else {
                xpAwarded = 0;
                message = 'VERIFICATION FAILED';
            }

            const submissionRecord = {
                missionId: mission.id,
                title: mission.title,
                category: mission.category,
                type: 'mcq',
                selectedOption: String(optionChar).toUpperCase(),
                correctOption: mission.correct,
                isCorrect: isCorrect,
                xpAwarded: xpAwarded,
                alreadyClaimed: isAlreadySolved,
                timestamp: new Date().toISOString()
            };

            user.submissions[mission.id] = submissionRecord;
            user.history.unshift(submissionRecord);
            saveUser(user);

            const tierInfo = calculateTier(user.xp);
            const leveledUp = user.level > oldLevel;

            return {
                status: 'SUCCESS',
                isCorrect: isCorrect,
                alreadyClaimed: isAlreadySolved,
                xpAwarded: xpAwarded,
                totalXp: user.xp,
                newLevel: user.level,
                leveledUp: leveledUp,
                tierTitle: tierInfo.title,
                correctOption: mission.correct,
                selectedOption: String(optionChar).toUpperCase(),
                message: message
            };
        },

        // Mode A: Interactive Coding Challenge
        runCode: function (missionId, userCode) {
            const missions = getStoredMissions();
            const mission = missions.find(m => m.id === Number(missionId));
            if (!mission || mission.type !== 'code') {
                return Promise.resolve({ success: false, error: 'Coding mission not found.' });
            }
            return runCodeSandboxed(userCode, mission.functionName, mission.testCases);
        },

        submitCodeMission: async function (missionId, userCode) {
            const user = getStoredUser();
            const missions = getStoredMissions();
            const mission = missions.find(m => m.id === Number(missionId));
            if (!mission) return { status: 'ERROR', message: 'Mission not found.' };

            const execResult = await runCodeSandboxed(userCode, mission.functionName, mission.testCases);
            if (!execResult.success) {
                return {
                    status: 'RUN_ERROR',
                    isCorrect: false,
                    error: execResult.error,
                    results: []
                };
            }

            const allPassed = execResult.results.length > 0 && execResult.results.every(r => r.passed);
            const isAlreadySolved = user.completedMissions.includes(mission.id);
            const oldLevel = user.level;

            let xpAwarded = 0;
            let message = '';

            if (allPassed) {
                if (isAlreadySolved) {
                    xpAwarded = 0;
                    message = 'PRACTICE COMPLETE (XP ALREADY CLAIMED)';
                } else {
                    xpAwarded = mission.xp;
                    user.completedMissions.push(mission.id);
                    user.xp = (Number(user.xp) || 0) + xpAwarded;
                    user.level = Math.floor(user.xp / 100) + 1;
                    message = 'ALL TEST CASES PASSED - PROTOCOL MASTERED';
                }
            } else {
                xpAwarded = 0;
                message = 'TEST CASES FAILED';
            }

            const submissionRecord = {
                missionId: mission.id,
                title: mission.title,
                category: mission.category,
                type: 'code',
                isCorrect: allPassed,
                xpAwarded: xpAwarded,
                alreadyClaimed: isAlreadySolved,
                submittedCode: userCode,
                timestamp: new Date().toISOString()
            };

            user.submissions[mission.id] = submissionRecord;
            user.history.unshift(submissionRecord);
            saveUser(user);

            const tierInfo = calculateTier(user.xp);
            const leveledUp = user.level > oldLevel;

            return {
                status: 'SUCCESS',
                isCorrect: allPassed,
                alreadyClaimed: isAlreadySolved,
                xpAwarded: xpAwarded,
                totalXp: user.xp,
                newLevel: user.level,
                leveledUp: leveledUp,
                tierTitle: tierInfo.title,
                results: execResult.results,
                message: message
            };
        },

        // Admin Mission Management
        addMission: function (m) {
            const list = getStoredMissions();
            const newId = list.length > 0 ? Math.max(...list.map(x => x.id)) + 1 : 1;
            const isCodeType = m.type === 'code';

            const created = {
                id: newId,
                type: isCodeType ? 'code' : 'mcq',
                title: (m.title || 'Untitled Mission').trim(),
                description: (m.description || '').trim(),
                category: (m.category || 'General').trim(),
                difficulty: m.difficulty || 'Medium',
                xp: Number(m.xp) || 50
            };

            if (isCodeType) {
                created.language = m.language || 'javascript';
                created.functionName = (m.functionName || 'solve').trim();
                created.starterCode = m.starterCode || `function ${created.functionName}() {\n    // Code here\n}`;
                created.testCases = Array.isArray(m.testCases) && m.testCases.length > 0 ? m.testCases : [
                    { input: [1], expected: 1, label: 'Default Test Case' }
                ];
            } else {
                created.optionA = (m.optionA || '').trim();
                created.optionB = (m.optionB || '').trim();
                created.optionC = (m.optionC || '').trim();
                created.optionD = (m.optionD || '').trim();
                created.correct = (m.correct || 'A').toUpperCase().trim();
            }

            list.push(created);
            saveMissions(list);
            return created;
        },

        deleteMission: function (id) {
            let list = getStoredMissions();
            list = list.filter(m => m.id !== Number(id));
            saveMissions(list);
            return list;
        },

        resetDefaultMissions: function () {
            saveMissions(DEFAULT_MISSIONS);
            return DEFAULT_MISSIONS;
        }
    };
})(window);
