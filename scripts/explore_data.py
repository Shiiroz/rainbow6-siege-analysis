import pandas as pd
import os

def explore_dataset():
    """Explore le dataset R6 Siege téléchargé"""
    
    raw_path = "data/raw"
    
    # Lister tous les fichiers CSV
    csv_files = [f for f in os.listdir(raw_path) if f.endswith('.csv')]
    
    print(f"📊 {len(csv_files)} fichier(s) CSV trouvé(s)\n")
    print("="*70)
    
    for file in csv_files:
        filepath = os.path.join(raw_path, file)
        size_mb = os.path.getsize(filepath) / (1024**2)
        
        print(f"\n📄 Fichier : {file}")
        print(f"💾 Taille : {size_mb:.2f} MB")
        
        # Charger un échantillon (10000 lignes pour ne pas saturer la RAM)
        print("⏳ Chargement d'un échantillon...")
        df = pd.read_csv(filepath, nrows=10000)
        
        print(f"📏 Dimensions : {len(df):,} lignes × {len(df.columns)} colonnes (échantillon)")
        
        print("\n🔍 Aperçu des colonnes :")
        print(df.dtypes)
        
        print("\n📈 Premières lignes :")
        print(df.head(3))
        
        print("\n📊 Statistiques descriptives :")
        print(df.describe())
        
        print("\n❓ Valeurs manquantes :")
        missing = df.isnull().sum()
        if missing.sum() > 0:
            print(missing[missing > 0])
        else:
            print("✅ Aucune valeur manquante !")
        
        print("\n" + "="*70)

if __name__ == "__main__":
    explore_dataset()