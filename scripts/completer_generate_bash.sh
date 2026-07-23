#!/bin/bash
# =============================================================================
# completer_generate_bash.sh
# Implémente toutes les actions bash pour macrosTitux
# =============================================================================

set -e

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJET="$(dirname "$SCRIPTS_DIR")"
SRC="$PROJET/src"

ROUGE='\033[0;31m'
VERT='\033[0;32m'
JAUNE='\033[1;33m'
NEUTRE='\033[0m'

echo -e "${JAUNE}[bash] Génération du fichier generate_bash.sh${NEUTRE}"

cat > "$SRC/generate_bash.sh" <<'BASH_SCRIPT'
#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: generate_bash.sh
# Description: Convertit un XML de macro en script Bash exécutable
# Version: 1.0
# Licence: GPL-3.0
#------------------------------------------------------------------------------

set -e

# Vérification des arguments
if [ $# -lt 2 ]; then
    echo "Utilisation: $0 <fichier_xml> <fichier_sortie>"
    echo "Exemple: $0 ~/.config/macrosTitux/macros/test.xml ./test.sh"
    exit 1
fi

FICHIER_XML="$1"
FICHIER_SORTIE="$2"

# Vérification que le fichier XML existe
if [ ! -f "$FICHIER_XML" ]; then
    echo "Erreur: Fichier XML introuvable: $FICHIER_XML"
    exit 1
fi

echo "=== Conversion XML → Bash ==="
echo "Entrée : $FICHIER_XML"
echo "Sortie : $FICHIER_SORTIE"
echo ""

# Extraction du nom de la macro
NOM_MACRO=$(xmllint --xpath "string(/macro/@name)" "$FICHIER_XML" 2>/dev/null || echo "Macro_Sans_Nom")

echo "Macro: $NOM_MACRO"
echo ""

# Création du script de sortie
cat > "$FICHIER_SORTIE" <<HEADER
#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Macro: $NOM_MACRO
# Généré le: $(date '+%Y-%m-%d %H:%M:%S')
# Source XML: $FICHIER_XML
#------------------------------------------------------------------------------
set -e

# Variable pour le résultat
RESULTAT=""

HEADER

# ------------------------------------------------------------------------------
# SECTION 1: DÉCLENCHEURS
# ------------------------------------------------------------------------------
echo "=== Traitement des déclencheurs ==="

# Déclencheur DEMARRAGE_APP
if xmllint --xpath "//declencheur[@type='DEMARRAGE_APP']" "$FICHIER_XML" >/dev/null 2>&1; then
    DELAI=$(xmllint --xpath "string(//declencheur[@type='DEMARRAGE_APP']/config/parametre[@key='delai']/@value)" "$FICHIER_XML" 2>/dev/null || echo "0")
    
    cat >> "$FICHIER_SORTIE" <<DEMARRAGE

# === DÉCLENCHEUR: Démarrage application ===
echo "[Démarrage] Initialisation de la macro '$NOM_MACRO'..."
sleep $DELAI
echo "[Démarrage] Exécution initiée."

DEMARRAGE
    echo "  ✓ Déclencheur DEMARRAGE_APP (délai: ${DELAI}s)"
else
    echo "  ⚠ Aucun déclencheur trouvé (la macro s'exécutera immédiatement)"
fi

echo ""

# ------------------------------------------------------------------------------
# SECTION 2: VARIABLES
# ------------------------------------------------------------------------------
echo "=== Traitement des variables ==="

# Initialisation des variables
if xmllint --xpath "//variables" "$FICHIER_XML" >/dev/null 2>&1; then
    echo '# Variables' >> "$FICHIER_SORTIE"
    echo '' >> "$FICHIER_SORTIE"
    
    while IFS= read -r ligne; do
        if [ -n "$ligne" ]; then
            NOM_VAR=$(echo "$ligne" | sed 's/.*name="\([^"]*\)".*/\1/')
            VALEUR=$(echo "$ligne" | sed 's/.*value="\([^"]*\)".*/\1/')
            
            if [ -z "$VALEUR" ]; then
                echo "# Variable $NOM_VAR (à définir)" >> "$FICHIER_SORTIE"
            else
                echo "$NOM_VAR=\"$VALEUR\"" >> "$FICHIER_SORTIE"
            fi
        fi
    done < <(xmllint --xpath "//variables/variable" "$FICHIER_XML" 2>/dev/null | tr '\n' '\r' | tr '<variable' '\n' | grep -o '<variable[^>]*>')
    
    echo "" >> "$FICHIER_SORTIE"
    echo "  ✓ Variables déclarées"
fi

echo ""

# ------------------------------------------------------------------------------
# SECTION 3: CONTRAINTES
# ------------------------------------------------------------------------------
echo "=== Traitement des contraintes ==="

if xmllint --xpath "//contraintes/contrainte" "$FICHIER_XML" >/dev/null 2>&1; then
    cat >> "$FICHIER_SORTIE" <<CONTRAINTES

# === CONTRAINTES ===

CONTRAINTES
    
    while IFS= read -r type_contrainte; do
        if [ -n "$type_contrainte" ]; then
            TYPE=$(echo "$type_contrainte" | sed 's/.*type="\([^"]*\)".*/\1/')
            LABEL=$(echo "$type_contrainte" | sed 's/.*label="\([^"]*\)".*/\1/')
            
            case "$TYPE" in
                "ESPACE_DISQUE")
                    MIN_ESPACE=$(echo "$type_contrainte" | sed 's/.*espace_minimum="\([^"]*\)".*/\1/')
                    MIN_ESPACE=${MIN_ESPACE:-10}
                    
                    cat >> "$FICHIER_SORTIE" <<ESPACE

