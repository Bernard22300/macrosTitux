# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: gui.py
# Description: Interface principale (MacrosTituxApp)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from tkinter import ttk, messagebox, Listbox, X, W, E
import os
from model import generer_bash_depuis_xml, initialiser_dossiers
from fonction_loader import obtenir_toutes_les_fonctions, scanner_fonctions_actives
from pathlib import Path

class MacrosTituxApp(ttk.Frame):
    """Application principale."""

    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        parent.title("macrosTitux v0.4c")
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

        onglet_fonctions = ttk.Frame(tabs)
        tabs.add(onglet_fonctions, text="Fonctionnalites")
        self.configurer_onglet_fonctions(onglet_fonctions)

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

    def configurer_onglet_fonctions(self, parent):
        """Onglet pour gerer les fonctions actives/inactives."""
        
        # Titre
        titre_label = ttk.Label(parent, text="Gestion des fonctionnalites", font=("Arial", 12, "bold"))
        titre_label.pack(pady=10)
        
        # Instructions
        info_label = ttk.Label(parent, text="Activez ou desactivez les fonctions selon vos besoins.\nRedemarrage de l'application necessaire pour prendre en compte.", foreground="gray")
        info_label.pack(pady=5)
        
        # Zone de scroll pour la liste des fonctions
        cadre_liste = ttk.Frame(parent)
        cadre_liste.pack(fill="both", expand=True, padx=20, pady=10)
        
        defilement_x = ttk.Scrollbar(cadre_liste, orient="horizontal")
        defilement_x.pack(side="bottom", fill="x")
        
        defilement_y = ttk.Scrollbar(cadre_liste, orient="vertical")
        defilement_y.pack(side="right", fill="y")
        
        # Treeview pour afficher les fonctions
        colonnes_fonctions = ("identificateur", "description", "statut", "actions")
        self.tree_fonctions = ttk.Treeview(cadre_liste, columns=colonnes_fonctions, show="headings", yscrollcommand=defilement_y.set, xscrollcommand=defilement_x.set)
        self.tree_fonctions.heading("identificateur", text="Identificateur")
        self.tree_fonctions.heading("description", text="Description")
        self.tree_fonctions.heading("statut", text="Statut")
        self.tree_fonctions.column("identificateur", width=200)
        self.tree_fonctions.column("description", width=400)
        self.tree_fonctions.column("statut", width=80)
        self.tree_fonctions.column("actions", width=120)
        self.tree_fonctions.pack(fill="both", expand=True)
        
        defilement_y.configure(command=self.tree_fonctions.yview)
        defilement_x.configure(command=self.tree_fonctions.xview)
        
        # Boutons d'action
        cadre_boutons_fonctions = ttk.Frame(parent)
        cadre_boutons_fonctions.pack(fill="x", padx=20, pady=10)
        
        ttk.Button(cadre_boutons_fonctions, text="Actualiser", command=self.actualiser_fonctions).pack(side="left", padx=5)
        ttk.Button(cadre_boutons_fonctions, text="Activer selectionnee", command=self.activer_fonction_selectionnee).pack(side="left", padx=5)
        ttk.Button(cadre_boutons_fonctions, text="Desactiver selectionnee", command=self.desactiver_fonction_selectionnee).pack(side="left", padx=5)
        
        # Initialiser l'affichage
        self.actualiser_fonctions()

    def actualiser_fonctions(self):
        """Actualise la liste des fonctions dans l'onglet Fonctionnalites."""
        
        # Vider la treeview
        for item in self.tree_fonctions.get_children():
            self.tree_fonctions.delete(item)
        
        # Chemins
        src_dir = Path(__file__).parent
        possibles_dir = src_dir / "fonctions" / "possibles"
        actives_dir = src_dir / "fonctions" / "actives"
        
        # Scanner les fichiers disponibles
        if not possibles_dir.exists():
            return
        
        for f in possibles_dir.glob("*.py"):
            if f.name.startswith("_"):
                continue
            
            nom_fonction = f.stem
            chemin_complet = str(f)
            
            # Verifier si active (lien symbolique existe)
            lien_actif = actives_dir / f"{nom_fonction}.py"
            est_active = lien_actif.exists() or lien_actif.is_symlink()
            
            # Essayer de charger la fonction pour obtenir la description
            try:
                # Import temporaire pour recuperer la classe
                import sys
                sys.path.insert(0, str(possibles_dir))
                module = __import__(nom_fonction)
                
                # Trouver la classe qui herite de Fonction_de_base
                description = "Description inconnue"
                for attr_name in dir(module):
                    attr = getattr(module, attr_name)
                    if isinstance(attr, type) and hasattr(attr, '__bases__'):
                        from fonction_base import Fonction_de_base
                        if issubclass(attr, Fonction_de_base) and attr != Fonction_de_base:
                            instance = attr()
                            description = instance.description
                            break
                
                # Nettoyer le sys.path
                sys.path.remove(str(possibles_dir))
            except Exception as e:
                description = f"Erreur chargement: {str(e)[:30]}"
            
            # Statut
            statut = "ACTIVE" if est_active else "inactive"
            
            # Inscrire dans la treeview
            self.tree_fonctions.insert("", "end", iid=nom_fonction, values=(nom_fonction, description, statut))
        
        # Colorer les statuts
        for item in self.tree_fonctions.get_children():
            valeurs = self.tree_fonctions.item(item, "values")
            if valeurs and valeurs[2] == "ACTIVE":
                self.tree_fonctions.tag_configure("actif", foreground="green")
                self.tree_fonctions.item(item, tags=("actif",))

    def activer_fonction_selectionnee(self):
        """Active la fonction selectionnee en creant un lien symbolique."""
        selection = self.tree_fonctions.selection()
        if not selection:
            messagebox.showwarning("Attention", "Selectionnez une fonction.")
            return
        
        nom_fonction = selection[0]
        src_dir = Path(__file__).parent
        possibles_dir = src_dir / "fonctions" / "possibles"
        actives_dir = src_dir / "fonctions" / "actives"
        
        source = possibles_dir / f"{nom_fonction}.py"
        dest = actives_dir / f"{nom_fonction}.py"
        
        if not source.exists():
            messagebox.showerror("Erreur", f"Fichier source introuvable: {source}")
            return
        
        if dest.exists() or dest.is_symlink():
            messagebox.showerror("Erreur", "Cette fonction est deja activee.")
            return
        
        try:
            actives_dir.mkdir(parents=True, exist_ok=True)
            # Creer un lien symbolique relatif
            lien_relatif = os.path.relpath(source, actives_dir)
            os.symlink(lien_relatif, dest)
            messagebox.showinfo("Succes", f"Fonction {nom_fonction} activee avec succes.")
            self.actualiser_fonctions()
        except Exception as e:
            messagebox.showerror("Erreur", f"Echec de l'activation: {str(e)}")

    def desactiver_fonction_selectionnee(self):
        """Desactive la fonction selectionnee en supprimant le lien symbolique."""
        selection = self.tree_fonctions.selection()
        if not selection:
            messagebox.showwarning("Attention", "Selectionnez une fonction.")
            return
        
        nom_fonction = selection[0]
        src_dir = Path(__file__).parent
        actives_dir = src_dir / "fonctions" / "actives"
        
        lien = actives_dir / f"{nom_fonction}.py"
        
        if not lien.exists() and not lien.is_symlink():
            messagebox.showerror("Erreur", "Cette fonction n'est pas activee.")
            return
        
        try:
            lien.unlink()
            messagebox.showinfo("Succes", f"Fonction {nom_fonction} desactivee.")
            self.actualiser_fonctions()
        except Exception as e:
            messagebox.showerror("Erreur", f"Echec de la desactivation: {str(e)}")

    def configurer_onglet_parametres(self, parent):
        ttk.Label(parent, text="Parametres de l'application", font=("Arial", 12, "bold")).pack(pady=10)
        ttk.Label(parent, text="Version: 0.4c", font=("Arial", 10)).pack(pady=5)
        ttk.Label(parent, text="Licence: GPL-3.0", font=("Arial", 10)).pack(pady=5)
        
        # Section Fonctions actives (recapitulatif)
        ttk.Label(parent, text="Fonctions actives (rapport)", font=("Arial", 10, "bold")).pack(pady=(20, 5))
        
        fonctions = obtenir_toutes_les_fonctions()
        
        if fonctions:
            for ident, instance in fonctions.items():
                cadre_fonction = ttk.Frame(parent)
                cadre_fonction.pack(fill=X, padx=20, pady=2)
                ttk.Label(cadre_fonction, text=f"✓ {ident}", foreground="green").pack(side="left")
                ttk.Label(cadre_fonction, text=instance.description).pack(side="left", padx=10)
        else:
            ttk.Label(parent, text="Aucune fonction active", foreground="gray").pack(pady=10)
        
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
                # IMPORTANT: l'iid est le nom du fichier (ex: test_demo_datingue.xml)
                self.tree.insert("", "end", iid=f, values=(nom, declencheur, actions_str))
            except Exception as e:
                self.tree.insert("", "end", iid=f, values=(f, "Erreur: " + str(e)[:30], "-"))

    def sur_selection(self, event=None):
        selection = self.tree.selection()
        self.element_selectionne = selection[0] if selection else None

    def nouvelle_macro(self):
        from dialogs import DialogueNouvelleMacro
        dialogue = DialogueNouvelleMacro(self.parent)
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
        
        # IMPORTANT: element_selectionne est le nom du FICHIER (iid de la treeview)
        nom_fichier = self.element_selectionne
        
        dossier_macros = os.path.expanduser("~/.config/macrosTitux/macros/")
        chemin_xml = os.path.join(dossier_macros, nom_fichier)
        
        print("\n" + "=" * 60)
        print(f"  XML de la macro: {nom_fichier}")
        print("=" * 60)
        with open(chemin_xml, "r", encoding="utf-8") as f:
            print(f.read())
        print("=" * 60 + "\n")

        chemin_sh = os.path.join(dossier_macros, nom_fichier.replace('.xml', '.sh'))
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
