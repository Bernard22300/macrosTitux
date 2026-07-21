#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: generer_fichiers_manquants.sh
# Description: Crée les fichiers manquants prioritaires pour macrosTitux v0.3
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -uo pipefail

# Remonte d'un niveau depuis scripts/ vers la racine du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$PROJECT_ROOT/src"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
success() { log "✅ $*"; }
warning() { log "⚠  $*"; }
error() { log "❌ $*"; }

#------------------------------------------------------------------------------
# Création de src/config.py
#------------------------------------------------------------------------------
creer_config_py() {
    log "Création de $SRC_DIR/config.py..."

    cat > "$SRC_DIR/config.py" << 'EOFCONFIG'
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: config.py
# Description: Constantes et configurations globales de l'application
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

APP_NAME = "macrosTitux"
APP_VERSION = "0.3"
APP_LICENSE = "GPL-3.0"

DEFAULT_CONFIG = {
    "theme": "defaut",
    "langue": "fr_FR.UTF-8",
    "notifications": True,
    "journal_activite": True
}

#------------------------------------------------------------------------------
# Déclencheurs disponibles (TYPE_CODE: Libellé affiché)
#------------------------------------------------------------------------------
TRIGGERS = {
    "DEMARRAGE": "Au démarrage du système",
    "HORAIRE": "Horaire programmé",
    "FICHIER_MODIFIE": "Fichier modifié",
    "FICHIER_CREE": "Fichier créé",
    "RESEAU_ACTIF": "Réseau actif détecté",
    "SORTIE_TUBE": "Sortie de tube (named pipe)",
    "USB_CONNECTE": "Périphérique USB connecté"
}

#------------------------------------------------------------------------------
# Actions disponibles (TYPE_CODE: Libellé affiché)
#------------------------------------------------------------------------------
ACTIONS = {
    "NOTIFIER": "Notifier l'utilisateur",
    "COPIER_FICHIER": "Copier un fichier",
    "DEPLACER_FICHIER": "Déplacer un fichier",
    "SUPPRIMER_FICHIER": "Supprimer un fichier",
    "EXECUTER_CMD": "Exécuter une commande",
    "REDÉMARRER_SERV": "Redémarrer un service",
    "SORTIR_RESULTAT": "Sortir résultat dans un tube"
}

#------------------------------------------------------------------------------
# Contraintes disponibles (TYPE_CODE: Libellé affiché)
#------------------------------------------------------------------------------
CONSTRAINTS = {
    "ESPACE_DISQUE": "Espace disque minimum",
    "PLAGE_HORAIRE": "Plage horaire valide",
    "PROCESSUS_ACTIF": "Processus en cours d'exécution"
}

#------------------------------------------------------------------------------
# Paramètres par défaut pour chaque déclencheur
#------------------------------------------------------------------------------
TRIGGER_DEFAULT_PARAMS = {
    "DEMARRAGE": {},
    "HORAIRE": {"heure": "8", "minute": "0", "jours": "* * * * *"},
    "FICHIER_MODIFIE": {"chemin": ""},
    "FICHIER_CREE": {"chemin": ""},
    "RESEAU_ACTIF": {"interface": "(toutes)"},
    "SORTIE_TUBE": {"macro_source": "", "variable_reception": "DONNEES_RECUES"},
    "USB_CONNECTE": {"peripherique": "(tous)"}
}

#------------------------------------------------------------------------------
# Paramètres par défaut pour chaque action
#------------------------------------------------------------------------------
ACTION_DEFAULT_PARAMS = {
    "NOTIFIER": {"titre": "Notification", "message": ""},
    "COPIER_FICHIER": {"source": "", "destination": "", "motif": "*"},
    "DEPLACER_FICHIER": {"source": "", "destination": ""},
    "SUPPRIMER_FICHIER": {"chemin": "", "confirmation": "non"},
    "EXECUTER_CMD": {"commande": ""},
    "REDÉMARRER_SERV": {"service": ""},
    "SORTIR_RESULTAT": {"tube": "", "donnees": ""}
}

#------------------------------------------------------------------------------
# Paramètres par défaut pour chaque contrainte
#------------------------------------------------------------------------------
CONSTRAINT_DEFAULT_PARAMS = {
    "ESPACE_DISQUE": {"espace_minimum": "10"},
    "PLAGE_HORAIRE": {"heure_debut": "0800", "heure_fin": "1800"},
    "PROCESSUS_ACTIF": {"processus": ""}
}
EOFCONFIG

    if [[ -f "$SRC_DIR/config.py" ]]; then
        success "config.py créé avec succès"
    else
        error "Échec de création de config.py"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Création de src/dialogs.py
#------------------------------------------------------------------------------
creer_dialogs_py() {
    log "Création de $SRC_DIR/dialogs.py..."

    cat > "$SRC_DIR/dialogs.py" << 'EOFDIALOGS'
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: dialogs.py
# Description: Boîtes de dialogue pour la création/édition de macros
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from tkinter import ttk, Frame, Label, Entry, Button, messagebox
from tkinter import Toplevel, Scrollbar, TOP, BOTTOM, LEFT, RIGHT, BOTH, W, E, N, S, NS
from config import TRIGGERS, ACTIONS, CONSTRAINTS
from widgets import TriggerWidget, ActionFrame, ConstraintFrame, VariableFrame

class NewMacroDialog(Toplevel):
    """Boîte de dialogue pour créer une nouvelle macro."""

    def __init__(self, parent):
        super().__init__(parent)
        self.title("Nouvelle Macro")
        self.geometry("700x500")
        self.result = None

        self.setup_ui()

        # Centre la fenêtre
        self.transient(parent)
        self.grab_set()
        parent.wait_window(self)

    def setup_ui(self):
        main_frame = Frame(self)
        main_frame.pack(fill=BOTH, expand=True, padx=10, pady=10)

        # Nom de la macro
        nom_frame = Frame(main_frame)
        nom_frame.pack(fill=X, pady=(0, 10))
        Label(nom_frame, text="Nom de la macro:").pack(side=LEFT)
        self.nom_entry = Entry(nom_frame, width=40)
        self.nom_entry.pack(side=LEFT, padx=5)

        # Déclencheur
        Label(main_frame, text="Déclencheur:", font=('Arial', 9, 'bold')).pack(anchor=W, pady=(10, 0))
        self.trigger_widget = TriggerWidget(main_frame)
        self.trigger_widget.pack(fill=X, pady=5)

        # Variables
        Label(main_frame, text="Variables (optionnel):", font=('Arial', 9, 'bold')).pack(anchor=W, pady=(10, 0))
        self.variables_frame = Frame(main_frame)
        self.variables_frame.pack(fill=X, pady=5)
        self.variable_frames = []

        # Ajouter une première variable vide
        self.ajouter_variable()

        Button(main_frame, text="+ Ajouter variable", command=self.ajouter_variable).pack(anchor=W)

        # Actions
        Label(main_frame, text="Actions:", font=('Arial', 9, 'bold')).pack(anchor=W, pady=(10, 0))
        self.actions_scroll = Scrollbar(main_frame)
        self.actions_scroll.pack(side=RIGHT, fill=Y)
        self.actions_container = Frame(main_frame)
        self.actions_container.pack(fill=X, pady=5)
        self.action_frames = []

        # Ajouter une première action vide
        self.ajouter_action()

        Button(main_frame, text="+ Ajouter action", command=self.ajouter_action).pack(anchor=W)

        # Contraintes
        Label(main_frame, text="Contraintes (optionnel):", font=('Arial', 9, 'bold')).pack(anchor=W, pady=(10, 0))
        self.constraints_scroll = Scrollbar(main_frame)
        self.constraints_scroll.pack(side=RIGHT, fill=Y)
        self.constraints_container = Frame(main_frame)
        self.constraints_container.pack(fill=X, pady=5)
        self.constraint_frames = []

        Button(main_frame, text="+ Ajouter contrainte", command=self.ajouter_contrainte).pack(anchor=W, pady=(5, 10))

        # Boutons de validation
        btn_frame = Frame(main_frame)
        btn_frame.pack(side=BOTTOM, fill=X, pady=10)

        Button(btn_frame, text="Annuler", command=self.annuler).pack(side=RIGHT, padx=5)
        Button(btn_frame, text="Créer", command=self.valider).pack(side=RIGHT, padx=5)

    def ajouter_variable(self):
        var_num = len(self.variable_frames) + 1
        frame = VariableFrame(self.variables_frame, var_num=var_num)
        frame.pack(fill=X, pady=2)
        self.variable_frames.append(frame)

    def ajouter_action(self):
        action_num = len(self.action_frames) + 1
        frame = ActionFrame(self.actions_container, action_num=action_num)
        frame.pack(fill=X, pady=2)
        self.action_frames.append(frame)

    def ajouter_contrainte(self):
        constraint_num = len(self.constraint_frames) + 1
        frame = ConstraintFrame(self.constraints_container, constraint_num=constraint_num)
        frame.pack(fill=X, pady=2)
        self.constraint_frames.append(frame)

    def annuler(self):
        self.result = None
        self.destroy()

    def valider(self):
        nom = self.nom_entry.get().strip()
        if not nom:
            messagebox.showerror("Erreur", "Le nom de la macro est obligatoire.")
            return

        trigger_data = self.trigger_widget.get_data()
        variables = [vf.get_data() for vf in self.variable_frames]
        actions = [af.get_data() for af in self.action_frames]
        constraints = [cf.get_data() for cf in self.constraint_frames]

        self.result = (nom, trigger_data, variables, actions, constraints)
        self.destroy()

class EditMacroDialog(NewMacroDialog):
    """Boîte de dialogue pour éditer une macro existante (similaire à NewMacroDialog)."""

    def __init__(self, parent, macro_data=None):
        self.macro_data = macro_data
        super().__init__(parent)
        self.title("Éditer Macro")

    def charger_macro(self):
        if self.macro_data:
            # TODO: Implémenter le chargement des données dans les widgets
            self.nom_entry.delete(0, 'end')
            self.nom_entry.insert(0, self.macro_data.get('nom', ''))
EOFDIALOGS

    if [[ -f "$SRC_DIR/dialogs.py" ]]; then
        success "dialogs.py créé avec succès"
    else
        error "Échec de création de dialogs.py"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Création de src/generate_bash.sh
#------------------------------------------------------------------------------
creer_generate_bash_sh() {
    log "Création de $SRC_DIR/generate_bash.sh..."

    cat > "$SRC_DIR/generate_bash.sh" << 'EOFBASH'
#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: generate_bash.sh
# Description: Convertit un fichier XML de macro en script Bash exécutable
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Utilisation: $0 <fichier_input.xml> <fichier_output.sh>"
    exit 1
fi

INPUT_XML="$1"
OUTPUT_SH="$2"

if [[ ! -f "$INPUT_XML" ]]; then
    echo "Erreur: Fichier XML introuvable: $INPUT_XML"
    exit 1
fi

#------------------------------------------------------------------------------
# Vérification des dépendances
#------------------------------------------------------------------------------
if ! command -v xmllint >/dev/null 2>&1; then
    echo "Erreur: xmllint non trouvé. Installer avec: sudo apt-get install libxml2-utils"
    exit 1
fi

#------------------------------------------------------------------------------
# Extraction des données depuis le XML
#------------------------------------------------------------------------------
extract_attr() {
    local element="$1"
    local attr="$2"
    xmllint --xpath "string($element/@$attr)" "$INPUT_XML" 2>/dev/null || echo ""
}

extract_param() {
    local parent="$1"
    local key="$2"
    xmllint --xpath "string($parent/param[@key='$key']/@value)" "$INPUT_XML" 2>/dev/null || echo ""
}

# Nom de la macro
MACRO_NAME=$(extract_attr "//macro" "name")
[[ -z "$MACRO_NAME" ]] && MACRO_NAME="macro_non_nomme"

# Type de déclencheur
TRIGGER_TYPE=$(extract_attr "//trigger" "type")
TRIGGER_LABEL=$(extract_attr "//trigger" "label")

# Paramètres du déclencheur
declare -A TRIGGER_PARAMS
for key in $(xmllint --xpath "//trigger/config/param/@key" "$INPUT_XML" 2>/dev/null | sed 's/key="\([^"]*\)"/\1\n/g'); do
    value=$(extract_param "//trigger/config" "$key")
    TRIGGER_PARAMS["$key"]="$value"
done

# Construire le script Bash

cat > "$OUTPUT_SH" << EOFHEADER
#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script généré par macrosTitux v0.3
# Macro: $MACRO_NAME
# Déclencheur: $TRIGGER_LABEL
# Généré le: $(date '+%Y-%m-%d %H:%M:%S')
#------------------------------------------------------------------------------

set -euo pipefail

# Variables
EOFHEADER

# Variables déclarées dans la macro
while IFS= read -r var_line; do
    var_name=$(echo "$var_line" | cut -d'|' -f1)
    var_value=$(echo "$var_line" | cut -d'|' -f2-)
    if [[ -n "$var_name" ]]; then
        echo "$var_name=\"$var_value\"" >> "$OUTPUT_SH"
    fi
done < <(xmllint --xpath "//variables/var" "$INPUT_XML" 2>/dev/null | grep -oP 'name="\K[^"]+' | paste -d'|' - <(xmllint --xpath "//variables/var" "$INPUT_XML" 2>/dev/null | grep -oP 'value="\K[^"]+'))

# Génération du corps selon le type de déclencheur
echo "" >> "$OUTPUT_SH"
echo "# Déclencheur: $TRIGGER_LABEL" >> "$OUTPUT_SH"

case "$TRIGGER_TYPE" in
    "DEMARRAGE")
        echo "# Ce script est conçu pour être exécuté au démarrage" >> "$OUTPUT_SH"
        echo "logger 'Macro $MACRO_NAME démarrée'" >> "$OUTPUT_SH"
        ;;
    "HORAIRE")
        HEURE="${TRIGGER_PARAMS[heure]:-8}"
        MINUTE="${TRIGGER_PARAMS[minute]:-0}"
        echo "# Programme avec cron à ${HEURE}:${MINUTE}" >> "$OUTPUT_SH"
        echo "crontab -l 2>/dev/null | grep -v '$MACRO_NAME'" >> "$OUTPUT_SH"
        echo "echo \"${MINUTE} ${HEURE} * * * $OUTPUT_SH\" | crontab -" >> "$OUTPUT_SH"
        ;;
    "FICHIER_MODIFIE")
        CHEMIN="${TRIGGER_PARAMS[chemin]:-/tmp}"
        echo "# Surveillance de modification de fichier" >> "$OUTPUT_SH"
        echo "INOTIFY_WAIT=\"${CHEMIN}\"" >> "$OUTPUT_SH"
        echo "echo 'Surveillance active sur: $INOTIFY_WAIT'" >> "$OUTPUT_SH"
        ;;
    "FICHIER_CREE")
        CHEMIN="${TRIGGER_PARAMS[chemin]:-/tmp}"
        echo "# Surveillance de création de fichier" >> "$OUTPUT_SH"
        echo "WATCH_PATH=\"${CHEMIN}\"" >> "$OUTPUT_SH"
        ;;
    "RESEAU_ACTIF")
        INTERFACE="${TRIGGER_PARAMS[interface]:-eth0}"
        echo "# Vérification du réseau sur interface: $INTERFACE" >> "$OUTPUT_SH"
        echo "ip link show $INTERFACE | grep -q 'UP'" >> "$OUTPUT_SH"
        ;;
    "SORTIE_TUBE")
        TUBE="${TRIGGER_PARAMS[tube]:-/tmp/macrosTitux_tube}"
        VAR_RECEPTION="${TRIGGER_PARAMS[variable_reception]:-DONNEES_RECUES}"
        echo "# Lecture depuis le tube: $TUBE" >> "$OUTPUT_SH"
        echo "$VAR_RECEPTION=\$(cat \"$TUBE\" 2>/dev/null || echo '')" >> "$OUTPUT_SH"
        ;;
    "USB_CONNECTE")
        PERIPHERIQUE="${TRIGGER_PARAMS[peripherique]:-(tous)}"
        echo "# Détection USB: $PERIPHERIQUE" >> "$OUTPUT_SH"
        echo "udevadm monitor --environment --udev 2>/dev/null &" >> "$OUTPUT_SH"
        ;;
    *)
        echo "# Déclencheur inconnu: $TRIGGER_TYPE" >> "$OUTPUT_SH"
        ;;