# Contrainte: Espace disque ($LABEL)
echo "[Contrôle] Vérification de l'espace disque (min: ${MIN_ESPACE} Go)..."
ESPACE_LIBRE=\$(df /home | tail -1 | awk '{print \$4}')
ESPACE_GB=\$((\$ESPACE_LIBRE / 1024 / 1024))
if [ \$ESPACE_GB -lt $MIN_ESPACE ]; then
    echo "[Erreur] Espace insuffisant: \$ESPACE_GB Go disponible (min requis: $MIN_ESPACE Go)"
    exit 1
fi
echo "[Contrôle] Espace OK: \$ESPACE_GB Go disponible."

ESPACE
                    ;;
                
                "PLAGE_HORAIRE")
                    HEURE_DEBUT=$(echo "$type_contrainte" | sed 's/.*heure_debut="\([^"]*\)".*/\1/')
                    HEURE_FIN=$(echo "$type_contrainte" | sed 's/.*heure_fin="\([^"]*\)".*/\1/')
                    HEURE_DEBUT=${HEURE_DEBUT:-0800}
                    HEURE_FIN=${HEURE_FIN:-1800}
                    
                    cat >> "$FICHIER_SORTIE" <<HORRAIRE

# Contrainte: Plage horaire ($LABEL)
echo "[Contrôle] Vérification de la plage horaire (${HEURE_DEBUT}-${HEURE_FIN})..."
HEURE_ACTUELLE=\$(date +%H%M)
if [[ \$HEURE_ACTUELLE -lt $HEURE_DEBUT ]] || [[ \$HEURE_ACTUELLE -gt $HEURE_FIN ]]; then
    echo "[Erreur] Hors plage horaire actuelle (\$HEURE_ACTUELLE)"
    exit 1
fi
echo "[Contrôle] Plage horaire OK (\$HEURE_ACTUELLE)."

HORRAIRE
                    ;;
                
                "PROCESSUS_ACTIF")
                    PROCESSUS=$(echo "$type_contrainte" | sed 's/.*processus="\([^"]*\)".*/\1/')
                    PROCESSUS=${PROCESSUS:-firefox}
                    
                    cat >> "$FICHIER_SORTIE" <<PROC

