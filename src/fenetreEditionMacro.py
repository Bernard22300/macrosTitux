# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: widgets.py
# Description: Composants GUI reutilisables (EditionDeclencheur, EditionAction...)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import os
from tkinter import ttk, Frame, StringVar, Entry, Label, Text, END, LEFT, RIGHT, TOP, BOTTOM, BOTH, W, E, N, S
from config import DECLNCHEURS, ACTIONS, CONTRAINTES

class EditionDeclencheur(Frame):
    """Widget pour selectionner et configurer un declencheur."""

    def __init__(self, parent, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.configurer_ui()

    def configurer_ui(self):
        Label(self, text="Type de declencheur:", font=('Arial', 9, 'bold')).grid(row=0, column=0, sticky=W, padx=5, pady=2)

        self.variable_declencheur = StringVar()
        self.combobox_declencheur = ttk.Combobox(self, textvariable=self.variable_declencheur, values=list(DECLNCHEURS.values()), state='readonly', width=40)
        self.combobox_declencheur.current(0)
        self.combobox_declencheur.grid(row=0, column=1, sticky=W+E, padx=5, pady=2)

        self.cadre_params = Frame(self)
        self.cadre_params.grid(row=1, column=0, columnspan=2, sticky=W+E, padx=5, pady=5)

        self.entrees_param = {}
        self.metre_a_jour_panneau_params()

        self.combobox_declencheur.bind('<<ComboboxSelected>>', lambda e: self.metre_a_jour_panneau_params())

    def metre_a_jour_panneau_params(self):
        for widget in self.cadre_params.winfo_children():
            widget.destroy()
        self.entrees_param.clear()

        type_declencheur = [k for k, v in DECLNCHEURS.items() if v == self.variable_declencheur.get()][0]

        ligne = 0
        if type_declencheur == "HORAIRE":
            Label(self.cadre_params, text="Heure:").grid(row=ligne, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['heure'] = ttk.Spinbox(self.cadre_params, from_=0, to=23, width=5)
            self.entrees_param['heure'].grid(row=ligne, column=1, sticky=W, padx=5, pady=2)
            self.entrees_param['heure'].set("8")

            ligne += 1
            Label(self.cadre_params, text="Minute:").grid(row=ligne, column=2, sticky=E, padx=5, pady=2)
            self.entrees_param['minute'] = ttk.Spinbox(self.cadre_params, from_=0, to=59, width=5)
            self.entrees_param['minute'].grid(row=ligne, column=3, sticky=W, padx=5, pady=2)
            self.entrees_param['minute'].set("0")

            ligne += 1
            Label(self.cadre_params, text="Jours:").grid(row=ligne, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['jours'] = Entry(self.cadre_params, width=20)
            self.entrees_param['jours'].grid(row=ligne, column=1, sticky=W, padx=5, pady=2)
            self.entrees_param['jours'].insert(0, "* * * * * (tous les jours)")

        elif type_declencheur in ["FICHIER_MODIFIE", "FICHIER_CREE"]:
            Label(self.cadre_params, text="Chemin du fichier:").grid(row=ligne, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['chemin'] = Entry(self.cadre_params, width=50)
            self.entrees_param['chemin'].grid(row=ligne, column=1, sticky=W, padx=5, pady=2)

        elif type_declencheur == "RESEAU_ACTIF":
            Label(self.cadre_params, text="Interface reseau:").grid(row=ligne, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['interface'] = Entry(self.cadre_params, width=20)
            self.entrees_param['interface'].grid(row=ligne, column=1, sticky=W, padx=5, pady=2)
            self.entrees_param['interface'].insert(0, "(toutes)")

        elif type_declencheur == "SORTIE_TUBE":
            Label(self.cadre_params, text="Macro source:").grid(row=ligne, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['macro_source'] = Entry(self.cadre_params, width=20)
            self.entrees_param['macro_source'].grid(row=ligne, column=1, sticky=W, padx=5, pady=2)

            ligne += 1
            Label(self.cadre_params, text="Variable de reception:").grid(row=ligne, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['variable_reception'] = Entry(self.cadre_params, width=20)
            self.entrees_param['variable_reception'].grid(row=ligne, column=1, sticky=W, padx=5, pady=2)
            self.entrees_param['variable_reception'].insert(0, "DONNEES_RECUES")

        elif type_declencheur == "USB_CONNECTE":
            Label(self.cadre_params, text="Peripherique (optionnel):").grid(row=ligne, column=0, sticky=E, padx=5, pady=2)
            self.entrees_param['peripherique'] = Entry(self.cadre_params, width=20)
            self.entrees_param['peripherique'].grid(row=ligne, column=1, sticky=W, padx=5, pady=2)
            self.entrees_param['peripherique'].insert(0, "(tous)")

    def get_data(self):
        libelle_declencheur = self.variable_declencheur.get()
        type_declencheur = [k for k, v in DECLNCHEURS.items() if v == libelle_declencheur][0]

        params = {}
        for cle, entree in self.entrees_param.items():
            if hasattr(entree, 'get'):
                val = entree.get().strip()
            else:
                val = str(entree.get())
            if val:
                params[cle] = val

        return {
            'type': type_declencheur,
            'label': libelle_declencheur,
            'params': params
        }

class EditionAction(Frame):
    """Frame pour une seule action avec ses parametres."""

    def __init__(self, parent, numero_action=1, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.numero_action = numero_action
        self.configurer_ui()

    def configurer_ui(self):
        Label(self, text=f"{self.numero_action}. ", font=('Arial', 9, 'bold')).pack(side=LEFT, padx=2)

        self.variable_type_action = StringVar()
        self.combobox_action = ttk.Combobox(self, textvariable=self.variable_type_action, values=list(ACTIONS.values()), state='readonly', width=35)
        self.combobox_action.current(0)
        self.combobox_action.pack(side=LEFT, padx=5)

        self.texte_params = Text(self, height=4, width=60)
        self.texte_params.pack(side=LEFT, padx=10)

        self.combobox_action.bind('<<ComboboxSelected>>', lambda e: self.metre_a_jour_texte_params())

    def metre_a_jour_texte_params(self):
        self.texte_params.delete("1.0", END)
        libelle_action = self.variable_type_action.get()
        type_action = [k for k, v in ACTIONS.items() if v == libelle_action][0]

        if type_action == "NOTIFIER":
            self.texte_params.insert(END, "titre=Notification\nmessage=Votre message ici")
        elif type_action == "COPIER_FICHIER":
            self.texte_params.insert(END, "source=~/Documents\ndestination=~/backup/\nmotif=*.pdf")
        elif type_action == "EXECUTER_CMD":
            self.texte_params.insert(END, "commande=echo Hello World")
        elif type_action == "REDÉMARRER_SERV":
            self.texte_params.insert(END, "service=cron")
        elif type_action == "SORTIR_RESULTAT":
            self.texte_params.insert(END, "tube=resultat\ndonnees=VARIABLE")

    def get_data(self):
        libelle_action = self.variable_type_action.get()
        type_action = [k for k, v in ACTIONS.items() if v == libelle_action][0]

        texte_params = self.texte_params.get("1.0", END).strip()
        params = {}
        if texte_params:
            for ligne in texte_params.split('\n'):
                if '=' in ligne:
                    cle, val = ligne.split('=', 1)
                    params[cle.strip()] = val.strip()

        return {
            'id': str(self.numero_action),
            'type': type_action,
            'label': libelle_action,
            'params': params
        }

class EditionContrainte(Frame):
    """Frame pour une seule contrainte avec ses parametres."""

    def __init__(self, parent, numero_contrainte=1, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.numero_contrainte = numero_contrainte
        self.configurer_ui()

    def configurer_ui(self):
        Label(self, text=f"{self.numero_contrainte}. ").pack(side=LEFT, padx=2)

        self.variable_type_contrainte = StringVar()
        self.combobox_contrainte = ttk.Combobox(self, textvariable=self.variable_type_contrainte, values=list(CONTRAINTES.values()), state='readonly', width=30)
        self.combobox_contrainte.current(0)
        self.combobox_contrainte.pack(side=LEFT, padx=5)

        self.texte_params = Text(self, height=3, width=60)
        self.texte_params.pack(side=LEFT, padx=10)

        self.combobox_contrainte.bind('<<ComboboxSelected>>', lambda e: self.metre_a_jour_texte_params())

    def metre_a_jour_texte_params(self):
        self.texte_params.delete("1.0", END)
        libelle_contrainte = self.variable_type_contrainte.get()
        type_contrainte = [k for k, v in CONTRAINTES.items() if v == libelle_contrainte][0]

        if type_contrainte == "ESPACE_DISQUE":
            self.texte_params.insert(END, "espace_minimum=10")
        elif type_contrainte == "PLAGE_HORAIRE":
            self.texte_params.insert(END, "heure_debut=0800\nheure_fin=1800")
        elif type_contrainte == "PROCESSUS_ACTIF":
            self.texte_params.insert(END, "processus=firefox")

    def get_data(self):
        libelle_contrainte = self.variable_type_contrainte.get()
        type_contrainte = [k for k, v in CONTRAINTES.items() if v == libelle_contrainte][0]

        texte_params = self.texte_params.get("1.0", END).strip()
        params = {}
        if texte_params:
            for ligne in texte_params.split('\n'):
                if '=' in ligne:
                    cle, val = ligne.split('=', 1)
                    params[cle.strip()] = val.strip()

        return {
            'id': str(self.numero_contrainte),
            'type': type_contrainte,
            'label': libelle_contrainte,
            'params': params
        }

class EditionVariable(Frame):
    """Frame pour une variable simple nom=valeur."""

    def __init__(self, parent, numero_variable=1, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.numero_variable = numero_variable
        self.configurer_ui()

    def configurer_ui(self):
        Label(self, text=f"{self.numero_variable}. ").pack(side=LEFT, padx=2)

        Label(self, text="Nom:").pack(side=LEFT, padx=2)
        self.entree_nom = Entry(self, width=15)
        self.entree_nom.pack(side=LEFT, padx=2)

        Label(self, text="Valeur:").pack(side=LEFT, padx=2)
        self.entree_valeur = Entry(self, width=30)
        self.entree_valeur.pack(side=LEFT, padx=2)

    def get_data(self):
        return {
            'name': self.entree_nom.get().strip(),
            'value': self.entree_valeur.get().strip()
        }
