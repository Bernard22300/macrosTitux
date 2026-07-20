#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: refactor_modulaire.sh
# Description: Découpe src/macrosTitux.py en plusieurs fichiers modulaires
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
success() { log "✅ $*"; }
error() { log "❌ $*"; }

#------------------------------------------------------------------------------
# Fichier 1: src/__init__.py (déjà existant, vérifié)
#------------------------------------------------------------------------------
create_init_file() {
    local file="$PROJECT_ROOT/src/__init__.py"
    if [[ -f "$file" ]]; then
        success "__init__.py déjà présent"
    else
        cat > "$file" << 'EOF'
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: src/__init__.py
# Description: Rend le dossier src/ un package Python
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from .config import APP_NAME, APP_VERSION, TRIGGERS, ACTIONS, CONSTRAINTS
from .model import init_dirs, load_config, load_macros_list, save_macro, generate_bash_from_xml
EOF
        success "Création de __init__.py"
    fi
}

#------------------------------------------------------------------------------
# Fichier 2: src/widgets.py - Composants GUI réutilisables
#------------------------------------------------------------------------------
create_widgets_file() {
    local file="$PROJECT_ROOT/src/widgets.py"
    log "Création de $file..."

    cat > "$file" << 'EOF'
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: widgets.py
# Description: Composants GUI réutilisables (TriggerWidget, ActionFrame...)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import os
from tkinter import ttk, Frame, StringVar, Entry, Label, Text, END, LEFT, RIGHT, TOP, BOTTOM, BOTH, W, E, N, S
from config import TRIGGERS, ACTIONS, CONSTRAINTS

class TriggerWidget(Frame):
    """Widget pour sélectionner et configurer un déclencheur."""

    def __init__(self, parent, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.setup_ui()

    def setup_ui(self):
        ttk.Label(self, text="Type de déclencheur:", font=('Arial', 9, 'bold')).grid(row=0, column=0, sticky=W, padx=5, pady=2)

        self.trigger_var = StringVar()
        self.trigger_combo = ttk.Combobox(self, textvariable=self.trigger_var, values=list(TRIGGERS.values()), state='readonly', width=40)
        self.trigger_combo.current(0)
        self.trigger_combo.grid(row=0, column=1, sticky=W+E, padx=5, pady=2)

        self.params_frame = Frame(self)
        self.params_frame.grid(row=1, column=0, columnspan=2, sticky=W+E, padx=5, pady=5)

        self.param_entries = {}
        self.update_params_panel()

        self.trigger_combo.bind('<<ComboboxSelected>>', lambda e: self.update_params_panel())

    def update_params_panel(self):
        for widget in self.params_frame.winfo_children():
            widget.destroy()
        self.param_entries.clear()

        trigger_type = [k for k, v in TRIGGERS.items() if v == self.trigger_var.get()][0]

        row = 0
        if trigger_type == "HORAIRE":
            ttk.Label(self.params_frame, text="Heure:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.param_entries['heure'] = ttk.Spinbox(self.params_frame, from_=0, to=23, width=5)
            self.param_entries['heure'].grid(row=row, column=1, sticky=W, padx=5, pady=2)
            self.param_entries['heure'].set("8")

            row += 1
            ttk.Label(self.params_frame, text="Minute:").grid(row=row, column=2, sticky=E, padx=5, pady=2)
            self.param_entries['minute'] = ttk.Spinbox(self.params_frame, from_=0, to=59, width=5)
            self.param_entries['minute'].grid(row=row, column=3, sticky=W, padx=5, pady=2)
            self.param_entries['minute'].set("0")

            row += 1
            ttk.Label(self.params_frame, text="Jours:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.param_entries['jours'] = Entry(self.params_frame, width=20)
            self.param_entries['jours'].grid(row=row, column=1, sticky=W, padx=5, pady=2)
            self.param_entries['jours'].insert(0, "* * * * * (tous les jours)")

        elif trigger_type in ["FICHIER_MODIFIE", "FICHIER_CREE"]:
            ttk.Label(self.params_frame, text="Chemin du fichier:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.param_entries['chemin'] = Entry(self.params_frame, width=50)
            self.param_entries['chemin'].grid(row=row, column=1, sticky=W, padx=5, pady=2)

        elif trigger_type == "RESEAU_ACTIF":
            ttk.Label(self.params_frame, text="Interface réseau:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.param_entries['interface'] = Entry(self.params_frame, width=20)
            self.param_entries['interface'].grid(row=row, column=1, sticky=W, padx=5, pady=2)
            self.param_entries['interface'].insert(0, "(toutes)")

        elif trigger_type == "SORTIE_TUBE":
            ttk.Label(self.params_frame, text="Macro source:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.param_entries['macro_source'] = Entry(self.params_frame, width=20)
            self.param_entries['macro_source'].grid(row=row, column=1, sticky=W, padx=5, pady=2)

            row += 1
            ttk.Label(self.params_frame, text="Variable de réception:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.param_entries['variable_reception'] = Entry(self.params_frame, width=20)
            self.param_entries['variable_reception'].grid(row=row, column=1, sticky=W, padx=5, pady=2)
            self.param_entries['variable_reception'].insert(0, "DONNEES_RECUES")

        elif trigger_type == "USB_CONNECTE":
            ttk.Label(self.params_frame, text="Périphérique (optionnel):").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.param_entries['peripherique'] = Entry(self.params_frame, width=20)
            self.param_entries['peripherique'].grid(row=row, column=1, sticky=W, padx=5, pady=2)
            self.param_entries['peripherique'].insert(0, "(tous)")

    def get_data(self):
        trigger_label = self.trigger_var.get()
        trigger_type = [k for k, v in TRIGGERS.items() if v == trigger_label][0]

        params = {}
        for key, entry in self.param_entries.items():
            if hasattr(entry, 'get'):
                val = entry.get().strip()
            else:
                val = str(entry.get())
            if val:
                params[key] = val

        return {
            'type': trigger_type,
            'label': trigger_label,
            'params': params
        }

class ActionFrame(Frame):
    """Frame pour une seule action avec ses paramètres."""

    def __init__(self, parent, action_num=1, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.action_num = action_num
        self.setup_ui()

    def setup_ui(self):
        ttk.Label(self, text=f"{self.action_num}. ", font=('Arial', 9, 'bold')).pack(side=LEFT, padx=2)

        self.action_type_var = StringVar()
        self.action_combo = ttk.Combobox(self, textvariable=self.action_type_var, values=list(ACTIONS.values()), state='readonly', width=35)
        self.action_combo.current(0)
        self.action_combo.pack(side=LEFT, padx=5)

        self.params_text = Text(self, height=4, width=60)
        self.params_text.pack(side=LEFT, padx=10)

        self.action_combo.bind('<<ComboboxSelected>>', lambda e: self.update_params_text())

    def update_params_text(self):
        self.params_text.delete("1.0", END)
        action_label = self.action_type_var.get()
        action_type = [k for k, v in ACTIONS.items() if v == action_label][0]

        if action_type == "NOTIFIER":
            self.params_text.insert(END, "titre=Notification\nmessage=Votre message ici")
        elif action_type == "COPIER_FICHIER":
            self.params_text.insert(END, "source=~/Documents\ndestination=~/backup/\nmotif=*.pdf")
        elif action_type == "EXECUTER_CMD":
            self.params_text.insert(END, "commande=echo Hello World")
        elif action_type == "REDÉMARRER_SERV":
            self.params_text.insert(END, "service=cron")
        elif action_type == "SORTIR_RESULTAT":
            self.params_text.insert(END, "tube=resultat\ndonnees=VARIABLE")

    def get_data(self):
        action_label = self.action_type_var.get()
        action_type = [k for k, v in ACTIONS.items() if v == action_label][0]

        params_text = self.params_text.get("1.0", END).strip()
        params = {}
        if params_text:
            for line in params_text.split('\n'):
                if '=' in line:
                    key, val = line.split('=', 1)
                    params[key.strip()] = val.strip()

        return {
            'id': str(self.action_num),
            'type': action_type,
            'label': action_label,
            'params': params
        }

class ConstraintFrame(Frame):
    """Frame pour une seule contrainte avec ses paramètres."""

    def __init__(self, parent, constraint_num=1, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.constraint_num = constraint_num
        self.setup_ui()

    def setup_ui(self):
        ttk.Label(self, text=f"{self.constraint_num}. ").pack(side=LEFT, padx=2)

        self.constraint_type_var = StringVar()
        self.constraint_combo = ttk.Combobox(self, textvariable=self.constraint_type_var, values=list(CONSTRAINTS.values()), state='readonly', width=30)
        self.constraint_combo.current(0)
        self.constraint_combo.pack(side=LEFT, padx=5)

        self.params_text = Text(self, height=3, width=60)
        self.params_text.pack(side=LEFT, padx=10)

        self.constraint_combo.bind('<<ComboboxSelected>>', lambda e: self.update_params_text())

    def update_params_text(self):
        self.params_text.delete("1.0", END)
        constraint_label = self.constraint_type_var.get()
        constraint_type = [k for k, v in CONSTRAINTS.items() if v == constraint_label][0]

        if constraint_type == "ESPACE_DISQUE":
            self.params_text.insert(END, "espace_minimum=10")
        elif constraint_type == "PLAGE_HORAIRE":
            self.params_text.insert(END, "heure_debut=0800\nheure_fin=1800")
        elif constraint_type == "PROCESSUS_ACTIF":
            self.params_text.insert(END, "processus=firefox")

    def get_data(self):
        constraint_label = self.constraint_type_var.get()
        constraint_type = [k for k, v in CONSTRAINTS.items() if v == constraint_label][0]

        params_text = self.params_text.get("1.0", END).strip()
        params = {}
        if params_text:
            for line in params_text.split('\n'):
                if '=' in line:
                    key, val = line.split('=', 1)
                    params[key.strip()] = val.strip()

        return {
            'id': str(self.constraint_num),
            'type': constraint_type,
            'label': constraint_label,
            'params': params
        }

class VariableFrame(Frame):
    """Frame pour une variable simple nom=valeur."""

    def __init__(self, parent, var_num=1, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.var_num = var_num
        self.setup_ui()

    def setup_ui(self):
        ttk.Label(self, text=f"{self.var_num}. ").pack(side=LEFT, padx=2)

        ttk.Label(self, text="Nom:").pack(side=LEFT, padx=2)
        self.name_entry = Entry(self, width=15)
        self.name_entry.pack(side=LEFT, padx=2)

        ttk.Label(self, text="Valeur:").pack(side=LEFT, padx=2)
        self.value_entry = Entry(self, width=30)
        self.value_entry.pack(side=LEFT, padx=2)

    def get_data(self):
        return {
            'name': self.name_entry.get().strip(),
            'value': self.value_entry.get().strip()
        }
EOF
    success "Fichier widgets.py créé"
}

#------------------------------------------------------------------------------
# Fichier 3: src/dialogs.py - Dialogues (NewMacroDialog, etc.)
#------------------------------------------------------------------------------
create_dialogs_file() {
    local file="$PROJECT_ROOT/src/dialogs.py"
    log "Création de $file..."

    cat > "$file" << 'EOF'
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: dialogs.py
# Description: Dialogues modaux pour création/modification de macros
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from tkinter import ttk, Toplevel, Frame, Canvas, Scrollbar, Button, Label, Entry, Listbox, messagebox, W, X, BOTH, LEFT, RIGHT, END
from widgets import TriggerWidget, ActionFrame, ConstraintFrame, VariableFrame

class NewMacroDialog(Toplevel):
    """Dialog structuré pour créer une nouvelle macro - VERSION MODULAIRE."""

    def __init__(self, parent):
        super().__init__(parent)
        self.title("Nouvelle macro")
        self.geometry("800x750")

        self.result = None
        self.actions_frames = []
        self.constraints_frames = []
        self.variables_frames = []

        self.setup_ui()

    def setup_ui(self):
        main_frame = Frame(self)
        main_frame.pack(fill=BOTH, expand=True, padx=10, pady=10)

        # === Nom ===
        name_frame = Frame(main_frame)
        name_frame.pack(fill=X, pady=(0, 10))
        Label(name_frame, text="Nom de la macro:", font=('Arial', 10, 'bold')).pack(anchor=W)
        self.name_entry = Entry(name_frame, width=50)
        self.name_entry.pack(fill=X, pady=5)

        # === Déclencheur ===
        trigger_label_frame = Frame(main_frame)
        trigger_label_frame.pack(fill=X, pady=(10, 5))
        Label(trigger_label_frame, text="Déclencheur", font=('Arial', 10, 'bold'), foreground='#6d4aff').pack(anchor=W)

        self.trigger_widget = TriggerWidget(main_frame)
        self.trigger_widget.pack(fill=X, pady=5)

        # === Variables ===
        vars_label_frame = Frame(main_frame)
        vars_label_frame.pack(fill=X, pady=(10, 5))
        Label(vars_label_frame, text="Variables (optionnel)", font=('Arial', 10, 'bold'), foreground='#6d4aff').pack(anchor=W)

        vars_btn_frame = Frame(main_frame)
        vars_btn_frame.pack(fill=X, pady=2)
        Button(vars_btn_frame, text="+ Ajouter variable", command=self.add_variable).pack(anchor=W)

        vars_container = Frame(main_frame)
        vars_container.pack(fill=X, pady=5)
        vars_scroll = Scrollbar(vars_container)
        vars_scroll.pack(side=RIGHT, fill=Y)
        self.vars_listbox = Listbox(vars_container, height=3, yscrollcommand=vars_scroll.set)
        self.vars_listbox.pack(side=LEFT, fill=X)
        vars_scroll.config(command=self.vars_listbox.yview)

        # === Actions ===
        actions_label_frame = Frame(main_frame)
        actions_label_frame.pack(fill=X, pady=(10, 5))
        Label(actions_label_frame, text="Actions", font=('Arial', 10, 'bold'), foreground='#6d4aff').pack(anchor=W)

        actions_btn_frame = Frame(main_frame)
        actions_btn_frame.pack(fill=X, pady=2)
        Button(actions_btn_frame, text="+ Ajouter action", command=self.add_action).pack(anchor=W)

        actions_container = Frame(main_frame)
        actions_container.pack(fill=BOTH, expand=True, pady=5)
        actions_scroll = Scrollbar(actions_container)
        actions_scroll.pack(side=RIGHT, fill=Y)
        self.actions_listbox = Listbox(actions_container, height=8, yscrollcommand=actions_scroll.set)
        self.actions_listbox.pack(side=LEFT, fill=BOTH, expand=True)
        actions_scroll.config(command=self.actions_listbox.yview)

        # === Contraintes ===
        constr_label_frame = Frame(main_frame)
        constr_label_frame.pack(fill=X, pady=(10, 5))
        Label(constr_label_frame, text="Contraintes (optionnel)", font=('Arial', 10, 'bold'), foreground='#6d4aff').pack(anchor=W)

        constr_btn_frame = Frame(main_frame)
        constr_btn_frame.pack(fill=X, pady=2)
        Button(constr_btn_frame, text="+ Ajouter contrainte", command=self.add_constraint).pack(anchor=W)

        constr_container = Frame(main_frame)
        constr_container.pack(fill=X, pady=5)
        constr_scroll = Scrollbar(constr_container)
        constr_scroll.pack(side=RIGHT, fill=Y)
        self.constraints_listbox = Listbox(constr_container, height=5, yscrollcommand=constr_scroll.set)
        self.constraints_listbox.pack(side=LEFT, fill=X)
        constr_scroll.config(command=self.constraints_listbox.yview)

        # === Boutons ===
        btn_frame = Frame(self)
        btn_frame.pack(fill=X, pady=10)
        Button(btn_frame, text="Annuler", command=self.destroy).pack(side=RIGHT, padx=5)
        Button(btn_frame, text="Créer", command=self.save).pack(side=RIGHT, padx=5)

    def add_variable(self):
        num = len(self.variables_frames) + 1
        frame = VariableFrame(self, num)
        frame.pack(fill=X, pady=2)
        self.variables_frames.append(frame)
        self.vars_listbox.insert(END, f"Variable {num}")

    def add_action(self):
        num = len(self.actions_frames) + 1
        frame = ActionFrame(self, num)
        frame.pack(fill=X, pady=2)
        self.actions_frames.append(frame)
        self.actions_listbox.insert(END, f"Action {num}")

    def add_constraint(self):
        num = len(self.constraints_frames) + 1
        frame = ConstraintFrame(self, num)
        frame.pack(fill=X, pady=2)
        self.constraints_frames.append(frame)
        self.constraints_listbox.insert(END, f"Contrainte {num}")

    def save(self):
        name = self.name_entry.get().strip()
        if not name:
            messagebox.showerror("Erreur", "Le nom de la macro est requis.")
            return

        trigger_data = self.trigger_widget.get_data()
        variables = [v.get_data() for v in self.variables_frames]
        actions = [a.get_data() for a in self.actions_frames]
        constraints = [c.get_data() for c in self.constraints_frames]

        self.result = (name, trigger_data, variables, actions, constraints)
        self.destroy()
EOF
    success "Fichier dialogs.py créé"
}

#------------------------------------------------------------------------------
# Fichier 4: src/gui.py - Interface principale
#------------------------------------------------------------------------------
create_gui_file() {
    local file="$PROJECT_ROOT/src/gui.py"
    log "Création de $file..."

    cat > "$file" << 'EOF'
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: gui.py
# Description: Interface graphique principale (MacrosTituxApp)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import os
from tkinter import ttk, Tk, Frame, Label, LabelFrame, Text, Scrollbar, Listbox, END, W, X, BOTH
from pathlib import Path
from dialogs import NewMacroDialog
from model import load_macros_list, save_macro, generate_bash_from_xml, load_config
import shutil
from tkinter import filedialog, messagebox

APP_NAME = "macrosTitux"
APP_VERSION = "0.3"
BASE_DIR = Path(os.path.dirname(os.path.abspath(__file__)).replace('/src', ''))
CONFIG_DIR = Path.home() / ".config" / APP_NAME
MACRO_DIR = CONFIG_DIR / "macros"

class MacrosTituxApp(Frame):
    """Application principale avec interface graphique."""

    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.parent.title(f"{APP_NAME} v{APP_VERSION}")
        self.parent.geometry("800x600")
        self.setup_ui()
        self.refresh_macros_list()

    def setup_ui(self):
        # Notebook principal
        notebook = ttk.Notebook(self.parent)
        notebook.pack(fill='both', expand=True, padx=10, pady=10)

        # Onglet Macros
        self.tab_macros = Frame(notebook)
        notebook.add(self.tab_macros, text="Macros")
        self.setup_tab_macros()

        # Onglet Templates
        self.tab_templates = Frame(notebook)
        notebook.add(self.tab_templates, text="Templates")
        self.setup_tab_templates()

        # Onglet Paramètres
        self.tab_settings = Frame(notebook)
        notebook.add(self.tab_settings, text="Parametres")
        self.setup_tab_settings()

        # Barre de boutons
        btn_frame = Frame(self)
        btn_frame.pack(fill='x', padx=10, pady=5)
        ttk.Button(btn_frame, text="+ Nouvelle macro", command=self.new_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Editer", command=self.edit_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Supprimer", command=self.delete_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Tester", command=self.test_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Exporter", command=self.export_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Importer", command=self.import_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Quitter", command=self.quit).pack(side='right')

    def setup_tab_macros(self):
        columns = ('Nom', 'Declencheur', 'Action')
        self.tree = ttk.Treeview(self.tab_macros, columns=columns, show='headings')

        for col in columns:
            self.tree.heading(col, text=col.capitalize())

        self.tree.column('Nom', width=200)
        self.tree.column('Declencheur', width=250)
        self.tree.column('Action', width=250)
        self.tree.pack(fill='both', expand=True, padx=5, pady=5)

    def setup_tab_templates(self):
        label = Label(self.tab_templates, text="Aucun template disponible pour le moment.", justify='center')
        label.pack(expand=True, pady=50)

    def setup_tab_settings(self):
        config = load_config()
        Label(self.tab_settings, text="Repertoire des macros:", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        Entry(self.tab_settings, textvariable=config.get('export_dir', '')).pack(fill='x', padx=10, pady=2)
        Label(self.tab_settings, text=f"Version: {APP_VERSION}", foreground='gray').pack(anchor='w', padx=10, pady=20)

    def refresh_macros_list(self):
        for item in self.tree.get_children():
            self.tree.delete(item)
        for name, trigger, action in load_macros_list():
            self.tree.insert('', 'end', values=(name, trigger, action))

    def new_macro(self):
        dialog = NewMacroDialog(self.parent)
        dialog.grab_set()
        if dialog.result:
            name, trigger_data, variables, actions, constraints = dialog.result
            save_macro(name, trigger_data, variables, actions, constraints)
            self.refresh_macros_list()
            messagebox.showinfo("Info", f"Macro '{name}' créée avec succès.")
        dialog.release_grab()

    def edit_macro(self):
        selection = self.tree.selection()
        if not selection:
            messagebox.showwarning("Attention", "Veuillez selectionner une macro a editer.")
            return
        name = self.tree.item(selection[0])['values'][0]
        messagebox.showinfo("Edition", f"Mode édition pour: {name}\nÀ implémenter...")

    def delete_macro(self):
        selection = self.tree.selection()
        if not selection:
            messagebox.showwarning("Attention", "Veuillez selectionner une macro a supprimer.")
            return
        name = self.tree.item(selection[0])['values'][0]
        if messagebox.askyesno("Suppression", f"Voulez-vous vraiment supprimer la macro {name}?"):
            os.remove(MACRO_DIR / f"{name}.xml")
            self.refresh_macros_list()

    def test_macro(self):
        selection = self.tree.selection()
        if not selection:
            messagebox.showwarning("Attention", "Veuillez selectionner une macro a tester.")
            return
        name = self.tree.item(selection[0])['values'][0]
        xml_path = MACRO_DIR / f"{name}.xml"
        generate_bash_from_xml(xml_path)
        sh_path = xml_path.with_suffix('.sh')
        os.system(f"xterm -hold -e bash {sh_path}")

    def export_macro(self):
        selection = self.tree.selection()
        if not selection:
            messagebox.showwarning("Attention", "Veuillez selectionner une macro a exporter.")
            return
        name = self.tree.item(selection[0])['values'][0]
        xml_path = MACRO_DIR / f"{name}.xml"
        config = load_config()
        export_dir = Path(config.get('export_dir', str(Path.home() / "macrosTitux_exports")))
        export_dir.mkdir(parents=True, exist_ok=True)
        output_path = export_dir / f"{name}.sh"
        generate_bash_from_xml(xml_path, str(output_path))
        messagebox.showinfo("Export", f"Script généré: {output_path}")

    def import_macro(self):
        filepath = filedialog.askopenfilename(
            title="Importer une macro",
            filetypes=[("Fichiers XML", "*.xml"), ("Tous les fichiers", "*.*")]
        )

        if not filepath:
            return

        try:
            import xml.etree.ElementTree as ET
            tree = ET.parse(filepath)
            root = tree.getroot()

            if root.tag != 'macro':
                messagebox.showerror("Erreur", "Fichier XML invalide")
                return

            macro_name = root.get('name', 'Macro_Inconnue')
            dest_path = MACRO_DIR / f"{macro_name}.xml"

            if dest_path.exists():
                if not messagebox.askyesno("Remplacer", f"La macro '{macro_name}' existe déjà. Remplacer ?"):
                    return

            shutil.copy2(filepath, dest_path)
            self.refresh_macros_list()
            messagebox.showinfo("Info", f"Macro '{macro_name}' importée avec succès !")

        except Exception as e:
            messagebox.showerror("Erreur", f"Impossible d'importer la macro :\n{str(e)}")

    def quit(self):
        self.parent.destroy()
EOF
    success "Fichier gui.py créé"
}

#------------------------------------------------------------------------------
# Fichier 5: src/macrosTitux.py - Point d'entrée simplifié
#------------------------------------------------------------------------------
update_main_file() {
    local file="$PROJECT_ROOT/src/macrosTitux.py"
    log "Mise à jour de $file..."

    cat > "$file" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: macrosTitux.py
# Description: Point d'entrée principal de l'application
# Version: 0.3 (Modulaire)
# License: GPL-3.0
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import sys
import os
from pathlib import Path

# Ajout du dossier src au path
src_dir = Path(__file__).parent
sys.path.insert(0, str(src_dir))

from gui import MacrosTituxApp
from model import init_dirs
from tkinter import Tk

def main():
    """Point d'entrée de l'application."""
    init_dirs()

    root = Tk()
    app = MacrosTituxApp(root)
    app.mainloop()

if __name__ == "__main__":
    main()
EOF
    success "Fichier macrosTitux.py mis à jour"
}

#------------------------------------------------------------------------------
# Exécution principale
#------------------------------------------------------------------------------
main() {
    log "=========================================="
    log " REFACTORING MODULAIRE"
    log "=========================================="
    log " Projet: $PROJECT_ROOT"
    log ""

    create_init_file
    create_widgets_file
    create_dialogs_file
    create_gui_file
    update_main_file

    log ""
    log "=========================================="
    log " REFACTORING TERMINÉ"
    log "=========================================="
    log " Fichiers créés/mis à jour:"
    log "   - src/__init__.py"
    log "   - src/widgets.py"
    log "   - src/dialogs.py"
    log "   - src/gui.py"
    log "   - src/macrosTitux.py"
    log ""
    log " Testez avec: pytest tests/ -v"
    log " Lancez l'app: ./src/macrosTitux.py"
    log "=========================================="
}

main "$@"
