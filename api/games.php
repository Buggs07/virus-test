<?php
header('Content-Type: application/json');
session_start();

require_once 'db.php';
$db = Database::getConnection();

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Nicht eingeloggt']);
    exit;
}

$user_id = $_SESSION['user_id'];
$action = $_GET['action'] ?? '';

switch ($action) {
    case 'save':
        $category_id = $_POST['category_id'] ?? 0;
        $game_type = $_POST['game_type'] ?? '';
        $score = $_POST['score'] ?? 0;
        $completed = $_POST['completed'] ?? false;
        $vocab_mastered = $_POST['vocab_mastered'] ?? '[]';
        
        // Update user progress
        $stmt = $db->prepare("SELECT id FROM user_progress WHERE user_id = ? AND category_id = ? AND game_type = ?");
        $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
        $stmt->bindValue(2, $category_id, SQLITE3_INTEGER);
        $stmt->bindValue(3, $game_type, SQLITE3_TEXT);
        $result = $stmt->execute();
        $progress = $result->fetchArray();
        
        if ($progress) {
            $stmt = $db->prepare("UPDATE user_progress SET high_score = MAX(high_score, ?), attempts = attempts + 1, last_played = CURRENT_TIMESTAMP, completed = ?, vocab_mastered = ? WHERE id = ?");
            $stmt->bindValue(1, $score, SQLITE3_INTEGER);
            $stmt->bindValue(2, $completed ? 1 : 0, SQLITE3_INTEGER);
            $stmt->bindValue(3, $vocab_mastered, SQLITE3_TEXT);
            $stmt->bindValue(4, $progress['id'], SQLITE3_INTEGER);
        } else {
            $stmt = $db->prepare("INSERT INTO user_progress (user_id, category_id, game_type, high_score, attempts, completed, vocab_mastered) VALUES (?, ?, ?, ?, 1, ?, ?)");
            $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
            $stmt->bindValue(2, $category_id, SQLITE3_INTEGER);
            $stmt->bindValue(3, $game_type, SQLITE3_TEXT);
            $stmt->bindValue(4, $score, SQLITE3_INTEGER);
            $stmt->bindValue(5, $completed ? 1 : 0, SQLITE3_INTEGER);
            $stmt->bindValue(6, $vocab_mastered, SQLITE3_TEXT);
        }
        $stmt->execute();
        
        // Calculate rewards
        $coins_earned = 0;
        $xp_earned = 0;
        
        if ($completed) {
            // Game type specific rewards
            $rewards = [
                'match' => ['coins' => 5, 'xp' => 10],
                'quiz' => ['coins' => 8, 'xp' => 15],
                'memory' => ['coins' => 10, 'xp' => 20]
            ];
            
            $rewards = $rewards[$game_type] ?? ['coins' => 5, 'xp' => 10];
            $coins_earned = $rewards['coins'];
            $xp_earned = $rewards['xp'];
            
            // Update user stats
            $stmt = $db->prepare("UPDATE users SET coins = coins + ?, xp = xp + ?, level = CAST((xp + ?) / 100 + 1 AS INTEGER) WHERE id = ?");
            $stmt->bindValue(1, $coins_earned, SQLITE3_INTEGER);
            $stmt->bindValue(2, $xp_earned, SQLITE3_INTEGER);
            $stmt->bindValue(3, $xp_earned, SQLITE3_INTEGER);
            $stmt->bindValue(4, $user_id, SQLITE3_INTEGER);
            $stmt->execute();
        }
        
        echo json_encode([
            'success' => true,
            'rewards' => [
                'coins' => $coins_earned,
                'xp' => $xp_earned
            ]
        ]);
        break;
        
    case 'reset':
        $category_id = $_POST['category_id'] ?? 0;
        
        // Reset progress for all games in category
        $stmt = $db->prepare("UPDATE user_progress SET completed = 0, vocab_mastered = '[]' WHERE user_id = ? AND category_id = ?");
        $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
        $stmt->bindValue(2, $category_id, SQLITE3_INTEGER);
        $stmt->execute();
        
        // Increase reset count
        $stmt = $db->prepare("SELECT id FROM user_progress WHERE user_id = ? AND category_id = ? AND game_type = 'all'");
        $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
        $stmt->bindValue(2, $category_id, SQLITE3_INTEGER);
        $result = $stmt->execute();
        
        if ($result->fetchArray()) {
            $stmt = $db->prepare("UPDATE user_progress SET reset_count = reset_count + 1 WHERE user_id = ? AND category_id = ? AND game_type = 'all'");
            $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
            $stmt->bindValue(2, $category_id, SQLITE3_INTEGER);
        } else {
            $stmt = $db->prepare("INSERT INTO user_progress (user_id, category_id, game_type, reset_count) VALUES (?, ?, 'all', 1)");
            $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
            $stmt->bindValue(2, $category_id, SQLITE3_INTEGER);
        }
        $stmt->execute();
        
        echo json_encode(['success' => true]);
        break;
}
?>