/**
 * CodeQuest Web Audio Synthesizer
 * Zero external audio assets needed - synthesized in realtime via Web Audio API.
 */
(function() {
    let audioCtx = null;
    let isMuted = false;

    // Read cookie for persistent mute state
    const match = document.cookie.match(new RegExp('(^| )codequest_muted=([^;]+)'));
    if (match && match[2] === 'true') {
        isMuted = true;
    }

    function initAudio() {
        if (!audioCtx) {
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            if (AudioContext) {
                audioCtx = new AudioContext();
            }
        }
        if (audioCtx && audioCtx.state === 'suspended') {
            audioCtx.resume();
        }
    }

    // Expose sound functions globally
    window.GameAudio = {
        isMuted: function() {
            return isMuted;
        },
        toggleMute: function() {
            isMuted = !isMuted;
            document.cookie = "codequest_muted=" + isMuted + "; path=/; max-age=" + (30 * 24 * 60 * 60);
            const btn = document.getElementById('sound-toggle-btn');
            if (btn) {
                btn.classList.toggle('muted', isMuted);
                btn.title = isMuted ? "Sound: Off (Click to unmute)" : "Sound: On (Click to mute)";
                btn.innerHTML = isMuted ? '🔇' : '🔊';
            }
            return isMuted;
        },
        playBlip: function() {
            if (isMuted) return;
            initAudio();
            if (!audioCtx) return;
            try {
                const osc = audioCtx.createOscillator();
                const gain = audioCtx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(440, audioCtx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(880, audioCtx.currentTime + 0.08);
                gain.gain.setValueAtTime(0.04, audioCtx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.08);
                osc.connect(gain);
                gain.connect(audioCtx.destination);
                osc.start();
                osc.stop(audioCtx.currentTime + 0.08);
            } catch (e) {}
        },
        playSelect: function() {
            if (isMuted) return;
            initAudio();
            if (!audioCtx) return;
            try {
                const osc = audioCtx.createOscillator();
                const gain = audioCtx.createGain();
                osc.type = 'triangle';
                osc.frequency.setValueAtTime(587.33, audioCtx.currentTime); // D5
                osc.frequency.setValueAtTime(880, audioCtx.currentTime + 0.05); // A5
                gain.gain.setValueAtTime(0.06, audioCtx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.12);
                osc.connect(gain);
                gain.connect(audioCtx.destination);
                osc.start();
                osc.stop(audioCtx.currentTime + 0.12);
            } catch (e) {}
        },
        playSuccess: function() {
            if (isMuted) return;
            initAudio();
            if (!audioCtx) return;
            try {
                const notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6 triumphant chord
                notes.forEach((freq, idx) => {
                    const osc = audioCtx.createOscillator();
                    const gain = audioCtx.createGain();
                    osc.type = 'triangle';
                    osc.frequency.setValueAtTime(freq, audioCtx.currentTime + (idx * 0.08));
                    gain.gain.setValueAtTime(0.08, audioCtx.currentTime + (idx * 0.08));
                    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + (idx * 0.08) + 0.35);
                    osc.connect(gain);
                    gain.connect(audioCtx.destination);
                    osc.start(audioCtx.currentTime + (idx * 0.08));
                    osc.stop(audioCtx.currentTime + (idx * 0.08) + 0.35);
                });
            } catch (e) {}
        },
        playError: function() {
            if (isMuted) return;
            initAudio();
            if (!audioCtx) return;
            try {
                const osc = audioCtx.createOscillator();
                const gain = audioCtx.createGain();
                osc.type = 'sawtooth';
                osc.frequency.setValueAtTime(160, audioCtx.currentTime);
                osc.frequency.linearRampToValueAtTime(110, audioCtx.currentTime + 0.22);
                gain.gain.setValueAtTime(0.08, audioCtx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.22);
                osc.connect(gain);
                gain.connect(audioCtx.destination);
                osc.start();
                osc.stop(audioCtx.currentTime + 0.22);
            } catch (e) {}
        },
        playLevelUp: function() {
            if (isMuted) return;
            initAudio();
            if (!audioCtx) return;
            try {
                const notes = [440, 554.37, 659.25, 880, 1108.73, 1318.51]; // A major fanfare
                notes.forEach((freq, idx) => {
                    const osc = audioCtx.createOscillator();
                    const gain = audioCtx.createGain();
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(freq, audioCtx.currentTime + (idx * 0.09));
                    gain.gain.setValueAtTime(0.09, audioCtx.currentTime + (idx * 0.09));
                    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + (idx * 0.09) + 0.45);
                    osc.connect(gain);
                    gain.connect(audioCtx.destination);
                    osc.start(audioCtx.currentTime + (idx * 0.09));
                    osc.stop(audioCtx.currentTime + (idx * 0.09) + 0.45);
                });
            } catch (e) {}
        }
    };

    // Auto-bind sound toggle button if present
    document.addEventListener('DOMContentLoaded', function() {
        const btn = document.getElementById('sound-toggle-btn');
        if (btn) {
            btn.classList.toggle('muted', isMuted);
            btn.title = isMuted ? "Sound: Off (Click to unmute)" : "Sound: On (Click to mute)";
            btn.innerHTML = isMuted ? '🔇' : '🔊';
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                initAudio();
                window.GameAudio.toggleMute();
            });
        }

        // Attach subtle hover sounds to buttons
        const hoverables = document.querySelectorAll('.btn, .nav-links a, .filter-pill');
        hoverables.forEach(el => {
            el.addEventListener('mouseenter', () => {
                window.GameAudio.playBlip();
            });
        });
    });
})();

