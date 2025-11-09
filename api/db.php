<?php
// Datenbank-Verbindung
class Database {
    private static $db = null;

    public static function getConnection() {
        if (self::$db === null) {
            $dbPath = __DIR__ . '/../db/pflege.db';
            $dbDir = dirname($dbPath);
            
            if (!file_exists($dbDir)) {
                mkdir($dbDir, 0777, true);
            }
            
            self::$db = new SQLite3($dbPath);
            self::$db->busyTimeout(5000);
            
            // Enable foreign keys
            self::$db->exec('PRAGMA foreign_keys = ON;');
        }
        return self::$db;
    }
}
?>