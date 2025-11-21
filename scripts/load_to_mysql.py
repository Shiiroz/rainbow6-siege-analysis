# ═══════════════════════════════════════════════════════════════════════════
# 🗄️ CHARGEMENT DES DONNÉES DANS MYSQL
# ═══════════════════════════════════════════════════════════════════════════
# Ce script charge les données nettoyées dans la base MySQL
# ═══════════════════════════════════════════════════════════════════════════

import pandas as pd
import mysql.connector
from mysql.connector import Error
from pathlib import Path
import os
from datetime import datetime

# ═══════════════════════════════════════════════════════════════════════════
# ⚙️ CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

# 🔧 Paramètres de connexion MySQL
# ⚠️ MODIFIE CES VALEURS SELON TA CONFIGURATION
MYSQL_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Ryan@59215',  
    'database': 'r6siege_db',
    'port': 3306
}

# 📁 Chemin vers les données nettoyées
DATA_PATH = Path("data/processed/r6siege_cleaned.csv")


# ═══════════════════════════════════════════════════════════════════════════
# 🔌 FONCTIONS DE CONNEXION
# ═══════════════════════════════════════════════════════════════════════════

def create_connection():
    """
    Crée une connexion à la base de données MySQL.
    
    Returns:
    --------
    connection : mysql.connector.connection ou None
    """
    try:
        connection = mysql.connector.connect(**MYSQL_CONFIG)
        if connection.is_connected():
            print("✅ Connexion à MySQL réussie !")
            db_info = connection.get_server_info()
            print(f"   Version MySQL : {db_info}")
            return connection
    except Error as e:
        print(f"❌ Erreur de connexion : {e}")
        return None


def close_connection(connection):
    """Ferme la connexion MySQL."""
    if connection and connection.is_connected():
        connection.close()
        print("🔌 Connexion MySQL fermée")


# ═══════════════════════════════════════════════════════════════════════════
# 📥 FONCTION DE CHARGEMENT
# ═══════════════════════════════════════════════════════════════════════════

def load_data_to_mysql(csv_path, connection, table_name='player_stats', batch_size=5000):
    """
    Charge les données CSV dans MySQL par lots.
    
    Parameters:
    -----------
    csv_path : Path
        Chemin vers le fichier CSV
    connection : mysql.connector.connection
        Connexion MySQL active
    table_name : str
        Nom de la table cible
    batch_size : int
        Nombre de lignes par lot (pour éviter les timeouts)
    """
    
    print("\n" + "="*70)
    print("📥 CHARGEMENT DES DONNÉES DANS MYSQL")
    print("="*70)
    
    # ─────────────────────────────────────────────────────────────────────────
    # ÉTAPE 1 : Charger le CSV
    # ─────────────────────────────────────────────────────────────────────────
    print(f"\n⏳ Chargement du fichier : {csv_path}")
    
    df = pd.read_csv(csv_path)
    
    print(f"✅ {len(df):,} lignes chargées")
    print(f"📊 Colonnes : {len(df.columns)}")
    
    # ─────────────────────────────────────────────────────────────────────────
    # ÉTAPE 2 : Préparer les données
    # ─────────────────────────────────────────────────────────────────────────
    print("\n⏳ Préparation des données...")
    
    # Remplacer les NaN par None (pour MySQL)
    df = df.where(pd.notnull(df), None)
    
    # Convertir les colonnes datetime si nécessaire
    if 'match_date' in df.columns:
        df['match_date'] = pd.to_datetime(df['match_date'], errors='coerce')
        df['match_date'] = df['match_date'].dt.strftime('%Y-%m-%d')
    
    print("✅ Données préparées")
    
    # ─────────────────────────────────────────────────────────────────────────
    # ÉTAPE 3 : Générer la requête INSERT
    # ─────────────────────────────────────────────────────────────────────────
    
    # Colonnes à insérer (exclure 'id' car auto-increment)
    columns = [col for col in df.columns if col != 'id']
    
    # Créer la requête INSERT
    placeholders = ', '.join(['%s'] * len(columns))
    columns_str = ', '.join(columns)
    
    insert_query = f"""
        INSERT INTO {table_name} ({columns_str})
        VALUES ({placeholders})
    """
    
    # ─────────────────────────────────────────────────────────────────────────
    # ÉTAPE 4 : Insérer les données par lots
    # ─────────────────────────────────────────────────────────────────────────
    print(f"\n⏳ Insertion des données (par lots de {batch_size:,})...")
    
    cursor = connection.cursor()
    
    total_rows = len(df)
    inserted_rows = 0
    start_time = datetime.now()
    
    try:
        for i in range(0, total_rows, batch_size):
            # Extraire le lot
            batch = df.iloc[i:i+batch_size]
            
            # Convertir en liste de tuples
            data = [tuple(row) for row in batch[columns].values]
            
            # Exécuter l'insertion
            cursor.executemany(insert_query, data)
            connection.commit()
            
            inserted_rows += len(batch)
            progress = (inserted_rows / total_rows) * 100
            
            print(f"   📊 Progression : {inserted_rows:,}/{total_rows:,} ({progress:.1f}%)")
        
        # Temps d'exécution
        elapsed_time = (datetime.now() - start_time).total_seconds()
        
        print("\n" + "-"*70)
        print(f"✅ CHARGEMENT TERMINÉ !")
        print(f"   📊 Lignes insérées : {inserted_rows:,}")
        print(f"   ⏱️  Temps d'exécution : {elapsed_time:.2f} secondes")
        print(f"   🚀 Vitesse : {inserted_rows/elapsed_time:.0f} lignes/seconde")
        
    except Error as e:
        print(f"❌ Erreur lors de l'insertion : {e}")
        connection.rollback()
    
    finally:
        cursor.close()
    
    print("="*70)


