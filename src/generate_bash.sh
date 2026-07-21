#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: generate_bash.sh
# Description: Convertit un fichier XML de macro en script Bash exécutable
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Utilisation: $0 <fichier_input.xml> <fichier_output.sh>"
    exit 1
fi

INPUT_XML="$1"
OUTPUT_SH="$2"

if [[ ! -f "$INPUT_XML" ]]; then
    echo "Erreur: Fichier XML introuvable: $INPUT_XML"
    exit 1
fi

#------------------------------------------------------------------------------
# Vérification des dépendances
#------------------------------------------------------------------------------
if ! command -v xmllint >/dev/null 2>&1; then
    echo "Erreur: xmllint non trouvé. Installer avec: sudo apt-get install libxml2-utils"
    exit 1
fi

#------------------------------------------------------------------------------
# Extraction des données depuis le XML
#------------------------------------------------------------------------------
extract_attr() {
    local element="$1"
    local attr="$2"
    xmllint --xpath "string($element/@$attr)" "$INPUT_XML" 2>/dev/null || echo ""
}

extract_param() {
    local parent="$1"
    local key="$2"
    xmllint --xpath "string($parent/param[@key='$key']/@value)" "$INPUT_XML" 2>/dev/null || echo ""
}

# Nom de la macro
MACRO_NAME=$(extract_attr "//macro" "name")
[[ -z "$MACRO_NAME" ]] && MACRO_NAME="macro_non_nomme"

# Type de déclencheur
TRIGGER_TYPE=$(extract_attr "//trigger" "type")
TRIGGER_LABEL=$(extract_attr "//trigger" "label")

# Paramètres du déclencheur
declare -A TRIGGER_PARAMS
for key in $(xmllint --xpath "//trigger/config/param/@key" "$INPUT_XML" 2>/dev/null | sed 's/key="\([^"]*\)"/\1\n/g'); do
    value=$(extract_param "//trigger/config" "$key")
    TRIGGER_PARAMS["$key"]="$value"
done

# Construire le script Bash

cat > "$OUTPUT_SH" << EOFHEADER
#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script généré par macrosTitux v0.3
# Macro: $MACRO_NAME
# Déclencheur: $TRIGGER_LABEL
# Généré le: $(date '+%Y-%m-%d %H:%M:%S')
#------------------------------------------------------------------------------

set -euo pipefail

# Variables
EOFHEADER

# Variables déclarées dans la macro
while IFS= read -r var_line; do
    var_name=$(echo "$var_line" | cut -d'|' -f1)
    var_value=$(echo "$var_line" | cut -d'|' -f2-)
    if [[ -n "$var_name" ]]; then
        echo "$var_name=\"$var_value\"" >> "$OUTPUT_SH"
    fi
done < <(xmllint --xpath "//variables/var" "$INPUT_XML" 2>/dev/null | grep -oP 'name="\K[^"]+' | paste -d'|' - <(xmllint --xpath "//variables/var" "$INPUT_XML" 2>/dev/null | grep -oP 'value="\K[^"]+'))

# Génération du corps selon le type de déclencheur
echo "" >> "$OUTPUT_SH"
echo "# Déclencheur: $TRIGGER_LABEL" >> "$OUTPUT_SH"

