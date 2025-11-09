import { VocabMatch } from './match.js';
import { QuizGame } from './quiz.js';
import { MemoryGame } from './memory.js';
import { showConfetti } from '../utils/confetti.js';

export class GameManager {
    constructor() {
        this.currentCategory = null;
        this.currentGame = null;
        this.vocabulary = [];
        
        this.gameSelection = document.getElementById('gameSelection');
        this.gameArea = document.getElementById('gameArea');
    }

    async init(category) {
        this.currentCategory = category;
        document.getElementById('gameTitle').textContent = category.name;
        this.showGameSelection();
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Event delegation for game cards
        this.gameSelection.addEventListener('click', (e) => {
            const card = e.target.closest('.game-card');
            if (card) {
                const gameType = card.dataset.game;
                this.startGame(gameType);
            }
        });
    }

    showGameSelection() {
        this.gameSelection.style.display = 'block';
        this.gameArea.style.display = 'none';
        
        // Load vocabulary
        this.loadVocabulary();
    }

    async loadVocabulary() {
        try {
            const response = await fetch(`api/categories.php?action=vocab&category_id=${this.currentCategory.id}`);
            const data = await response.json();
            this.vocabulary = data.vocabulary || [];
            
            // Validate we have enough vocab
            if (this.vocabulary.length < 6) {
                this.gameArea.innerHTML = `
                    <div class="quiz-results active">
                        <div class="result-icon">⚠️</div>
                        <h2>Nicht genug Vokabeln</h2>
                        <p>Diese Kategorie hat weniger als 6 Vokabeln. Spiel nicht verfügbar.</p>
                        <button class="nav-btn" onclick="window.app.showDashboard()">Zurück</button>
                    </div>
                `;
                this.gameSelection.style.display = 'none';
                this.gameArea.style.display = 'block';
            }
        } catch (error) {
            console.error('Vokabelfehler:', error);
            this.vocabulary = [];
        }
    }

    startGame(type) {
        this.gameSelection.style.display = 'none';
        this.gameArea.style.display = 'block';
        
        // Show loading state
        this.gameArea.innerHTML = '<div class="loading"><i class="fas fa-spinner fa-spin"></i> Spiel wird geladen...</div>';
        
        switch (type) {
            case 'match':
                this.currentGame = new VocabMatch(this.vocabulary, this.currentCategory);
                break;
            case 'quiz':
                this.currentGame = new QuizGame(this.vocabulary, this.currentCategory);
                break;
            case 'memory':
                this.currentGame = new MemoryGame(this.vocabulary, this.currentCategory);
                break;
            default:
                console.error('Unbekannter Spieltyp:', type);
                return;
        }
        
        // Initialize game after a brief delay to show loading
        setTimeout(() => {
            this.currentGame.init();
        }, 300);
    }
}