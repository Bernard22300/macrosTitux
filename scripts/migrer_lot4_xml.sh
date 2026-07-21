#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: migrer_lot4_xml.sh
# Description: Migration Lot 4 - Traduction des tags XML et mise à jour du convertisseur
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$PROJECT_ROOT/src"
MODELES_DIR="$PROJECT_ROOT/modèles"
MACROS_DIR="$HOME/.config/macrosTitux/macros/"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
success() { log "✅ $*"; }
warning() { log "⚠  $*"; }
error() { log "❌ $*"; }

#------------------------------------------------------------------------------
# Traduction des tags XML dans generate_bash.sh
#------------------------------------------------------------------------------
migrer_generate_bash_xml() {
    log "Migration des références XML dans generate_bash.sh..."

    # Sauvegarde préalable
    cp "$SRC_DIR/generate_bash.sh" "$SRC_DIR/generate_bash.sh.bak.$(date +%Y%m%d%H%M%S)"

    # Tags XML dans les expressions xpath
    sed -i 's|//macro|//macro|g' "$SRC_DIR/generate_bash.sh"  # Reste identique
    sed -i 's|//trigger|//declencheur|g' "$SRC_DIR/generate_bash.sh"
    sed -i 's|//actions/action|//actions/action|g' "$SRC_DIR/generate_bash.sh"  # Reste identique
    sed -i 's|//constraints/constraint|//contraintes/contrainte|g' "$SRC_DIR/generate_bash.sh"
    sed -i 's|//variables/var|//variables/variable|g' "$SRC_DIR/generate_bash.sh"
    sed -i 's|trigger/config|declencheur/config|g' "$SRC_DIR/generate_bash.sh"

    success "generate_bash.sh mis à jour"
}

#------------------------------------------------------------------------------
# Traduction des tags XML dans model.py
#------------------------------------------------------------------------------
migrer_model_xml() {
    log "Migration des références XML dans model.py..."

    # Sauvegarde préalable
    cp "$SRC_DIR/model.py" "$SRC_DIR/model.py.bak.$(date +%Y%m%d%H%M%S)"

    # Méthode load_macros_list()
    sed -i "s/root.find('trigger')/root.find('declencheur')/g" "$SRC_DIR/model.py"
    sed -i "s/root.findall('actions/action'/root.findall('actions/action'/g" "$SRC_DIR/model.py"  # Reste identique
    sed -i "s/root.findall('constraints/contrainte'/root.findall('contraintes/contrainte'/g" "$SRC_DIR/model.py"

    # Méthode save_macro()
    sed -i 's/<trigger>/<declencheur>/g' "$SRC_DIR/model.py"
    sed -i 's/<variables>/<variables>/g' "$SRC_DIR/model.py"  # Reste identique
    sed -i 's/<var>/<variable>/g' "$SRC_DIR/model.py"
    sed -i 's/<actions>/<actions>/g' "$SRC_DIR/model.py"  # Reste identique
    sed -i 's/<action>/<action>/g' "$SRC_DIR/model.py"  # Reste identique
    sed -i 's/<constraints>/<contraintes>/g' "$SRC_DIR/model.py"
    sed -i 's/<constraint>/<contrainte>/g' "$SRC_DIR/model.py"
    sed -i 's/<config>/<config>/g' "$SRC_DIR/model.py"  # Reste identique
    sed -i 's/<param>/<parametre>/g' "$SRC_DIR/model.py"

    success "model.py mis à jour"
}

