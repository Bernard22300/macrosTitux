# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: gui.py
# Description: Interface graphique principale (MacrosTituxApp)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import os
from tkinter import ttk, Tk, Frame, Label, Entry, Button, Text, Scrollbar, Listbox, messagebox, W, X, BOTH, StringVar
from pathlib import Path
from dialogs import NewMacroDialog
from model import load_macros_list, save_macro, generate_bash_from_xml, load_config
import shutil
from tkinter import filedialog

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
        notebook = ttk.Notebook(self.parent)
        notebook.pack(fill='both', expand=True, padx=10, pady=10)
        
        self.tab_macros = Frame(notebook)
        notebook.add(self.tab_macros, text="Macros")
        self.setup_tab_macros()
        
        self.tab_templates = Frame(notebook)
        notebook.add(self.tab_templates, text="Templates")
        self.setup_tab_templates()
        
        self.tab_settings = Frame(notebook)
        notebook.add(self.tab_settings, text="Parametres")
        self.setup_tab_settings()
        
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
        Label(self.tab_settings, text="Version: {APP_VERSION}", foreground='gray').pack(anchor='w', padx=10, pady=20)
    
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
