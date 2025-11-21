-- ═══════════════════════════════════════════════════════════════════════════
-- 🎮 RAINBOW SIX SIEGE - SCHÉMA DE BASE DE DONNÉES
-- ═══════════════════════════════════════════════════════════════════════════
-- Auteur : Ryan
-- Date : 2025
-- Description : Schéma pour stocker les données de matchs R6 Siege Saison 5
-- ═══════════════════════════════════════════════════════════════════════════

-- Supprimer la base si elle existe déjà (ATTENTION : données perdues)
DROP DATABASE IF EXISTS r6siege_db;

-- Créer la base de données
CREATE DATABASE r6siege_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Utiliser la base
USE r6siege_db;

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE 1 : matches
-- Stocke les informations générales des matchs
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE matches (
    match_id BIGINT PRIMARY KEY COMMENT 'ID unique du match',
    date_id INT NOT NULL COMMENT 'Date au format YYYYMMDD',
    match_date DATE COMMENT 'Date convertie au format DATE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de création de l\'enregistrement',
    
    INDEX idx_date (date_id),
    INDEX idx_match_date (match_date)
) ENGINE=InnoDB COMMENT='Table des matchs';

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE 2 : rounds
-- Stocke les informations des rounds de chaque match
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE rounds (
    round_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID unique du round',
    match_id BIGINT NOT NULL COMMENT 'Référence au match',
    round_number TINYINT NOT NULL COMMENT 'Numéro du round (1-9)',
    round_duration SMALLINT NOT NULL COMMENT 'Durée du round en secondes',
    winning_team TINYINT COMMENT 'Équipe gagnante (0 ou 1)',
    
    FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    INDEX idx_match (match_id),
    INDEX idx_round_number (round_number)
) ENGINE=InnoDB COMMENT='Table des rounds';

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE 3 : players_stats
-- Stocke les performances des joueurs par round
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE players_stats (
    stat_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID unique de la stat',
    match_id BIGINT NOT NULL COMMENT 'Référence au match',
    round_number TINYINT NOT NULL COMMENT 'Numéro du round',
    
    -- Informations joueur
    player_hash VARCHAR(64) COMMENT 'Hash du nom du joueur (anonymisé)',
    clearance_level SMALLINT DEFAULT 0 COMMENT 'Niveau du joueur (0-331)',
    team TINYINT NOT NULL COMMENT 'Équipe (0=Défense, 1=Attaque)',
    
    -- Informations opérateur
    operator VARCHAR(50) COMMENT 'Nom de l\'opérateur',
    operator_side ENUM('attack', 'defense') COMMENT 'Côté de l\'opérateur',
    
    -- Performance
    nb_kills TINYINT DEFAULT 0 COMMENT 'Nombre de kills',
    is_dead BOOLEAN DEFAULT FALSE COMMENT 'Le joueur est mort (TRUE) ou vivant (FALSE)',
    has_won BOOLEAN DEFAULT FALSE COMMENT 'Le joueur a gagné le round',
    
    -- Loadout primaire
    primary_weapon VARCHAR(100) COMMENT 'Arme primaire',
    primary_sight VARCHAR(50) COMMENT 'Viseur primaire',
    primary_barrel VARCHAR(50) COMMENT 'Canon primaire',
    primary_grip VARCHAR(50) COMMENT 'Poignée primaire',
    primary_underbarrel VARCHAR(50) COMMENT 'Accessoire sous-canon primaire',
    
    -- Loadout secondaire
    secondary_weapon VARCHAR(100) COMMENT 'Arme secondaire',
    secondary_sight VARCHAR(50) COMMENT 'Viseur secondaire',
    secondary_barrel VARCHAR(50) COMMENT 'Canon secondaire',
    secondary_grip VARCHAR(50) COMMENT 'Poignée secondaire',
    secondary_underbarrel VARCHAR(50) COMMENT 'Accessoire sous-canon secondaire',
    
    -- Gadgets
    gadget VARCHAR(100) COMMENT 'Gadget équipé',
    
    -- Métadonnées
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de création',
    
    FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    INDEX idx_match (match_id),
    INDEX idx_operator (operator),
    INDEX idx_team (team),
    INDEX idx_clearance (clearance_level),
    INDEX idx_kills (nb_kills)
) ENGINE=InnoDB COMMENT='Statistiques détaillées des joueurs par round';

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE 4 : operators
-- Table de référence des opérateurs (pour analyses)
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE operators (
    operator_id INT AUTO_INCREMENT PRIMARY KEY,
    operator_name VARCHAR(50) UNIQUE NOT NULL COMMENT 'Nom de l\'opérateur',
    operator_side ENUM('attack', 'defense') NOT NULL COMMENT 'Côté (attaque/défense)',
    speed_rating TINYINT COMMENT 'Vitesse (1-3)',
    armor_rating TINYINT COMMENT 'Armure (1-3)',
    description TEXT COMMENT 'Description de l\'opérateur',
    
    INDEX idx_side (operator_side)
) ENGINE=InnoDB COMMENT='Table de référence des opérateurs';

