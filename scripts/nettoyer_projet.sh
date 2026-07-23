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
    "$PROJET/scripts/archiver_projet_pre_refactoring.sh"
    "$PROJET/scripts/completer_generate_bash.sh"
    "$PROJET/scripts/corriger_xml.sh"
    "$PROJET/scripts/creer_macro_test_demo.sh"
    "$PROJET/scripts/fix-gitignore.sh"
    "$PROJET/scripts/fix-projet.sh"
    "$PROJET/scripts/generer_fichiers_manquants.sh"
    "$PROJET/scripts/gestion_fonctions.sh"
    "$PROJET/scripts/implenter_demo_test.sh"
    "$PROJET/scripts/migrer_lot1_donnees.sh"
    "$PROJET/scripts/migrer_lot4_xml.sh"
    "$PROJET/scripts/migrer_widgets_vers_edition.sh"
    "$PROJET/scripts/refactor_modulaire.sh"
    "$PROJET/scripts/refonte_application_nouvelle_architecture.sh"
)

for f in "${SCRIPTS_ONE_SHOT[@]}"; do
    if [ -f "$f" ]; then
        A_SUPPRIMER+=("$f")
    fi
done

# --- Fichiers patch one-shot ---
if [ -f "$PROJET/src/constants_update.patch" ]; then
    A_SUPPRIMER+=("$PROJET/src/constants_update.patch")
fi

# --- Dossier pytest redondant (tests/ existe deja) ---
if [ -d "$PROJET/pytest" ]; then
    A_SUPPRIMER+=("$PROJET/pytest")
fi

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
