import { VocabMatch } from './match.js';
import { QuizGame } from './quiz.js';
import { MemoryGame } from './memory.js';

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
    }

    showGameSelection() {
        this.gameSelection.style.display = 'block';
        this.gameArea.style.display = 'none';
        
        // Load vocabulary
        this.loadVocabulary();
        
        // Event Listeners
        document.querySelectorAll('.game-card').forEach(card => {
            card.addEventListener('click', (e) => {
                const gameType = e.currentTarget.dataset.game;
                this.startGame(gameType);
            });
        });
    }

    async loadVocabulary() {
        try {
            const response = await fetch(`api/categories.php?action=vocab&category_id=${this.currentCategory.id}`);
            const data = await response.json();
            this.v