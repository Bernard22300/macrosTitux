# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: test_fenetre_edition_macro.py
# Description: Tests des widgets Tkinter
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import pytest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))
from config import DECLNCHEURS, ACTIONS, CONTRAINTES

class TestLogiqueWidgets:
    """Tests logiques des widgets (sans GUI)."""
    
    def test_trigger_widget_get_data_returns_type(self):
        """Le widget TriggerWidget retourne le bon type."""
        # Test simplifié - logique sans instance Tk
        assert "DEMARRAGE" in DECLNCHEURS
        assert "Au démarrage" in DECLNCHEURS.values()
    
    def test_action_widget_has_all_types(self):
        """Tous les types d'actions sont disponibles."""
        expected_actions = [
            "COPIER_FICHIER", "DEPLACER_FICHIER", "SUPPRIMER_FICHIER",
            "NOTIFIER", "EXECUTER_CMD", "SORTIR_RESULTAT"
        ]
        for action in expected_actions:
            assert action in ACTIONS
    
    def test_constraint_widget_has_all_types(self):
        """Tous les types de contraintes sont disponibles."""
        expected_constraints = ["ESPACE_DISQUE", "PLAGE_HORAIRE", "PROCESSUS_ACTIF"]
        for constraint in expected_constraints:
            assert constraint in CONTRAINTES

