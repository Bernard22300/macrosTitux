#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: migrer_widgets_vers_edition.sh
# Description: Renomme widgets.py -> fenetreEditionMacro.py et les classes
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$PROJECT_ROOT/src"
TESTS_DIR="$PROJECT_ROOT/tests"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
success() { log "✅ $*"; }
error() { log "❌ $*"; }

main() {
    log "=========================================="
    log " MIGRATION widgets.py -> fenetreEditionMacro.py"
    log "=========================================="
    log ""
    
    # 1. Renommer le fichier
    log "Renommage du fichier..."
    if [[ -f "$SRC_DIR/widgets.py" ]]; then
        mv "$SRC_DIR/widgets.py" "$SRC_DIR/fenetreEditionMacro.py"
        success "widgets.py -> fenetreEditionMacro.py"
    else
        error "widgets.py introuvable"
        exit 1
    fi
    
    # 2. Remplacer les noms de classes dans fenetreEditionMacro.py
    log "Migration des classes dans fenetreEditionMacro.py..."
    sed -i 's/class WidgetDeclencheur/class EditionDeclencheur/g' "$SRC_DIR/fenetreEditionMacro.py"
    sed -i 's/WidgetDeclencheur/EditionDeclencheur/g' "$SRC_DIR/fenetreEditionMacro.py"
    sed -i 's/class CadreAction/class EditionAction/g' "$SRC_DIR/fenetreEditionMacro.py"
    sed -i 's/CadreAction/EditionAction/g' "$SRC_DIR/fenetreEditionMacro.py"
    sed -i 's/class CadreContrainte/class EditionContrainte/g' "$SRC_DIR/fenetreEditionMacro.py"
    sed -i 's/CadreContrainte/EditionContrainte/g' "$SRC_DIR/fenetreEditionMacro.py"
    sed -i 's/class CadreVariable/class EditionVariable/g' "$SRC_DIR/fenetreEditionMacro.py"
    sed -i 's/CadreVariable/EditionVariable/g' "$SRC_DIR/fenetreEditionMacro.py"
    success "Classes renommees dans fenetreEditionMacro.py"
    
    # 3. Mettre a jour dialogs.py
    log "Mise a jour de dialogs.py..."
    sed -i 's/from widgets import/from fenetreEditionMacro import/g' "$SRC_DIR/dialogs.py"
    sed -i 's/WidgetDeclencheur/EditionDeclencheur/g' "$SRC_DIR/dialogs.py"
    sed -i 's/CadreAction/EditionAction/g' "$SRC_DIR/dialogs.py"
    sed -i 's/CadreContrainte/EditionContrainte/g' "$SRC_DIR/dialogs.py"
    sed -i 's/CadreVariable/EditionVariable/g' "$SRC_DIR/dialogs.py"
    success "dialogs.py mis a jour"
    
    # 4. Mettre a jour gui.py (si references)
    log "Verification de gui.py..."
    if grep -q "widgets" "$SRC_DIR/gui.py" 2>/dev/null; then
        sed -i 's/from widgets import/from fenetreEditionMacro import/g' "$SRC_DIR/gui.py"
        sed -i 's/WidgetDeclencheur/EditionDeclencheur/g' "$SRC_DIR/gui.py"
        sed -i 's/CadreAction/EditionAction/g' "$SRC_DIR/gui.py"
        sed -i 's/CadreContrainte/EditionContrainte/g' "$SRC_DIR/gui.py"
        sed -i 's/CadreVariable/EditionVariable/g' "$SRC_DIR/gui.py"
        success "gui.py mis a jour"
    else
        success "gui.py: aucune reference directe aux widgets"
    fi
    
    # 5. Mettre a jour les tests
    log "Mise a jour des tests..."
    if [[ -f "$TESTS_DIR/test_widgets.py" ]]; then
        mv "$TESTS_DIR/test_widgets.py" "$TESTS_DIR/test_fenetre_edition_macro.py"
        sed -i 's/from widgets import/from fenetreEditionMacro import/g' "$TESTS_DIR/test_fenetre_edition_macro.py"
        sed -i 's/from src.widgets/from src.fenetreEditionMacro/g' "$TESTS_DIR/test_fenetre_edition_macro.py"
        sed -i 's/WidgetDeclencheur/EditionDeclencheur/g' "$TESTS_DIR/test_fenetre_edition_macro.py"
        sed -i 's/CadreAction/EditionAction/g' "$TESTS_DIR/test_fenetre_edition_macro.py"
        sed -i 's/CadreContrainte/EditionContrainte/g' "$TESTS_DIR/test_fenetre_edition_macro.py"
        sed -i 's/CadreVariable/EditionVariable/g' "$TESTS_DIR/test_fenetre_edition_macro.py"
        sed -i 's/TestWidgetsLogic/TestLogiqueEdition/g' "$TESTS_DIR/test_fenetre_edition_macro.py"
        sed -i 's/test_widgets/test_fenetre_edition_macro/g' "$TESTS_DIR/test_fenetre_edition_macro.py"
        success "test_widgets.py -> test_fenetre_edition_macro.py"
    fi
    
    # 6. Mettre a jour conftest.py (si references)
    if [[ -f "$TESTS_DIR/conftest.py" ]]; then
        sed -i 's/from widgets import/from fenetreEditionMacro import/g' "$TESTS_DIR/conftest.py"
        sed -i 's/from src.widgets/from src.fenetreEditionMacro/g' "$TESTS_DIR/conftest.py"
        sed -i 's/WidgetDeclencheur/EditionDeclencheur/g' "$TESTS_DIR/conftest.py"
        sed -i 's/CadreAction/EditionAction/g' "$TESTS_DIR/conftest.py"
        sed -i 's/CadreContrainte/EditionContrainte/g' "$TESTS_DIR/conftest.py"
        sed -i 's/CadreVariable/EditionVariable/g' "$TESTS_DIR/conftest.py"
        success "conftest.py mis a jour"
    fi
    
    # 7. Mettre a jour model.py (si references)
    if [[ -f "$SRC_DIR/model.py" ]]; then
        if grep -q "widgets" "$SRC_DIR/model.py" 2>/dev/null; then
            sed -i 's/from widgets import/from fenetreEditionMacro import/g' "$SRC_DIR/model.py"
            success "model.py mis a jour"
        fi
    fi
    
    # 8. Nettoyer le cache
    rm -rf "$SRC_DIR/__pycache__" "$TESTS_DIR/__pycache__"
    
    # 9. Mettre a jour README.md
    if [[ -f "$PROJECT_ROOT/README.md" ]]; then
        sed -i 's/widgets.py.*Composants GUI/fenetreEditionMacro.py  Composants d edition/g' "$PROJECT_ROOT/README.md"
        sed -i 's/WidgetDeclencheur/EditionDeclencheur/g' "$PROJECT_ROOT/README.md"
        sed -i 's/CadreAction/EditionAction/g' "$PROJECT_ROOT/README.md"
        sed -i 's/CadreContrainte/EditionContrainte/g' "$PROJECT_ROOT/README.md"
        sed -i 's/CadreVariable/EditionVariable/g' "$PROJECT_ROOT/README.md"
        sed -i 's/test_widgets.py/test_fenetre_edition_macro.py/g' "$PROJECT_ROOT/README.md"
        sed -i 's/test_widgets/test_fenetre_edition_macro/g' "$PROJECT_ROOT/README.md"
        sed -i 's/TestLogiqueWidgets/TestLogiqueEdition/g' "$PROJECT_ROOT/README.md"
        success "README.md mis a jour"
    fi
    
    log ""
    log "=========================================="
    success "Migration terminee!"
    log ""
    log "Renommages effectues :"
    log "  Fichier: widgets.py -> fenetreEditionMacro.py"
    log "  Classe:  WidgetDeclencheur -> EditionDeclencheur"
    log "  Classe:  CadreAction -> EditionAction"
    log "  Classe:  CadreContrainte -> EditionContrainte"
    log "  Classe:  CadreVariable -> EditionVariable"
    log "  Test:    test_widgets.py -> test_fenetre_edition_macro.py"
    log ""
    log "Prochaine etape :"
    log "  pytest tests/ -v"
    log "  python3 src/macrosTitux.py"
    log "=========================================="
}

main "$@"