# ═══════════════════════════════════════════════════════════════════════════
# 🔍 FONCTION DE VÉRIFICATION
# ═══════════════════════════════════════════════════════════════════════════

def verify_data(connection, table_name='player_stats'):
    """
    Vérifie les données chargées dans MySQL.
    """
    
    print("\n" + "="*70)
    print("🔍 VÉRIFICATION DES DONNÉES")
    print("="*70)
    
    cursor = connection.cursor()
    
    try:
        # Compter les lignes
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        print(f"\n📊 Nombre de lignes : {count:,}")
        
        # Aperçu des premières lignes
        cursor.execute(f"SELECT * FROM {table_name} LIMIT 5")
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        
        print(f"\n📋 Aperçu (5 premières lignes) :")
        df_preview = pd.DataFrame(rows, columns=columns)
        print(df_preview.to_string())
        
        # Statistiques rapides
        print(f"\n📈 Statistiques rapides :")
        
        cursor.execute(f"SELECT COUNT(DISTINCT match_id) FROM {table_name}")
        n_matches = cursor.fetchone()[0]
        print(f"   • Matchs uniques : {n_matches:,}")
        
        cursor.execute(f"SELECT COUNT(DISTINCT operator_name) FROM {table_name}")
        n_operators = cursor.fetchone()[0]
        print(f"   • Opérateurs uniques : {n_operators:,}")
        
        cursor.execute(f"SELECT AVG(nb_kills) FROM {table_name}")
        avg_kills = cursor.fetchone()[0]
        print(f"   • Moyenne de kills : {avg_kills:.2f}")
        
        cursor.execute(f"SELECT AVG(has_won) * 100 FROM {table_name}")
        win_rate = cursor.fetchone()[0]
        print(f"   • Taux de victoire : {win_rate:.2f}%")
        
    except Error as e:
        print(f"❌ Erreur : {e}")
    
    finally:
        cursor.close()
    
    print("="*70)


# ═══════════════════════════════════════════════════════════════════════════
# 🚀 EXÉCUTION PRINCIPALE
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    
    print("\n")
    print("╔" + "═"*68 + "╗")
    print("║" + " "*68 + "║")
    print("║" + "🎮 RAINBOW SIX SIEGE - IMPORT MYSQL".center(68) + "║")
    print("║" + " "*68 + "║")
    print("╚" + "═"*68 + "╝")
    
    # Vérifier que le fichier CSV existe
    if not DATA_PATH.exists():
        print(f"\n❌ Fichier non trouvé : {DATA_PATH}")
        print("💡 Exécute d'abord le notebook de nettoyage !")
        exit(1)
    
    # Créer la connexion
    connection = create_connection()
    
    if connection:
        # Charger les données
        load_data_to_mysql(DATA_PATH, connection)
        
        # Vérifier les données
        verify_data(connection)
        
        # Fermer la connexion
        close_connection(connection)
    
    print("\n🎉 Processus terminé !")