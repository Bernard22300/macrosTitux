#!/bin/bash
# =============================================================================
# gestion_fonctions.sh - Activer/desactiver des fonctions dans macrosTitux
# =============================================================================

set -e

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJET="$(dirname "$SCRIPTS_DIR")"
SRC="$PROJET/src"
POSSIBLES="$SRC/fonctions/possibles"
ACTIVES="$SRC/fonctions/actives"

ROUGE='\033[0;31m'
VERT='\033[0;32m'
JAUNE='\033[1;33m'
NEUTRE='\033[0m'

echo -e "${JAUNE}[fonctions] Gestion des plugins de fonctions${NEUTRE}"
echo ""

liste_disponibles() {
    echo -e "${JAUNE}=== Fonctions disponibles ===${NEUTRE}"
    if [ ! -d "$POSSIBLES" ]; then
        echo -e "${ROUGE}Erreur: Dossier $POSSIBLES inexistant${NEUTRE}"
        exit 1
    fi
    local trouve=0
    for f in "$POSSIBLES"/*.py; do
        [ -f "$f" ] || continue
        base=$(basename "$f" .py)
        if [ -L "$ACTIVES/$base.py" ]; then
            echo -e "  ${VERT}✓${NEUTRE} $base (active)"
        else
            echo -e "  ☐ $base"
        fi
        trouve=1
    done
    if [ "$trouve" -eq 0 ]; then
        echo "  Aucune fonction disponible"
    fi
}

activer() {
    local nom="$1"
    local source="$POSSIBLES/${nom}.py"
    local dest="$ACTIVES/${nom}.py"
    if [ ! -f "$source" ]; then
        echo -e "${ROUGE}Erreur: Fonction '$nom' introuvable dans $POSSIBLES${NEUTRE}"
        exit 1
    fi
    if [ -e "$dest" ]; then
        echo -e "${ROUGE}Erreur: Fonction '$nom' deja active${NEUTRE}"
        exit 1
    fi
    mkdir -p "$ACTIVES"
    ln -s "../possibles/${nom}.py" "$dest"
    echo -e "${VERT}✓ Activee:${NEUTRE} $nom"
}

desactiver() {
    local nom="$1"
    local dest="$ACTIVES/${nom}.py"
    if [ ! -L "$dest" ]; then
        echo -e "${ROUGE}Erreur: Fonction '$nom' n'est pas active${NEUTRE}"
        exit 1
    fi
    rm "$dest"
    echo -e "${ROUGE}✗ Desactivee:${NEUTRE} $nom"
}

statut() {
    echo -e "${JAUNE}=== Fonctions actives ===${NEUTRE}"
    if [ ! -d "$ACTIVES" ]; then
        echo "Aucune fonction active"
        return
    fi
    local compteur=0
    for f in "$ACTIVES"/*.py; do
        [ -L "$f" ] || continue
        base=$(basename "$f" .py)
        echo -e "  ${VERT}✓${NEUTRE} $base"
        ((compteur++))
    done
    if [ "$compteur" -eq 0 ]; then
        echo "Aucune fonction active"
    else
        echo ""
        echo -e "${VERT}$compteur fonction(s) active(s)${NEUTRE}"
    fi
}

case "$1" in
    liste|--list|-l)
        liste_disponibles
        ;;
    actif|--active|-a)
        statut
        ;;
    activer|--activate)
        if [ -z "$2" ]; then
            echo "Usage: $0 activer <nom_fonction>"
            echo "Exemple: $0 activer date_du_jour"
            exit 1
        fi
        activer "$2"
        ;;
    desactiver|--deactivate)
        if [ -z "$2" ]; then
            echo "Usage: $0 desactiver <nom_fonction>"
            exit 1
        fi
        desactiver "$2"
        ;;
    *)
        echo "Utilisation:"
        echo "  $0 liste             # Liste toutes les fonctions"
        echo "  $0 actif             # Montre les fonctions actives"
        echo "  $0 activer <nom>     # Active une fonction"
        echo "  $0 desactiver <nom>  # Desactive une fonction"
        echo ""
        echo "Exemple:"
        echo "  $0 activer date_du_jour"
        ;;
esac
