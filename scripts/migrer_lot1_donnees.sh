#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: migrer_lot1_donnees.sh
# Description: Refactoring Lot 1 - Couche données (config.py + model.py + tests)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$PROJECT_ROOT/src"
TESTS_DIR="$PROJECT_ROOT/tests"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
success() { log "✅ $*"; }
warning() { log "⚠  $*"; }
error() { log "❌ $*"; }

#------------------------------------------------------------------------------
# Sauvegardes préalables
#------------------------------------------------------------------------------
creer_backup() {
    local fichier="$1"
    if [[ -f "$fichier" ]]; then
        cp "$fichier" "${fichier}.bak.$(date +%Y%m%d%H%M%S)"
        success "Backup: ${fichier}.bak.*"
    fi
}

#------------------------------------------------------------------------------
# Migration de src/config.py
#------------------------------------------------------------------------------
migrer_config_py() {
    log "Migration de $SRC_DIR/config.py..."

    crea_backup "$SRC_DIR/config.py"

    # Traduction des constantes
    sed -i 's/APP_NAME/NOM_APPLICATION/g' "$SRC_DIR/config.py"
    sed -i 's/APP_VERSION/VERSION_APPLICATION/g' "$SRC_DIR/config.py"
    sed -i 's/APP_LICENSE/LICENCE_APPLICATION/g' "$SRC_DIR/config.py"
    sed -i 's/DEFAULT_CONFIG/CONFIG_DEFAUT/g' "$SRC_DIR/config.py"
    sed -i 's/TRIGGERS/DECLNCHEURS/g' "$SRC_DIR/config.py"
    sed -i 's/ACTIONS/ACTIONS/g' "$SRC_DIR/config.py"  # Reste identique
    sed -i 's/CONSTRAINTS/CONTRAINTES/g' "$SRC_DIR/config.py"
    sed -i 's/TRIGGER_DEFAULT_PARAMS/PARAMS_DEFAUT_DECLNCHEUR/g' "$SRC_DIR/config.py"
    sed -i 's/ACTION_DEFAULT_PARAMS/PARAMS_DEFAUT_ACTION/g' "$SRC_DIR/config.py"
    sed -i 's/CONSTRAINT_DEFAULT_PARAMS/PARAMS_DEFAUT_CONTRAINTES/g' "$SRC_DIR/config.py"

    success "config.py traduit"
}

#------------------------------------------------------------------------------
# Migration de src/model.py
#------------------------------------------------------------------------------
migrer_model_py() {
    log "Migration de $SRC_DIR/model.py..."

    crea_backup "$SRC_DIR/model.py"

    # Imports et constantes
    sed -i 's/from config import APP_NAME, DEFAULT_CONFIG/from config import NOM_APPLICATION, CONFIG_DEFAUT/g' "$SRC_DIR/model.py"

    # Variables globales
    sed -i 's/CONFIG_DIR/DOSSIER_CONFIG/g' "$SRC_DIR/model.py"
    sed -i 's/MACRO_DIR/DOSSIER_MACROS/g' "$SRC_DIR/model.py"
    sed -i 's/CONF_FILE/FICHIER_CONF/g' "$SRC_DIR/model.py"

    # Fonctions
    sed -i 's/def init_dirs()/def initialiser_dossiers()/g' "$SRC_DIR/model.py"
    sed -i 's/def load_config()/def charger_config()/g' "$SRC_DIR/model.py"
    sed -i 's/def load_macros_list()/def charger_liste_macros()/g' "$SRC_DIR/model.py"
    sed -i 's/def save_macro(/def sauvegarder_macro(/g' "$SRC_DIR/model.py"
    sed -i 's/def generate_bash_from_xml(/def generer_bash_depuis_xml(/g' "$SRC_DIR/model.py"
    sed -i 's/def delete_macro(/def supprimer_macro(/g' "$SRC_DIR/model.py"

    # Paramètres de fonctions
    sed -i 's/trigger_data/donnees_declencheur/g' "$SRC_DIR/model.py"
    sed -i 's/xml_path/chemin_xml/g' "$SRC_DIR/model.py"
    sed -i 's/output_path/chemin_sortie/g' "$SRC_DIR/model.py"
    sed -i 's/dry_run/simulation/g' "$SRC_DIR/model.py"
    sed -i 's/macro_name/nom_macro/g' "$SRC_DIR/model.py"
    sed -i 's/script_path/chemin_script/g' "$SRC_DIR/model.py"
    sed -i 's/sh_path/chemin_sh/g' "$SRC_DIR/model.py"

    success "model.py traduit"
}

