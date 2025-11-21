# 🎮 Rainbow Six Siege - Data Analysis Project

Analyse complète des données Rainbow Six Siege (Saison 5) : extraction SQL, nettoyage Python et visualisation Power BI.

## 📊 Dataset

**Source** : [Kaggle - Rainbow Six Siege S5 Ranked Dataset](https://www.kaggle.com/datasets/maxcobra/rainbow-six-siege-s5-ranked-dataset)

## 🛠️ Technologies

- **SQL** : MySQL Workbench
- **Python** : Pandas, NumPy, Matplotlib, Seaborn
- **Visualisation** : Power BI
- **Outils** : VSCode, Anaconda, Git

## 📁 Structure du projet
```
rainbow6-siege-analysis/
├── data/
│   ├── raw/          # Données brutes (gitignore)
│   └── processed/    # Données nettoyées
├── sql/
│   ├── schema.sql    # Structure de la base
│   └── queries.sql   # Requêtes d'analyse
├── scripts/
│   ├── download_kaggle_data.py
│   ├── data_cleaning.py
│   └── load_to_mysql.py
├── notebooks/
│   └── exploratory_analysis.ipynb
├── visualizations/
│   └── dashboard.pbix
└── images/           # Screenshots pour README
```

## 🚀 Installation

### 1. Cloner le repository
```bash
git clone https://github.com/TON_USERNAME/rainbow6-siege-analysis.git
cd rainbow6-siege-analysis
```

### 2. Créer l'environnement Python
```bash
conda create -n r6siege python=3.10
conda activate r6siege
pip install -r requirements.txt
```

### 3. Configurer Kaggle API
1. Va sur [kaggle.com/settings](https://www.kaggle.com/settings)
2. Télécharge `kaggle.json`
3. Place-le dans `~/.kaggle/` (Linux/Mac) ou `C:\Users\TON_NOM\.kaggle\` (Windows)

### 4. Télécharger les données
```bash
python scripts/download_kaggle_data.py
```

### 5. Créer la base de données MySQL
```bash
mysql -u root -p < sql/schema.sql
```

### 6. Nettoyer et charger les données
```bash
python scripts/data_cleaning.py
python scripts/load_to_mysql.py
```

## 📈 Analyses réalisées

- ✅ Distribution des rangs des joueurs
- ✅ Taux de victoire par opérateur
- ✅ Corrélation K/D ratio et Win rate
- ✅ Analyse temporelle des performances
- ✅ Méta-game : opérateurs les plus joués

## 🎯 Résultats clés

*(À compléter après l'analyse)*

## 📸 Visualisations

*(Screenshots de ton dashboard Power BI)*

## 📝 Auteur

**Ton Nom**
- LinkedIn : [Ton profil](https://linkedin.com/in/ton-profil)
- GitHub : [@TON_USERNAME](https://github.com/TON_USERNAME)

## 📄 Licence

MIT License