case "$TRIGGER_TYPE" in
    "DEMARRAGE")
        echo "# Ce script est conçu pour être exécuté au démarrage" >> "$OUTPUT_SH"
        echo "logger 'Macro $MACRO_NAME démarrée'" >> "$OUTPUT_SH"
        ;;
    "HORAIRE")
        HEURE="${TRIGGER_PARAMS[heure]:-8}"
        MINUTE="${TRIGGER_PARAMS[minute]:-0}"
        echo "# Programme avec cron à ${HEURE}:${MINUTE}" >> "$OUTPUT_SH"
        echo "crontab -l 2>/dev/null | grep -v '$MACRO_NAME'" >> "$OUTPUT_SH"
        echo "echo \"${MINUTE} ${HEURE} * * * $OUTPUT_SH\" | crontab -" >> "$OUTPUT_SH"
        ;;
    "FICHIER_MODIFIE")
        CHEMIN="${TRIGGER_PARAMS[chemin]:-/tmp}"
        echo "# Surveillance de modification de fichier" >> "$OUTPUT_SH"
        echo "INOTIFY_WAIT=\"${CHEMIN}\"" >> "$OUTPUT_SH"
        echo "echo 'Surveillance active sur: $INOTIFY_WAIT'" >> "$OUTPUT_SH"
        ;;
    "FICHIER_CREE")
        CHEMIN="${TRIGGER_PARAMS[chemin]:-/tmp}"
        echo "# Surveillance de création de fichier" >> "$OUTPUT_SH"
        echo "WATCH_PATH=\"${CHEMIN}\"" >> "$OUTPUT_SH"
        ;;
    "RESEAU_ACTIF")
        INTERFACE="${TRIGGER_PARAMS[interface]:-eth0}"
        echo "# Vérification du réseau sur interface: $INTERFACE" >> "$OUTPUT_SH"
        echo "ip link show $INTERFACE | grep -q 'UP'" >> "$OUTPUT_SH"
        ;;
    "SORTIE_TUBE")
        TUBE="${TRIGGER_PARAMS[tube]:-/tmp/macrosTitux_tube}"
        VAR_RECEPTION="${TRIGGER_PARAMS[variable_reception]:-DONNEES_RECUES}"
        echo "# Lecture depuis le tube: $TUBE" >> "$OUTPUT_SH"
        echo "$VAR_RECEPTION=\$(cat \"$TUBE\" 2>/dev/null || echo '')" >> "$OUTPUT_SH"
        ;;
    "USB_CONNECTE")
        PERIPHERIQUE="${TRIGGER_PARAMS[peripherique]:-(tous)}"
        echo "# Détection USB: $PERIPHERIQUE" >> "$OUTPUT_SH"
        echo "udevadm monitor --environment --udev 2>/dev/null &" >> "$OUTPUT_SH"
        ;;
    *)
        echo "# Déclencheur inconnu: $TRIGGER_TYPE" >> "$OUTPUT_SH"
        ;;
esac

# Génération des contraintes
echo "" >> "$OUTPUT_SH"
echo "# Contraintes" >> "$OUTPUT_SH"

while IFS='|' read -r c_type c_label c_params; do
    [[ -z "$c_type" ]] && continue

    case "$c_type" in
        "ESPACE_DISQUE")
            ESPACE_MIN=$(echo "$c_params" | grep -oP 'espace_minimum=\K\d+' || echo "10")
            echo "ESPACE_LIBRE=\$(df -k / | tail -1 | awk '{print \$4}')" >> "$OUTPUT_SH"
            echo "if [[ \$ESPACE_LIBRE -lt $((ESPACE_MIN * 1024 * 1024)) ]]; then" >> "$OUTPUT_SH"
            echo "    logger 'Contrainte espace disque non respectée'" >> "$OUTPUT_SH"
            echo "    exit 1" >> "$OUTPUT_SH"
            echo "fi" >> "$OUTPUT_SH"
            ;;
        "PLAGE_HORAIRE")
            HEURE_DEBUT=$(echo "$c_params" | grep -oP 'heure_debut=\K\d+' || echo "0800")
            HEURE_FIN=$(echo "$c_params" | grep -oP 'heure_fin=\K\d+' || echo "1800")
            HEURE_ACTUELLE=$(date +%H%M)
            echo "HEURE_ACTUELLE=\$(date +%H%M)" >> "$OUTPUT_SH"
            echo "if [[ \$HEURE_ACTUELLE -lt $HEURE_DEBUT || \$HEURE_ACTUELLE -gt $HEURE_FIN ]]; then" >> "$OUTPUT_SH"
            echo "    logger 'En dehors de la plage horaire autorisée'" >> "$OUTPUT_SH"
            echo "    exit 1" >> "$OUTPUT_SH"
            echo "fi" >> "$OUTPUT_SH"
            ;;
        "PROCESSUS_ACTIF")
            PROCESSUS=$(echo "$c_params" | grep -oP 'processus=\K[^&]+' || echo "")
            if [[ -n "$PROCESSUS" ]]; then
                echo "# Vérification processus: $PROCESSUS" >> "$OUTPUT_SH"
                echo "pgrep -x '$PROCESSUS' >/dev/null || exit 1" >> "$OUTPUT_SH"
            fi
            ;;
    esac
done < <(xmllint --xpath "//constraints/constraint" "$INPUT_XML" 2>/dev/null | \
    grep -oP 'type="\K[^"]+' | paste -d'|' - \
    <(xmllint --xpath "//constraints/constraint" "$INPUT_XML" 2>/dev/null | \
        grep -oP 'label="\K[^"]+' | \
        paste -d'|' - \
        <(xmllint --xpath "//constraints/constraint/config/param" "$INPUT_XML" 2>/dev/null | \
            grep -oP 'key="\K[^"]+=[^"]*' | tr '\n' '&')))

# Génération des actions
echo "" >> "$OUTPUT_SH"
echo "# Actions" >> "$OUTPUT_SH"