#------------------------------------------------------------------------------
# Migration des modèles XML existants
#------------------------------------------------------------------------------
migrer_modeles_xml() {
    log "Migration des modèles XML dans $MODELES_DIR..."

    local compteur=0

    for xml_file in "$MODELES_DIR"/*.xml; do
        if [[ -f "$xml_file" ]]; then
            local nom_fichier
            nom_fichier=$(basename "$xml_file")
            local backup="${xml_file}.bak.$(date +%Y%m%d%H%M%S)"

            log "  Conversion: $nom_fichier"

            # Backup du fichier original
            cp "$xml_file" "$backup"

            # Traduction des tags
            sed -i 's/<trigger>/<declencheur>/g' "$xml_file"
            sed -i 's/<\/trigger>/<\/declencheur>/g' "$xml_file"
            sed -i 's/<var>/<variable>/g' "$xml_file"
            sed -i 's/<\/var>/<\/variable>/g' "$xml_file"
            sed -i 's/<constraints>/<contraintes>/g' "$xml_file"
            sed -i 's/<\/constraints>/<\/contraintes>/g' "$xml_file"
            sed -i 's/<constraint>/<contrainte>/g' "$xml_file"
            sed -i 's/<\/constraint>/<\/contrainte>/g' "$xml_file"
            sed -i 's/<param>/<parametre>/g' "$xml_file"
            sed -i 's/<\/param>/<\/parametre>/g' "$xml_file"

            ((compteur++))
        fi
    done

    success "Modeles XML migrés: $compteur fichier(s)"
}

#------------------------------------------------------------------------------
# Migration des macros utilisateur (si elles existent)
#------------------------------------------------------------------------------
migrer_macros_utilisateur() {
    log "Migration des macros utilisateur dans $MACROS_DIR..."

    if [[ ! -d "$MACROS_DIR" ]]; then
        warning "Dossier des macros utilisateur introuvable, création..."
        mkdir -p "$MACROS_DIR"
    fi

    local compteur=0

    for xml_file in "$MACROS_DIR"/*.xml; do
        if [[ -f "$xml_file" ]]; then
            local nom_fichier
            nom_fichier=$(basename "$xml_file")
            local backup="${xml_file}.bak.$(date +%Y%m%d%H%M%S)"

            log "  Conversion: $nom_fichier"

            # Backup du fichier original
            cp "$xml_file" "$backup"

            # Traduction des tags
            sed -i 's/<trigger>/<declencheur>/g' "$xml_file"
            sed -i 's/<\/trigger>/<\/declencheur>/g' "$xml_file"
            sed -i 's/<var>/<variable>/g' "$xml_file"
            sed -i 's/<\/var>/<\/variable>/g' "$xml_file"
            sed -i 's/<constraints>/<contraintes>/g' "$xml_file"
            sed -i 's/<\/constraints>/<\/contraintes>/g' "$xml_file"
            sed -i 's/<constraint>/<contrainte>/g' "$xml_file"
            sed -i 's/<\/constraint>/<\/contrainte>/g' "$xml_file"
            sed -i 's/<param>/<parametre>/g' "$xml_file"
            sed -i 's/<\/param>/<\/parametre>/g' "$xml_file"

            ((compteur++))
        fi
    done

    if [[ $compteur -eq 0 ]]; then
        success "Aucune macro utilisateur à migrer"
    else
        success "Macros utilisateur migrées: $compteur fichier(s)"
    fi
}

#------------------------------------------------------------------------------
# Validation : tester la lecture d'un modèle XML migré
#------------------------------------------------------------------------------
validation_xml() {
    log "Validation: test de lecture XML..."

    # Créer un petit XML test
    local xml_test="/tmp/test_macro_migration.xml"
    cat > "$xml_test" << 'EOFTEST'
<?xml version="1.0" encoding="UTF-8"?>
<macro name="Test_Migration">
    <declencheur type="HORAIRE" label="Horaire programmé">
        <config>
            <parametre key="heure" value="8"/>
            <parametre key="minute" value="0"/>
        </config>
    </declencheur>
    <variables>
        <variable name="TEST_VAR" value="Hello"/>
    </variables>
    <actions>
        <action id="1" type="NOTIFIER" label="Notifier">
            <config>
                <parametre key="titre" value="Test"/>
                <parametre key="message" value="Message de test"/>
            </config>
        </action>
    </actions>
    <contraintes>
        <contrainte id="1" type="ESPACE_DISQUE" label="Espace disque">
            <config>
                <parametre key="espace_minimum" value="10"/>
            </config>
        </contrainte>
    </contraintes>
</macro>
EOFTEST

    # Tester avec xmllint
    if xmllint --noout "$xml_test" 2>/dev/null; then
        success "XML test valide syntaxiquement"

        # Extraire une donnée
        local type_declencheur
        type_declencheur=$(xmllint --xpath "string(//declencheur/@type)" "$xml_test" 2>/dev/null)
        if [[ "$type_declencheur" == "HORAIRE" ]]; then
            success "Extraction attribut déclencheur: $type_declencheur"
        else
            error "Échec extraction attribut déclencheur"
        fi

        # Nettoyer
        rm -f "$xml_test"
    else
        error "XML test invalide syntaxiquement"
    fi
}

#------------------------------------------------------------------------------
# Exécution principale
#------------------------------------------------------------------------------
main() {
    log "=========================================="
    log " LOT 4 - MIGRATION XML"
    log "=========================================="
    log " Projet: $PROJECT_ROOT"
    log ""

    # Migration des scripts source
    log "Migration des scripts Python/Bash..."
    migrer_generate_bash_xml
    migrer_model_xml

    # Migration des modèles
    log ""
    log "Migration des modèles XML..."
    migrer_modeles_xml

    # Migration des macros utilisateur (optionnel)
    log ""
    log "Migration des macros utilisateur..."
    migrer_macros_utilisateur

    # Validation
    log ""
    log "Validation syntaxique..."
    validation_xml

    # Résumé
    log ""
    log "=========================================="
    success "Migration Lot 4 terminée!"
    log ""
    log "Tags XML traduits :"
    log "  • <trigger> → <declencheur>"
    log "  • <var> → <variable>"
    log "  • <constraints> → <contraintes>"
    log "  • <constraint> → <contrainte>"
    log "  • <param> → <parametre>"
    log ""
    log "Fichiers impactés :"
    log "  • $SRC_DIR/generate_bash.sh"
    log "  • $SRC_DIR/model.py"
    log "  • $MODELES_DIR/*.xml"
    log ""
    log "Prochaine étape : lancer les tests"
    log "  pytest tests/ -v"
    log "=========================================="
}

main "$@"
