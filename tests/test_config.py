# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: test_config.py
# Description: Tests des constantes de configuration
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import pytest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))
from config import TRIGGERS, ACTIONS, CONSTRAINTS, APP_NAME, APP_VERSION

class TestConfig:
    """Tests des constantes."""
    
    def test_app_name(self):
        assert APP_NAME == "macrosTitux"
    
    def test_app_version(self):
        assert APP_VERSION == "0.3"
    
    def test_triggers_exist(self):
        assert len(TRIGGERS) >= 5  # Minimum 5 déclencheurs
    
    def test_actions_exist(self):
        assert len(ACTIONS) >= 5  # Minimum 5 actions
    
    def test_constraints_exist(self):
        assert len(CONSTRAINTS) >= 3  # Minimum 3 contraintes
    
    def test_trigger_keys_are_uppercase(self):
        for key in TRIGGERS.keys():
            assert key.isupper() or '_' in key
    
    def test_action_keys_are_uppercase(self):
        for key in ACTIONS.keys():
            assert key.isupper() or '_' in key
    
    def test_trigger_values_not_empty(self):
        for key, value in TRIGGERS.items():
            assert value.strip() != ""
    
    def test_action_values_not_empty(self):
        for key, value in ACTIONS.items():
            assert value.strip() != ""

