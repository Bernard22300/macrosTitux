#!/bin/bash
# =============================================================================
# nettoyer_projet.sh - Supprime les fichiers/dossiers inutiles du projet
# macrosTitux - Créé par Bernard Rolland
# =============================================================================

set -e

# Couleurs
ROUGE='\033[0;31m'
VERT='\033[0;32m'
JAUNE='\033[1;33m'
NEUTRE='\033[0m'

PROJET="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJET"

echo -e "${JAUNE}[nettoyage] Démarrage du nettoyage de macrosTitux...${NEUTRE}"
echo -e "${JAUNE}[nettoyage] Projet : $PROJET${NEUTRE}"
echo ""

COMPTEUR=0

# -----------------------------------------------------------------------------
# Fonction : supprimer un fichier s'il existe
# -----------------------------------------------------------------------------
supprimer_fichier() {
    local cible="$1"
    local raison="$2"
    if [ -f "$cible" ]; then
        rm -f "$cible"
        echo -e "  ${VERT}✅ Supprimé${NEUTRE} : $cible ($raison)"
        ((COMPTEUR++))
    fi
}

# -----------------------------------------------------------------------------
# Fonction : supprimer un dossier s'il existe
# -----------------------------------------------------------------------------
supprimer_dossier() {
    local cible="$1"
    local raison="$2"
    if [ -d "$cible" ]; then
        rm -rf "$cible"
        echo -e "  ${VERT}✅ Supprimé${NEUTRE} : $cible/ ($raison)"
        ((COMPTEUR++))
    fi
}

echo "=== 1. Archives et backups locaux ==="
supprimer_fichier "macrosTitux_pre_refactoring_20260721_120941.tar.gz" \
    "archive pré-refactoring, GitHub suffit"
supprimer_fichier "macrosTitux.tar" \
    "archive tar obsolète si présente"

echo ""
echo "=== 2. Cache pytest ==="
supprimer_dossier ".pytest_cache" \
    "cache auto-généré par pytest"
supprimer_dossier "pytest" \
    "dossier vide redondant avec tests/"

echo ""
echo "=== 3. Fichiers de patch déjà appliqués ==="
supprimer_fichier "src/constants_update.patch" \
    "patch déjà appliqué, obsolète"

echo ""
echo "=== 4. Fichiers temporaires et d'échange ==="
find . -name '*.swp' -o -name '*.swo' -o -name '*.kate-swp' -o -name '*~' | while read -r f; do
    rm -f "$f"
    echo -e "  ${VERT}✅ Supprimé${NEUTRE} : $f (fichier temporaire)"
done

echo ""
echo "=== 5. Cache Python __pycache__ ==="
find . -type d -name '__pycache__' | while read -r d; do
    rm -rf "$d"
    echo -e "  ${VERT}✅ Supprimé${NEUTRE} : $d/"
done

echo ""
echo "=== 6. Vérification du .gitignore ==="

FICHIERS_A_IGNORER=(
    "__pycache__/"
    "*.pyc"
    ".pytest_cache/"
    "*.swp"
    "*.swo"
    "*.kate-swp"
    "*~"
    "venv/"
    "*.tar"
    "*.tar.gz"
)

MODIFIE=0
for entree in "${FICHIERS_A_IGNORER[@]}"; do
    if ! grep -qxF "$entree" .gitignore 2>/dev/null; then
        echo "$entree" >> .gitignore
        echo -e "  ${VERT}✅ Ajouté au .gitignore${NEUTRE} : $entree"
        ((MODIFIE++))
    fi
done

if [ "$MODIFIE" -eq 0 ]; then
    echo -e "  ${JAUNE}ℹ️  .gitignore déjà à jour${NEUTRE}"
fi

echo ""
echo "=== 7. Résumé ==="
echo -e "${VERT}[nettoyage] $COMPTEUR fichier(s)/dossier(s) supprimé(s)${NEUTRE}"
echo -e "${VERT}[nettoyage] $MODIFIE entrée(s) ajoutée(s) au .gitignore${NEUTRE}"
echo ""
echo "Structure finale :"
tree -I '__pycache__|.git|*.pyc|venv|*.swp|*.kate-swp'
echo ""
echo -e "${VERT}==========================================${NEUTRE}"
echo -e "${VERT}  NETTOYAGE TERMINÉ${NEUTRE}"
echo -e "${VERT}==========================================${NEUTRE}"