while IFS='|' read -r a_id a_type a_label a_params; do
    [[ -z "$a_type" ]] && continue

    case "$a_type" in
        "NOTIFIER")
            TITRE=$(echo "$a_params" | grep -oP 'titre=\K[^&]+' || echo "Notification")
            MESSAGE=$(echo "$a_params" | grep -oP 'message=\K[^&]+' || echo "")
            echo "notify-send \"$TITRE\" \"$MESSAGE\"" >> "$OUTPUT_SH"
            ;;
        "COPIER_FICHIER")
            SOURCE=$(echo "$a_params" | grep -oP 'source=\K[^&]+' || echo "")
            DESTINATION=$(echo "$a_params" | grep -oP 'destination=\K[^&]+' || echo "")
            MOTIF=$(echo "$a_params" | grep -oP 'motif=\K[^&]+' || echo "*")
            if [[ -n "$SOURCE" && -n "$DESTINATION" ]]; then
                echo "mkdir -p \"$DESTINATION\"" >> "$OUTPUT_SH"
                echo "cp -r \"$SOURCE\"/$MOTIF \"$DESTINATION/\" 2>/dev/null || true" >> "$OUTPUT_SH"
            fi
            ;;
        "DEPLACER_FICHIER")
            SOURCE=$(echo "$a_params" | grep -oP 'source=\K[^&]+' || echo "")
            DESTINATION=$(echo "$a_params" | grep -oP 'destination=\K[^&]+' || echo "")
            if [[ -n "$SOURCE" && -n "$DESTINATION" ]]; then
                echo "mv \"$SOURCE\" \"$DESTINATION/\" 2>/dev/null || true" >> "$OUTPUT_SH"
            fi
            ;;
        "SUPPRIMER_FICHIER")
            CHEMIN=$(echo "$a_params" | grep -oP 'chemin=\K[^&]+' || echo "")
            CONFIRMATION=$(echo "$a_params" | grep -oP 'confirmation=\K[^&]+' || echo "non")
            if [[ -n "$CHEMIN" ]]; then
                if [[ "$CONFIRMATION" == "non" ]]; then
                    echo "rm -rf \"$CHEMIN\" 2>/dev/null || true" >> "$OUTPUT_SH"
                else
                    echo "read -p 'Supprimer $CHEMIN ? (o/n) ' CONFIRM && [[ \"\$CONFIRM\" == \"o\" ]] && rm -rf \"$CHEMIN\"" >> "$OUTPUT_SH"
                fi
            fi
            ;;
        "EXECUTER_CMD")
            COMMANDE=$(echo "$a_params" | grep -oP 'commande=\K[^&]+' || echo "echo 'Commande exécutée'")
            echo "$COMMANDE" >> "$OUTPUT_SH"
            ;;
        "REDÉMARRER_SERV")
            SERVICE=$(echo "$a_params" | grep -oP 'service=\K[^&]+' || echo "")
            if [[ -n "$SERVICE" ]]; then
                echo "sudo systemctl restart \"$SERVICE\" 2>/dev/null || true" >> "$OUTPUT_SH"
            fi
            ;;
        "SORTIR_RESULTAT")
            TUBE_SORTIE=$(echo "$a_params" | grep -oP 'tube=\K[^&]+' || echo "/tmp/resultat")
            DONNEES=$(echo "$a_params" | grep -oP 'donnees=\K[^&]+' || echo "RESULTAT")
            echo "echo \"\$${DONNEES}\" > \"$TUBE_SORTIE\" 2>/dev/null || true" >> "$OUTPUT_SH"
            ;;
        *)
            echo "# Action inconnue: $a_type" >> "$OUTPUT_SH"
            ;;
    esac
done < <(xmllint --xpath "//actions/action" "$INPUT_XML" 2>/dev/null | \
    grep -oP 'id="\K[^"]+' | paste -d'|' - \
    <(xmllint --xpath "//actions/action" "$INPUT_XML" 2>/dev/null | \
        grep -oP 'type="\K[^"]+' | \
        paste -d'|' - \
        <(xmllint --xpath "//actions/action"  "$INPUT_XML" 2>/dev/null | \
            grep -oP 'label="\K[^"]+' | \
            paste -d'|' - \
            <(xmllint --xpath "//actions/action/config/param" "$INPUT_XML" 2>/dev/null | \
                grep -oP 'key="\K[^"]+=[^"]*' | tr '\n' '&'))))

# Footer
echo "" >> "$OUTPUT_SH"
echo "logger 'Macro $MACRO_NAME terminée'" >> "$OUTPUT_SH"
echo "exit 0" >> "$OUTPUT_SH"

# Rendre le script exécutable
chmod +x "$OUTPUT_SH"

echo "Succès: Script généré: $OUTPUT_SH"
exit 0
