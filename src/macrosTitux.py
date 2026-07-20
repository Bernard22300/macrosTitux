#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
macrosTitux.py
Version: 0.1
License: GPL-3.0
"""
import os
import sys
import json
import xml.etree.ElementTree as ET
from pathlib import Path
from tkinter import ttk, messagebox, StringVar, Text, Tk, Toplevel

APP_NAME = "macrosTitux"
APP_VERSION = "0.1"
BASE_DIR = Path(os.path.dirname(os.path.abspath(__file__)).replace('/src', ''))
CONFIG_DIR = Path.home() / ".config" / APP_NAME
MACRO_DIR = CONFIG_DIR / "macros"
CONF_FILE = CONFIG_DIR / "macrosTitux.conf"

TRIGGERS = {
    "DEMARRAGE": "Au démarrage",
    "HORAIRE": "Horaire",
    "FICHIER_MODIFIE": "Fichier modifié",
    "FICHIER_CREE": "Fichier créé",
    "USB_CONNECTE": "USB connecté",
    "RESEAU_ACTIF": "Réseau activé",
    "SORTIE_TUBE": "Sortie de tube"
}

ACTIONS = {
    "COPIER_FICHIER": "Copier fichier(s)",
    "DEPLACER_FICHIER": "Déplacer fichier(s)",
    "SUPPRIMER_FICHIER": "Supprimer fichier(s)",
    "NOTIFIER": "Notifier",
    "EXECUTER_CMD": "Exécuter commande",
    "REDÉMARRER_SERV": "Redémarrer service",
    "SORTIR_RESULTAT": "Sortir résultat dans tube"
}

CONSTRAINTS = {
    "ESPACE_DISQUE": "Espace disque disponible",
    "PLAGE_HORAIRE": "Plage horaire",
    "PROCESSUS_ACTIF": "Processus actif"
}

def init_dirs():
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    MACRO_DIR.mkdir(parents=True, exist_ok=True)
    if not CONF_FILE.exists():
        config = {
            "editor": "nano",
            "auto_test": False,
            "export_dir": str(Path.home() / "macrosTitux_exports"),
            "log_level": "info"
        }
        with open(CONF_FILE, 'w') as f:
            json.dump(config, f, indent=4, ensure_ascii=False)

def load_config():
    with open(CONF_FILE, 'r') as f:
        return json.load(f)

def load_macros_list():
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

def save_macro(name, trigger_type, trigger_label, trigger_params, actions, constraints):
    root = ET.Element("macro")
    root.set('name', name)
    trigger = ET.SubElement(root, "trigger")
    trigger.set('type', trigger_type)
    trigger.set('label', trigger_label)
    config = ET.SubElement(trigger, "config")
    for k, v in trigger_params.items():
        param = ET.SubElement(config, "param")
        param.set('key', k)
        param.text = str(v)
    actions_elem = ET.SubElement(root, "actions")
    for i, action in enumerate(actions):
        action_el = ET.SubElement(actions_elem, "action")
        action_el.set('id', str(i + 1))
        action_el.set('type', action['type'])
        action_el.set('label', action.get('label', ''))
        cfg = ET.SubElement(action_el, "config")
        for k, v in action.get('params', {}).items():
            p = ET.SubElement(cfg, "param")
            p.set('key', k)
            p.text = str(v)
    constraints_elem = ET.SubElement(root, "constraints")
    for i, constraint in enumerate(constraints):
        c_el = ET.SubElement(constraints_elem, "constraint")
        c_el.set('id', str(i + 1))
        c_el.set('type', constraint['type'])
        c_el.set('label', constraint.get('label', ''))
    tree = ET.ElementTree(root)
    ET.indent(tree, space="    ")
    with open(MACRO_DIR / f"{name}.xml", 'wb') as f:
        tree.write(f, encoding='utf-8', xml_declaration=True)

def generate_bash_from_xml(xml_path, output_path=None):
    script_path = Path(__file__).parent / "generate_bash.sh"
    if output_path is None:
        output_path = str(xml_path).replace('.xml', '.sh')
    os.system(f"bash {script_path} {xml_path} {output_path}")

class MacrosTituxApp(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.parent.title(f"{APP_NAME} v{APP_VERSION}")
        self.parent.geometry("800x600")
        notebook = ttk.Notebook(self)
        notebook.pack(fill='both', expand=True, padx=10, pady=10)
        self.tab_macros = ttk.Frame(notebook)
        notebook.add(self.tab_macros, text="Macros")
        self.setup_tab_macros()
        self.tab_templates = ttk.Frame(notebook)
        notebook.add(self.tab_templates, text="Templates")
        self.setup_tab_templates()
        self.tab_settings = ttk.Frame(notebook)
        notebook.add(self.tab_settings, text="Parametres")
        self.setup_tab_settings()
        btn_frame = ttk.Frame(self)
        btn_frame.pack(fill='x', padx=10, pady=5)
        ttk.Button(btn_frame, text="+ Nouvelle macro", command=self.new_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Editer", command=self.edit_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Supprimer", command=self.delete_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Tester", command=self.test_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Exporter", command=self.export_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Quitter", command=self.quit).pack(side='right')
        self.refresh_macros_list()

    def setup_tab_macros(self):
        self.tree = ttk.Treeview(self.tab_macros, columns=('Nom', 'Declencheur', 'Action'), show='headings')
        self.tree.heading('Nom', text='Nom')
        self.tree.heading('Declencheur', text='Declencheur')
        self.tree.heading('Action', text='Action')
        self.tree.column('Nom', width=200)
        self.tree.column('Declencheur', width=250)
        self.tree.column('Action', width=250)
        self.tree.pack(fill='both', expand=True, padx=5, pady=5)

    def setup_tab_templates(self):
        label = ttk.Label(self.tab_templates, text="Aucun template disponible pour le moment.", justify='center')
        label.pack(expand=True, pady=50)

    def setup_tab_settings(self):
        config = load_config()
        ttk.Label(self.tab_settings, text="Repertoire des macros:", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        ttk.Entry(self.tab_settings, textvariable=StringVar(value=str(MACRO_DIR))).pack(fill='x', padx=10, pady=2)
        ttk.Label(self.tab_settings, text="Editeur par defaut:", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        ttk.Entry(self.tab_settings, textvariable=StringVar(value=config.get('editor', 'nano'))).pack(fill='x', padx=10, pady=2)
        ttk.Label(self.tab_settings, text="Repertoire d'export:", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        ttk.Entry(self.tab_settings, textvariable=StringVar(value=config.get('export_dir', ''))).pack(fill='x', padx=10, pady=2)
        ttk.Label(self.tab_settings, text=f"Version: {APP_VERSION}", foreground='gray').pack(anchor='w', padx=10, pady=20)

    def refresh_macros_list(self):
        for item in self.tree.get_children():
            self.tree.delete(item)
        for name, trigger, action in load_macros_list():
            self.tree.insert('', 'end', values=(name, trigger, action))

    def new_macro(self):
        dialog = NewMacroDialog(self.parent)
        if dialog.result:
            save_macro(*dialog.result)
            self.refresh_macros_list()
            messagebox.showinfo("Info", f"Macro '{dialog.result[0]}' creee avec succes.")

    def edit_macro(self):
        selection = self.tree.selection()
        if not selection:
            messagebox.showwarning("Attention", "Veuillez selectionner une macro a editer.")
            return
        name = self.tree.item(selection[0])['values'][0]
        messagebox.showinfo("Edition", f"Mode edition pour: {name}\nA implementer...")

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
        os.system(f"xterm -e bash {sh_path}; echo 'Pressez Entree pour fermer'; read")

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
        messagebox.showinfo("Export", f"Script genere: {output_path}")

    def quit(self):
        self.parent.destroy()

class NewMacroDialog(ttk.Frame):
    def __init__(self, parent):
        super().__init__()
        self.result = None
        self.window = Toplevel(parent)
        self.window.title("Nouvelle macro")
        self.window.geometry("500x400")
        ttk.Label(self.window, text="Nom de la macro:", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        self.name_entry = ttk.Entry(self.window)
        self.name_entry.pack(fill='x', padx=10, pady=2)
        ttk.Label(self.window, text="Declencheur:", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        self.trigger_combo = ttk.Combobox(self.window, values=list(TRIGGERS.values()), state='readonly')
        self.trigger_combo.current(0)
        self.trigger_combo.pack(fill='x', padx=10, pady=2)
        ttk.Label(self.window, text="Actions (optionnel):", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        self.actions_text = Text(self.window, height=5)
        self.actions_text.pack(fill='x', padx=10, pady=2)
        ttk.Label(self.window, text="Contraintes (optionnel):", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        self.constraints_text = Text(self.window, height=3)
        self.constraints_text.pack(fill='x', padx=10, pady=2)
        btn_frame = ttk.Frame(self.window)
        btn_frame.pack(fill='x', padx=10, pady=10)
        ttk.Button(btn_frame, text="Annuler", command=self.window.destroy).pack(side='right', padx=5)
        ttk.Button(btn_frame, text="Creer", command=self.save).pack(side='right')

    def save(self):
        name = self.name_entry.get().strip()
        if not name:
            messagebox.showerror("Erreur", "Le nom de la macro est requis.")
            return
        trigger_label = self.trigger_combo.get()
        trigger_type = [k for k, v in TRIGGERS.items() if v == trigger_label][0]
        self.result = (name, trigger_type, trigger_label, {}, [], [])
        self.window.destroy()

if __name__ == "__main__":
    init_dirs()
    root = Tk()
    app = MacrosTituxApp(root)
    app.pack(fill='both', expand=True)
    app.mainloop()
