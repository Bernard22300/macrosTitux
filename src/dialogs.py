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
