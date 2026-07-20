#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
macrosTitux.py
Version: 0.2 (Interface structurée Vue/Moteur)
License: GPL-3.0
"""
import os
import sys
import json
import xml.etree.ElementTree as ET
import shutil
from pathlib import Path
from tkinter import ttk, messagebox, StringVar, Text, Tk, Toplevel, filedialog, Entry, Label, Frame, Listbox, END, W, NW

APP_NAME = "macrosTitux"
APP_VERSION = "0.2"
BASE_DIR = Path(os.path.dirname(os.path.abspath(__file__)).replace('/src', ''))
CONFIG_DIR = Path.home() / ".config" / APP_NAME
MACRO_DIR = CONFIG_DIR / "macros"
CONF_FILE = CONFIG_DIR / "macrosTitux.conf"

#------------------------------------------------------------------------------
# CONSTANTES
#------------------------------------------------------------------------------
TRIGGERS = {
    "DEMARRAGE": "Au démarrage",
    "HORAIRE": "Horaire (cron)",
    "FICHIER_MODIFIE": "Fichier modifié",
    "FICHIER_CREE": "Fichier créé",
    "USB_CONNECTE": "USB connecté",
    "RESEAU_ACTIF": "Réseau activé",
    "SORTIE_TUBE": "Sortie de tube"
}

ACTIONS = {
    "COPIER_FICHIER": "Copier fichier(s)",
    "DEPLACER_FICHIER": "Déplacer fichier(s)",
    "SUPPRIMER_FICHIER": "Supprimer fichier(s)",
    "NOTIFIER": "Notifier",
    "EXECUTER_CMD": "Exécuter commande",
    "REDÉMARRER_SERV": "Redémarrer service",
    "SORTIR_RESULTAT": "Sortir résultat dans tube"
}

CONSTRAINTS = {
    "ESPACE_DISQUE": "Espace disque disponible",
    "PLAGE_HORAIRE": "Plage horaire",
    "PROCESSUS_ACTIF": "Processus actif"
}

#==============================================================================
# VUE : Widgets modulaires pour formulaire
#==============================================================================

class TriggerWidget(Frame):
    """Widget pour sélectionner et configurer un déclencheur."""

    def __init__(self, parent, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.setup_ui()

    def setup_ui(self):
        # Menu déroulant pour type de déclencheur
        ttk.Label(self, text="Type de déclencheur:", font=('Arial', 9, 'bold')).grid(row=0, column=0, sticky=W, padx=5, pady=2)

        self.trigger_var = StringVar()
        self.trigger_combo = ttk.Combobox(self, textvariable=self.trigger_var, values=list(TRIGGERS.values()), state='readonly', width=40)
        self.trigger_combo.current(0)
        self.trigger_combo.grid(row=0, column=1, sticky=W+E, padx=5, pady=2)

        # Panneau dynamique de paramètres selon le type
        self.params_frame = Frame(self)
        self.params_frame.grid(row=1, column=0, columnspan=2, sticky=W+E, padx=5, pady=5)

        # Champs dynamiques
        self.param_entries = {}
        self.update_params_panel()

        self.trigger_combo.bind('<<ComboboxSelected>>', lambda e: self.update_params_panel())

    def update_params_panel(self):
        # Nettoyer l'ancien panneau
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
            frame = Frame(self.params_frame)
            frame.grid(row=row, column=1, sticky=W+E, padx=5, pady=2)
            self.param_entries['chemin'] = Entry(frame, width=40)
            self.param_entries['chemin'].pack(side=LEFT)
            ttk.Button(frame, text="...").pack(side=LEFT, padx=2)

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
        """Retourne dict structuré pour le moteur."""
        trigger_label = self.trigger_var.get()
        trigger_type = [k for k, v in TRIGGERS.items() if v == trigger_label][0]

        params = {}
        for key, entry in self.param_entries.items():
            if isinstance(entry, ttk.Spinbox):
                val = entry.get()
            else:
                val = entry.get().strip() if hasattr(entry, 'get') else str(entry.get())
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
        # Numéro
        ttk.Label(self, text=f"{self.action_num}. ", font=('Arial', 9, 'bold')).pack(side=LEFT, padx=2)

        # Type d'action
        self.action_type_var = StringVar()
        self.action_combo = ttk.Combobox(self, textvariable=self.action_type_var, values=list(ACTIONS.values()), state='readonly', width=35)
        self.action_combo.current(0)
        self.action_combo.pack(side=LEFT, padx=5)

        # Panneau de paramètres dynamiques
        self.params_frame = Frame(self)
        self.params_frame.pack(side=LEFT, padx=10)

        self.param_entries = {}
        self.update_params_panel()

        self.action_combo.bind('<<ComboboxSelected>>', lambda e: self.update_params_panel())

    def update_params_panel(self):
        # Nettoyer
        for widget in self.params_frame.winfo_children():
            widget.destroy()
        self.param_entries.clear()

        action_label = self.action_type_var.get()
        action_type = [k for k, v in ACTIONS.items() if v == action_label][0]

        row = 0
        if action_type == "COPIER_FICHIER":
            ttk.Label(self.params_frame, text="Source:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['source'] = Entry(self.params_frame, width=25)
            self.param_entries['source'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['source'].insert(0, "~/Documents")

            row += 1
            ttk.Label(self.params_frame, text="Motif:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['motif'] = Entry(self.params_frame, width=25)
            self.param_entries['motif'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['motif'].insert(0, "*.pdf")

            row += 1
            ttk.Label(self.params_frame, text="Destination:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['destination'] = Entry(self.params_frame, width=25)
            self.param_entries['destination'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['destination'].insert(0, "~/backup/")

        elif action_type == "NOTIFIER":
            ttk.Label(self.params_frame, text="Titre:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['titre'] = Entry(self.params_frame, width=25)
            self.param_entries['titre'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['titre'].insert(0, "Notification")

            row += 1
            ttk.Label(self.params_frame, text="Message:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['message'] = Entry(self.params_frame, width=25)
            self.param_entries['message'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['message'].insert(0, "Message de test")

        elif action_type == "EXECUTER_CMD":
            ttk.Label(self.params_frame, text="Commande:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['commande'] = Entry(self.params_frame, width=50)
            self.param_entries['commande'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['commande'].insert(0, "echo Bonjour")

        elif action_type == "REDÉMARRER_SERV":
            ttk.Label(self.params_frame, text="Service:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['service'] = Entry(self.params_frame, width=25)
            self.param_entries['service'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['service'].insert(0, "cron")

        elif action_type == "SORTIR_RESULTAT":
            ttk.Label(self.params_frame, text="Nom du tube:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['tube'] = Entry(self.params_frame, width=25)
            self.param_entries['tube'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['tube'].insert(0, "resultat")

            row += 1
            ttk.Label(self.params_frame, text="Données:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['donnees'] = Entry(self.params_frame, width=25)
            self.param_entries['donnees'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['donnees'].insert(0, "VARIABLE")

        elif action_type == "DEPLACER_FICHIER":
            ttk.Label(self.params_frame, text="Source:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['source'] = Entry(self.params_frame, width=25)
            self.param_entries['source'].grid(row=row, column=1, sticky=W, padx=2, pady=2)

            row += 1
            ttk.Label(self.params_frame, text="Motif:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['motif'] = Entry(self.params_frame, width=25)
            self.param_entries['motif'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['motif'].insert(0, "*")

            row += 1
            ttk.Label(self.params_frame, text="Destination:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['destination'] = Entry(self.params_frame, width=25)
            self.param_entries['destination'].grid(row=row, column=1, sticky=W, padx=2, pady=2)

        elif action_type == "SUPPRIMER_FICHIER":
            ttk.Label(self.params_frame, text="Chemin:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['chemin'] = Entry(self.params_frame, width=25)
            self.param_entries['chemin'].grid(row=row, column=1, sticky=W, padx=2, pady=2)

            row += 1
            ttk.Label(self.params_frame, text="Motif (optionnel):").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['motif'] = Entry(self.params_frame, width=25)
            self.param_entries['motif'].grid(row=row, column=1, sticky=W, padx=2, pady=2)

        else:
            ttk.Label(self.params_frame, text="(Pas de paramètres spécifiques)", foreground='gray').grid(row=row, column=0, columnspan=2, padx=2, pady=2)

    def get_data(self):
        action_label = self.action_type_var.get()
        action_type = [k for k, v in ACTIONS.items() if v == action_label][0]

        params = {}
        for key, entry in self.param_entries.items():
            val = entry.get().strip() if hasattr(entry, 'get') else str(entry.get())
            if val:
                params[key] = val

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

        self.params_frame = Frame(self)
        self.params_frame.pack(side=LEFT, padx=10)

        self.param_entries = {}
        self.update_params_panel()

        self.constraint_combo.bind('<<ComboboxSelected>>', lambda e: self.update_params_panel())

    def update_params_panel(self):
        for widget in self.params_frame.winfo_children():
            widget.destroy()
        self.param_entries.clear()

        constraint_label = self.constraint_type_var.get()
        constraint_type = [k for k, v in CONSTRAINTS.items() if v == constraint_label][0]

        row = 0
        if constraint_type == "ESPACE_DISQUE":
            ttk.Label(self.params_frame, text="Espace min (%):").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['espace_minimum'] = Entry(self.params_frame, width=10)
            self.param_entries['espace_minimum'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['espace_minimum'].insert(0, "10")

        elif constraint_type == "PLAGE_HORAIRE":
            ttk.Label(self.params_frame, text="De:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['heure_debut'] = Entry(self.params_frame, width=10)
            self.param_entries['heure_debut'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['heure_debut'].insert(0, "0800")

            ttk.Label(self.params_frame, text="À:").grid(row=row, column=2, sticky=E, padx=2, pady=2)
            self.param_entries['heure_fin'] = Entry(self.params_frame, width=10)
            self.param_entries['heure_fin'].grid(row=row, column=3, sticky=W, padx=2, pady=2)
            self.param_entries['heure_fin'].insert(0, "1800")

        elif constraint_type == "PROCESSUS_ACTIF":
            ttk.Label(self.params_frame, text="Nom du processus:").grid(row=row, column=0, sticky=E, padx=2, pady=2)
            self.param_entries['processus'] = Entry(self.params_frame, width=20)
            self.param_entries['processus'].grid(row=row, column=1, sticky=W, padx=2, pady=2)
            self.param_entries['processus'].insert(0, "firefox")

    def get_data(self):
        constraint_label = self.constraint_type_var.get()
        constraint_type = [k for k, v in CONSTRAINTS.items() if v == constraint_label][0]

        params = {}
        for key, entry in self.param_entries.items():
            val = entry.get().strip() if hasattr(entry, 'get') else str(entry.get())
            if val:
                params[key] = val

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


#==============================================================================
# MOTEUR : Nouvelle boîte de dialogue structurée
#==============================================================================

class NewMacroDialog(Toplevel):
    """Dialog structuré pour créer une nouvelle macro."""

    def __init__(self, parent):
        super().__init__(parent)
        self.title("Nouvelle macro")
        self.geometry("700x650")
        self.resizable(True, True)

        self.result = None
        self.actions_list = []
        self.constraints_list = []
        self.variables_list = []

        self.setup_ui()

    def setup_ui(self):
        # Scrollable canvas
        canvas = Canvas(self)
        scrollbar = ttk.Scrollbar(self, orient="vertical", command=canvas.yview)
        scrollable_frame = Frame(canvas)

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        # === Section Nom ===
        name_frame = Frame(scrollable_frame)
        name_frame.pack(fill=X, padx=10, pady=5)
        ttk.Label(name_frame, text="Nom de la macro:", font=('Arial', 10, 'bold')).pack(anchor=W)
        self.name_entry = Entry(name_frame, width=50)
        self.name_entry.pack(fill=X, pady=5)

        # === Section Déclencheur ===
        trigger_frame = Frame(scrollable_frame)
        trigger_frame.pack(fill=X, padx=10, pady=5)
        ttk.Label(trigger_frame, text="Déclencheur", font=('Arial', 9, 'bold'), foreground='#6d4aff').pack(anchor=W)
        self.trigger_widget = TriggerWidget(trigger_frame)
        self.trigger_widget.pack(fill=X, pady=5)

        # === Section Variables ===
        ttk.Label(scrollable_frame, text="Variables (optionnel)", font=('Arial', 9, 'bold'), foreground='#6d4aff').pack(anchor=W, padx=10, pady=(10,5))

        variables_container = Frame(scrollable_frame)
        variables_container.pack(fill=X, padx=10)
        self.add_variable_btn = ttk.Button(variables_container, text="+ Ajouter variable",
                                           command=lambda: self.add_variable(variables_container))
        self.add_variable_btn.pack(pady=5)
        self.variables_canvas = Canvas(variables_container, height=80)
        self.variables_scrollbar = ttk.Scrollbar(variables_container, orient="vertical", command=self.variables_canvas.yview)
        self.variables_inner = Frame(self.variables_canvas)
        self.variables_inner.bind("<Configure>", lambda e: self.variables_canvas.configure(scrollregion=self.variables_canvas.bbox("all")))
        self.canvas_var = self.variables_canvas.create_window((0, 0), window=self.variables_inner, anchor="nw")
        self.variables_canvas.configure(yscrollcommand=self.variables_scrollbar.set)
        self.variables_canvas.pack(side=LEFT, fill=BOTH, expand=True)
        self.variables_scrollbar.pack(side=RIGHT, fill=Y)

        # === Section Actions ===
        ttk.Label(scrollable_frame, text="Actions", font=('Arial', 9, 'bold'), foreground='#6d4aff').pack(anchor=W, padx=10, pady=(10,5))

        actions_container = Frame(scrollable_frame)
        actions_container.pack(fill=X, padx=10)
        self.add_action_btn = ttk.Button(actions_container, text="+ Ajouter action",
                                         command=lambda: self.add_action(actions_container))
        self.add_action_btn.pack(pady=5)
        self.actions_canvas = Canvas(actions_container, height=200)
        self.actions_scrollbar = ttk.Scrollbar(actions_container, orient="vertical", command=self.actions_canvas.yview)
        self.actions_inner = Frame(self.actions_canvas)
        self.actions_inner.bind("<Configure>", lambda e: self.actions_canvas.configure(scrollregion=self.actions_canvas.bbox("all")))
        self.canvas_act = self.actions_canvas.create_window((0, 0), window=self.actions_inner, anchor="nw")
        self.actions_canvas.configure(yscrollcommand=self.actions_scrollbar.set)
        self.actions_canvas.pack(side=LEFT, fill=BOTH, expand=True)
        self.actions_scrollbar.pack(side=RIGHT, fill=Y)

        # === Section Contraintes ===
        ttk.Label(scrollable_frame, text="Contraintes (optionnel)", font=('Arial', 9, 'bold'), foreground='#6d4aff').pack(anchor=W, padx=10, pady=(10,5))

        constraints_container = Frame(scrollable_frame)
        constraints_container.pack(fill=X, padx=10)
        self.add_constraint_btn = ttk.Button(constraints_container, text="+ Ajouter contrainte",
                                             command=lambda: self.add_constraint(constraints_container))
        self.add_constraint_btn.pack(pady=5)
        self.constraints_canvas = Canvas(constraints_container, height=150)
        self.constraints_scrollbar = ttk.Scrollbar(constraints_container, orient="vertical", command=self.constraints_canvas.yview)
        self.constraints_inner = Frame(self.constraints_canvas)
        self.constraints_inner.bind("<Configure>", lambda e: self.constraints_canvas.configure(scrollregion=self.constraints_canvas.bbox("all")))
        self.canvas_constr = self.constraints_canvas.create_window((0, 0), window=self.constraints_inner, anchor="nw")
        self.constraints_canvas.configure(yscrollcommand=self.constraints_scrollbar.set)
        self.constraints_canvas.pack(side=LEFT, fill=BOTH, expand=True)
        self.constraints_scrollbar.pack(side=RIGHT, fill=Y)

        # === Boutons d'action ===
        btn_frame = Frame(self)
        btn_frame.pack(fill=X, padx=10, pady=10)
        ttk.Button(btn_frame, text="Annuler", command=self.destroy).pack(side=RIGHT, padx=5)
        ttk.Button(btn_frame, text="Créer", command=self.save).pack(side=RIGHT, padx=5)

        # Configuration du scroll
        canvas.pack(side=LEFT, fill=BOTH, expand=True)
        scrollbar.pack(side=RIGHT, fill=Y)

        # Ajouter une action par défaut
        self.add_action(actions_container)

    def add_variable(self, container):
        num = len(self.variables_list) + 1
        frame = VariableFrame(self.variables_inner, num)
        frame.pack(fill=X, pady=2)
        self.variables_list.append(frame)

    def add_action(self, container):
        num = len(self.actions_list) + 1
        frame = ActionFrame(self.actions_inner, num)
        frame.pack(fill=X, pady=2)

        # Bouton supprimer
        del_btn = ttk.Button(self.actions_inner, text="✕", width=2,
                            command=lambda f=frame, b=del_btn: self.remove_action(f, b))
        del_btn.pack(anchor=E)
        self.actions_list.append(frame)

    def add_constraint(self, container):
        num = len(self.constraints_list) + 1
        frame = ConstraintFrame(self.constraints_inner, num)
        frame.pack(fill=X, pady=2)

        del_btn = ttk.Button(self.constraints_inner, text="✕", width=2,
                            command=lambda f=frame, b=del_btn: self.remove_constraint(f, b))
        del_btn.pack(anchor=E)
        self.constraints_list.append(frame)

    def remove_action(self, frame, btn):
        self.actions_inner.nametowidget(frame.master).pack_forget()
        self.actions_list.remove(frame)
        btn.pack_forget()
        # Renumeroter
        for i, f in enumerate(self.actions_list, 1):
            f.action_num = i

    def remove_constraint(self, frame, btn):
        self.constraints_inner.nametowidget(frame.master).pack_forget()
        self.constraints_list.remove(frame)
        btn.pack_forget()
        for i, f in enumerate(self.constraints_list, 1):
            f.constraint_num = i

    def save(self):
        name = self.name_entry.get().strip()
        if not name:
            messagebox.showerror("Erreur", "Le nom de la macro est requis.")
            return

        # Collecter déclencheur
        trigger_data = self.trigger_widget.get_data()

        # Collecter variables
        variables = []
        for vframe in self.variables_list:
            data = vframe.get_data()
            if data['name']:
                variables.append(data)

        # Collecter actions
        actions = []
        for aframe in self.actions_list:
            actions.append(aframe.get_data())

        # Collecter contraintes
        constraints = []
        for cframe in self.constraints_list:
            constraints.append(cframe.get_data())

        # Retourner tuple structuré au moteur
        self.result = (name, trigger_data, variables, actions, constraints)
        self.destroy()


#==============================================================================
# FONCTIONS UTILITAIRES
#==============================================================================

def init_dirs():
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    MACRO_DIR.mkdir(parents=True, exist_ok=True)
    if not CONF_FILE.exists():
        config = {
            "editor": "nano",
            "auto_test": False,
            "export_dir": str(Path.home() / "macrosTitux_exports"),
            "log_level": "info"
        }
        with open(CONF_FILE, 'w') as f:
            json.dump(config, f, indent=4, ensure_ascii=False)

def load_config():
    with open(CONF_FILE, 'r') as f:
        return json.load(f)

def load_macros_list():
    macros = []
    for f in MACRO_DIR.glob("*.xml"):
        tree = ET.parse(f)
        root = tree.getroot()
        name = root.get('name')
        trigger_label = root.find('trigger').get('label', '-') if root.find('trigger') is not None else '-'
        actions = root.findall('actions/action')
        action_label = actions[0].get('label', '-') if actions else '-'
        macros.append((name, trigger_label, action_label))
    return macros

def save_macro(name, trigger_data, variables, actions, constraints):
    root = ET.Element("macro")
    root.set('name', name)

    # Sauvegarder trigger
    trigger = ET.SubElement(root, "trigger")
    trigger.set('type', trigger_data['type'])
    trigger.set('label', trigger_data['label'])
    trigger_cfg = ET.SubElement(trigger, "config")
    for k, v in trigger_data['params'].items():
        param = ET.SubElement(trigger_cfg, "param")
        param.set('key', k)
        param.set('value', str(v))

    # Sauvegarder variables
    vars_elem = ET.SubElement(root, "variables")
    for var in variables:
        v = ET.SubElement(vars_elem, "var")
        v.set('name', var['name'])
        v.set('value', var['value'])

    # Sauvegarder actions
    actions_elem = ET.SubElement(root, "actions")
    for action in actions:
        action_el = ET.SubElement(actions_elem, "action")
        action_el.set('id', action['id'])
        action_el.set('type', action['type'])
        action_el.set('label', action.get('label', ''))
        cfg = ET.SubElement(action_el, "config")
        for k, v in action.get('params', {}).items():
            p = ET.SubElement(cfg, "param")
            p.set('key', k)
            p.set('value', str(v))

    # Sauvegarder contraintes
    constraints_elem = ET.SubElement(root, "constraints")
    for constraint in constraints:
        c_el = ET.SubElement(constraints_elem, "constraint")
        c_el.set('id', constraint['id'])
        c_el.set('type', constraint['type'])
        c_el.set('label', constraint.get('label', ''))
        cfg = ET.SubElement(c_el, "config")
        for k, v in constraint.get('params', {}).items():
            p = ET.SubElement(cfg, "param")
            p.set('key', k)
            p.set('value', str(v))

    tree = ET.ElementTree(root)
    ET.indent(tree, space="    ")
    with open(MACRO_DIR / f"{name}.xml", 'wb') as f:
        tree.write(f, encoding='utf-8', xml_declaration=True)

def generate_bash_from_xml(xml_path, output_path=None):
    script_path = Path(__file__).parent / "generate_bash.sh"
    if output_path is None:
        output_path = str(xml_path).replace('.xml', '.sh')
    os.system(f"bash {script_path} {xml_path} {output_path}")


#==============================================================================
# CLASSE PRINCIPALE (inchangée)
#==============================================================================

class MacrosTituxApp(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.parent.title(f"{APP_NAME} v{APP_VERSION}")
        self.parent.geometry("800x600")
        notebook = ttk.Notebook(self)
        notebook.pack(fill='both', expand=True, padx=10, pady=10)

        self.tab_macros = ttk.Frame(notebook)
        notebook.add(self.tab_macros, text="Macros")
        self.setup_tab_macros()

        self.tab_templates = ttk.Frame(notebook)
        notebook.add(self.tab_templates, text="Templates")
        self.setup_tab_templates()

        self.tab_settings = ttk.Frame(notebook)
        notebook.add(self.tab_settings, text="Parametres")
        self.setup_tab_settings()

        btn_frame = ttk.Frame(self)
        btn_frame.pack(fill='x', padx=10, pady=5)
        ttk.Button(btn_frame, text="+ Nouvelle macro", command=self.new_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Editer", command=self.edit_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Supprimer", command=self.delete_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Tester", command=self.test_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Exporter", command=self.export_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Importer", command=self.import_macro).pack(side='left', padx=2)
        ttk.Button(btn_frame, text="Quitter", command=self.quit).pack(side='right')
        self.refresh_macros_list()

    def setup_tab_macros(self):
        self.tree = ttk.Treeview(self.tab_macros, columns=('Nom', 'Declencheur', 'Action'), show='headings')
        self.tree.heading('Nom', text='Nom')
        self.tree.heading('Declencheur', text='Declencheur')
        self.tree.heading('Action', text='Action')
        self.tree.column('Nom', width=200)
        self.tree.column('Declencheur', width=250)
        self.tree.column('Action', width=250)
        self.tree.pack(fill='both', expand=True, padx=5, pady=5)

    def setup_tab_templates(self):
        label = ttk.Label(self.tab_templates, text="Aucun template disponible pour le moment.", justify='center')
        label.pack(expand=True, pady=50)

    def setup_tab_settings(self):
        config = load_config()
        ttk.Label(self.tab_settings, text="Repertoire des macros:", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        ttk.Entry(self.tab_settings, textvariable=StringVar(value=str(MACRO_DIR))).pack(fill='x', padx=10, pady=2)
        ttk.Label(self.tab_settings, text="Editeur par defaut:", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        ttk.Entry(self.tab_settings, textvariable=StringVar(value=config.get('editor', 'nano'))).pack(fill='x', padx=10, pady=2)
        ttk.Label(self.tab_settings, text="Repertoire d'export:", font=('Arial', 10, 'bold')).pack(anchor='w', padx=10, pady=5)
        ttk.Entry(self.tab_settings, textvariable=StringVar(value=config.get('export_dir', ''))).pack(fill='x', padx=10, pady=2)
        ttk.Label(self.tab_settings, text=f"Version: {APP_VERSION}", foreground='gray').pack(anchor='w', padx=10, pady=20)

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
            tree = ET.parse(filepath)
            root = tree.getroot()

            if root.tag != 'macro':
                messagebox.showerror("Erreur", "Fichier XML invalide : ce n'est pas une macro macrosTitux")
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


#==============================================================================
# POINT D'ENTRÉE
#==============================================================================

if __name__ == "__main__":
    init_dirs()
    root = Tk()
    app = MacrosTituxApp(root)
    app.pack(fill='both', expand=True)
    app.mainloop()
