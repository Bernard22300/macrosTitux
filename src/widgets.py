# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: widgets.py
# Description: Composants GUI réutilisables (TriggerWidget, ActionFrame...)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import os
from tkinter import ttk, Frame, StringVar, Entry, Label, Text, END, LEFT, RIGHT, TOP, BOTTOM, BOTH, W, E, N, S
from config import DECLNCHEURS, ACTIONS, CONTRAINTES

class WidgetDeclencheur(Frame):
    """Widget pour sélectionner et configurer un déclencheur."""

    def __init__(self, parent, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.setup_ui()

    def setup_ui(self):
        ttk.Label(self, text="Type de déclencheur:", font=('Arial', 9, 'bold')).grid(row=0, column=0, sticky=W, padx=5, pady=2)

        self.variable_declencheur = StringVar()
        self.combobox_declencheur = ttk.Combobox(self, textvariable=self.variable_declencheur, values=list(TRIGGERS.values()), state='readonly', width=40)
        self.combobox_declencheur.current(0)
        self.combobox_declencheur.grid(row=0, column=1, sticky=W+E, padx=5, pady=2)

        self.cadre_params = Frame(self)
        self.cadre_params.grid(row=1, column=0, columnspan=2, sticky=W+E, padx=5, pady=5)

        self.entrees_param = {}
        self.update_params_panel()

        self.combobox_declencheur.bind('<<ComboboxSelected>>', lambda e: self.update_params_panel())

    def update_params_panel(self):
        for widget in self.cadre_params.winfo_children():
            widget.destroy()
        self.entrees_param.clear()

        trigger_type = [k for k, v in TRIGGERS.items() if v == self.variable_declencheur.get()][0]

        row = 0
        if trigger_type == "HORAIRE":
            ttk.Label(self.cadre_params, text="Heure:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['heure'] = ttk.Spinbox(self.cadre_params, from_=0, to=23, width=5)
            self.entrees_param['heure'].grid(row=row, column=1, sticky=W, padx=5, pady=2)
            self.entrees_param['heure'].set("8")

            row += 1
            ttk.Label(self.cadre_params, text="Minute:").grid(row=row, column=2, sticky=E, padx=5, pady=2)
            self.entrees_param['minute'] = ttk.Spinbox(self.cadre_params, from_=0, to=59, width=5)
            self.entrees_param['minute'].grid(row=row, column=3, sticky=W, padx=5, pady=2)
            self.entrees_param['minute'].set("0")

            row += 1
            ttk.Label(self.cadre_params, text="Jours:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['jours'] = Entry(self.cadre_params, width=20)
            self.entrees_param['jours'].grid(row=row, column=1, sticky=W, padx=5, pady=2)
            self.entrees_param['jours'].insert(0, "* * * * * (tous les jours)")

        elif trigger_type in ["FICHIER_MODIFIE", "FICHIER_CREE"]:
            ttk.Label(self.cadre_params, text="Chemin du fichier:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['chemin'] = Entry(self.cadre_params, width=50)
            self.entrees_param['chemin'].grid(row=row, column=1, sticky=W, padx=5, pady=2)

        elif trigger_type == "RESEAU_ACTIF":
            ttk.Label(self.cadre_params, text="Interface réseau:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['interface'] = Entry(self.cadre_params, width=20)
            self.entrees_param['interface'].grid(row=row, column=1, sticky=W, padx=5, pady=2)
            self.entrees_param['interface'].insert(0, "(toutes)")

        elif trigger_type == "SORTIE_TUBE":
            ttk.Label(self.cadre_params, text="Macro source:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['macro_source'] = Entry(self.cadre_params, width=20)
            self.entrees_param['macro_source'].grid(row=row, column=1, sticky=W, padx=5, pady=2)

            row += 1
            ttk.Label(self.cadre_params, text="Variable de réception:").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['variable_reception'] = Entry(self.cadre_params, width=20)
            self.entrees_param['variable_reception'].grid(row=row, column=1, sticky=W, padx=5, pady=2)
            self.entrees_param['variable_reception'].insert(0, "DONNEES_RECUES")

        elif trigger_type == "USB_CONNECTE":
            ttk.Label(self.cadre_params, text="Périphérique (optionnel):").grid(row=row, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['peripherique'] = Entry(self.cadre_params, width=20)
            self.entrees_param['peripherique'].grid(row=row, column=1, sticky=W, padx=5, pady=2)
            self.entrees_param['peripherique'].insert(0, "(tous)")

    def get_data(self):
        trigger_label = self.variable_declencheur.get()
        trigger_type = [k for k, v in TRIGGERS.items() if v == trigger_label][0]

        params = {}
        for key, entry in self.entrees_param.items():
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

class CadreAction(Frame):
    """Frame pour une seule action avec ses paramètres."""

    def __init__(self, parent, action_num=1, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.numero_action = action_num
        self.setup_ui()

    def setup_ui(self):
        ttk.Label(self, text=f"{self.numero_action}. ", font=('Arial', 9, 'bold')).pack(side=LEFT, padx=2)

        self.variable_type_action = StringVar()
        self.combobox_action = ttk.Combobox(self, textvariable=self.variable_type_action, values=list(ACTIONS.values()), state='readonly', width=35)
        self.combobox_action.current(0)
        self.combobox_action.pack(side=LEFT, padx=5)

        self.texte_params = Text(self, height=4, width=60)
        self.texte_params.pack(side=LEFT, padx=10)

        self.combobox_action.bind('<<ComboboxSelected>>', lambda e: self.update_params_text())

    def update_params_text(self):
        self.texte_params.delete("1.0", END)
        action_label = self.variable_type_action.get()
        action_type = [k for k, v in ACTIONS.items() if v == action_label][0]

        if action_type == "NOTIFIER":
            self.texte_params.insert(END, "titre=Notification\nmessage=Votre message ici")
        elif action_type == "COPIER_FICHIER":
            self.texte_params.insert(END, "source=~/Documents\ndestination=~/backup/\nmotif=*.pdf")
        elif action_type == "EXECUTER_CMD":
            self.texte_params.insert(END, "commande=echo Hello World")
        elif action_type == "REDÉMARRER_SERV":
            self.texte_params.insert(END, "service=cron")
        elif action_type == "SORTIR_RESULTAT":
            self.texte_params.insert(END, "tube=resultat\ndonnees=VARIABLE")

    def get_data(self):
        action_label = self.variable_type_action.get()
        action_type = [k for k, v in ACTIONS.items() if v == action_label][0]

        params_text = self.texte_params.get("1.0", END).strip()
        params = {}
        if params_text:
            for line in params_text.split('\n'):
                if '=' in line:
                    key, val = line.split('=', 1)
                    params[key.strip()] = val.strip()

        return {
            'id': str(self.numero_action),
            'type': action_type,
            'label': action_label,
            'params': params
        }

class CadreContrainte(Frame):
    """Frame pour une seule contrainte avec ses paramètres."""

    def __init__(self, parent, constraint_num=1, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.numero_contrainte = constraint_num
        self.setup_ui()

    def setup_ui(self):
        ttk.Label(self, text=f"{self.numero_contrainte}. ").pack(side=LEFT, padx=2)

        self.variable_type_contrainte = StringVar()
        self.combobox_contrainte = ttk.Combobox(self, textvariable=self.variable_type_contrainte, values=list(CONSTRAINTS.values()), state='readonly', width=30)
        self.combobox_contrainte.current(0)
        self.combobox_contrainte.pack(side=LEFT, padx=5)

        self.texte_params = Text(self, height=3, width=60)
        self.texte_params.pack(side=LEFT, padx=10)

        self.combobox_contrainte.bind('<<ComboboxSelected>>', lambda e: self.update_params_text())

    def update_params_text(self):
        self.texte_params.delete("1.0", END)
        constraint_label = self.variable_type_contrainte.get()
        constraint_type = [k for k, v in CONSTRAINTS.items() if v == constraint_label][0]

        if constraint_type == "ESPACE_DISQUE":
            self.texte_params.insert(END, "espace_minimum=10")
        elif constraint_type == "PLAGE_HORAIRE":
            self.texte_params.insert(END, "heure_debut=0800\nheure_fin=1800")
        elif constraint_type == "PROCESSUS_ACTIF":
            self.texte_params.insert(END, "processus=firefox")

    def get_data(self):
        constraint_label = self.variable_type_contrainte.get()
        constraint_type = [k for k, v in CONSTRAINTS.items() if v == constraint_label][0]

        params_text = self.texte_params.get("1.0", END).strip()
        params = {}
        if params_text:
            for line in params_text.split('\n'):
                if '=' in line:
                    key, val = line.split('=', 1)
                    params[key.strip()] = val.strip()

        return {
            'id': str(self.numero_contrainte),
            'type': constraint_type,
            'label': constraint_label,
            'params': params
        }

class CadreVariable(Frame):
    """Frame pour une variable simple nom=valeur."""

    def __init__(self, parent, var_num=1, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.numero_variable = var_num
        self.setup_ui()

    def setup_ui(self):
        ttk.Label(self, text=f"{self.numero_variable}. ").pack(side=LEFT, padx=2)

        ttk.Label(self, text="Nom:").pack(side=LEFT, padx=2)
        self.entree_nom = Entry(self, width=15)
        self.entree_nom.pack(side=LEFT, padx=2)

        ttk.Label(self, text="Valeur:").pack(side=LEFT, padx=2)
        self.entree_valeur = Entry(self, width=30)
        self.entree_valeur.pack(side=LEFT, padx=2)

    def get_data(self):
        return {
            'name': self.entree_nom.get().strip(),
            'value': self.entree_valeur.get().strip()
        }