# Contrainte: Processus actif ($LABEL)
echo "[Contrôle] Vérification du processus: $PROCESSUS..."
if ! pgrep -x "$PROCESSUS" > /dev/null; then
    echo "[Erreur] Processus $PROCESSUS non actif"
    exit 1
fi
echo "[Contrôle] Processus $PROCESSUS actif."

PROC
                    ;;
                
                *)
                    echo "  ⚠ Contrainte non reconnue: $TYPE"
                    ;;
            esac
        fi
    done < <(xmllint --xpath "//contraintes/contrainte" "$FICHIER_XML" 2>/dev/null | tr '\n' '\r' | tr '<contrainte' '\n' | grep -o '<contrainte[^>]*>')
    
    echo "  ✓ Contraintes ajoutées"
else
    echo "  ℹ Aucune contrainte définie"
fi

echo ""

# ------------------------------------------------------------------------------
# SECTION 4: ACTIONS
# ------------------------------------------------------------------------------
echo "=== Traitement des actions ==="

# Section d'en-tête pour les actions
cat >> "$FICHIER_SORTIE" <<ACTIONS_HEADER

# === ACTIONS ===

ACTIONS_HEADER

if xmllint --xpath "//actions/action" "$FICHIER_XML" >/dev/null 2>&1; then
    ID_ACTION=0
    
    while IFS= read -r action_line; do
        if [ -n "$action_line" ]; then
            ((ID_ACTION++))
            TYPE_ACTION=$(echo "$action_line" | sed 's/.*type="\([^"]*\)".*/\1/')
            LABEL_ACTION=$(echo "$action_line" | sed 's/.*label="\([^"]*\)".*/\1/')
            
            echo "  Processing action #$ID_ACTION: $TYPE_ACTION ($LABEL_ACTION)"
            
            case "$TYPE_ACTION" in
                "NOTIFIER")
                    TITRE=$(echo "$action_line" | sed -n 's/.*titre="\([^"]*\)".*/\1/p')
                    MESSAGE=$(echo "$action_line" | sed -n 's/.*message="\([^"]*\)".*/\1/p')
                    TITRE=${TITRE:-Notification}
                    MESSAGE=${MESSAGE:-Message par défaut}
                    
                    # Remplacement des variables par leur valeur
                    MESSAGE=$(echo "$MESSAGE" | sed "s/\$DATE_DU_JOUR/\$(date +%Y-%m-%d)/g")
                    MESSAGE=$(echo "$MESSAGE" | sed "s/\$HEURE/\$(date +%H:%M)/g")
                    MESSAGE=$(echo "$MESSAGE" | sed "s/\$UTILISATEUR/\$(whoami)/g")
                    
                    cat >> "$FICHIER_SORTIE" <<NOTIFIER

# Action #$ID_ACTION: NOTIFIER
notify-send "$TITRE" "$MESSAGE"
echo "[Action #$ID_ACTION] Notification envoyée"

NOTIFIER
                    ;;
                
                "AFFICHER_DATE")
                    FORMAT=$(echo "$action_line" | sed -n 's/.*format="\([^"]*\)".*/\1/p')
                    FORMAT=${FORMAT:-%Y-%m-%d}
                    TITRE=$(echo "$action_line" | sed -n 's/.*titre="\([^"]*\)".*/\1/p')
                    TITRE=${TITRE:-Date du jour}
                    
                    cat >> "$FICHIER_SORTIE" <<AFFICHE_DATE

# Action #$ID_ACTION: AFFICHER_DATE
DATE_JOUR=\$(date +"$FORMAT")
echo "[$TITRE] \$DATE_JOUR"
# Optionnel: afficher dans une fenêtre zenity si disponible
if command -v zenity &> /dev/null; then
    zenity --info --title="$TITRE" --text="Date du jour:\n\n\$DATE_JOUR"
