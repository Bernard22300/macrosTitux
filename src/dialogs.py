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
