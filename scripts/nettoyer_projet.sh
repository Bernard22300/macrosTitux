#!/bin/bash
# nettoyer_projet.sh - Supprime les fichiers non necessaires au fonctionnement du projet
# Usage : ./scripts/nettoyer_projet.sh

PROJET="/Data/Compte/Bernard_ROLLAND/Développement/macrosTitux"

echo "=============================================="
echo "  NETTOYAGE DU PROJET macrosTitux"
echo "=============================================="
echo ""

# Liste des fichiers a supprimer
declare -a A_SUPPRIMER=()

# --- Cache Python ---
while IFS= read -r -d '' f; do
    A_SUPPRIMER+=("$f")
done < <(find "$PROJET" -type d -name "__pycache__" -print0)

while IFS= read -r -d '' f; do
    A_SUPPRIMER+=("$f")
done < <(find "$PROJET" -name "*.pyc" -print0)

# --- Fichiers temporaires editeur ---
while IFS= read -r -d '' f; do
    A_SUPPRIMER+=("$f")
done < <(find "$PROJET" -name "*.kate-swp" -print0)

while IFS= read -r -d '' f; do
    A_SUPPRIMER+=("$f")
done < <(find "$PROJET" -name "*.swp" -print0)

while IFS= read -r -d '' f; do
    A_SUPPRIMER+=("$f")
done < <(find "$PROJET" -name "*~" -print0)

# --- Scripts one-shot de migration et correction ---
SCRIPTS_ONE_SHOT=(
    "$PROJET/scripts/migrer_vers_bloc_fonctions.sh"
)

for f in "${SCRIPTS_ONE_SHOT[@]}"; do
    if [ -f "$f" ]; then
        A_SUPPRIMER+=("$f")
    fi
done

# --- Afficher la liste ---
if [ ${#A_SUPPRIMER[@]} -eq 0 ]; then
    echo "Rien a nettoyer. Le projet est deja propre."
    exit 0
fi

echo "Fichiers/dossiers a supprimer (${#A_SUPPRIMER[@]}) :"
echo ""
for f in "${A_SUPPRIMER[@]}"; do
    echo "  $f"
done
echo ""

# --- Confirmation ---
read -p "Supprimer ces fichiers ? (oui/non) : " CONFIRMATION

if [ "$CONFIRMATION" != "oui" ]; then
    echo "Nettoyage annule."
    exit 0
fi

# --- Suppression ---
COMPTEUR=0
for f in "${A_SUPPRIMER[@]}"; do
    if [ -d "$f" ]; then
        rm -rf "$f"
        echo "  📁 Supprime: $(basename "$f")/"
    elif [ -f "$f" ]; then
        rm -f "$f"
        echo "  📄 Supprime: $(basename "$f")"
    fi
    COMPTEUR=$((COMPTEUR + 1))
done

echo ""
echo "=============================================="
echo "  NETTOYAGE TERMINE ($COMPTEUR elements supprimes)"
echo "=============================================="