fi

AFFICHE_DATE
                    ;;
                
                "EXECUTER_CMD"):
                    COMMANDE=$(echo "$action_line" | sed -n 's/.*commande="\([^"]*\)".*/\1/p')
                    if [ -n "$COMMANDE" ]; then
                        cat >> "$FICHIER_SORTIE" <<EXEC_CMD

# Action #$ID_ACTION: EXECUTER_CMD
echo "[Action #$ID_ACTION] Exécution: $COMMANDE"
$COMMANDE

EXEC_CMD
                    fi
                    ;;
                
                "COPIER_FICHIER")
                    SOURCE=$(echo "$action_line" | sed -n 's/.*source="\([^"]*\)".*/\1/p')
                    DESTINATION=$(echo "$action_line" | sed -n 's/.*destination="\([^"]*\)".*/\1/p')
                    MOTIF=$(echo "$action_line" | sed -n 's/.*motif="\([^"]*\)".*/\1/p')
                    MOTIF=${MOTIF:*}
                    
                    if [ -n "$SOURCE" ] && [ -n "$DESTINATION" ]; then
                        cat >> "$FICHIER_SORTIE" <<COPIE

# Action #$ID_ACTION: COPIER_FICHIER
echo "[Action #$ID_ACTION] Copie: $SOURCE -> $DESTINATION"
mkdir -p "$DESTINATION"
cp $MOTIF "$SOURCE" "$DESTINATION/" 2>/dev/null || echo "[Attention] Copie impossible (chemins invalides)"

COPIE
                    fi
                    ;;
                
                "SUPPRIMER_FICHIER")
                    CHEMIN=$(echo "$action_line" | sed -n 's/.*chemin="\([^"]*\)".*/\1/p')
                    CONFIRMATION=$(echo "$action_line" | sed -n 's/.*confirmation="\([^"]*\)".*/\1/p')
                    
                    if [ -n "$CHEMIN" ]; then
                        if [ "$CONFIRMATION" = "non" ]; then
                            cat >> "$FICHIER_SORTIE" <<SUPPRIME

# Action #$ID_ACTION: SUPPRIMER_FICHIER
echo "[Action #$ID_ACTION] Suppression: $CHEMIN"
rm -rf "$CHEMIN" 2>/dev/null || echo "[Attention] Suppression impossible"

SUPPRIME
                        else
                            cat >> "$FICHIER_SORTIE" <<SUPPRIME_CONFIRM

# Action #$ID_ACTION: SUPPRIMER_FICHIER (avec confirmation)
echo "[Action #$ID_ACTION] Suppression: $CHEMIN"
read -p "Confirmer la suppression ? (o/n) " -n 1 -r
echo
if [[ \$REPLY =~ ^[Oo]$ ]]; then
    rm -rf "$CHEMIN" 2>/dev/null
    echo "[Action] Fichier supprimé"
else
    echo "[Action] Annulé"
fi

SUPPRIME_CONFIRM
                        fi
                    fi
                    ;;
                
                "DEPLACER_FICHIER")
                    SOURCE=$(echo "$action_line" | sed -n 's/.*source="\([^"]*\)".*/\1/p')
                    DESTINATION=$(echo "$action_line" | sed -n 's/.*destination="\([^"]*\)".*/\1/p')
                    
                    if [ -n "$SOURCE" ] && [ -n "$DESTINATION" ]; then
                        cat >> "$FICHIER_SORTIE" <<DEPLACE

# Action #$ID_ACTION: DEPLACER_FICHIER
echo "[Action #$ID_ACTION] Déplacement: $SOURCE -> $DESTINATION"
mv "$SOURCE" "$DESTINATION/" 2>/dev/null || echo "[Attention] Déplacement impossible"

