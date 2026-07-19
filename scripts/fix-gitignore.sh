#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: fix-gitignore.sh
# Description: Configure .gitignore pour exclure fichiers temporaires
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITIGNORE="$(dirname "$SCRIPT_DIR")/.gitignore"
LOG_FILE="/tmp/fix-gitignore-log.txt"

#------------------------------------------------------------------------------
# Fonction: Message de log
#------------------------------------------------------------------------------
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

#------------------------------------------------------------------------------
# Fonction: Verifier encodage
#------------------------------------------------------------------------------
check_encoding() {
    local current_encoding
    current_encoding=$(locale charmap)
    
    if [[ "$current_encoding" != "UTF-8" ]]; then
        log "WARNING: Encodage detecte: $current_encoding (attendu: UTF-8)"
        log "Continuation possible mais risques d'incoherences."
    else
        log "Encodage: $current_encoding - OK"
    fi
}

#------------------------------------------------------------------------------
# Fonction: Creer ou mettre a jour .gitignore
#------------------------------------------------------------------------------
configure_gitignore() {
    log "Traitement du fichier .gitignore..."
    
    # Contenu minimal pour .gitignore
    cat > "$GITIGNORE" << 'EOF'
#------------------------------------------------------------------------------
# Fichiers temporaires d'editeurs
#------------------------------------------------------------------------------
.*.kate-swp
.*.swp
.*.swo
*~
*.bak

#------------------------------------------------------------------------------
# Python
#------------------------------------------------------------------------------
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/

#------------------------------------------------------------------------------
# Divers
#------------------------------------------------------------------------------
*.log
.DS_Store
Thumbs.db

#------------------------------------------------------------------------------
# Dossiers de builds ou exports
#------------------------------------------------------------------------------
dist/
build/
*.sh~
EOF
    
    log "Fichier .gitignore mis a jour: $GITIGNORE"
}

#------------------------------------------------------------------------------
# Fonction: Nettoyer fichiers deja versionnes (optionnel)
#------------------------------------------------------------------------------
cleanup_existing_files() {
    log "Recherche de fichiers temporaires a supprimer..."
    
    local count=0
    while IFS= read -r -d '' file; do
        log "  Suppression: $file"
        rm -f "$file"
        ((count++)) || true
    done < <(find "$SCRIPT_DIR" -type f \( -name ".*.swp" -o -name "*~" \) -print0 2>/dev/null)
    
    if [[ $count -gt 0 ]]; then
        log "Total supprime: $count fichier(s)"
    else
        log "Aucun fichier temporaire trouve."
    fi
}

#------------------------------------------------------------------------------
# Fonction: Afficher resume
#------------------------------------------------------------------------------
show_summary() {
    log ""
    log "=========================================="
    log "RESUME DE LA CONFIGURATION"
    log "=========================================="
    log "Fichier .gitignore: $GITIGNORE"
    log ""
    log "Regles actives:"
    grep -v '^#' "$GITIGNORE" | grep -v '^$' | sed 's/^/  - /'
    log ""
    log "Commandes Git a executer ensuite:"
    log "  git add .gitignore"
    log "  git rm --cached *.kate-swp *.swp 2>/dev/null || true"
    log "  git commit -m \"Configuration .gitignore\""
    log "=========================================="
}

#------------------------------------------------------------------------------
# Execution principale
#------------------------------------------------------------------------------
main() {
    log "Lancement de la configuration .gitignore..."
    
    check_encoding
    configure_gitignore
    cleanup_existing_files
    show_summary
    
    log "Configuration terminee avec succes !"
}

# Lancer le script
main "$@"