#------------------------------------------------------------------------------
# Mise à jour de src/macrosTitux.py
#------------------------------------------------------------------------------
migrer_macrotitux_py() {
    log "Migration de $SRC_DIR/macrosTitux.py..."

    crea_backup "$SRC_DIR/macrosTitux.py"

    # Appel à init_dirs() → initialiser_dossiers()
    sed -i 's/init_dirs()/initialiser_dossiers()/g' "$SRC_DIR/macrosTitux.py"

    # Fonction principale
    sed -i 's/def main()/def principal()/g' "$SRC_DIR/macrosTitux.py"
    sed -i 's/if __name__ == "__main__":/if __name__ == "__main__":/g' "$SRC_DIR/macrosTitux.py"  # Ne change rien

    success "macrosTitux.py traduit"
}

#------------------------------------------------------------------------------
# Mise à jour de src/gui.py
#------------------------------------------------------------------------------
migrer_gui_py() {
    log "Migration de $SRC_DIR/gui.py..."

    crea_backup "$SRC_DIR/gui.py"

    # Imports depuis model
    sed -i 's/from model import generate_bash_from_xml, init_dirs/from model import generer_bash_depuis_xml, initialiser_dossiers/g' "$SRC_DIR/gui.py"

    # Appels à initialiser_dossiers()
    sed -i 's/init_dirs()/initialiser_dossiers()/g' "$SRC_DIR/gui.py"

    # Appels à save_macro()
    sed -i 's/save_macro(/sauvegarder_macro(/g' "$SRC_DIR/gui.py"
    sed -i 's/delete_macro(/supprimer_macro(/g' "$SRC_DIR/gui.py"
    sed -i 's/generate_bash_from_xml(/generer_bash_depuis_xml(/g' "$SRC_DIR/gui.py"

    # Variables d'instance
    sed -i 's/self.selected_item/self.element_selectionne/g' "$SRC_DIR/gui.py"

    # Nom des boutons
    sed -i 's/+ Nouvelle macro/+ Nouvelle macro/g' "$SRC_DIR/gui.py"  # Ne change pas
    sed -i 's/Editer/Éditer/g' "$SRC_DIR/gui.py"
    sed -i 's/Tester/Tester/g' "$SRC_DIR/gui.py"
    sed -i 's/Exporter/Exporter/g' "$SRC_DIR/gui.py"
    sed -i 's/Importer/Importer/g' "$SRC_DIR/gui.py"

    success "gui.py traduit"
}

#------------------------------------------------------------------------------
# Mise à jour de src/dialogs.py
#------------------------------------------------------------------------------
migrer_dialogs_py() {
    log "Migration de $SRC_DIR/dialogs.py..."

    crea_backup "$SRC_DIR/dialogs.py"

    # Imports depuis config
    sed -i 's/from config import TRIGGERS, ACTIONS, CONSTRAINTS/from config import DECLNCHEURS, ACTIONS, CONTRAINTES/g' "$SRC_DIR/dialogs.py"

    # Imports depuis widgets
    sed -i 's/from widgets import TriggerWidget, ActionFrame, ConstraintFrame, VariableFrame/from widgets import WidgetDeclencheur, CadreAction, CadreContrainte, CadreVariable/g' "$SRC_DIR/dialogs.py"

    # Utilisations de widgets
    sed -i 's/TriggerWidget/WidgetDeclencheur/g' "$SRC_DIR/dialogs.py"
    sed -i 's/ActionFrame/CadreAction/g' "$SRC_DIR/dialogs.py"
    sed -i 's/ConstraintFrame/CadreContrainte/g' "$SRC_DIR/dialogs.py"
    sed -i 's/VariableFrame/CadreVariable/g' "$SRC_DIR/dialogs.py"

    success "dialogs.py traduit"
}

