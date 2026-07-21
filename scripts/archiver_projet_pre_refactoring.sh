#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: archiver_projet_pre_refactoring.sh
# Description: Crée une archive complète du projet avant refactoring
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="macrosTitux_pre_refactoring_${TIMESTAMP}.tar.gz"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
success() { log "✅ $*"; }
warning() { log "⚠  $*"; }
error() { log "❌ $*"; }

main() {
    log "=========================================="
    log " ARCHIVAGE DU PROJET (Pré-refactoring)"
    log "=========================================="
    log " Projet: $PROJECT_ROOT"
    log " Archive: $ARCHIVE_NAME"
    log ""

    # Vérifier qu'on est bien dans macrosTitux
    if [[ ! -d "$PROJECT_ROOT/src" ]]; then
        error "Dossier src/ introuvable dans $PROJECT_ROOT"
        exit 1
    fi

    # Changer vers le dossier projet
    cd "$PROJECT_ROOT"

    # Créer l'archive compressée
    log "Création de l'archive..."
    tar -czf "$ARCHIVE_NAME" \
        --exclude='.git' \
        --exclude='venv' \
        --exclude='.pytest_cache' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='.DS_Store' \
        .

    if [[ -f "$ARCHIVE_NAME" ]]; then
        local taille
        taille=$(du -h "$ARCHIVE_NAME" | cut -f1)
        success "Archive créée: $ARCHIVE_NAME ($taille)"

        # Afficher les fichiers inclus
        log ""
        log "Contenu de l'archive:"
        tar -tzf "$ARCHIVE_NAME" | head -20
        log "... ($(tar -tzf "$ARCHIVE_NAME" | wc -l) fichiers au total)"

        # Vérifier l'intégrité
        log ""
        log "Vérification de l'intégrité..."
        if tar -tzf "$ARCHIVE_NAME" >/dev/null 2>&1; then
            success "Archive valide et récupérable"
        else
            error "Archive corrompue !"
            exit 1
        fi

        # Afficher chemin absolu
        log ""
        log "Chemin absolu: $PROJECT_ROOT/$ARCHIVE_NAME"

    else
        error "Échec de création de l'archive"
        exit 1
    fi

    log ""
    log "=========================================="
    log " Archivage terminé avec succès!"
    log " "
    log " Pour restaurer:"
    log "   tar -xzf $ARCHIVE_NAME -C /destination/"
    log "=========================================="
}

main "$@"
