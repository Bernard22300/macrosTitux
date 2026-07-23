# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: config.py
# Description: Constantes et configurations globales de l'application
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from pathlib import Path
import sys

src_dir = Path(__file__).parent
if str(src_dir) not in sys.path:
    sys.path.insert(0, str(src_dir))

from bloc_fonctions import obtenir_bloc_fonctions

NOM_APPLICATION = "macrosTitux"
VERSION_APPLICATION = "0.3"
LICENCE_APPLICATION = "GPL-3.0"

CONFIG_DEFAUT = {
    "theme": "defaut",
    "langue": "fr_FR.UTF-8",
    "notifications": True,
    "journal_activite": True
}

#------------------------------------------------------------------------------
# Declencheurs, Actions, Contraintes charges dynamiquement
#------------------------------------------------------------------------------
_GESTIONNAIRE = obtenir_bloc_fonctions()
DECLENCHEURS = _GESTIONNAIRE.obtenir_declencheurs()
ACTIONS = _GESTIONNAIRE.obtenir_actions()
CONTRAINTES = _GESTIONNAIRE.obtenir_contraintes()

PARAMS_DEFAUT_DECLENCHEUR = {}
PARAMS_DEFAUT_ACTION = {}
PARAMS_DEFAUT_CONTRAINTES = {}
