#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: generate_bash.sh
# Description: Convertit un XML de macro en script Bash exécutable
# Version: 1.1
# Licence: GPL-3.0
#------------------------------------------------------------------------------

set -e

if [ $# -lt 2 ]; then
    echo "Utilisation: $0 <fichier_xml> <fichier_sortie>"
    exit 1
fi

FICHIER_XML="$1"
FICHIER_SORTIE="$2"

if [ ! -f "$FICHIER_XML" ]; then
    echo "Erreur: Fichier XML introuvable: $FICHIER_XML"
    exit 1
fi

echo "=== Conversion XML -> Bash ==="
echo "Entree : $FICHIER_XML"
echo "Sortie : $FICHIER_SORTIE"
echo ""

# Extraction du nom de la macro
NOM_MACRO=$(xmllint --xpath "string(/macro/@name)" "$FICHIER_XML" 2>/dev/null || echo "Macro_Sans_Nom")
echo "Macro: $NOM_MACRO"
echo ""

# Fonction utilitaire pour extraire un parametre d'une action
# Usage: extraire_param <fichier_xml> <action_id> <key>
extraire_param() {
    local xml_file="$1"
    local action_id="$2"
    local key="$3"
    xmllint --xpath "string(//action[@id='$action_id']/config/parametre[@key='$key']/@value)" "$xml_file" 2>/dev/null
}

# Creation du script de sortie
cat > "$FICHIER_SORTIE" <<HEADER
#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Macro: $NOM_MACRO
# Genere le: $(date '+%Y-%m-%d %H:%M:%S')
# Source XML: $FICHIER_XML
#------------------------------------------------------------------------------
set -e

HEADER

# ------------------------------------------------------------------------------
# SECTION 1: VARIABLES
# ------------------------------------------------------------------------------
echo "=== Traitement des variables ==="

NOMBRE_VARS=$(xmllint --xpath "count(//variables/variable)" "$FICHIER_XML" 2>/dev/null || echo "0")

if [ "$NOMBRE_VARS" -gt 0 ]; then
    echo '# Variables' >> "$FICHIER_SORTIE"
    
    for i in $(seq 1 "$NOMBRE_VARS"); do
        NOM_VAR=$(xmllint --xpath "string(//variables/variable[$i]/@name)" "$FICHIER_XML" 2>/dev/null)
        VALEUR_VAR=$(xmllint --xpath "string(//variables/variable[$i]/@value)" "$FICHIER_XML" 2>/dev/null)
        
        if [ -n "$VALEUR_VAR" ]; then
            echo "${NOM_VAR}=\"${VALEUR_VAR}\"" >> "$FICHIER_SORTIE"
        else
            echo "# Variable ${NOM_VAR} (a definir)" >> "$FICHIER_SORTIE"
        fi
    done
    
    echo "" >> "$FICHIER_SORTIE"
    echo "  ✓ $NOMBRE_VARS variable(s) declaree(s)"
else
    echo "  ℹ Aucune variable definie"
fi

echo ""

# ------------------------------------------------------------------------------
# SECTION 2: DECLENCHEURS
# ------------------------------------------------------------------------------
echo "=== Traitement des declencheurs ==="

TYPE_DECL=$(xmllint --xpath "string(//declencheur/@type)" "$FICHIER_XML" 2>/dev/null || echo "")

if [ -n "$TYPE_DECL" ]; then
    case "$TYPE_DECL" in
        "DEMARRAGE_APP")
            DELAI=$(xmllint --xpath "string(//declencheur/config/parametre[@key='delai']/@value)" "$FICHIER_XML" 2>/dev/null || echo "0")
            
            cat >> "$FICHIER_SORTIE" <<DEMARRAGE

# === DECLENCHEUR: Demarrage application ===
echo "[Demarrage] Initialisation de la macro '$NOM_MACRO'..."
sleep $DELAI
echo "[Demarrage] Execution initiee."

DEMARRAGE
            echo "  ✓ Declencheur DEMARRAGE_APP (delai: ${DELAI}s)"
            ;;
        
        "HORAIRE")
            HEURE=$(xmllint --xpath "string(//declencheur/config/parametre[@key='heure']/@value)" "$FICHIER_XML" 2>/dev/null || echo "8")
            MINUTE=$(xmllint --xpath "string(//declencheur/config/parametre[@key='minute']/@value)" "$FICHIER_XML" 2>/dev/null || echo "0")
            
            cat >> "$FICHIER_SORTIE" <<HORRAIRE

