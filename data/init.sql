-- SQLite Datenbank für PflegefachProfi

-- Benutzer-Tabelle
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    coins INTEGER DEFAULT 100,
    xp INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Kategorien-Tabelle
CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    icon TEXT NOT NULL,
    color TEXT NOT NULL,
    unlock_cost INTEGER DEFAULT 50
);

-- Vokabeln-Tabelle
CREATE TABLE IF NOT EXISTS vocabulary (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER,
    term TEXT NOT NULL,
    definition TEXT NOT NULL,
    difficulty INTEGER DEFAULT 1,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Benutzer-Fortschritt
CREATE TABLE IF NOT EXISTS user_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    category_id INTEGER,
    game_type TEXT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    high_score INTEGER DEFAULT 0,
    attempts INTEGER DEFAULT 0,
    last_played TIMESTAMP,
    vocab_mastered TEXT DEFAULT '[]',
    reset_count INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Freigeschaltete Kategorien
CREATE TABLE IF NOT EXISTS user_unlocked_categories (
    user_id INTEGER,
    category_id INTEGER,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, category_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Kategorien einfügen
INSERT OR IGNORE INTO categories (key, name, icon, color, unlock_cost) VALUES
('herz_kreislauf', 'Herz und Kreislauf', '❤️', '#e74c3c', 50),
('lungen', 'Lungen', '🫁', '#3498db', 50),
('verdauung', 'Verdauungssystem', '🍽️', '#f39c12', 50),
('nieren', 'Nieren', '💧', '#9b59b6', 50),
('prophylaxen', 'Prophylaxen', '🛡️', '#2ecc71', 50),
('pflegetheorien', 'Pflegetheorien', '📚', '#e67e22', 50),
('expertenstandards', 'Expertenstandards', '⭐', '#34495e', 50);

-- Vokabeln: Herz und Kreislauf
INSERT OR IGNORE INTO vocabulary (category_id, term, definition, difficulty) VALUES
(1, 'Myokardinfarkt', 'Herzinfarkt durch Unterbrechung der Herzkranzgefäß-Durchblutung', 1),
(1, 'Hypotonie', 'Blutdruckabfall (RR systolisch < 100 mmHg)', 1),
(1, 'Hypertonie', 'Bluthochdruck (RR systolisch > 140 mmHg)', 1),
(1, 'Arrhythmie', 'Herzrhythmusstörung', 1),
(1, 'Tachykardie', 'Beschleunigte Herzfrequenz (> 100/min)', 1),
(1, 'Bradykardie', 'Verlangsamte Herzfrequenz (< 60/min)', 1),
(1, 'Herzkatheter', 'Diagnostisches/Invasives Verfahren zur Herzuntersuchung', 2),
(1, 'Stent', 'Gefäßstütze zur Offenhaltung von Arterien', 2),
(1, 'Bypass', 'Umleitung einer verengten Herzkranzarterie', 2),
(1, 'Defibrillator', 'Gerät zur elektrischen Kardioversion', 2);

-- Vokabeln: Lungen
INSERT OR IGNORE INTO vocabulary (category_id, term, definition, difficulty) VALUES
(2, 'Atelektase', 'Lungenkollaps durch Alveolarkollaps', 1),
(2, 'Pneumonie', 'Lungenentzündung', 1),
(2, 'Dyspnoe', 'Atemnot', 1),
(2, 'Trachealkanüle', 'Kunstliche Luftrohre zur Beatmung', 1),
(2, 'Spirometrie', 'Lungenfunktionstest', 1),
(2, 'Beatmung', 'Künstliche Atmungsunterstützung', 1),
(2, 'Sauerstoffsättigung', 'O2-Gehalt im Blut (SpO2)', 1),
(2, 'Thoraxdrainage', 'Brustkorb-Drainage bei Pleuraerguss', 2),
(2, 'Asthma', 'Allergisch-entzündliche Atemwegserkrankung', 1),
(2, 'COPD', 'Chronisch obstruktive Lungenerkrankung', 1);

-- Vokabeln: Verdauungssystem
INSERT OR IGNORE INTO vocabulary (category_id, term, definition, difficulty) VALUES
(3, 'Dysphagie', 'Schluckstörung', 1),
(3, 'PEG-Sonde', 'Perkutane endoskopische Gastrostomie', 2),
(3, 'Stoma', 'Kunstliche Körperöffnung', 1),
(3, 'Kolostoma', 'Künstlicher Dickdarmausgang', 1),
(3, 'Ileus', 'Darmverschluss', 2),
(3, 'Ulkus', 'Geschwür (z.B. Magen-, Duodenalulkus)', 1),
(3, 'Reflux', 'Rückfluss von Magensäure', 1),
(3, 'Magensonde', 'Sonde zur Magenentleerung', 1),
(3, 'Eneralernährung', 'Ernährung über den Darm', 1),
(3, 'Aspiration', 'Inhalation von Sekret/Nahrung', 1);

-- Vokabeln: Nieren
INSERT OR IGNORE INTO vocabulary (category_id, term, definition, difficulty) VALUES
(4, 'Dialyse', 'Künstliche Blutwäsche', 1),
(4, 'Niereninsuffizienz', 'Eingeschränkte Nierenfunktion', 1),
(4, 'Harnwegsinfekt', 'Infektion des Harntrakts (HWI)', 1),
(4, 'Blasenkatheter', 'Dauerkatheter zur Harnableitung', 1),
(4, 'Anurie', 'Harnmangel (< 100 ml/Tag)', 2),
(4, 'Polyurie', 'Harnvermehrung (> 2500 ml/Tag)', 1),
(4, 'Harninkontinenz', 'Unwillkürlicher Harnverlust', 1),
(4, 'Nephrologie', 'Lehre von den Nierenerkrankungen', 1),
(4, 'Harnstau', 'Abflussbehinderung des Harns', 1),
(4, 'Nierenstein', 'Konzrement im Nierenbecken/Harnleiter', 1);

-- Vokabeln: Prophylaxen
INSERT OR IGNORE INTO vocabulary (category_id, term, definition, difficulty) VALUES
(5, 'Dekubitusprophylaxe', 'Maßnahmen zur Druckgeschwürvermeidung', 1),
(5, 'Thromboseprophylaxe', 'Verhinderung von Blutgerinnseln', 1),
(5, 'Pneumonieprophylaxe', 'Vermeidung von Lungenentzündungen', 1),
(5, 'Kontrakturprophylaxe', 'Vorbeugung von Gelenkversteifungen', 1),
(5, 'Stressulzusprophylaxe', 'Vermeidung von Stressgeschwüren', 1),
(5, 'Mobilisation', 'Frühzeitiges Bewegen des Patienten', 1),
(5, 'Lagerung', 'Zielgerichtete Patientenpositionierung', 1),
(5, 'Ulcus cruris', 'Unterschenkelgeschwür (offenes Bein)', 1),
(5, 'Pflegeplanung', 'Individuelle Pflege organisieren', 1),
(5, 'RCM', 'Risikocontrolling und -management', 2);

-- Vokabeln: Pflegetheorien
INSERT OR IGNORE INTO vocabulary (category_id, term, definition, difficulty) VALUES
(6, 'Orem', 'Selbstpflegedefizit-Theorie', 2),
(6, 'Krohwinkel', 'Situationale Pflegediagnose', 2),
(6, 'Peplau', 'Interpersonelle Beziehung', 2),
(6, 'Rogers', 'Science of Unitary Human Beings', 3),
(6, 'Activities of Daily Living', 'Grundaktivitäten des täglichen Lebens', 1),
(6, 'Pflegediagnose', 'Analyse der Pflegebedürftigkeit', 1),
(6, 'Pflegeprozess', 'Systematische Pflegedurchführung', 1),
(6, 'Ressourcen', 'Vorhandene Fähigkeiten des Patienten', 1),
(6, 'Partizipation', 'Einbeziehung des Patienten', 1),
(6, 'Autonomie', 'Selbstbestimmung des Patienten', 1);

-- Vokabeln: Expertenstandards
INSERT OR IGNORE INTO vocabulary (category_id, term, definition, difficulty) VALUES
(7, 'Schmerzmanagement', 'Systematische Schmerzerfassung und -therapie', 1),
(7, 'Ernährung', 'Bedarfsgerechte Ernährungssicherung', 1),
(7, 'Dekubitus', 'Expertenstandard zur Druckgeschwurprophylaxe', 1),
(7, 'Sturzprophylaxe', 'Vermeidung von Patientenstürzen', 1),
(7, 'Demenz', 'Versorgung demenzkranker Menschen', 1),
(7, 'Palliativpflege', 'Begleitung Sterbender', 1),
(7, 'Wundmanagement', 'Professionelle Wundversorgung', 1),
(7, 'Hygiene', 'Hygiene in der Pflege', 1),
(7, 'Medikation', 'Sichere Medikamentengabe', 1),
(7, 'Dokumentation', 'Pflegedokumentation nach DokuKrank', 1);