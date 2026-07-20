#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: generate_bash.sh
# Description: Convertit un fichier XML de macro en script Bash exécutable
# Dépendance: xmllint (libxml2-utils)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -euo pipefail

FIFO_BASE="/tmp/macrosTitux_pipes"

#------------------------------------------------------------------------------
# Fonctions utilitaires XML
#------------------------------------------------------------------------------
xml_get() {
    xmllint --xpath "$2" "$1" 2>/dev/null || echo ""
}

xml_count() {
    xmllint --xpath "count($2)" "$1" 2>/dev/null || echo "0"
}

normalize_name() {
    echo "$1" | tr ' ' '_' | tr '[:upper:]' '[:lower:]'
}

#------------------------------------------------------------------------------
# Extraction des paramètres d'un élément XML
# Arguments: fichier_xml xpath_contexte
# Sortie: lignes "cle=valeur" sur stdout
#------------------------------------------------------------------------------
get_params() {
    local xml="$1"
    local ctx="$2"
    local count
    count=$(xml_count "$xml" "count(${ctx}/config/param)")
    count=${count:-0}
    local j
    for (( j=1; j<=count; j++ )); do
        local key val
        key=$(xml_get "$xml" "string(${ctx}/config/param[${j}]/@key)")
        val=$(xml_get "$xml" "string(${ctx}/config/param[${j}])")
        echo "${key}=${val}"
    done
}

#------------------------------------------------------------------------------
# Extraction paramètres trigger
#------------------------------------------------------------------------------
read_trigger_params() {
    local xml="$1"
    while IFS='=' read -r key val; do
        [[ -z "$key" ]] && continue
        case "$key" in
            heure)           T_HEURE="$val" ;;
            minute)          T_MINUTE="$val" ;;
            jours)           T_JOURS="$val" ;;
            chemin)          T_CHEMIN="$val" ;;
            peripherique)    T_PERIPH="$val" ;;
            interface)       T_INTERFACE="$val" ;;
            macro_source)    T_SOURCE_MACRO="$val" ;;
            variable_reception) T_VAR_RECV="$val" ;;
        esac
    done < <(get_params "$xml" '/macro/trigger')
}

#------------------------------------------------------------------------------
# Extraction paramètres action
#------------------------------------------------------------------------------
read_action_params() {
    local xml="$1"
    local idx="$2"
    P_SOURCE=""
    P_MOTIF=""
    P_DESTINATION=""
    P_CHEMIN=""
    P_TITRE=""
    P_MESSAGE=""
    P_COMMANDE=""
    P_SERVICE=""
    P_TUBE=""
    P_DONNEES=""
    while IFS='=' read -r key val; do
        [[ -z "$key" ]] && continue
        case "$key" in
            source)      P_SOURCE="$val" ;;
            motif)       P_MOTIF="$val" ;;
            destination) P_DESTINATION="$val" ;;
            chemin)      P_CHEMIN="$val" ;;
            titre)       P_TITRE="$val" ;;
            message)     P_MESSAGE="$val" ;;
            commande)    P_COMMANDE="$val" ;;
            service)     P_SERVICE="$val" ;;
            tube)        P_TUBE="$val" ;;
            donnees)     P_DONNEES="$val" ;;
        esac
    done < <(get_params "$xml" "/macro/actions/action[${idx}]")
}

#------------------------------------------------------------------------------
# Extraction paramètres contrainte
#------------------------------------------------------------------------------
read_constraint_params() {
    local xml="$1"
    local idx="$2"
    C_ESPACE_MIN=""
    C_HEURE_DEBUT=""
    C_HEURE_FIN=""
    C_PROCESSUS=""
    while IFS='=' read -r key val; do
        [[ -z "$key" ]] && continue
        case "$key" in
            espace_minimum) C_ESPACE_MIN="$val" ;;
            heure_debut)    C_HEURE_DEBUT="$val" ;;
            heure_fin)      C_HEURE_FIN="$val" ;;
            processus)      C_PROCESSUS="$val" ;;
        esac
    done < <(get_params "$xml" "/macro/constraints/constraint[${idx}]")
}