-- ═══════════════════════════════════════════════════════════════════════════
-- VUES ANALYTIQUES
-- ═══════════════════════════════════════════════════════════════════════════

-- Vue 1 : Performance par opérateur
CREATE OR REPLACE VIEW v_operator_performance AS
SELECT 
    operator,
    operator_side,
    COUNT(*) as total_rounds,
    SUM(has_won) as wins,
    ROUND(AVG(has_won) * 100, 2) as win_rate,
    ROUND(AVG(nb_kills), 2) as avg_kills,
    ROUND(AVG(is_dead) * 100, 2) as death_rate,
    ROUND(AVG(clearance_level), 0) as avg_player_level
FROM players_stats
WHERE operator IS NOT NULL
GROUP BY operator, operator_side
ORDER BY win_rate DESC;

-- Vue 2 : Performance par niveau de joueur
CREATE OR REPLACE VIEW v_performance_by_level AS
SELECT 
    CASE 
        WHEN clearance_level < 50 THEN 'Débutant (0-49)'
        WHEN clearance_level < 100 THEN 'Intermédiaire (50-99)'
        WHEN clearance_level < 150 THEN 'Avancé (100-149)'
        WHEN clearance_level < 200 THEN 'Expert (150-199)'
        ELSE 'Maître (200+)'
    END as level_category,
    COUNT(*) as total_rounds,
    ROUND(AVG(nb_kills), 2) as avg_kills,
    ROUND(AVG(has_won) * 100, 2) as win_rate,
    ROUND(AVG(is_dead) * 100, 2) as death_rate
FROM players_stats
GROUP BY level_category
ORDER BY MIN(clearance_level);

-- Vue 3 : Loadout populaire par opérateur
CREATE OR REPLACE VIEW v_popular_loadouts AS
SELECT 
    operator,
    primary_weapon,
    primary_sight,
    COUNT(*) as usage_count,
    ROUND(AVG(has_won) * 100, 2) as win_rate_with_loadout
FROM players_stats
WHERE operator IS NOT NULL 
    AND primary_weapon IS NOT NULL
    AND primary_sight IS NOT NULL
GROUP BY operator, primary_weapon, primary_sight
HAVING usage_count > 100
ORDER BY operator, usage_count DESC;

-- ═══════════════════════════════════════════════════════════════════════════
-- PROCÉDURES STOCKÉES
-- ═══════════════════════════════════════════════════════════════════════════

DELIMITER //

-- Procédure : Obtenir les stats d'un opérateur
CREATE PROCEDURE sp_get_operator_stats(IN op_name VARCHAR(50))
BEGIN
    SELECT 
        operator,
        operator_side,
        COUNT(*) as matches_played,
        SUM(has_won) as wins,
        ROUND(AVG(has_won) * 100, 2) as win_rate,
        ROUND(AVG(nb_kills), 2) as avg_kills_per_round,
        ROUND(AVG(CASE WHEN is_dead = 0 THEN 1 ELSE 0 END) * 100, 2) as survival_rate,
        ROUND(AVG(clearance_level), 0) as avg_player_level
    FROM players_stats
    WHERE operator = op_name
    GROUP BY operator, operator_side;
END //

-- Procédure : Top N opérateurs par winrate
CREATE PROCEDURE sp_top_operators(IN top_n INT)
BEGIN
    SELECT 
        operator,
        operator_side,
        COUNT(*) as rounds_played,
        ROUND(AVG(has_won) * 100, 2) as win_rate,
        ROUND(AVG(nb_kills), 2) as avg_kills
    FROM players_stats
    WHERE operator IS NOT NULL
    GROUP BY operator, operator_side
    HAVING rounds_played > 100
    ORDER BY win_rate DESC
    LIMIT top_n;
END //

DELIMITER ;

-- ═══════════════════════════════════════════════════════════════════════════
-- DONNÉES DE TEST (Optionnel)
-- ═══════════════════════════════════════════════════════════════════════════

-- Insérer quelques opérateurs de référence
INSERT INTO operators (operator_name, operator_side, speed_rating, armor_rating, description) VALUES
('Ash', 'attack', 3, 1, 'Attaquante rapide avec lance-grenades explosives'),
('Thermite', 'attack', 2, 2, 'Perceur de murs renforcés avec charges exothermiques'),
('Sledge', 'attack', 2, 2, 'Perceur de surfaces avec son marteau'),
('Jager', 'defense', 3, 1, 'Défenseur avec système de défense active'),
('Bandit', 'defense', 3, 1, 'Électrificateur de murs et barbelés'),
('Rook', 'defense', 1, 3, 'Fournisseur de plaques d\'armure pour l\'équipe');

-- ═══════════════════════════════════════════════════════════════════════════
-- FIN DU SCHÉMA
-- ═══════════════════════════════════════════════════════════════════════════

-- Afficher un résumé
SELECT 'Base de données créée avec succès !' as Status;
SELECT TABLE_NAME, TABLE_COMMENT 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'r6siege_db' 
    AND TABLE_TYPE = 'BASE TABLE';