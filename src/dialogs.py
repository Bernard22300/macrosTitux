# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: dialogs.py
# Description: Dialogues modaux pour creation/modification de macros
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from tkinter import (ttk, Toplevel, Frame, Canvas, Scrollbar, Button, Label,
                     Entry, Listbox, messagebox, W, X, Y, BOTH, LEFT, RIGHT, END)

from widgets import TriggerWidget, ActionFrame, ConstraintFrame, VariableFrame


class NewMacroDialog(Toplevel):
    """Dialog structure pour creer une nouvelle macro."""

    def __init__(self, parent):
        super().__init__(parent)
        self.title("Nouvelle macro")
        self.geometry("700x550")
        self.minsize(600, 450)

        self.result = None
        self.actions_frames = []
        self.constraints_frames = []
        self.variables_frames = []

        self.setup_ui()

    def setup_ui(self):
        # Zone scrollable
        container = Frame(self)
        container.pack(fill=BOTH, expand=True, padx=5, pady=5)

        main_canvas = Canvas(container)
        main_scrollbar = Scrollbar(container, orient="vertical", command=main_canvas.yview)
        scrollable_frame = Frame(main_canvas)

        scrollable_frame.bind(
            "<Configure>",
            lambda e: main_canvas.configure(scrollregion=main_canvas.bbox("all"))
        )

        self.canvas_window = main_canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        main_canvas.configure(yscrollcommand=main_scrollbar.set)

        def on_canvas_configure(event):
            main_canvas.itemconfig(self.canvas_window, width=event.width)
        main_canvas.bind("<Configure>", on_canvas_configure)

        # === Nom ===
        name_frame = Frame(scrollable_frame)
        name_frame.pack(fill=X, padx=10, pady=5)
        Label(name_frame, text="Nom de la macro:", font=("Arial", 10, "bold")).pack(anchor=W)
        self.name_entry = Entry(name_frame, width=50)
        self.name_entry.pack(fill=X, pady=5)

        # === Declencheur ===
        trigger_section = Frame(scrollable_frame)
        trigger_section.pack(fill=X, padx=10, pady=5)
        Label(trigger_section, text="Declencheur", font=("Arial", 10, "bold"), foreground="#6d4aff").pack(anchor=W)
        self.trigger_widget = TriggerWidget(trigger_section)
        self.trigger_widget.pack(fill=X, pady=5)

        # === Variables ===
        vars_section = Frame(scrollable_frame)
        vars_section.pack(fill=X, padx=10, pady=5)
        Label(vars_section, text="Variables (optionnel)", font=("Arial", 10, "bold"), foreground="#6d4aff").pack(anchor=W)
        vars_btn_frame = Frame(vars_section)
        vars_btn_frame.pack(fill=X, pady=2)
        Button(vars_btn_frame, text="+ Ajouter variable", command=self.add_variable).pack(anchor=W)
        self.vars_container = Frame(vars_section)
        self.vars_container.pack(fill=X, pady=2)

        # === Actions ===
        actions_section = Frame(scrollable_frame)
        actions_section.pack(fill=X, padx=10, pady=5)
        Label(actions_section, text="Actions", font=("Arial", 10, "bold"), foreground="#6d4aff").pack(anchor=W)
        actions_btn_frame = Frame(actions_section)
        actions_btn_frame.pack(fill=X, pady=2)
        Button(actions_btn_frame, text="+ Ajouter action", command=self.add_action).pack(anchor=W)
        self.actions_container = Frame(actions_section)
        self.actions_container.pack(fill=X, pady=2)

        # === Contraintes ===
        constraints_section = Frame(scrollable_frame)
        constraints_section.pack(fill=X, padx=10, pady=5)
        Label(constraints_section, text="Contraintes (optionnel)", font=("Arial", 10, "bold"), foreground="#6d4aff").pack(anchor=W)
        constr_btn_frame = Frame(constraints_section)
        constr_btn_frame.pack(fill=X, pady=2)
        Button(constr_btn_frame, text="+ Ajouter contrainte", command=self.add_constraint).pack(anchor=W)
        self.constraints_container = Frame(constraints_section)
        self.constraints_container.pack(fill=X, pady=2)

        # === Boutons bas ===
        btn_frame = Frame(self)
        btn_frame.pack(fill=X, pady=5, padx=10, side=RIGHT)
        Button(btn_frame, text="Annuler", command=self.destroy).pack(side=RIGHT, padx=5)
        Button(btn_frame, text="Creer", command=self.save).pack(side=RIGHT, padx=5)

        # Pack canvas et scrollbar
        main_canvas.pack(side=LEFT, fill=BOTH, expand=True)
        main_scrollbar.pack(side=RIGHT, fill=Y)

    def add_variable(self):
        num = len(self.variables_frames) + 1
        frame = VariableFrame(self.vars_container, num)
        frame.pack(fill=X, pady=2)
        self.variables_frames.append(frame)

    def add_action(self):
        num = len(self.actions_frames) + 1
        frame = ActionFrame(self.actions_container, num)
        frame.pack(fill=X, pady=2)
        self.actions_frames.append(frame)

    def add_constraint(self):
        num = len(self.constraints_frames) + 1
        frame = ConstraintFrame(self.constraints_container, num)
        frame.pack(fill=X, pady=2)
        self.constraints_frames.append(frame)

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
