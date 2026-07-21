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