#------------------------------------------------------------------------------
# Mise à jour de src/widgets.py
#------------------------------------------------------------------------------
migrer_widgets_py() {
    log "Migration de $SRC_DIR/widgets.py..."

    crea_backup "$SRC_DIR/widgets.py"

    # Imports depuis config
    sed -i 's/from config import TRIGGERS, ACTIONS, CONSTRAINTS/from config import DECLNCHEURS, ACTIONS, CONTRAINTES/g' "$SRC_DIR/widgets.py"

    # Noms des classes
    sed -i 's/class TriggerWidget/class WidgetDeclencheur/g' "$SRC_DIR/widgets.py"
    sed -i 's/class ActionFrame/class CadreAction/g' "$SRC_DIR/widgets.py"
    sed -i 's/class ConstraintFrame/class CadreContrainte/g' "$SRC_DIR/widgets.py"
    sed -i 's/class VariableFrame/class CadreVariable/g' "$SRC_DIR/widgets.py"

    # Remplacement des références aux anciennes classes
    sed -i 's/super().__init__(parent, \*args, \*\*kwargs)/super().__init__(parent, *args, **kwargs)/g' "$SRC_DIR/widgets.py"  # Pas de changement

    # Variables d'instance
    sed -i 's/self.trigger_var/self.variable_declencheur/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.trigger_combo/self.combobox_declencheur/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.params_frame/self.cadre_params/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.param_entries/self.entrees_param/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.action_type_var/self.variable_type_action/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.action_combo/self.combobox_action/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.params_text/self.texte_params/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.action_num/self.numero_action/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.constraint_type_var/self.variable_type_contrainte/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.constraint_combo/self.combobox_contrainte/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.constraint_num/self.numero_contrainte/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.var_num/self.numero_variable/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.name_entry/self.entree_nom/g' "$SRC_DIR/widgets.py"
    sed -i 's/self.value_entry/self.entree_valeur/g' "$SRC_DIR/widgets.py"

    # Paramètres de méthodes
    sed -i 's/action_num=1/action_num=1/g' "$SRC_DIR/widgets.py"  # Reste pareil
    sed -i 's/constraint_num=1/constraint_num=1/g' "$SRC_DIR/widgets.py"
    sed -i 's/var_num=1/var_num=1/g' "$SRC_DIR/widgets.py"

    success "widgets.py traduit"
}

#------------------------------------------------------------------------------
# Mise à jour des tests
#------------------------------------------------------------------------------
migrer_tests() {
    log "Migration des tests..."

    # test_config.py
    crea_backup "$TESTS_DIR/test_config.py"
    sed -i 's/from config import TRIGGERS, ACTIONS, CONSTRAINTS, APP_NAME, APP_VERSION/from config import DECLNCHEURS, ACTIONS, CONTRAINTES, NOM_APPLICATION, VERSION_APPLICATION/g' "$TESTS_DIR/test_config.py"
    sed -i 's/assert APP_NAME/assert NOM_APPLICATION/g' "$TESTS_DIR/test_config.py"
    sed -i 's/assert APP_VERSION/assert VERSION_APPLICATION/g' "$TESTS_DIR/test_config.py"
    sed -i 's/TRIGGERS/DECLNCHEURS/g' "$TESTS_DIR/test_config.py"
    sed -i 's/CONSTRAINTS/CONTRAINTES/g' "$TESTS_DIR/test_config.py"
    sed -i 's/actions_exist/actions_exist/g' "$TESTS_DIR/test_config.py"  # Ne change pas
    sed -i 's/test_action_keys_are_uppercase/test_cles_action_en_majuscules/g' "$TESTS_DIR/test_config.py"
    sed -i 's/test_trigger_keys_are_uppercase/test_cles_declencheurs_en_majuscules/g' "$TESTS_DIR/test_config.py"
    sed -i 's/test_action_values_not_empty/test_valeurs_action_non_vides/g' "$TESTS_DIR/test_config.py"
    sed -i 's/test_trigger_values_not_empty/test_valeurs_declencheurs_non_vides/g' "$TESTS_DIR/test_config.py"

    # test_model.py
    crea_backup "$TESTS_DIR/test_model.py"
    sed -i 's/from model import save_macro, load_macros_list, init_dirs, MACRO_DIR/from model import sauvegarder_macro, charger_liste_macros, initialiser_dossiers, DOSSIER_MACROS/g' "$TESTS_DIR/test_model.py"
    sed -i 's/save_macro/sauvegarder_macro/g' "$TESTS_DIR/test_model.py"
    sed -i 's/init_dirs/initialiser_dossiers/g' "$TESTS_DIR/test_model.py"
    sed -i 's/MACRO_DIR/DOSSIER_MACROS/g' "$TESTS_DIR/test_model.py"
    sed -i 's/trigger_data/donnees_declencheur/g' "$TESTS_DIR/test_model.py"
    sed -i 's/xml_file/fichier_xml/g' "$TESTS_DIR/test_model.py"

    # test_generate_bash.py
    crea_backup "$TESTS_DIR/test_generate_bash.py"
    sed -i 's/sample_macro_xml/echantillon_xml/g' "$TESTS_DIR/test_generate_bash.py"
    sed -i 's/mock_generate_bash_script/echantillon_script_bash/g' "$TESTS_DIR/test_generate_bash.py"

    # test_widgets.py
    crea_backup "$TESTS_DIR/test_widgets.py"
    sed -i 's/from config import TRIGGERS, ACTIONS, CONSTRAINTS/from config import DECLNCHEURS, ACTIONS, CONTRAINTES/g' "$TESTS_DIR/test_widgets.py"
    sed -i 's/TRIGGERS/DECLNCHEURS/g' "$TESTS_DIR/test_widgets.py"
    sed -i 's/actions_exist/actions_exist/g' "$TESTS_DIR/test_widgets.py"  # Ne change pas
    sed -i 's/CONSTRAINTS/CONTRAINTES/g' "$TESTS_DIR/test_widgets.py"
    sed -i 's/TestWidgetsLogic/TestLogiqueWidgets/g' "$TESTS_DIR/test_widgets.py"

    # conftest.py
    crea_backup "$TESTS_DIR/conftest.py"
    sed -i 's/sample_macro_xml/echantillon_xml/g' "$TESTS_DIR/conftest.py"
    sed -i 's/mock_generate_bash_script/echantillon_script_bash/g' "$TESTS_DIR/conftest.py"
    sed -i 's/temp_dir/dossier_temporaire/g' "$TESTS_DIR/conftest.py"

    success "Tests traduits"
}

