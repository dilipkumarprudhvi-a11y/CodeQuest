/**
 * CodeQuest Interactive Neo-Brutalist Pop HUD & Canvas Particle Engine
 */
document.addEventListener('DOMContentLoaded', function() {
    'use strict';

    // 1. Interactive Neo-Brutalist Geometric Canvas Particle Background
    const canvas = document.getElementById('cyber-canvas');
    if (canvas) {
        const ctx = canvas.getContext('2d');
        let width = canvas.width = window.innerWidth;
        let height = canvas.height = window.innerHeight;

        const particles = [];
        const particleCount = Math.min(Math.floor((width * height) / 18000), 45);
        const popColors = ['#FF007F', '#0047FF', '#CCFF00', '#000000', '#FFE600'];

        class NeoParticle {
            constructor() {
                this.x = Math.random() * width;
                this.y = Math.random() * height;
                this.vx = (Math.random() - 0.5) * 0.4;
                this.vy = (Math.random() - 0.5) * 0.4;
                this.radius = Math.random() * 2 + 2;
                this.color = popColors[Math.floor(Math.random() * popColors.length)];
                this.isSquare = Math.random() > 0.6;
            }
            update() {
                this.x += this.vx;
                this.y += this.vy;
                if (this.x < 0 || this.x > width) this.vx *= -1;
                if (this.y < 0 || this.y > height) this.vy *= -1;
            }
            draw() {
                ctx.save();
                ctx.fillStyle = this.color;
                ctx.strokeStyle = '#000000';
                ctx.lineWidth = 1.5;

                if (this.isSquare) {
                    const size = this.radius * 2;
                    ctx.fillRect(this.x - size / 2, this.y - size / 2, size, size);
                    ctx.strokeRect(this.x - size / 2, this.y - size / 2, size, size);
                } else {
                    ctx.beginPath();
                    ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.stroke();
                }
                ctx.restore();
            }
        }

        for (let i = 0; i < particleCount; i++) {
            particles.push(new NeoParticle());
        }

        function animate() {
            ctx.clearRect(0, 0, width, height);

            // Connect nearby nodes with crisp solid lines
            for (let i = 0; i < particles.length; i++) {
                particles[i].update();
                particles[i].draw();

                for (let j = i + 1; j < particles.length; j++) {
                    const dx = particles[i].x - particles[j].x;
                    const dy = particles[i].y - particles[j].y;
                    const dist = Math.sqrt(dx * dx + dy * dy);

                    if (dist < 120) {
                        ctx.beginPath();
                        ctx.moveTo(particles[i].x, particles[i].y);
                        ctx.lineTo(particles[j].x, particles[j].y);
                        ctx.strokeStyle = `rgba(0, 0, 0, ${0.16 * (1 - dist / 120)})`;
                        ctx.lineWidth = 1.2;
                        ctx.stroke();
                    }
                }
            }
            requestAnimationFrame(animate);
        }

        animate();

        window.addEventListener('resize', function() {
            width = canvas.width = window.innerWidth;
            height = canvas.height = window.innerHeight;
        });
    }

    // 2. Interactive Mission Choice Item Selector
    const optionItems = document.querySelectorAll('.option-item');
    optionItems.forEach(item => {
        item.addEventListener('click', function(e) {
            const radio = this.querySelector('input[type="radio"]');
            if (radio && !radio.disabled) {
                radio.checked = true;

                // Remove selected class from sibling options in the same card/form
                const parentCluster = this.closest('.options-cluster');
                if (parentCluster) {
                    parentCluster.querySelectorAll('.option-item').forEach(el => el.classList.remove('selected'));
                }
                this.classList.add('selected');

                if (window.GameAudio && window.GameAudio.playSelect) {
                    window.GameAudio.playSelect();
                }

                // Enable submit button in this card
                const form = this.closest('form');
                if (form) {
                    const submitBtn = form.querySelector('button[type="submit"]');
                    if (submitBtn) {
                        submitBtn.disabled = false;
                        submitBtn.classList.remove('btn-outline');
                        submitBtn.classList.add('btn-primary');
                    }
                }
            }
        });
    });

    // 3. Client-Side Quick Filter Animation (for instant snappy UX)
    const filterPills = document.querySelectorAll('.filter-pill[data-filter]');
    filterPills.forEach(pill => {
        pill.addEventListener('click', function(e) {
            const filterType = this.getAttribute('data-filter-type'); // 'category' or 'difficulty'
            const filterVal = this.getAttribute('data-filter');

            // Visual active toggle
            const siblingGroup = this.parentElement.querySelectorAll('.filter-pill');
            siblingGroup.forEach(p => p.classList.remove('active'));
            this.classList.add('active');

            if (window.GameAudio && window.GameAudio.playBlip) {
                window.GameAudio.playBlip();
            }

            const cards = document.querySelectorAll('.quest-card');
            cards.forEach(card => {
                let match = true;
                if (filterVal && filterVal !== 'All') {
                    const cardVal = card.getAttribute('data-' + filterType);
                    if (cardVal && cardVal.toLowerCase() !== filterVal.toLowerCase()) {
                        match = false;
                    }
                }
                card.style.display = match ? 'flex' : 'none';
            });
        });
    });

    // 4. Toast notifications helper
    window.showToast = function(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = `alert alert-${type}`;
        toast.style.position = 'fixed';
        toast.style.bottom = '25px';
        toast.style.right = '25px';
        toast.style.zIndex = '9999';
        toast.style.boxShadow = '5px 5px 0px #000000';
        toast.textContent = message;
        document.body.appendChild(toast);
        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transition = 'opacity 0.4s ease';
            setTimeout(() => toast.remove(), 400);
        }, 3500);
    };

    // 5. XP Progress Bar smooth fill
    const progressFill = document.querySelector('.progress-fill[data-progress]');
    if (progressFill) {
        const targetPercent = progressFill.getAttribute('data-progress') || 0;
        setTimeout(() => {
            progressFill.style.width = targetPercent + '%';
        }, 150);
    }
});
