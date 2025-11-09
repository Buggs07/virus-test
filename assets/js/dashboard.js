import { updateUserStats } from './utils/user.js';

export class Dashboard {
    constructor() {
        this.categories = [];
        this.container = document.getElementById('pathContainer');
    }

    async load() {
        try {
            const response = await fetch('api/categories.php?action=list');
            const data = await response.json();
            
            if (data.error) {
                console.error('Fehler:', data.error);
                return;
            }
            
            this.categories = data.categories;
            this.render();
        } catch (error) {
            console.error('Ladefehler:', error);
        }
    }

    render() {
        this.container.innerHTML = this.categories.map(category => this.createCard(category)).join('');
        
        // Event Listeners
        document.querySelectorAll('.unlock-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.unlockCategory(e.target.dataset.id));
        });
        
        document.querySelectorAll('.start-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.startCategory(e.target.dataset.id));
        });
    }

    createCard(category) {
        const status = category.unlocked ? 'unlocked' : 'locked';
        const buttonText = category.unlocked ? 'Starten' : `Freischalten für ${category.unlock_cost}`;
        const buttonClass = category.unlocked ? 'start' : 'unlock';
        
        return `
            <div class="path-card ${status}">
                <div class="path-header">
                    <div class="path-icon">
                        ${category.icon}
                    </div>
                    ${!category.unlocked ? `
                        <div class="path-cost">
                            <i class="fas fa-coins"></i>
                            ${category.unlock_cost}
                        </div>
                    ` : ''}
                </div>
                <h3 class="path-title">${category.name}</h3>
                <p class="path-description">Lerne die wichtigsten Vokabeln für ${category.name.toLowerCase()}</p>
                <div class="path-stats">
                    <div class="stat">
                        <span class="stat-value">${category.attempts}</span>
                        <span class="stat-label">Versuche</span>
                    </div>
                    <div class="stat">
                        <span class="stat-value">${category.reset_count}</span>
                        <span class="stat-label">Resets</span>
                    </div>
                    <div class="stat">
                        <span class="stat-value">${category.unlocked ? '✓' : '🔒'}</span>
                        <span class="stat-label">Status</span>
                    </div>
                </div>
                <button class="path-action ${buttonClass} ${category.unlocked ? 'start-btn' : 'unlock-btn'}" 
                        data-id="${category.id}">
                    <i class="fas ${category.unlocked ? 'fa-play' : 'fa-lock-open'}"></i>
                    ${buttonText}
                </button>
            </div>
        `;
    }

    async unlockCategory(categoryId) {
        const button = document.querySelector(`[data-id="${categoryId}"]`);
        button.disabled = true;
        
        const response = await fetch('api/categories.php?action=unlock', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: `category_id=${categoryId}`
        });
        
        const result = await response.json();
        
        if (result.success) {
            await this.load();
            await updateUserStats();
        } else {
            alert('Nicht genug Münzen!');
            button.disabled = false;
        }
    }

    startCategory(categoryId) {
        const category = this.categories.find(c => c.id == categoryId);
        window.app.showGameModule(category);
    }
}