esac

# Génération des contraintes
echo "" >> "$OUTPUT_SH"
echo "# Contraintes" >> "$OUTPUT_SH"

while IFS='|' read -r c_type c_label c_params; do
    [[ -z "$c_type" ]] && continue

    case "$c_type" in
        "ESPACE_DISQUE")
            ESPACE_MIN=$(echo "$c_params" | grep -oP 'espace_minimum=\K\d+' || echo "10")
            echo "ESPACE_LIBRE=\$(df -k / | tail -1 | awk '{print \$4}')" >> "$OUTPUT_SH"
            echo "if [[ \$ESPACE_LIBRE -lt $((ESPACE_MIN * 1024 * 1024)) ]]; then" >> "$OUTPUT_SH"
            echo "    logger 'Contrainte espace disque non respectée'" >> "$OUTPUT_SH"
            echo "    exit 1" >> "$OUTPUT_SH"
            echo "fi" >> "$OUTPUT_SH"
            ;;
        "PLAGE_HORAIRE")
            HEURE_DEBUT=$(echo "$c_params" | grep -oP 'heure_debut=\K\d+' || echo "0800")
            HEURE_FIN=$(echo "$c_params" | grep -oP 'heure_fin=\K\d+' || echo "1800")
            HEURE_ACTUELLE=$(date +%H%M)
            echo "HEURE_ACTUELLE=\$(date +%H%M)" >> "$OUTPUT_SH"
            echo "if [[ \$HEURE_ACTUELLE -lt $HEURE_DEBUT || \$HEURE_ACTUELLE -gt $HEURE_FIN ]]; then" >> "$OUTPUT_SH"
            echo "    logger 'En dehors de la plage horaire autorisée'" >> "$OUTPUT_SH"
            echo "    exit 1" >> "$OUTPUT_SH"
            echo "fi" >> "$OUTPUT_SH"
            ;;
        "PROCESSUS_ACTIF")
            PROCESSUS=$(echo "$c_params" | grep -oP 'processus=\K[^&]+' || echo "")
            if [[ -n "$PROCESSUS" ]]; then
                echo "# Vérification processus: $PROCESSUS" >> "$OUTPUT_SH"
                echo "pgrep -x '$PROCESSUS' >/dev/null || exit 1" >> "$OUTPUT_SH"
            fi
            ;;
    esac