DEPLACE
                    fi
                    ;;
                
                "REDÉMARRER_SERV")
                    SERVICE=$(echo "$action_line" | sed -n 's/.*service="\([^"]*\)".*/\1/p')
                    
                    if [ -n "$SERVICE" ]; then
                        cat >> "$FICHIER_SORTIE <<RESTART"

# Action #$ID_ACTION: REDÉMARRER_SERV
echo "[Action #$ID_ACTION] Redémarrage du service: $SERVICE"
sudo systemctl restart $SERVICE 2>/dev/null || echo "[Attention] Redémarrage impossible (droits admin requis)"

RESTART
                    fi
                    ;;
                
                "SORTIR_RESULTAT")
                    TUBE=$(echo "$action_line" | sed -n 's/.*tube="\([^"]*\)".*/\1/p')
                    DONNEES=$(echo "$action_line" | sed -n 's/.*donnees="\([^"]*\)".*/\1/p')
                    
                    if [ -n "$TUBE" ] && [ -n "$DONNEES" ]; then
                        cat >> "$FICHIER_SORTIE" <<SORTIE_TUBE

# Action #$ID_ACTION: SORTIR_RESULTAT
# Sortie dans named pipe: $TUBE
DONNEE_RESULTAT=$DONNEES
if [ -p "$TUBE" ]; then
    echo "\$DONNEE_RESULTAT > "$TUBE" 2>/dev/null
    echo "[Action] Résultat envoyé au tube"
else
    echo "[Action] Tube inexistant: $TUBE (création nécessaire)"
fi

SORTIE_TUBE
                    fi
                    ;;
                
                *)
                    echo "  ⚠ Action non reconnue: $TYPE_ACTION"
                    echo "echo '[Action #$ID_ACTION] Non implémentée: $TYPE_ACTION'" >> "$FICHIER_SORTIE"
                    ;;
            esac
        fi
    done < <(xmllint --xpath "//actions/action" "$FICHIER_XML" 2>/dev/null | tr '\n' '\r' | tr '<action' '\n' | grep -o '<action[^>]*>')
    
    echo ""
    echo "  ✓ Actions traitées"
else
    echo "  ⚠ Aucune action définie"
fi

# Section de fin
cat >> "$FICHIER_SORTIE" <<END

echo ""
echo "==================================="
echo "Macro '$NOM_MACRO' exécutée avec succès"
echo "==================================="
exit 0

END

# Attribution des permissions
chmod +x "$FICHIER_SORTIE"

echo ""
echo "=== Conversion terminée ==="
echo "Script généré: $FICHIER_SORTIE"
echo "Permissions: $(ls -la "$FICHIER_SORTIE" | awk '{print \$1}')"
echo ""
echo "Pour exécuter:"
echo "  $FICHIER_SORTIE"

BASH_SCRIPT

# Attribution des permissions
chmod +x "$SRC/generate_bash.sh"

echo -e "  ${VERT}✓${NEUTRE} $SRC/generate_bash.sh généré et rendu exécutable"
echo ""
echo -e "${VERT}[bash] ==========================================${NEUTRE}"
echo -e "${VERT}[bash]  GENERATION BASH TERMINÉE${NEUTRE}"
echo -e "${VERT}[bash] ==========================================${NEUTRE}"
echo ""
echo "Actions implémentées :"
echo "  - NOTIFIER (via notify-send)"
echo "  - AFFICHER_DATE (via zenity ou echo)"
echo "  - EXECUTER_CMD (exécution commande shell)"
echo "  - COPIER_FICHIER (cp)"
echo "  - DEPLACER_FICHIER (mv)"
echo "  - SUPPRIMER_FICHIER (rm)"
echo "  - REDÉMARRER_SERV (systemctl)"
echo "  - SORTIR_RESULTAT (named pipe)"
echo ""
echo "Prochaine étape recommandée :"
echo "  ./scripts/sauvegarder_projet.sh \"Implémentation generate_bash.sh - toutes les actions\""
