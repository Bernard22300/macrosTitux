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
    xmllint --xpath "$2" "$1" 2>/dev/null | tr -d '[:space:]' || echo "0"
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

#==============================================================================
# GÉNÉRATION DU SCRIPT BASH
#==============================================================================

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
            local heure minute
            heure=$(xml_get "$xml_file" 'string(/macro/trigger/config/param[@key="heure"])')
            minute=$(xml_get "$xml_file" 'string(/macro/trigger/config/param[@key="minute"])')
            echo "# Planification: ${minute:-0} ${heure:-0} * * *"
            echo '# echo "[MACRO] Exécution horaire à $(date)"'
            ;;
        FICHIER_MODIFIE)
            local chemin
            chemin=$(xml_get "$xml_file" 'string(/macro/trigger/config/param[@key="chemin"])')
            chemin=${chemin:-/tmp/fichier.txt}
            echo "# Surveillance fichier: ${chemin}"
            echo 'if [[ -e "'"${chemin}"'" ]]; then'
            echo '    echo "[MACRO] Fichier modifié"'
            echo 'fi'
            ;;
        FICHIER_CREE)
            local chemin
            chemin=$(xml_get "$xml_file" 'string(/macro/trigger/config/param[@key="chemin"])')
            chemin=${chemin:-/tmp/fichier.txt}
            echo "# Surveillance création fichier: ${chemin}"
            echo 'if [[ -e "'"${chemin}"'" ]]; then'
            echo '    echo "[MACRO] Fichier créé"'
            echo 'fi'
            ;;
        USB_CONNECTE)
            echo 'echo "[MACRO] USB connecté"'
            ;;
        RESEAU_ACTIF)
            echo 'if ip link show up 2>/dev/null | grep -q "state UP"; then'
            echo '    echo "[MACRO] Réseau actif"'
            echo 'fi'
            ;;
        SORTIE_TUBE)
            local source_macro var_recv fifo_src
            source_macro=$(xml_get "$xml_file" 'string(/macro/trigger/config/param[@key="macro_source"])')
            var_recv=$(xml_get "$xml_file" 'string(/macro/trigger/config/param[@key="variable_reception"])')
            source_macro=${source_macro:-source}
            var_recv=${var_recv:-DONNEES_RECUES}
            fifo_src="${FIFO_BASE}/$(normalize_name "${source_macro}").fifo"
            echo "# Lecture depuis tube: ${source_macro}"
            echo "TUBE_SOURCE=\"${fifo_src}\""
            echo 'if [[ -p "$TUBE_SOURCE" ]]; then'
            echo "    ${var_recv}=\$(cat \"\$TUBE_SOURCE\")"
            echo '    echo "[MACRO] Données reçues du tube"'
            echo 'else'
            echo '    echo "[MACRO] ATTENTION: Tube introuvable ($TUBE_SOURCE)"'
            echo "    ${var_recv}=\"\""
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
            local ctype
            ctype=$(xml_get "$xml_file" "string(/macro/constraints/constraint[${c}]/@type)")

            echo "# Contrainte ${c}: ${ctype}"
            case "$ctype" in
                ESPACE_DISQUE)
                    local espace_min
                    espace_min=$(xml_get "$xml_file" "string(/macro/constraints/constraint[${c}]/config/param[@key='espace_minimum'])")
                    espace_min=${espace_min:-10}
                    echo 'if [[ $(df / | awk "NR==2 {print \$5}" | sed "s/%//") -lt '"${espace_min}"' ]]; then'
                    echo '    echo "[CONTRAINTE] Espace disque insuffisant"'
                    echo '    exit 1'
                    echo 'fi'
                    ;;
                PLAGE_HORAIRE)
                    local heure_debut heure_fin
                    heure_debut=$(xml_get "$xml_file" "string(/macro/constraints/constraint[${c}]/config/param[@key='heure_debut'])")
                    heure_fin=$(xml_get "$xml_file" "string(/macro/constraints/constraint[${c}]/config/param[@key='heure_fin'])")
                    echo '# Contrainte plage horaire'
                    echo 'HEURE_ACTUELLE=$(date +%H%M)'
                    echo 'if [[ "$HEURE_ACTUELLE" -lt '"${heure_debut:-0000}"' ]] || [[ "$HEURE_ACTUELLE" -gt '"${heure_fin:-2359}"' ]]; then'
                    echo '    echo "[CONTRAINTE] Hors plage horaire"'
                    echo '    exit 1'
                    echo 'fi'
                    ;;
                PROCESSUS_ACTIF)
                    local processus
                    processus=$(xml_get "$xml_file" "string(/macro/constraints/constraint[${c}]/config/param[@key='processus'])")
                    processus=${processus:-init}
                    echo 'if ! pgrep -x "'"${processus}"'" >/dev/null 2>&1; then'
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

            echo "# Action ${a}: ${alabel:-$atype}"

            # Récupération des paramètres de l'action
            local source motif destination chemin titre message commande service tube donnees
            source=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/config/param[@key='source'])")
            motif=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/config/param[@key='motif'])")
            destination=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/config/param[@key='destination'])")
            chemin=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/config/param[@key='chemin'])")
            titre=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/config/param[@key='titre'])")
            message=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/config/param[@key='message'])")
            commande=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/config/param[@key='commande'])")
            service=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/config/param[@key='service'])")
            tube=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/config/param[@key='tube'])")
            donnees=$(xml_get "$xml_file" "string(/macro/actions/action[${a}]/config/param[@key='donnees'])")

            case "$atype" in
                COPIER_FICHIER)
                    source=${source:-.}
                    motif=${motif:-*}
                    destination=${destination:-/tmp}
                    echo "mkdir -p \"${destination}\""
                    echo "cp -rv \"${source}\"/${motif} \"${destination}/\" 2>/dev/null || echo \"[ACTION] Aucun fichier à copier\""
                    ;;
                DEPLACER_FICHIER)
                    source=${source:-.}
                    motif=${motif:-*}
                    destination=${destination:-/tmp}
                    echo "mkdir -p \"${destination}\""
                    echo "mv -rv \"${source}\"/${motif} \"${destination}/\" 2>/dev/null || echo \"[ACTION] Aucun fichier à déplacer\""
                    ;;
                SUPPRIMER_FICHIER)
                    chemin=${chemin:-/tmp}
                    motif=${motif:--}
                    if [[ -n "$motif" && "$motif" != "-" ]]; then
                        echo "find \"${chemin}\" -name \"${motif}\" -type f -delete 2>/dev/null && echo \"[ACTION] Fichiers supprimés\" || echo \"[ACTION] Rien à supprimer\""
                    else
                        echo "rm -fv \"${chemin}\" 2>/dev/null && echo \"[ACTION] Fichier supprimé\" || echo \"[ACTION] Fichier non trouvé\""
                    fi
                    ;;
                NOTIFIER)
                    titre=${titre:-Notification}
                    message=${message:-}
                    echo 'if command -v notify-send >/dev/null 2>&1; then'
                    echo "    notify-send \"${titre}\" \"${message}\""
                    echo 'else'
                    echo "    echo \"[NOTIFICATION] ${titre}: ${message}\""
                    echo 'fi'
                    ;;
                EXECUTER_CMD)
                    commande=${commande:-echo "Commande vide"}
                    echo "eval \"${commande}\" 2>&1 | while read line; do echo \"[CMD] \$line\"; done"
                    ;;
                REDÉMARRER_SERV)
                    service=${service:-cron}
                    echo 'if systemctl is-active --quiet "'"${service}"'" 2>/dev/null; then'
                    echo "    sudo systemctl restart \"${service}\" && echo \"[SERVICE] ${service} redémarré\" || echo \"[SERVICE] Échec\""
                    echo 'else'
                    echo "    echo \"[SERVICE] Service '${service}' non trouvé\""
                    echo 'fi'
                    ;;
                SORTIR_RESULTAT)
                    tube=${tube:-resultat}
                    donnees=${donnees:-}
                    local fifo_out
                    fifo_out="${FIFO_BASE}/$(normalize_name "${tube}").fifo"
                    echo "mkdir -p \"\$(dirname \"${fifo_out}\")\""
                    echo '[[-p "'"$fifo_out"'" ]] || mkfifo "'"$fifo_out"'"'
                    echo "echo \"${donnees}\" > \"${fifo_out}\" &"
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

    generate_script "$xml_file" > "$output_file"
    chmod +x "$output_file"

    echo "OK: $output_file"
}

main "$@"
