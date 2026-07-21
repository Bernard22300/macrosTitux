# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: gui.py
# Description: Interface principale (MacrosTituxApp)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from tkinter import ttk, messagebox, Listbox
import os
from model import generate_bash_from_xml, init_dirs

class MacrosTituxApp(ttk.Frame):
    """Application principale."""

    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        parent.title("macrosTitux v0.3")
        parent.geometry("900x600")

        self.selected_item = None

        init_dirs()
        self.setup_ui()
        self.refresh_list()

        self.pack(fill="both", expand=True)

    def setup_ui(self):
        tabs = ttk.Notebook(self)
        tabs.pack(fill="both", expand=True, padx=5, pady=5)

        macros_tab = ttk.Frame(tabs)
        tabs.add(macros_tab, text="Macros")
        self.setup_macros_tab(macros_tab)

        modeles_tab = ttk.Frame(tabs)
        tabs.add(modeles_tab, text="Modeles")
        self.setup_modeles_tab(modeles_tab)

        settings_tab = ttk.Frame(tabs)
        tabs.add(settings_tab, text="Parametres")
        self.setup_settings_tab(settings_tab)

    def setup_macros_tab(self, parent):
        columns = ("nom", "declencheur", "action")
        self.tree = ttk.Treeview(parent, columns=columns, show="headings")
        self.tree.heading("nom", text="Nom")
        self.tree.heading("declencheur", text="Declencheur")
        self.tree.heading("action", text="Action")
        self.tree.column("nom", width=200)
        self.tree.column("declencheur", width=150)
        self.tree.column("action", width=200)
        self.tree.pack(fill="both", expand=True, padx=10, pady=10)
        self.tree.bind("<<TreeviewSelect>>", self.on_select)

        scrollbar = ttk.Scrollbar(parent, orient="vertical", command=self.tree.yview)
        scrollbar.pack(side="right", fill="y", padx=(0, 10))
        self.tree.configure(yscrollcommand=scrollbar.set)

        btn_frame = ttk.Frame(parent)
        btn_frame.pack(fill="x", padx=10, pady=10)

        ttk.Button(btn_frame, text="+ Nouvelle macro", command=self.new_macro).pack(side="left", padx=2)
        ttk.Button(btn_frame, text="Editer", command=self.edit_macro).pack(side="left", padx=2)
        ttk.Button(btn_frame, text="Supprimer", command=self.delete_macro).pack(side="left", padx=2)
        ttk.Button(btn_frame, text="Tester", command=self.test_macro).pack(side="left", padx=2)
        ttk.Button(btn_frame, text="Exporter", command=self.export_macro).pack(side="left", padx=2)
        ttk.Button(btn_frame, text="Importer", command=self.import_macro).pack(side="left", padx=2)

    def setup_modeles_tab(self, parent):
        title_label = ttk.Label(parent, text="Modeles disponibles", font=("Arial", 12, "bold"))
        title_label.pack(pady=10)

        modeles_dir = os.path.join(os.path.dirname(__file__), "..", "modeles")
        modeles_dir = os.path.abspath(modeles_dir)

        if os.path.isdir(modeles_dir):
            modele_files = [f for f in os.listdir(modeles_dir) if f.endswith(".xml")]
            if modele_files:
                self.modele_listbox = Listbox(parent, selectmode="single", height=8)
                self.modele_listbox.pack(fill="both", expand=True, padx=20, pady=10)
                for m in modele_files:
                    self.modele_listbox.insert("end", m.replace(".xml", ""))

                btn_frame = ttk.Frame(parent)
                btn_frame.pack(fill="x", padx=20, pady=10)
                ttk.Button(btn_frame, text="Installer le modele selectionne",
                          command=lambda: self.installer_modele(modeles_dir)).pack(side="left")
                ttk.Button(btn_frame, text="Ouvrir le dossier modeles",
                          command=lambda: os.system("xdg-open " + modeles_dir)).pack(side="left", padx=5)
            else:
                ttk.Label(parent, text="Aucun modele disponible").pack(pady=20)
        else:
            ttk.Label(parent, text="Dossier modeles inexistant").pack(pady=20)

    def setup_settings_tab(self, parent):
        ttk.Label(parent, text="Parametres de l'application", font=("Arial", 12, "bold")).pack(pady=10)
        ttk.Label(parent, text="Version: 0.3", font=("Arial", 10)).pack(pady=5)
        ttk.Label(parent, text="Licence: GPL-3.0", font=("Arial", 10)).pack(pady=5)

        btn_frame = ttk.Frame(parent)
        btn_frame.pack(side="bottom", pady=20)
        ttk.Button(btn_frame, text="Quitter", command=self.quit_app).pack(padx=5)

    def refresh_list(self):
        if not hasattr(self, "tree"):
            return
        macros_dir = os.path.expanduser("~/.config/macrosTitux/macros/")
        if not os.path.isdir(macros_dir):
            return
        for item in self.tree.get_children():
            self.tree.delete(item)
        files = sorted([f for f in os.listdir(macros_dir) if f.endswith(".xml")])
        for f in files:
            xml_path = os.path.join(macros_dir, f)
            try:
                info = generate_bash_from_xml(xml_path, dry_run=True)
                nom = info.get("name", f.replace(".xml", ""))
                trigger = info.get("trigger_type", "Inconnu")
                actions = info.get("actions", [])
                action_labels = [a.get("label", "") for a in actions[:2]]
                action_str = ", ".join(action_labels)
                self.tree.insert("", "end", iid=f, values=(nom, trigger, action_str))
            except Exception as e:
                self.tree.insert("", "end", iid=f, values=(f, "Erreur: " + str(e)[:30], "-"))

    def on_select(self, event=None):
        selection = self.tree.selection()
        self.selected_item = selection[0] if selection else None

    def new_macro(self):
        from dialogs import NewMacroDialog
        dialog = NewMacroDialog(self.parent)
        self.parent.wait_window(dialog)
        if dialog.result:
            name, trigger, variables, actions, constraints = dialog.result
            from model import save_macro
            save_macro(name, trigger, variables, actions, constraints)
            self.refresh_list()

    def edit_macro(self):
        if not self.selected_item:
            messagebox.showwarning("Attention", "Selectionnez une macro.")
            return
        messagebox.showinfo("Info", "Fonctionnalite non implantee pour le moment.")

    def delete_macro(self):
        if not self.selected_item:
            messagebox.showwarning("Attention", "Selectionnez une macro.")
            return
        result = messagebox.askyesno("Confirmation", "Supprimer la macro " + self.selected_item + "?")
        if result:
            from model import delete_macro
            delete_macro(self.selected_item)
            self.refresh_list()

    def test_macro(self):
        if not self.selected_item:
            messagebox.showwarning("Attention", "Selectionnez une macro.")
            return
        macro_file = self.selected_item
        macro_dir = os.path.expanduser("~/.config/macrosTitux/macros/")
        sh_content, sh_path = generate_bash_from_xml(os.path.join(macro_dir, macro_file), dry_run=False)
        with open(sh_path, "w", encoding="utf-8") as f:
            f.write(sh_content)
        os.chmod(sh_path, 0o755)
        os.system("xterm -hold -e bash " + sh_path)

    def export_macro(self):
        if not self.selected_item:
            messagebox.showwarning("Attention", "Selectionnez une macro.")
            return
        import shutil
        macro_dir = os.path.expanduser("~/.config/macrosTitux/macros/")
        dest = os.path.join(os.getcwd(), self.selected_item)
        shutil.copy(os.path.join(macro_dir, self.selected_item), dest)
        messagebox.showinfo("Info", "Macro exportee dans le dossier projet")

    def import_macro(self):
        result = messagebox.askyesno("Importer", "Choisir un fichier XML ?")
        if result:
            messagebox.showinfo("Info", "Fonctionnalite non implantee pour le moment.")

    def installer_modele(self, modeles_dir):
        selection = self.modele_listbox.curselection()
        if not selection:
            messagebox.showwarning("Attention", "Selectionnez un modele.")
            return
        modele_name = self.modele_listbox.get(selection[0])
        modele_file = os.path.join(modeles_dir, modele_name + ".xml")
        user_dir = os.path.expanduser("~/.config/macrosTitux/macros/")
        import shutil
        shutil.copy(modele_file, user_dir)
        self.refresh_list()
        messagebox.showinfo("Info", "Modele installe avec succes")

    def quit_app(self):
        self.parent.destroy()
