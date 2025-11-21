-- ═══════════════════════════════════════════════════════════════════════════
-- 🎮 RAINBOW SIX SIEGE - CRÉATION DE LA BASE DE DONNÉES
-- ═══════════════════════════════════════════════════════════════════════════

-- Supprimer la base si elle existe
DROP DATABASE IF EXISTS r6siege_db;

-- Créer la base de données
CREATE DATABASE r6siege_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Utiliser la base
USE r6siege_db;

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE PRINCIPALE : player_stats
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE player_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date_id INT,
    match_id BIGINT,
    round_number TINYINT,
    round_duration SMALLINT,
    clearance_level SMALLINT,
    team TINYINT,
    has_won TINYINT,
    nb_kills TINYINT,
    is_dead TINYINT,
    operator_name VARCHAR(50),
    operator_side VARCHAR(20),
    primary_weapon VARCHAR(100),
    secondary_weapon VARCHAR(100),
    primary_sight VARCHAR(50),
    primary_barrel VARCHAR(50),
    primary_grip VARCHAR(50),
    primary_underbarrel VARCHAR(50),
    secondary_sight VARCHAR(50),
    secondary_barrel VARCHAR(50),
    secondary_grip VARCHAR(50),
    secondary_underbarrel VARCHAR(50),
    gadget VARCHAR(100),
    level_category VARCHAR(20),
    performance_score TINYINT,
    duration_category VARCHAR(30),
    match_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_match (match_id),
    INDEX idx_operator (operator_name),
    INDEX idx_team (team),
    INDEX idx_level (clearance_level),
    INDEX idx_date (match_date)
) ENGINE=InnoDB;

-- Vérifier la création
SELECT 'Base de donnees r6siege_db creee avec succes !' AS Status;
SHOW TABLES;