#==============================================================================
# GÉNÉRATION DU SCRIPT BASH
#==============================================================================

# Variables globales pour trigger
T_HEURE="" T_MINUTE="" T_JOURS="" T_CHEMIN=""
T_PERIPH="" T_INTERFACE="" T_SOURCE_MACRO="" T_VAR_RECV=""

generate_script() {
    local xml_file="$1"

    #--- Extraction infos de base ---
    local macro_name trigger_type trigger_label
    macro_name=$(xml_get "$xml_file" 'string(/macro/@name)')
    macro_name=${macro_name:-"Macro_Sans_Nom"}
    trigger_type=$(xml_get "$xml_file" 'string(/macro/trigger/@type)')
    trigger_type=${trigger_type:-"MANUEL"}
    trigger_label=$(xml_get "$xml_file" 'string(/macro/trigger/@label)')
    trigger_label=${trigger_label:-"Non spécifié"}

    #--- Lecture paramètres trigger ---
    read_trigger_params "$xml_file"

    #--- En-tête ---
    echo "#!/bin/bash"
    echo "# -*- coding: utf-8 -*-"
    echo "#------------------------------------------------------------------------------"
    echo "# Script généré par macrosTitux"
    echo "# Macro: ${macro_name}"
    echo "# Source: ${xml_file}"
    echo "# Généré le: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "#------------------------------------------------------------------------------"
    echo ""
    echo "set -euo pipefail"
    echo "FIFO_BASE=\"${FIFO_BASE}\""
    echo ""

    #--- Variables ---
    local var_count
    var_count=$(xml_count "$xml_file" 'count(/macro/variables/var)')
    var_count=${var_count:-0}
    if [[ "$var_count" -gt 0 ]] 2>/dev/null; then
        echo "# ============================== VARIABLES =============================="
        local v
        for (( v=1; v<=var_count; v++ )); do
            local vname vval
            vname=$(xml_get "$xml_file" "string(/macro/variables/var[${v}]/@name)")
            vval=$(xml_get "$xml_file" "string(/macro/variables/var[${v}]/@value)")
            echo "${vname}=\"${vval}\""
        done
        echo ""
    fi

    #--- Déclencheur ---
    echo "# ============================== DÉCLENCHEUR =============================="
    echo "# Type: ${trigger_type} (${trigger_label})"
    echo ""

    case "$trigger_type" in
        DEMARRAGE)
            echo 'echo "[MACRO] Démarrage à $(date)"'
            ;;
        HORAIRE)
            echo "# Planification: ${T_MINUTE:-0} ${T_HEURE:-0} * * *"
            echo "# Ajouter au crontab: crontab -e"
            echo '# echo "[MACRO] Exécution horaire à $(date)"'
            ;;
        FICHIER_MODIFIE)
            echo "# Surveillance fichier: ${T_CHEMIN:-/tmp/fichier.txt}"
            echo '# Nécessite: inotifywait (apt install inotify-tools)'
            echo 'if [[ -e "'"${T_CHEMIN:-/tmp/fichier.txt}"'" ]]; then'
            echo '    echo "[MACRO] Fichier modifié"'
            echo 'fi'
            ;;
        FICHIER_CREE)
            echo "# Surveillance création fichier: ${T_CHEMIN:-/tmp/fichier.txt}"
            echo 'if [[ -e "'"${T_CHEMIN:-/tmp/fichier.txt}"'" ]]; then'
            echo '    echo "[MACRO] Fichier créé"'
            echo 'fi'
            ;;
        USB_CONNECTE)
            echo "# USB connecté: ${T_PERIPH:-(tous)}"
            echo '# Détection via dmesg ou udev'
            echo 'echo "[MACRO] USB connecté"'
            ;;
        RESEAU_ACTIF)
            echo "# Réseau activé: ${T_INTERFACE:-(toutes)}"
            echo 'if ip link show up 2>/dev/null | grep -q "state UP"; then'
            echo '    echo "[MACRO] Réseau actif"'
            echo 'fi'
            ;;
        SORTIE_TUBE)
            local fifo_src
            fifo_src="${FIFO_BASE}/$(normalize_name "${T_SOURCE_MACRO:-source}").fifo"
            echo "# Lecture depuis tube: ${T_SOURCE_MACRO:-source}"
            echo "TUBE_SOURCE=\"${fifo_src}\""
            echo 'if [[ -p "$TUBE_SOURCE" ]]; then'
            echo "    ${T_VAR_RECV:-DONNEES_RECUES}=\$(cat \"\$TUBE_SOURCE\")"
            echo '    echo "[MACRO] Données reçues du tube"'
            echo 'else'
            echo '    echo "[MACRO] ATTENTION: Tube introuvable ($TUBE_SOURCE)"'
            echo "    ${T_VAR_RECV:-DONNEES_RECUES}=\"\""
            echo 'fi'
            ;;
        *)
            echo 'echo "[MACRO] Déclencheur inconnu, exécution manuelle à $(date)"'
            ;;
    esac
    echo ""

    #--- Contraintes ---
    local constr_count
    constr_count=$(xml_count "$xml_file" 'count(/macro/constraints/constraint)')
    constr_count=${constr_count:-0}
    if [[ "$constr_count" -gt 0 ]] 2>/dev/null; then
        echo "# ============================== CONTRAINTES =============================="
        local c
        for (( c=1; c<=constr_count; c++ )); do
            local ctype clabel
            ctype=$(xml_get "$xml_file" "string(/macro/constraints/constraint[${c}]/@type)")
            clabel=$(xml_get "$xml_file" "string(/macro/constraints/constraint[${c}]/@label)")
            read_constraint_params "$xml_file" "$c"

            echo "# Contrainte ${c}: ${clabel:-$ctype}"
            case "$ctype" in
                ESPACE_DISQUE)
                    echo 'if [[ $(df / | awk "NR==2 {print \$5}" | sed "s/%//") -lt '"${C_ESPACE_MIN:-10}"' ]]; then'
                    echo '    echo "[CONTRAINTE] Espace disque insuffisant"'
                    echo '    exit 1'
                    echo 'fi'
                    ;;
                PLAGE_HORAIRE)
                    echo '# Contrainte plage horaire'
                    echo 'HEURE_ACTUELLE=$(date +%H%M)'
                    echo 'if [[ "$HEURE_ACTUELLE" -lt '"${C_HEURE_DEBUT:-0000}"' ]] || [[ "$HEURE_ACTUELLE" -gt '"${C_HEURE_FIN:-2359}"' ]]; then'
                    echo '    echo "[CONTRAINTE] Hors plage horaire"'
                    echo '    exit 1'
                    echo 'fi'
                    ;;
                PROCESSUS_ACTIF)
                    echo 'if ! pgrep -x "'"${C_PROCESSUS:-init}"'" >/dev/null 2>&1; then'
                    echo '    echo "[CONTRAINTE] Processus non actif"'
                    echo '    exit 1'
                    echo 'fi'
                    ;;
            esac
            echo ""
        done
    fi

    #--- Actions ---
    local action_count
    action_count=$(xml_count "$xml_file" 'count(/macro/actions/action)')
    action_count=${action_count:-0}
    if [[ "$action_count" -gt 0 ]] 2>/dev/null; then
        echo "# ============================== ACTIONS =============================="
        local a
        for (( a=1; a<=action_count; a++ )); do
            local atype alabel
            atype=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/@type)")
            alabel=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/@label)")
            read_action_params "$xml_file" "$a"

            echo "# Action ${a}: ${alabel:-$atype}"
            case "$atype" in
                COPIER_FICHIER)
                    echo "mkdir -p \"${P_DESTINATION:-/tmp}\""
                    echo "cp -v \"${P_SOURCE:-.}\"/${P_MOTIF:-*} \"${P_DESTINATION:-/tmp}/\" 2>/dev/null || echo \"[ACTION] Aucun fichier à copier\""
                    ;;
                DEPLACER_FICHIER)
                    echo "mkdir -p \"${P_DESTINATION:-/tmp}\""
                    echo "mv -v \"${P_SOURCE:-.}\"/${P_MOTIF:-*} \"${P_DESTINATION:-/tmp}/\" 2>/dev/null || echo \"[ACTION] Aucun fichier à déplacer\""
                    ;;
                SUPPRIMER_FICHIER)
                    if [[ -n "${P_MOTIF:-}" && "${P_MOTIF}" != "-" ]]; then
                        echo "find \"${P_CHEMIN:-/tmp}\" -name \"${P_MOTIF}\" -type f -delete 2>/dev/null && echo \"[ACTION] Fichiers supprimés\" || echo \"[ACTION] Rien à supprimer\""
                    else
                        echo "rm -fv \"${P_CHEMIN}\" 2>/dev/null && echo \"[ACTION] Fichier supprimé\" || echo \"[ACTION] Fichier non trouvé\""
                    fi
                    ;;
                NOTIFIER)
                    echo 'if command -v notify-send >/dev/null 2>&1; then'
                    echo "    notify-send \"${P_TITRE:-Notification}\" \"${P_MESSAGE:-}\""
                    echo 'else'
                    echo "    echo \"[NOTIFICATION] ${P_TITRE:-}: ${P_MESSAGE:-}\""
                    echo 'fi'
                    ;;
                EXECUTER_CMD)
                    echo "eval \"${P_COMMANDE:-echo 'Commande vide'}\" 2>&1 | while read line; do echo \"[CMD] \$line\"; done"
                    ;;
                REDÉMARRER_SERV)
                    echo 'if systemctl is-active --quiet "'"${P_SERVICE:-cron}"'" 2>/dev/null; then'
                    echo "    sudo systemctl restart \"${P_SERVICE:-cron}\" && echo \"[SERVICE] ${P_SERVICE:-} redémarré\" || echo \"[SERVICE] Échec\""
                    echo 'else'
                    echo "    echo \"[SERVICE] Service '${P_SERVICE:-}' non trouvé\""
                    echo 'fi'
                    ;;
                SORTIR_RESULTAT)
                    local fifo_out
                    fifo_out="${FIFO_BASE}/$(normalize_name "${P_TUBE:-resultat}").fifo"
                    echo "mkdir -p \"\$(dirname \"${fifo_out}\")\""
                    echo '[[-p "'"$fifo_out"'" ]] || mkfifo "'"$fifo_out"'"'
                    echo "echo \"${P_DONNEES:-}\" > \"${fifo_out}\" &"
                    echo 'sleep 0.5'
                    echo 'wait $! 2>/dev/null || true'
                    echo "[TUBE] Données écrites dans ${fifo_out}"
                    ;;
                *)
                    echo "# Action inconnue: $atype"
                    ;;
            esac
            echo ""
        done
    fi

    #--- Footer ---
    echo "# ============================== FIN =============================="
    echo 'echo "[MACRO] Terminé à $(date)"'
    echo 'exit 0'
}

#------------------------------------------------------------------------------
# Exécution principale
#------------------------------------------------------------------------------
main() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <fichier_xml> [fichier_sortie]" >&2
        exit 1
    fi

    local xml_file="$1"
    local output_file="${2:-${xml_file%.xml}.sh}"

    if [[ ! -f "$xml_file" ]]; then
        echo "ERREUR: Fichier XML introuvable: $xml_file" >&2
        exit 1
    fi

    log "Conversion: $(basename "$xml_file") → $(basename "$output_file")"
    generate_script < "$xml_file" > "$output_file"
    chmod +x "$output_file"
    log "OK: $output_file"
}

main "$@"
