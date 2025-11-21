import os
import kaggle
from kaggle.api.kaggle_api_extended import KaggleApi

def download_r6_dataset():
    """Télécharge le dataset R6 Siege depuis Kaggle"""
    
    api = KaggleApi()
    api.authenticate()
    
    dataset_name = "maxcobra/rainbow-six-siege-s5-ranked-dataset"
    download_path = "data/raw"
    
    os.makedirs(download_path, exist_ok=True)
    
    print("📥 Téléchargement du dataset R6 Siege...")
    
    api.dataset_download_files(
        dataset_name,
        path=download_path,
        unzip=True
    )
    
    print("✅ Dataset téléchargé dans data/raw/")
    
    files = os.listdir(download_path)
    print(f"\n📊 {len(files)} fichiers téléchargés:")
    for file in files:
        size = os.path.getsize(os.path.join(download_path, file)) / (1024**2)
        print(f"  - {file} ({size:.2f} MB)")

if __name__ == "__main__":
    download_r6_dataset()