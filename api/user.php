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

$stmt = $db->prepare("SELECT coins, xp, CAST(xp / 100 + 1 AS INTEGER) as level FROM users WHERE id = ?");
$stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
$result = $stmt->execute();
$user = $result->fetchArray(SQLITE3_ASSOC);

echo json_encode($user);
?>