/**
 * CodeQuest Web Audio Synthesizer
 * Zero external audio assets needed - synthesized in realtime via Web Audio API.
 * Uses lazy gesture-triggered initialization to comply with browser autoplay policies.
 */
(function() {
    'use strict';

    let audioCtx = null;
    let isMuted = false;

    // Standardized single localStorage key
    try {
        isMuted = localStorage.getItem('codequest_muted') === 'true';
    } catch (e) {
        isMuted = false;
    }

    function initAudio() {
        if (isMuted) return null;
        try {
            if (!audioCtx) {
                const AudioContextClass = window.AudioContext || window.webkitAudioContext;
                if (AudioContextClass) {
                    audioCtx = new AudioContextClass();
                }
            }
            if (audioCtx && audioCtx.state === 'suspended') {
                audioCtx.resume();
            }
        } catch (e) {
            console.warn('[AudioSynth] AudioContext init prevented:', e);
        }
        return audioCtx;
    }

    // Lazy resume on first user gesture anywhere on the page
    function setupGestureUnlock() {
        const unlock = function() {
            if (audioCtx && audioCtx.state === 'suspended') {
                audioCtx.resume();
            }
            document.removeEventListener('pointerdown', unlock);
            document.removeEventListener('keydown', unlock);
        };
        document.addEventListener('pointerdown', unlock, { passive: true, once: true });
        document.addEventListener('keydown', unlock, { passive: true, once: true });
    }
    setupGestureUnlock();

    // Expose sound functions globally
    window.GameAudio = {
        isMuted: function() {
            return isMuted;
        },
        toggleMute: function() {
            isMuted = !isMuted;
            try {
                localStorage.setItem('codequest_muted', isMuted ? 'true' : 'false');
            } catch (e) {}

            const btn = document.getElementById('sound-toggle-btn');
            if (btn) {
                btn.classList.toggle('muted', isMuted);
                btn.title = isMuted ? "Sound: Off (Click to unmute)" : "Sound: On (Click to mute)";
                btn.innerHTML = isMuted ? 'MUTED' : 'AUDIO';
            }
            return isMuted;
        },
        playBlip: function() {
            if (isMuted) return;
            const ctx = initAudio();
            if (!ctx) return;
            try {
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(440, ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(880, ctx.currentTime + 0.08);
                gain.gain.setValueAtTime(0.04, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.08);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start();
                osc.stop(ctx.currentTime + 0.08);
            } catch (e) {}
        },
        playSelect: function() {
            if (isMuted) return;
            const ctx = initAudio();
            if (!ctx) return;
            try {
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'triangle';
                osc.frequency.setValueAtTime(587.33, ctx.currentTime);
                osc.frequency.setValueAtTime(880, ctx.currentTime + 0.05);
                gain.gain.setValueAtTime(0.06, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.12);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start();
                osc.stop(ctx.currentTime + 0.12);
            } catch (e) {}
        },
        playSuccess: function() {
            if (isMuted) return;
            const ctx = initAudio();
            if (!ctx) return;
            try {
                const notes = [523.25, 659.25, 783.99, 1046.50];
                notes.forEach((freq, idx) => {
                    const osc = ctx.createOscillator();
                    const gain = ctx.createGain();
                    osc.type = 'triangle';
                    osc.frequency.setValueAtTime(freq, ctx.currentTime + (idx * 0.08));
                    gain.gain.setValueAtTime(0.08, ctx.currentTime + (idx * 0.08));
                    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + (idx * 0.08) + 0.35);
                    osc.connect(gain);
                    gain.connect(ctx.destination);
                    osc.start(ctx.currentTime + (idx * 0.08));
                    osc.stop(ctx.currentTime + (idx * 0.08) + 0.35);
                });
            } catch (e) {}
        },
        playVictory: function() {
            this.playSuccess();
        },
        playError: function() {
            if (isMuted) return;
            const ctx = initAudio();
            if (!ctx) return;
            try {
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'sawtooth';
                osc.frequency.setValueAtTime(160, ctx.currentTime);
                osc.frequency.linearRampToValueAtTime(110, ctx.currentTime + 0.22);
                gain.gain.setValueAtTime(0.08, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.22);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start();
                osc.stop(ctx.currentTime + 0.22);
            } catch (e) {}
        },
        playDefeat: function() {
            this.playError();
        },
        playLevelUp: function() {
            if (isMuted) return;
            const ctx = initAudio();
            if (!ctx) return;
            try {
                const notes = [440, 554.37, 659.25, 880, 1108.73, 1318.51];
                notes.forEach((freq, idx) => {
                    const osc = ctx.createOscillator();
                    const gain = ctx.createGain();
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(freq, ctx.currentTime + (idx * 0.09));
                    gain.gain.setValueAtTime(0.09, ctx.currentTime + (idx * 0.09));
                    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + (idx * 0.09) + 0.45);
                    osc.connect(gain);
                    gain.connect(ctx.destination);
                    osc.start(ctx.currentTime + (idx * 0.09));
                    osc.stop(ctx.currentTime + (idx * 0.09) + 0.45);
                });
            } catch (e) {}
        }
    };

    // Auto-bind sound toggle button across any page
    document.addEventListener('DOMContentLoaded', function() {
        const btn = document.getElementById('sound-toggle-btn');
        if (btn) {
            btn.classList.toggle('muted', isMuted);
            btn.title = isMuted ? "Sound: Off (Click to unmute)" : "Sound: On (Click to mute)";
            btn.innerHTML = isMuted ? 'MUTED' : 'AUDIO';
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                initAudio();
                window.GameAudio.toggleMute();
            });
        }

        // Attach subtle hover sounds only after user has interacted
        const hoverables = document.querySelectorAll('.btn, .nav-links a, .filter-pill');
        hoverables.forEach(el => {
            el.addEventListener('mouseenter', () => {
                if (audioCtx && audioCtx.state === 'running' && !isMuted) {
                    window.GameAudio.playBlip();
                }
            });
        });
    });
})();
