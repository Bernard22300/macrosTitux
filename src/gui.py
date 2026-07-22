# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: gui.py
# Description: Interface principale (MacrosTituxApp)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from tkinter import ttk, messagebox, Listbox
import os
from model import generer_bash_depuis_xml, initialiser_dossiers

class MacrosTituxApp(ttk.Frame):
    """Application principale."""

    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        parent.title("macrosTitux v0.3")
        parent.geometry("900x600")

        self.element_selectionne = None

        initialiser_dossiers()
        self.configurer_interface()
        self.rafraichir_liste()

        self.pack(fill="both", expand=True)

    def configurer_interface(self):
        tabs = ttk.Notebook(self)
        tabs.pack(fill="both", expand=True, padx=5, pady=5)

        onglet_macros = ttk.Frame(tabs)
        tabs.add(onglet_macros, text="Macros")
        self.configurer_onglet_macros(onglet_macros)

        onglet_modeles = ttk.Frame(tabs)
        tabs.add(onglet_modeles, text="Modeles")
        self.configurer_onglet_modeles(onglet_modeles)

        onglet_parametres = ttk.Frame(tabs)
        tabs.add(onglet_parametres, text="Parametres")
        self.configurer_onglet_parametres(onglet_parametres)

    def configurer_onglet_macros(self, parent):
        colonnes = ("nom", "declencheur", "action")
        self.tree = ttk.Treeview(parent, columns=colonnes, show="headings")
        self.tree.heading("nom", text="Nom")
        self.tree.heading("declencheur", text="Declencheur")
        self.tree.heading("action", text="Action")
        self.tree.column("nom", width=200)
        self.tree.column("declencheur", width=150)
        self.tree.column("action", width=200)
        self.tree.pack(fill="both", expand=True, padx=10, pady=10)
        self.tree.bind("<<TreeviewSelect>>", self.sur_selection)

        defilement = ttk.Scrollbar(parent, orient="vertical", command=self.tree.yview)
        defilement.pack(side="right", fill="y", padx=(0, 10))
        self.tree.configure(yscrollcommand=defilement.set)

        cadre_boutons = ttk.Frame(parent)
        cadre_boutons.pack(fill="x", padx=10, pady=10)

        ttk.Button(cadre_boutons, text="+ Nouvelle macro", command=self.nouvelle_macro).pack(side="left", padx=2)
        ttk.Button(cadre_boutons, text="Éditer", command=self.editer_macro).pack(side="left", padx=2)
        ttk.Button(cadre_boutons, text="Supprimer", command=self.supprimer_macro).pack(side="left", padx=2)
        ttk.Button(cadre_boutons, text="Tester", command=self.tester_macro).pack(side="left", padx=2)
        ttk.Button(cadre_boutons, text="Exporter", command=self.exporter_macro).pack(side="left", padx=2)
        ttk.Button(cadre_boutons, text="Importer", command=self.importer_macro).pack(side="left", padx=2)

    def configurer_onglet_modeles(self, parent):
        titre_label = ttk.Label(parent, text="Modeles disponibles", font=("Arial", 12, "bold"))
        titre_label.pack(pady=10)

        dossier_modeles = os.path.join(os.path.dirname(__file__), "..", "modeles")
        dossier_modeles = os.path.abspath(dossier_modeles)

        if os.path.isdir(dossier_modeles):
            fichiers_modeles = [f for f in os.listdir(dossier_modeles) if f.endswith(".xml")]
            if fichiers_modeles:
                self.listbox_modeles = Listbox(parent, selectmode="single", height=8)
                self.listbox_modeles.pack(fill="both", expand=True, padx=20, pady=10)
                for m in fichiers_modeles:
                    self.listbox_modeles.insert("end", m.replace(".xml", ""))

                cadre_boutons = ttk.Frame(parent)
                cadre_boutons.pack(fill="x", padx=20, pady=10)
                ttk.Button(cadre_boutons, text="Installer le modele selectionne",
                          command=lambda: self.installer_modele(dossier_modeles)).pack(side="left")
                ttk.Button(cadre_boutons, text="Ouvrir le dossier modeles",
                          command=lambda: os.system("xdg-open " + dossier_modeles)).pack(side="left", padx=5)
            else:
                ttk.Label(parent, text="Aucun modele disponible").pack(pady=20)
        else:
            ttk.Label(parent, text="Dossier modeles inexistant").pack(pady=20)

    def configurer_onglet_parametres(self, parent):
        ttk.Label(parent, text="Parametres de l'application", font=("Arial", 12, "bold")).pack(pady=10)
        ttk.Label(parent, text="Version: 0.3", font=("Arial", 10)).pack(pady=5)
        ttk.Label(parent, text="Licence: GPL-3.0", font=("Arial", 10)).pack(pady=5)

        cadre_boutons = ttk.Frame(parent)
        cadre_boutons.pack(side="bottom", pady=20)
        ttk.Button(cadre_boutons, text="Quitter", command=self.quitter_application).pack(padx=5)

    def rafraichir_liste(self):
        if not hasattr(self, "tree"):
            return
        dossier_macros = os.path.expanduser("~/.config/macrosTitux/macros/")
        if not os.path.isdir(dossier_macros):
            return
        for item in self.tree.get_children():
            self.tree.delete(item)
        fichiers = sorted([f for f in os.listdir(dossier_macros) if f.endswith(".xml")])
        for f in fichiers:
            chemin_xml = os.path.join(dossier_macros, f)
            try:
                infos = generer_bash_depuis_xml(chemin_xml, simulation=True)
                nom = infos.get("name", f.replace(".xml", ""))
                declencheur = infos.get("type_declencheur", "Inconnu")
                actions = infos.get("actions", [])
                labels_actions = [a.get("label", "") for a in actions[:2]]
                actions_str = ", ".join(labels_actions)
                self.tree.insert("", "end", iid=f, values=(nom, declencheur, actions_str))
            except Exception as e:
                self.tree.insert("", "end", iid=f, values=(f, "Erreur: " + str(e)[:30], "-"))

    def sur_selection(self, event=None):
        selection = self.tree.selection()
        self.element_selectionne = selection[0] if selection else None

    def nouvelle_macro(self):
        from dialogs import DialogueNouvelleMacro
        dialogue = DialogueNouvelleMacro(self.parent)
        pass
        if dialogue.result:
            nom, donnees_declencheur, variables, actions, contraintes = dialogue.result
            from model import sauvegarder_macro
            sauvegarder_macro(nom, donnees_declencheur, variables, actions, contraintes)
            self.rafraichir_liste()

    def editer_macro(self):
        if not self.element_selectionne:
            messagebox.showwarning("Attention", "Selectionnez une macro.")
            return
        messagebox.showinfo("Info", "Fonctionnalite non implantee pour le moment.")

    def supprimer_macro(self):
        if not self.element_selectionne:
            messagebox.showwarning("Attention", "Selectionnez une macro.")
            return
        result = messagebox.askyesno("Confirmation", "Supprimer la macro " + self.element_selectionne + "?")
        if result:
            from model import supprimer_macro
            supprimer_macro(self.element_selectionne)
            self.rafraichir_liste()

    def tester_macro(self):
        if not self.element_selectionne:
            messagebox.showwarning("Attention", "Selectionnez une macro.")
            return
        # Obtenir le nom depuis les valeurs du tree
        valeurs = self.tree.item(self.element_selectionne, "values")
        nom_macro = valeurs[0] if valeurs else self.element_selectionne

        dossier_macros = os.path.expanduser("~/.config/macrosTitux/macros/")
        chemin_xml = os.path.join(dossier_macros, nom_macro + ".xml")

        # Afficher le XML dans la console
        print("\n" + "=" * 60)
        print(f"  XML de la macro: {nom_macro}")
        print("=" * 60)
        with open(chemin_xml, "r", encoding="utf-8") as f:
            print(f.read())
        print("=" * 60 + "\n")

        # Generer et executer le script Bash
        chemin_sh = os.path.join(dossier_macros, nom_macro + ".sh")
        try:
            infos = generer_bash_depuis_xml(chemin_xml, chemin_sortie=chemin_sh)
            print(f"Script genere: {chemin_sh}")
            os.chmod(chemin_sh, 0o755)
            os.system("xterm -hold -e bash " + chemin_sh)
        except Exception as e:
            print(f"Erreur: {e}")
            messagebox.showerror("Erreur", str(e))

    def exporter_macro(self):
        if not self.element_selectionne:
            messagebox.showwarning("Attention", "Selectionnez une macro.")
            return
        import shutil
        dossier_macros = os.path.expanduser("~/.config/macrosTitux/macros/")
        destination = os.path.join(os.getcwd(), self.element_selectionne)
        shutil.copy(os.path.join(dossier_macros, self.element_selectionne), destination)
        messagebox.showinfo("Info", "Macro exportee dans le dossier projet")

    def importer_macro(self):
        result = messagebox.askyesno("Importer", "Choisir un fichier XML ?")
        if result:
            messagebox.showinfo("Info", "Fonctionnalite non implantee pour le moment.")

    def installer_modele(self, dossier_modeles):
        selection = self.listbox_modeles.curselection()
        if not selection:
            messagebox.showwarning("Attention", "Selectionnez un modele.")
            return
        nom_modele = self.listbox_modeles.get(selection[0])
        fichier_modele = os.path.join(dossier_modeles, nom_modele + ".xml")
        repertoire_utilisateur = os.path.expanduser("~/.config/macrosTitux/macros/")
        import shutil
        shutil.copy(fichier_modele, repertoire_utilisateur)
        self.rafraichir_liste()
        messagebox.showinfo("Info", "Modele installe avec succes")

    def quitter_application(self):
        self.parent.destroy()
