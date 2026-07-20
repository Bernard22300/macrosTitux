#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: sauvegarder_projet.sh
# Description: Ajoute, committe et pousse les modifications vers GitHub
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

log "Démarrage de la sauvegarde..."
log "Projet: $PROJECT_ROOT"
log ""

# Vérifier dépôt Git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "ERREUR: Ce dossier n'est pas un dépôt Git"
    exit 1
fi
log "OK: Dépôt Git détecté"

# Afficher changements
log "Changements détectés :"
git status --short
echo ""

# Récupérer message de commit
COMMIT_MSG="${1:-Mise à jour du projet}"
log "Message de commit: $COMMIT_MSG"

# Ajouter
log "Ajout des fichiers..."
git add .

# Committer
log "Commit..."
git commit -m "$COMMIT_MSG"

# Pousser
log "Envoi vers GitHub..."
