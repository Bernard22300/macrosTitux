# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: config.py
# Description: Constantes de l'application
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from pathlib import Path

APP_NAME = "macrosTitux"
APP_VERSION = "0.3"

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

DEFAULT_CONFIG = {
    "editor": "nano",
    "auto_test": False,
    "export_dir": str(Path.home() / "macrosTitux_exports"),
    "log_level": "info"
}
