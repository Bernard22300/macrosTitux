#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: sauvegarder_projet.sh
# Description: Nettoie, ajoute, committe et pousse les modifications vers GitHub
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
ok() { log "✅ $*"; }
err() { log "❌ $*"; }

log "Démarrage de la sauvegarde..."
log "Projet: $PROJECT_ROOT"
log ""

# 1. Vérifier dépôt Git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    err "Ce dossier n'est pas un dépôt Git"
    exit 1
fi
ok "Dépôt Git détecté"

# 1.5 NETTOYAGE AUTOMATIQUE (caches et scripts one-shot)
log "Nettoyage automatique (caches et scripts temporaires)..."
find "$PROJECT_ROOT" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -name "*.pyc" -delete 2>/dev/null || true
find "$PROJECT_ROOT" -name "*.kate-swp" -delete 2>/dev/null || true
find "$PROJECT_ROOT" -name "*.swp" -delete 2>/dev/null || true
find "$PROJECT_ROOT" -name "*~" -delete 2>/dev/null || true

# Supprimer les scripts one-shot connus
rm -f "$PROJECT_ROOT/scripts/migrer_vers_bloc_fonctions.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/archiver_projet_pre_refactoring.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/corriger_xml.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/creer_macro_test_demo.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/fix-gitignore.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/fix-projet.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/generer_fichiers_manquants.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/gestion_fonctions.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/implenter_demo_test.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/migrer_lot1_donnees.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/migrer_lot4_xml.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/migrer_widgets_vers_edition.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/refactor_modulaire.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/scripts/refonte_application_nouvelle_architecture.sh" 2>/dev/null || true
rm -f "$PROJECT_ROOT/src/constants_update.patch" 2>/dev/null || true

ok "Nettoyage terminé"

# 2. Afficher changements
log "Changements détectés :"
git status --short
echo ""

# 3. Vérifier qu'il y a des changements
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    log "Aucun changement à sauvegarder."

    # Vérifier si des commits non poussés existent
    AHEAD=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "0")
    if [ "$AHEAD" -gt 0 ]; then
        log "$AHEAD commit(s) non poussé(s) — envoi vers GitHub..."
        if git push origin main; then
            ok "Push terminé"
        else
            err "Échec du push — vérifie ta connexion ou les droits d'accès"
            exit 1
        fi
    fi
    exit 0
fi

# 4. Message de commit
COMMIT_MSG="${1:-Mise à jour du projet}"
log "Message de commit: $COMMIT_MSG"

# 5. Ajouter
log "Ajout des fichiers..."
git add .
if [ $? -ne 0 ]; then
    err "Échec de git add"
    exit 1
fi
ok "Fichiers ajoutés"

# 6. Committer
log "Commit..."
git commit -m "$COMMIT_MSG"
if [ $? -ne 0 ]; then
    err "Échec du commit"
    exit 1
fi
ok "Commit créé"

# 7. Récupérer les changements distants (sans masquer les erreurs)
log "Synchronisation avec le dépôt distant..."
git fetch origin main 2>/dev/null

BEHIND=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
if [ "$BEHIND" -gt 0 ]; then
    log "Le dépôt distant a $BEHIND commit(s) en avance — rebase..."
    if ! git pull --rebase origin main; then
        err "Échec du rebase — résous les conflits manuellement"
        exit 1
    fi
    ok "Rebase réussi"
fi

# 8. Pousser (avec vérification explicite)
log "Envoi vers GitHub..."
if git push origin main; then
    ok "Push terminé avec succès"
else
    err "Échec du push — vérifie ta connexion ou les droits d'accès"
    err "Ton commit est local. Lance 'git push origin main' manuellement."
    exit 1
fi

# 9. Résumé
log ""
log "=========================================="
log " SAUVEGARDE TERMINÉE"
log "=========================================="
log " Branche: $(git branch --show-current)"
log " Dernier commit: $(git log -1 --oneline)"
log " Statut distant: $(git status -sb | head -1)"
log "=========================================="