# === DECLENCHEUR: Horaire programme ===
echo "[Horaire] La macro s'executera a ${HEURE}h${MINUTE}"
HEURE_CIBLE="${HEURE}${MINUTE}"

HORRAIRE
            echo "  ✓ Declencheur HORAIRE (${HEURE}h${MINUTE})"
            ;;
        
        *)
            LABEL_DECL=$(xmllint --xpath "string(//declencheur/@label)" "$FICHIER_XML" 2>/dev/null || echo "")
            cat >> "$FICHIER_SORTIE" <<UNKNOWN

# === DECLENCHEUR: $LABEL_DECL (type: $TYPE_DECL) ===
echo "[Declencheur] $LABEL_DECL (type non reconnu: $TYPE_DECL)"

UNKNOWN
            echo "  ⚠ Declencheur non reconnu: $TYPE_DECL"
            ;;
    esac
else
    echo "  ⚠ Aucun declencheur trouve"
fi

echo ""

# ------------------------------------------------------------------------------
# SECTION 3: CONTRAINTES
# ------------------------------------------------------------------------------
echo "=== Traitement des contraintes ==="

NOMBRE_CONTR=$(xmllint --xpath "count(//contraintes/contrainte)" "$FICHIER_XML" 2>/dev/null || echo "0")

if [ "$NOMBRE_CONTR" -gt 0 ]; then
    cat >> "$FICHIER_SORTIE" <<CONTRAINTES

# === CONTRAINTES ===

CONTRAINTES
    
    for i in $(seq 1 "$NOMBRE_CONTR"); do
        TYPE_CONTR=$(xmllint --xpath "string(//contraintes/contrainte[$i]/@type)" "$FICHIER_XML" 2>/dev/null)
        LABEL_CONTR=$(xmllint --xpath "string(//contraintes/contrainte[$i]/@label)" "$FICHIER_XML" 2>/dev/null || echo "")
        ID_CONTR=$(xmllint --xpath "string(//contraintes/contrainte[$i]/@id)" "$FICHIER_XML" 2>/dev/null || echo "$i")
        
        case "$TYPE_CONTR" in
            "ESPACE_DISQUE")
                MIN_ESPACE=$(xmllint --xpath "string(//contrainte[@id='$ID_CONTR']/config/parametre[@key='espace_minimum']/@value)" "$FICHIER_XML" 2>/dev/null || echo "10")
                
                cat >> "$FICHIER_SORTIE" <<ESPACE
# Contrainte: Espace disque ($LABEL_CONTR)
echo "[Controle] Verification de l'espace disque (min: ${MIN_ESPACE} Go)..."
ESPACE_LIBRE=\$(df /home | tail -1 | awk '{print \$4}')
ESPACE_GB=\$((ESPACE_LIBRE / 1024 / 1024))
if [ \$ESPACE_GB -lt $MIN_ESPACE ]; then
    echo "[Erreur] Espace insuffisant: \$ESPACE_GB Go disponible"
    exit 1
fi
echo "[Controle] Espace OK: \$ESPACE_GB Go disponible."

ESPACE
                ;;
            
            "PLAGE_HORAIRE")
                HEURE_DEBUT=$(xmllint --xpath "string(//contrainte[@id='$ID_CONTR']/config/parametre[@key='heure_debut']/@value)" "$FICHIER_XML" 2>/dev/null || echo "0800")
                HEURE_FIN=$(xmllint --xpath "string(//contrainte[@id='$ID_CONTR']/config/parametre[@key='heure_fin']/@value)" "$FICHIER_XML" 2>/dev/null || echo "1800")
                
                cat >> "$FICHIER_SORTIE" <<HORRAIRE_C
# Contrainte: Plage horaire ($LABEL_CONTR)
echo "[Controle] Verification plage horaire (${HEURE_DEBUT}-${HEURE_FIN})..."
HEURE_ACTUELLE=\$(date +%H%M)
if [ "\$HEURE_ACTUELLE" -lt "$HEURE_DEBUT" ] || [ "\$HEURE_ACTUELLE" -gt "$HEURE_FIN" ]; then
    echo "[Erreur] Hors plage horaire (\$HEURE_ACTUELLE)"
    exit 1