done < <(xmllint --xpath "//constraints/constraint" "$INPUT_XML" 2>/dev/null | \
    grep -oP 'type="\K[^"]+' | paste -d'|' - \
    <(xmllint --xpath "//constraints/constraint" "$INPUT_XML" 2>/dev/null | \
        grep -oP 'label="\K[^"]+' | \
        paste -d'|' - \
        <(xmllint --xpath "//constraints/constraint/config/param" "$INPUT_XML" 2>/dev/null | \
            grep -oP 'key="\K[^"]+=[^"]*' | tr '\n' '&')))

# Génération des actions
echo "" >> "$OUTPUT_SH"
echo "# Actions" >> "$OUTPUT_SH"

while IFS='|' read -r a_id a_type a_label a_params; do
    [[ -z "$a_type" ]] && continue

    case "$a_type" in
        "NOTIFIER")
            TITRE=$(echo "$a_params" | grep -oP 'titre=\K[^&]+' || echo "Notification")
            MESSAGE=$(echo "$a_params" | grep -oP 'message=\K[^&]+' || echo "")
            echo "notify-send \"$TITRE\" \"$MESSAGE\"" >> "$OUTPUT_SH"
            ;;
        "COPIER_FICHIER")
            SOURCE=$(echo "$a_params" | grep -oP 'source=\K[^&]+' || echo "")
            DESTINATION=$(echo "$a_params" | grep -oP 'destination=\K[^&]+' || echo "")
            MOTIF=$(echo "$a_params" | grep -oP 'motif=\K[^&]+' || echo "*")
            if [[ -n "$SOURCE" && -n "$DESTINATION" ]]; then
                echo "mkdir -p \"$DESTINATION\"" >> "$OUTPUT_SH"
                echo "cp -r \"$SOURCE\"/$MOTIF \"$DESTINATION/\" 2>/dev/null || true" >> "$OUTPUT_SH"
            fi
            ;;
        "DEPLACER_FICHIER")
            SOURCE=$(echo "$a_params" | grep -oP 'source=\K[^&]+' || echo "")
            DESTINATION=$(echo "$a_params" | grep -oP 'destination=\K[^&]+' || echo "")
            if [[ -n "$SOURCE" && -n "$DESTINATION" ]]; then
                echo "mv \"$SOURCE\" \"$DESTINATION/\" 2>/dev/null || true" >> "$OUTPUT_SH"
            fi
            ;;
        "SUPPRIMER_FICHIER")
            CHEMIN=$(echo "$a_params" | grep -oP 'chemin=\K[^&]+' || echo "")
            CONFIRMATION=$(echo "$a_params" | grep -oP 'confirmation=\K[^&]+' || echo "non")
            if [[ -n "$CHEMIN" ]]; then
                if [[ "$CONFIRMATION" == "non" ]]; then
                    echo "rm -rf \"$CHEMIN\" 2>/dev/null || true" >> "$OUTPUT_SH"
                else
                    echo "read -p 'Supprimer $CHEMIN ? (o/n) ' CONFIRM && [[ \"\$CONFIRM\" == \"o\" ]] && rm -rf \"$CHEMIN\"" >> "$OUTPUT_SH"
                fi
            fi
            ;;
        "EXECUTER_CMD")
            COMMANDE=$(echo "$a_params" | grep -oP 'commande=\K[^&]+' || echo "echo 'Commande exécutée'")
            echo "$COMMANDE" >> "$OUTPUT_SH"
            ;;
        "REDÉMARRER_SERV")
            SERVICE=$(echo "$a_params" | grep -oP 'service=\K[^&]+' || echo "")
            if [[ -n "$SERVICE" ]]; then
                echo "sudo systemctl restart \"$SERVICE\" 2>/dev/null || true" >> "$OUTPUT_SH"
            fi
            ;;
        "SORTIR_RESULTAT")
            TUBE_SORTIE=$(echo "$a_params" | grep -oP 'tube=\K[^&]+' || echo "/tmp/resultat")
            DONNEES=$(echo "$a_params" | grep -oP 'donnees=\K[^&]+' || echo "RESULTAT")
            echo "echo \"\$${DONNEES}\" > \"$TUBE_SORTIE\" 2>/dev/null || true" >> "$OUTPUT_SH"
            ;;
        *)
            echo "# Action inconnue: $a_type" >> "$OUTPUT_SH"
            ;;
    esac
