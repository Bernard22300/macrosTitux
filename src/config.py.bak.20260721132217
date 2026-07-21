# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: config.py
# Description: Constantes et configurations globales de l'application
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

APP_NAME = "macrosTitux"
APP_VERSION = "0.3"
APP_LICENSE = "GPL-3.0"

DEFAULT_CONFIG = {
    "theme": "defaut",
    "langue": "fr_FR.UTF-8",
    "notifications": True,
    "journal_activite": True
}

#------------------------------------------------------------------------------
# Déclencheurs disponibles (TYPE_CODE: Libellé affiché)
#------------------------------------------------------------------------------
TRIGGERS = {
    "DEMARRAGE": "Au démarrage",
    "HORAIRE": "Horaire programmé",
    "FICHIER_MODIFIE": "Fichier modifié",
    "FICHIER_CREE": "Fichier créé",
    "RESEAU_ACTIF": "Réseau actif détecté",
    "SORTIE_TUBE": "Sortie de tube (named pipe)",
    "USB_CONNECTE": "Périphérique USB connecté"
}

#------------------------------------------------------------------------------
# Actions disponibles (TYPE_CODE: Libellé affiché)
#------------------------------------------------------------------------------
ACTIONS = {
    "NOTIFIER": "Notifier l'utilisateur",
    "COPIER_FICHIER": "Copier un fichier",
    "DEPLACER_FICHIER": "Déplacer un fichier",
    "SUPPRIMER_FICHIER": "Supprimer un fichier",
    "EXECUTER_CMD": "Exécuter une commande",
    "REDÉMARRER_SERV": "Redémarrer un service",
    "SORTIR_RESULTAT": "Sortir résultat dans un tube"
}

#------------------------------------------------------------------------------
# Contraintes disponibles (TYPE_CODE: Libellé affiché)
#------------------------------------------------------------------------------
CONSTRAINTS = {
    "ESPACE_DISQUE": "Espace disque minimum",
    "PLAGE_HORAIRE": "Plage horaire valide",
    "PROCESSUS_ACTIF": "Processus en cours d'exécution"
}

#------------------------------------------------------------------------------
# Paramètres par défaut pour chaque déclencheur
#------------------------------------------------------------------------------
TRIGGER_DEFAULT_PARAMS = {
    "DEMARRAGE": {},
    "HORAIRE": {"heure": "8", "minute": "0", "jours": "* * * * *"},
    "FICHIER_MODIFIE": {"chemin": ""},
    "FICHIER_CREE": {"chemin": ""},
    "RESEAU_ACTIF": {"interface": "(toutes)"},
    "SORTIE_TUBE": {"macro_source": "", "variable_reception": "DONNEES_RECUES"},
    "USB_CONNECTE": {"peripherique": "(tous)"}
}

#------------------------------------------------------------------------------
# Paramètres par défaut pour chaque action
#------------------------------------------------------------------------------
ACTION_DEFAULT_PARAMS = {
    "NOTIFIER": {"titre": "Notification", "message": ""},
    "COPIER_FICHIER": {"source": "", "destination": "", "motif": "*"},
    "DEPLACER_FICHIER": {"source": "", "destination": ""},
    "SUPPRIMER_FICHIER": {"chemin": "", "confirmation": "non"},
    "EXECUTER_CMD": {"commande": ""},
    "REDÉMARRER_SERV": {"service": ""},
    "SORTIR_RESULTAT": {"tube": "", "donnees": ""}
}

#------------------------------------------------------------------------------
# Paramètres par défaut pour chaque contrainte
#------------------------------------------------------------------------------
CONSTRAINT_DEFAULT_PARAMS = {
    "ESPACE_DISQUE": {"espace_minimum": "10"},
    "PLAGE_HORAIRE": {"heure_debut": "0800", "heure_fin": "1800"},
    "PROCESSUS_ACTIF": {"processus": ""}
}