fi
echo "[Controle] Plage horaire OK (\$HEURE_ACTUELLE)."

HORRAIRE_C
                ;;
            
            "PROCESSUS_ACTIF")
                PROCESSUS=$(xmllint --xpath "string(//contrainte[@id='$ID_CONTR']/config/parametre[@key='processus']/@value)" "$FICHIER_XML" 2>/dev/null || echo "firefox")
                
                cat >> "$FICHIER_SORTIE" <<PROC
# Contrainte: Processus actif ($LABEL_CONTR)
echo "[Controle] Verification processus: $PROCESSUS..."
if ! pgrep -x "$PROCESSUS" > /dev/null; then
    echo "[Erreur] Processus $PROCESSUS non actif"
    exit 1
fi
echo "[Controle] Processus $PROCESSUS actif."

PROC
                ;;
            
            *)
                echo "# Contrainte non reconnue: $TYPE_CONTR" >> "$FICHIER_SORTIE"
                ;;
        esac
    done
    
    echo "  ✓ $NOMBRE_CONTR contrainte(s) traitee(s)"
else
    echo "  ℹ Aucune contrainte definie"
fi

echo ""

# ------------------------------------------------------------------------------
# SECTION 4: ACTIONS
# ------------------------------------------------------------------------------
echo "=== Traitement des actions ==="

cat >> "$FICHIER_SORTIE" <<ACTIONS_HEADER

# === ACTIONS ===

ACTIONS_HEADER

NOMBRE_ACTIONS=$(xmllint --xpath "count(//actions/action)" "$FICHIER_XML" 2>/dev/null || echo "0")

if [ "$NOMBRE_ACTIONS" -gt 0 ]; then
    for i in $(seq 1 "$NOMBRE_ACTIONS"); do
        ID_ACTION=$(xmllint --xpath "string(//actions/action[$i]/@id)" "$FICHIER_XML" 2>/dev/null || echo "$i")
        TYPE_ACTION=$(xmllint --xpath "string(//actions/action[$i]/@type)" "$FICHIER_XML" 2>/dev/null || echo "")
        LABEL_ACTION=$(xmllint --xpath "string(//actions/action[$i]/@label)" "$FICHIER_XML" 2>/dev/null || echo "")
        
        echo "  Action #$ID_ACTION: $TYPE_ACTION ($LABEL_ACTION)"
        
        case "$TYPE_ACTION" in
            "NOTIFIER")
                TITRE=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='titre']/@value)" "$FICHIER_XML" 2>/dev/null || echo "Notification")
                MESSAGE=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='message']/@value)" "$FICHIER_XML" 2>/dev/null || echo "Message")
                
                cat >> "$FICHIER_SORTIE" <<NOTIFIER

# Action #$ID_ACTION: NOTIFIER
echo "[Action #$ID_ACTION] Notification: $TITRE"
notify-send "$TITRE" "$MESSAGE"

NOTIFIER
                ;;
            
            "AFFICHER_DATE")
                FORMAT=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='format']/@value)" "$FICHIER_XML" 2>/dev/null || echo "%Y-%m-%d")
                TITRE=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='titre']/@value)" "$FICHIER_XML" 2>/dev/null || echo "Date du jour")
                
                cat >> "$FICHIER_SORTIE" <<AFFICHE_DATE

# Action #$ID_ACTION: AFFICHER_DATE
DATE_JOUR=\$(date +"$FORMAT")
echo "[$TITRE] \$DATE_JOUR"
if command -v zenity &> /dev/null; then
    zenity --info --title="$TITRE" --text="Date du jour:\n\n\$DATE_JOUR" 2>/dev/null
fi

AFFICHE_DATE
                ;;
            
            "EXECUTER_CMD")
                COMMANDE=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='commande']/@value)" "$FICHIER_XML" 2>/dev/null || echo "")
                
                if [ -n "$COMMANDE" ]; then
                    cat >> "$FICHIER_SORTIE" <<EXEC_CMD

