# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: dialogs.py
# Description: Boites de dialogue pour la creation/edition de macros
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from tkinter import ttk, Frame, Label, Entry, Button, messagebox, X, Y
from tkinter import Toplevel, Scrollbar, TOP, BOTTOM, LEFT, RIGHT, BOTH, W, E, N, S
from config import DECLNCHEURS, ACTIONS, CONTRAINTES
from fenetreEditionMacro import EditionDeclencheur, EditionAction, EditionContrainte, EditionVariable

class DialogueNouvelleMacro(Toplevel):
    """Boite de dialogue pour creer une nouvelle macro."""

    def __init__(self, parent):
        super().__init__(parent)
        self.title("Nouvelle Macro")
        self.geometry("900x600")
        self.result = None
        
        self.configurer_interface()
        
        # Centre la fenetre
        self.transient(parent)
        self.grab_set()
        self.wait_window()

    def configurer_interface(self):
        cadre_principal = Frame(self)
        cadre_principal.pack(fill=BOTH, expand=True, padx=10, pady=10)

        # Nom de la macro
        cadre_nom = Frame(cadre_principal)
        cadre_nom.pack(fill=X, pady=(0, 10))
        Label(cadre_nom, text="Nom de la macro:").pack(side=LEFT)
        self.entree_nom = Entry(cadre_nom, width=40)
        self.entree_nom.pack(side=LEFT, padx=5)

        # Declencheur
        Label(cadre_principal, text="Declencheur:", font=('Arial', 9, 'bold')).pack(anchor=W, pady=(10, 0))
        self.widget_declencheur = EditionDeclencheur(cadre_principal)
        self.widget_declencheur.pack(fill=X, pady=5)

        # Variables
        Label(cadre_principal, text="Variables (optionnel):", font=('Arial', 9, 'bold')).pack(anchor=W, pady=(10, 0))
        self.cadre_variables = Frame(cadre_principal)
        self.cadre_variables.pack(fill=X, pady=5)
        self.cadres_variables = []

        # Ajouter une premiere variable vide
        self.ajouter_variable()

        Button(cadre_principal, text="+ Ajouter variable", command=self.ajouter_variable).pack(anchor=W)

        # Actions
        Label(cadre_principal, text="Actions:", font=('Arial', 9, 'bold')).pack(anchor=W, pady=(10, 0))
        self.defilement_actions = Scrollbar(cadre_principal)
        self.defilement_actions.pack(side=RIGHT, fill=Y)
        self.conteneur_actions = Frame(cadre_principal)
        self.conteneur_actions.pack(fill=X, pady=5)
        self.cadres_actions = []

        # Ajouter une premiere action vide
        self.ajouter_action()

        Button(cadre_principal, text="+ Ajouter action", command=self.ajouter_action).pack(anchor=W)

        # Contraintes
        Label(cadre_principal, text="Contraintes (optionnel):", font=('Arial', 9, 'bold')).pack(anchor=W, pady=(10, 0))
        self.defilement_contraintes = Scrollbar(cadre_principal)
        self.defilement_contraintes.pack(side=RIGHT, fill=Y)
        self.conteneur_contraintes = Frame(cadre_principal)
        self.conteneur_contraintes.pack(fill=X, pady=5)
        self.cadres_contraintes = []

        Button(cadre_principal, text="+ Ajouter contrainte", command=self.ajouter_contrainte).pack(anchor=W, pady=(5, 10))

        # Boutons de validation
        cadre_boutons = Frame(cadre_principal)
        cadre_boutons.pack(side=BOTTOM, fill=X, pady=10)

        Button(cadre_boutons, text="Annuler", command=self.annuler).pack(side=RIGHT, padx=5)
        Button(cadre_boutons, text="Creer", command=self.valider).pack(side=RIGHT, padx=5)

    def ajouter_variable(self):
        numero = len(self.cadres_variables) + 1
        frame = EditionVariable(self.cadre_variables, numero_variable=numero)
        frame.pack(fill=X, pady=2)
        self.cadres_variables.append(frame)

    def ajouter_action(self):
        numero = len(self.cadres_actions) + 1
        frame = EditionAction(self.conteneur_actions, numero_action=numero)
        frame.pack(fill=X, pady=2)
        self.cadres_actions.append(frame)

    def ajouter_contrainte(self):
        numero = len(self.cadres_contraintes) + 1
        frame = EditionContrainte(self.conteneur_contraintes, numero_contrainte=numero)
        frame.pack(fill=X, pady=2)
        self.cadres_contraintes.append(frame)

    def annuler(self):
        self.result = None
        self.destroy()

    def valider(self):
        nom = self.entree_nom.get().strip()
        if not nom:
            messagebox.showerror("Erreur", "Le nom de la macro est obligatoire.")
            return

        donnees_declencheur = self.widget_declencheur.get_data()
        variables = [vf.get_data() for vf in self.cadres_variables]
        actions = [af.get_data() for af in self.cadres_actions]
        contraintes = [cf.get_data() for cf in self.cadres_contraintes]

        self.result = (nom, donnees_declencheur, variables, actions, contraintes)
        self.destroy()

class DialogueEditionMacro(DialogueNouvelleMacro):
    """Boite de dialogue pour editer une macro existante (similaire a DialogueNouvelleMacro)."""

    def __init__(self, parent, donnees_macro=None):
        self.donnees_macro = donnees_macro
        super().__init__(parent)
        self.title("Editer Macro")

    def charger_macro(self):
        if self.donnees_macro:
            # TODO: Implémenter le chargement des données dans les widgets
            self.entree_nom.delete(0, 'end')
            self.entree_nom.insert(0, self.donnees_macro.get('nom', ''))
