#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: fix-projet.sh
# Description: Corrige le chemin .gitignore et nettoie les fichiers restants
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -euo pipefail

# Trouver la racine du projet (parent du dossier scripts/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
    echo "[$(date '+%H:%M:%S')] $*"
}

#------------------------------------------------------------------------------
# Etape 1: Corriger la ligne GITIGNORE dans fix-gitignore.sh
#------------------------------------------------------------------------------
fix_gitignore_script() {
    local script="$PROJECT_ROOT/scripts/fix-gitignore.sh"
    
    if [[ ! -f "$script" ]]; then
        log "ERREUR: $script introuvable"
        return 1
    fi
    
    log "Correction de la ligne GITIGNORE dans fix-gitignore.sh..."
    
    sed -i 's|GITIGNORE="$SCRIPT_DIR/.gitignore"|GITIGNORE="$(dirname "$SCRIPT_DIR")/.gitignore"|' "$script"
    
    log "Verification de la correction:"
    grep "GITIGNORE=" "$script"
    log "OK"
}

#------------------------------------------------------------------------------
# Etape 2: Supprimer le mauvais .gitignore dans scripts/
#------------------------------------------------------------------------------
remove_bad_gitignore() {
    local bad_file="$PROJECT_ROOT/scripts/.gitignore"
    
    if [[ -f "$bad_file" ]]; then
        rm -f "$bad_file"
        log "Supprime: scripts/.gitignore"
    else
        log "scripts/.gitignore deja absent"
    fi
}

#------------------------------------------------------------------------------
# Etape 3: Relancer fix-gitignore.sh pour generer le .gitignore racine
#------------------------------------------------------------------------------
run_fix_gitignore() {
    log "Execution de fix-gitignore.sh..."
    bash "$PROJECT_ROOT/scripts/fix-gitignore.sh"
}

#------------------------------------------------------------------------------
# Etape 4: Verifier le resultat
#------------------------------------------------------------------------------
verify_result() {
    log ""
    log "========== VERIFICATION =========="
    
    if [[ -f "$PROJECT_ROOT/.gitignore" ]]; then
        log "OK: .gitignore present a la racine"
    else
        log "ERREUR: .gitignore manquant a la racine"
        return 1
    fi
    
    if [[ ! -f "$PROJECT_ROOT/scripts/.gitignore" ]]; then
        log "OK: scripts/.gitignore supprime"
    else
        log "ERREUR: scripts/.gitignore encore present"
        return 1
    fi
    
    log ""
    log "Structure finale:"
    find "$PROJECT_ROOT" -type f -not -path '*/.git/*' -not -name '.*.swp' | sort
    log ""
    log "Tout est correct !"
    log "==================================="
}

#------------------------------------------------------------------------------
# Execution principale
#------------------------------------------------------------------------------
main() {
    log "Racine du projet: $PROJECT_ROOT"
    log ""
    
    fix_gitignore_script
    remove_bad_gitignore
    run_fix_gitignore
    verify_result
    
    log ""
    log "Termine! Pensez a mettre a jour Git:"
    log "  git add ."
    log "  git commit -m \"Correction .gitignore a la racine\""
    log "  git push"
}

main "$@"

