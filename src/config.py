# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: config.py
# Description: Constantes et configurations globales de l'application
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from pathlib import Path
import sys

# Assurer que src/ est dans le path
src_dir = Path(__file__).parent
if str(src_dir) not in sys.path:
    sys.path.insert(0, str(src_dir))

from fonctions import obtenir_gestionnaire_fonctions

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
# Declencheurs disponibles (TYPE_CODE: Libelle affiche)
# Charge dynamiquement depuis le gestionnaire de plugins
#------------------------------------------------------------------------------
_GESTIONNAIRE = obtenir_gestionnaire_fonctions()
DECLENCHEURS = _GESTIONNAIRE.obtenir_declencheurs()

#------------------------------------------------------------------------------
# Actions disponibles (TYPE_CODE: Libelle affiche)
#------------------------------------------------------------------------------
ACTIONS = _GESTIONNAIRE.obtenir_actions()

#------------------------------------------------------------------------------
# Contraintes disponibles (TYPE_CODE: Libelle affiche)
#------------------------------------------------------------------------------
CONTRAINTES = _GESTIONNAIRE.obtenir_contraintes()

#------------------------------------------------------------------------------
# Parametres par defaut pour chaque declencheur
#------------------------------------------------------------------------------
PARAMS_DEFAUT_DECLENCHEUR = {}

#------------------------------------------------------------------------------
# Parametres par defaut pour chaque action
#------------------------------------------------------------------------------
PARAMS_DEFAUT_ACTION = {}

#------------------------------------------------------------------------------
# Parametres par defaut pour chaque contrainte
#------------------------------------------------------------------------------
PARAMS_DEFAUT_CONTRAINTES = {}