#------------------------------------------------------------------------------
# Migration du convertisseur XML → Bash
#------------------------------------------------------------------------------
migrer_generate_bash_sh() {
    log "Migration de $SRC_DIR/generate_bash.sh..."

    crea_backup "$SRC_DIR/generate_bash.sh"

    # Variables du script bash
    sed -i 's/INPUT_XML/ENTREE_XML/g' "$SRC_DIR/generate_bash.sh"
    sed -i 's/OUTPUT_SH/SORTIE_SH/g' "$SRC_DIR/generate_bash.sh"
    sed -i 's/MACRO_NAME/NOM_MACRO/g' "$SRC_DIR/generate_bash.sh"
    sed -i 's/TRIGGER_TYPE/TYPE_DECLNCHEUR/g' "$SRC_DIR/generate_bash.sh"
    sed -i 's/TRIGGER_LABEL/LIBELLE_DECLNCHEUR/g' "$SRC_DIR/generate_bash.sh"
    sed -i 's/TRIGGER_PARAMS/PARAMS_DECLNCHEUR/g' "$SRC_DIR/generate_bash.sh"

    success "generate_bash.sh traduit"
}

#------------------------------------------------------------------------------
# Exécution principale
#------------------------------------------------------------------------------
main() {
    log "=========================================="
    log " LOT 1 - COUCHE DONNÉES"
    log "=========================================="
    log " Projet: $PROJECT_ROOT"
    log ""

    # Sauvegardes
    log "Création des backups..."
    for f in "$SRC_DIR/config.py" "$SRC_DIR/model.py" "$SRC_DIR/macrosTitux.py" \
             "$SRC_DIR/gui.py" "$SRC_DIR/dialogs.py" "$SRC_DIR/widgets.py" \
             "$SRC_DIR/generate_bash.sh" \
             "$TESTS_DIR/test_config.py" "$TESTS_DIR/test_model.py" \
             "$TESTS_DIR/test_generate_bash.py" "$TESTS_DIR/test_widgets.py" \
             "$TESTS_DIR/conftest.py"; do
        if [[ -f "$f" ]]; then
            cp "$f" "${f}.bak.$(date +%Y%m%d%H%M%S)"
        fi
    done
    success "Backups créés"

    # Migration
    log ""
    log "Exécution de la migration..."
    migrer_config_py
    migrer_model_py
    migrer_macrotitux_py
    migrer_gui_py
    migrer_dialogs_py
    migrer_widgets_py
    migrer_tests
    migrer_generate_bash_sh

    # Résumé
    log ""
    log "=========================================="
    success "Migration Lot 1 terminée!"
    log ""
    log "Fichiers modifiés :"
    log "  • $SRC_DIR/config.py"
    log "  • $SRC_DIR/model.py"
    log "  • $SRC_DIR/macrosTitux.py"
    log "  • $SRC_DIR/gui.py"
    log "  • $SRC_DIR/dialogs.py"
    log "  • $SRC_DIR/widgets.py"
    log "  • $SRC_DIR/generate_bash.sh"
    log "  • $TESTS_DIR/*.py"
    log ""
    log "Prochaine étape : lancer les tests"
    log "  pytest tests/ -v"
    log "=========================================="
}

main "$@"