done < <(xmllint --xpath "//actions/action" "$INPUT_XML" 2>/dev/null | \
    grep -oP 'id="\K[^"]+' | paste -d'|' - \
    <(xmllint --xpath "//actions/action" "$INPUT_XML" 2>/dev/null | \
        grep -oP 'type="\K[^"]+' | \
        paste -d'|' - \
        <(xmllint --xpath "//actions/action"  "$INPUT_XML" 2>/dev/null | \
            grep -oP 'label="\K[^"]+' | \
            paste -d'|' - \
            <(xmllint --xpath "//actions/action/config/param" "$INPUT_XML" 2>/dev/null | \
                grep -oP 'key="\K[^"]+=[^"]*' | tr '\n' '&'))))

# Footer
echo "" >> "$OUTPUT_SH"
echo "logger 'Macro $MACRO_NAME terminée'" >> "$OUTPUT_SH"
echo "exit 0" >> "$OUTPUT_SH"

# Rendre le script exécutable
chmod +x "$OUTPUT_SH"

echo "Succès: Script généré: $OUTPUT_SH"
exit 0
EOFBASH

    chmod +x "$SRC_DIR/generate_bash.sh"

    if [[ -x "$SRC_DIR/generate_bash.sh" ]]; then
        success "generate_bash.sh créé avec succès (exécutable)"
    else
        error "Échec de création/exécution de generate_bash.sh"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Correction de src/model.py