# Action #$ID_ACTION: EXECUTER_CMD
echo "[Action #$ID_ACTION] Execution: $COMMANDE"
$COMMANDE

EXEC_CMD
                fi
                ;;
            
            "COPIER_FICHIER")
                SOURCE=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='source']/@value)" "$FICHIER_XML" 2>/dev/null || echo "")
                DESTINATION=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='destination']/@value)" "$FICHIER_XML" 2>/dev/null || echo "")
                MOTIF=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='motif']/@value)" "$FICHIER_XML" 2>/dev/null || echo "*")
                
                if [ -n "$SOURCE" ] && [ -n "$DESTINATION" ]; then
                    cat >> "$FICHIER_SORTIE" <<COPIE

# Action #$ID_ACTION: COPIER_FICHIER
echo "[Action #$ID_ACTION] Copie: $SOURCE -> $DESTINATION"
mkdir -p "$DESTINATION"
cp $MOTIF "$SOURCE" "$DESTINATION/" 2>/dev/null || echo "[Attention] Copie impossible"

COPIE
                fi
                ;;
            
            "DEPLACER_FICHIER")
                SOURCE=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='source']/@value)" "$FICHIER_XML" 2>/dev/null || echo "")
                DESTINATION=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='destination']/@value)" "$FICHIER_XML" 2>/dev/null || echo "")
                
                if [ -n "$SOURCE" ] && [ -n "$DESTINATION" ]; then
                    cat >> "$FICHIER_SORTIE" <<DEPLACE

# Action #$ID_ACTION: DEPLACER_FICHIER
echo "[Action #$ID_ACTION] Deplacement: $SOURCE -> $DESTINATION"
mv "$SOURCE" "$DESTINATION/" 2>/dev/null || echo "[Attention] Deplacement impossible"

DEPLACE
                fi
                ;;
            
            "SUPPRIMER_FICHIER")
                CHEMIN=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='chemin']/@value)" "$FICHIER_XML" 2>/dev/null || echo "")
                CONFIRMATION=$(xmllint --xpath "string(//action[@id='$ID_ACTION']/config/parametre[@key='confirmation']/@value)" "$FICHIER_XML" 2>/dev/null || echo "oui")
                
                if [ -n "$CHEMIN" ]; then
                    if [ "$CONFIRMATION" = "non" ]; then
                        cat >> "$FICHIER_SORTIE" <<SUPPRIME

# Action #$ID_ACTION: SUPPRIMER_FICHIER
echo "[Action #$ID_ACTION] Suppression: $CHEMIN"
rm -rf "$CHEMIN" 2>/dev/null || echo "[Attention] Suppression impossible"

SUPPRIME
                    else
                        cat >> "$FICHIER_SORTIE" <<SUPPRIME_C

# Action #$ID_ACTION: SUPPRIMER_FICHIER (avec confirmation)
echo "[Action #$ID_ACTION] Suppression: $CHEMIN"
read -p "Confirmer la suppression ? (o/n) " -n 1 -r
echo
if [[ \$REPLY =~ ^[Oo]\$ ]]; then
    rm -rf "$CHEMIN" 2>/dev/null
    echo "[Action] Fichier supprime"
else
    echo "[Action] Annule"
fi

SUPPRIME_C
                    fi
                fi
                ;;
            
            *)
                cat >> "$FICHIER_SORTIE" <<INCONNU

# Action #$ID_ACTION: $LABEL_ACTION (type non reconnu: $TYPE_ACTION)
echo "[Action #$ID_ACTION] Non implementee: $TYPE_ACTION"

INCONNU
                ;;
        esac
    done
    
    echo "  ✓ $NOMBRE_ACTIONS action(s) traitee(s)"
else
    echo "  ⚠ Aucune action definie"
fi

# Section de fin
cat >> "$FICHIER_SORTIE" <<END

echo ""
echo "==================================="
echo "Macro '$NOM_MACRO' executee avec succes"
echo "==================================="
exit 0

END

chmod +x "$FICHIER_SORTIE"

echo ""
echo "=== Conversion terminee ==="
echo "Script genere: $FICHIER_SORTIE"
echo ""
echo "Pour executer:"
echo "  $FICHIER_SORTIE"
