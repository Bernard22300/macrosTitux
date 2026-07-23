#!/bin/bash
# refondre_projet_complet.sh - Nettoyage radical et création d'une archive propre
# Usage : ./scripts/refondre_projet_complet.sh

set -euo pipefail
PROJET="/Data/Compte/Bernard_ROLLAND/Développement/macrosTitux"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/tmp/macrosTitux_backup"

echo "=============================================="
echo "  REFORMATEMENT RADICAL DU PROJET"
echo "=============================================="
echo ""

# --- 1. Sauvegarde de sécurité avant tout ---
mkdir -p "$BACKUP_DIR"
BACKUP_NAME="$BACKUP_DIR/backup_avant_refonte_${DATE}.tar.gz"
echo "[1/5] Création backup de sécurité : $BACKUP_NAME"
tar czf "$BACKUP_NAME" -C "$(dirname "$PROJET")" "$(basename "$PROJET")" 2>/dev/null
echo "  ✅ Backup créé: $(ls -lh "$BACKUP_NAME" | awk '{print $5}')"
echo ""

# --- 2. Nettoyage des __pycache__ ---
echo "[2/5] Suppression __pycache__ et fichiers temporaires..."
find "$PROJET" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "$PROJET" -name "*.pyc" -delete 2>/dev/null || true
find "$PROJET" -name "*.kate-swp" -delete 2>/dev/null || true
find "$PROJET" -name "*.swp" -delete 2>/dev/null || true
find "$PROJET" -name "*~" -delete 2>/dev/null || true
echo "  ✅ Terminé"
echo ""

# --- 3. Analyse des plugins ambigus ---
echo "[3/5] Analyse des plugins ambigus..."
AMBIGUS=$(grep -rl "Fonction_de_base" "$PROJET/src/fonctions/" --include="*.py" 2>/dev/null || true)
if [ -n "$AMBIGUS" ]; then
    echo "  ⚠️  Fichiers utilisant Fonction_de_base (à clarifier) :"
    echo "$AMBIGUS"
    echo ""
    read -p "Supprimer ces plugins ? (oui/non) : " CONFIRM_AMBIGU
    if [ "$CONFIRM_AMBIGU" = "oui" ]; then
        echo "$AMBIGUS" | while read -r f; do
            rm -f "$f"
            echo "  🗑️  Supprimé: $(basename "$f")"
        done
    else
        echo "  ℹ️  Conserver pour analyse ultérieure"
    fi
fi
echo ""

# --- 4. Vérification de l'archive ---
echo "[4/5] Vérification de l'archive sauvegardée..."
if tar tzf "$BACKUP_NAME" >/dev/null 2>&1; then
    echo "  ✅ Archive valide: $BACKUP_NAME"
else
    echo "  ❌ ERREUR : Archive corrompue !"
    exit 1
fi
echo ""

# --- 5. Résumé ---
echo "=============================================="
echo "  REFONDEMENT TERMINÉ"
echo "=============================================="
echo ""
echo "Backup de sécurité : $BACKUP_NAME"
echo ""
echo "Prochaines étapes recommandées :"
echo "  1. Tester le projet sans les plugins ambigus"
echo "  2. Reconvertir les plugins dans le bon type (Fonction vs Instruction)"
echo "  3. Sauvegarder le résultat propre avec sauvegarder_projet.sh"
echo ""