#------------------------------------------------------------------------------
corriger_model_py() {
    log "Correction de $SRC_DIR/model.py..."

    # Backup du fichier original
    cp "$SRC_DIR/model.py" "$SRC_DIR/model.py.bak.$(date +%Y%m%d%H%M%S)"

    cat > "$SRC_DIR/model.py" << 'EOFMODEL'
# -*- coding: utf-8 -*-
import os
#------------------------------------------------------------------------------
# Fichier: model.py
# Description: Logique métier (sauvegarde, chargement, conversion)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import json
import xml.etree.ElementTree as ET
from pathlib import Path

# IMPORT ABSOLU (compatible pytest)
from config import APP_NAME, DEFAULT_CONFIG

CONFIG_DIR = Path.home() / ".config" / APP_NAME
MACRO_DIR = CONFIG_DIR / "macros"
CONF_FILE = CONFIG_DIR / "macrosTitux.conf"

def init_dirs():
    """Crée les dossiers de configuration."""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    MACRO_DIR.mkdir(parents=True, exist_ok=True)
    if not CONF_FILE.exists():
        with open(CONF_FILE, 'w', encoding='utf-8') as f:
            json.dump(DEFAULT_CONFIG, f, indent=4, ensure_ascii=False)

def load_config():
    """Charge la configuration utilisateur."""
    with open(CONF_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def load_macros_list():
    """Liste toutes les macros enregistrées."""
    macros = []
    for f in MACRO_DIR.glob("*.xml"):
        tree = ET.parse(f)
        root = tree.getroot()
        name = root.get('name')
        trigger_label = root.find('trigger').get('label', '-') if root.find('trigger') is not None else '-'
        actions = root.findall('actions/action')
        action_label = actions[0].get('label', '-') if actions else '-'
        macros.append((name, trigger_label, action_label))
    return macros

def save_macro(name, trigger_data, variables, actions, constraints):
    """Sauvegarde une macro au format XML."""
    root = ET.Element("macro")
    root.set('name', name)

    # Trigger
    trigger = ET.SubElement(root, "trigger")
    trigger.set('type', trigger_data['type'])
    trigger.set('label', trigger_data['label'])
    trigger_cfg = ET.SubElement(trigger, "config")
    for k, v in trigger_data['params'].items():
        param = ET.SubElement(trigger_cfg, "param")
        param.set('key', k)
        param.set('value', str(v))

    # Variables
    vars_elem = ET.SubElement(root, "variables")
    for var in variables:
        if var.get('name'):
            v = ET.SubElement(vars_elem, "var")
            v.set('name', var['name'])
            v.set('value', var.get('value', ''))

    # Actions
    actions_elem = ET.SubElement(root, "actions")
    for action in actions:
        action_el = ET.SubElement(actions_elem, "action")
        action_el.set('id', action.get('id', '1'))
        action_el.set('type', action['type'])
        action_el.set('label', action.get('label', ''))
        cfg = ET.SubElement(action_el, "config")
        for k, v in action.get('params', {}).items():
            p = ET.SubElement(cfg, "param")
            p.set('key', k)
            p.set('value', str(v))

    # Contraintes
    constraints_elem = ET.SubElement(root, "constraints")
    for constraint in constraints:
        c_el = ET.SubElement(constraints_elem, "constraint")
        c_el.set('id', constraint.get('id', '1'))
        c_el.set('type', constraint['type'])
        c_el.set('label', constraint.get('label', ''))
        cfg = ET.SubElement(c_el, "config")
        for k, v in constraint.get('params', {}).items():
            p = ET.SubElement(cfg, "param")
            p.set('key', k)
            p.set('value', str(v))

    tree = ET.ElementTree(root)
    ET.indent(tree, space="    ")
    with open(MACRO_DIR / f"{name}.xml", 'wb') as f:
        tree.write(f, encoding='utf-8', xml_declaration=True)

def delete_macro(macro_name):
    """Supprime une macro XML."""
    macro_path = MACRO_DIR / f"{macro_name}.xml"
    if macro_path.exists():
        macro_path.unlink()
        # Supprimer aussi le fichier Bash associé
        sh_path = MACRO_DIR / f"{macro_name}.sh"
        if sh_path.exists():
            sh_path.unlink()

def generate_bash_from_xml(xml_path, output_path=None, dry_run=False):
    """Convertit un XML en script Bash et retourne les infos de la macro.

    Args:
        xml_path: Chemin vers le fichier XML
        output_path: Chemin de sortie du script (optionnel)
        dry_run: Si True, retourne seulement les infos sans générer

    Returns:
        dict: Informations sur la macro (name, trigger_type, actions...)
    """
    # Parser le XML pour extraire les infos
    tree = ET.parse(xml_path)
    root = tree.getroot()

    info = {
        'name': root.get('name', ''),
        'trigger_type': root.find('trigger').get('type', 'Inconnu') if root.find('trigger') is not None else 'Inconnu',
        'actions': []
    }

    actions_elem = root.find('actions')
    if actions_elem is not None:
        for action in actions_elem.findall('action'):
            info['actions'].append({
                'id': action.get('id'),
                'type': action.get('type'),
                'label': action.get('label', '')
            })

    if not dry_run:
        # Générer le script Bash via le shell script
        script_path = Path(__file__).parent / "generate_bash.sh"
        if output_path is None:
            output_path = str(xml_path).replace('.xml', '.sh')

        result = os.system(f"bash \"{script_path}\" \"{xml_path}\" \"{output_path}\"")
        if result != 0:
            raise RuntimeError(f"Échec de génération du script Bash: {xml_path}")

        info['output_path'] = output_path

    return info
EOFMODEL

    if [[ -f "$SRC_DIR/model.py" ]]; then
        success "model.py corrigé avec succès"
        success "Backup conservé dans: model.py.bak.*"
    else
        error "Échec de correction de model.py"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Exécution principale
#------------------------------------------------------------------------------
main() {
    log "=========================================="
    log " GÉNÉRATION DES FICHIERS MANQUANTS"
    log "=========================================="
    log " Projet: $PROJECT_ROOT"
    log " Source: $SRC_DIR"
    log ""

    local erreurs=0

    creer_config_py || ((erreurs++))
    creer_dialogs_py || ((erreurs++))
    creer_generate_bash_sh || ((erreurs++))
    corriger_model_py || ((erreurs++))

    log ""
    log "=========================================="

    if [[ $erreurs -eq 0 ]]; then
        success "Toutes les tâches ont été réalisées avec succès!"
        log ""
        log "Pour tester l'application:"
        log "  cd $PROJECT_ROOT"
        log "  python3 src/macrosTitux.py"
        log ""
        log "Pour lancer les tests:"
        log "  source venv/bin/activate"
        log "  pytest tests/ -v"
    else
        error "$erreurs erreur(s) rencontrée(s) lors de la génération"
        exit 1
    fi

    log "=========================================="
}

main "$@"
