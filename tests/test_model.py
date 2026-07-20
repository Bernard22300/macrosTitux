# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: test_model.py
# Description: Tests du modèle de données (sauvegarde XML)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import pytest
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))
from model import save_macro, load_macros_list, init_dirs, MACRO_DIR

class TestModel:
    """Tests du modèle de données."""

    def test_save_macro_creates_valid_xml(self, temp_dir):
        """Un appel à save_macro crée un XML valide."""
        # Mock des dossiers
        from unittest.mock import patch, MagicMock

        with patch('model.MACRO_DIR', temp_dir):
            trigger_data = {
                'type': 'DEMARRAGE',
                'label': 'Au démarrage',
                'params': {}
            }
            variables = [{'name': 'TEST_VAR', 'value': 'Hello'}]
            actions = [{
                'id': '1',
                'type': 'NOTIFIER',
                'label': 'Notifier',
                'params': {'titre': 'Test', 'message': 'Test msg'}
            }]
            constraints = [{
                'id': '1',
                'type': 'ESPACE_DISQUE',
                'label': 'Espace disque',
                'params': {'espace_minimum': '10'}
            }]

            save_macro("Test_Macro", trigger_data, variables, actions, constraints)

        # Vérifie que le fichier a été créé
        xml_file = temp_dir / "Test_Macro.xml"
        assert xml_file.exists()

        # Vérifie que c'est un XML valide
        tree = ET.parse(xml_file)
        root = tree.getroot()
        assert root.tag == 'macro'
        assert root.get('name') == 'Test_Macro'

    def test_save_macro_preserves_trigger_type(self, temp_dir):
        """Le type de déclencheur est conservé dans le XML."""
        from unittest.mock import patch

        with patch('model.MACRO_DIR', temp_dir):
            trigger_data = {
                'type': 'HORAIRE',
                'label': 'Horaire',
                'params': {'heure': '8', 'minute': '0'}
            }
            save_macro("Test_Macro_2", trigger_data, [], [], [])

        xml_file = temp_dir / "Test_Macro_2.xml"
        tree = ET.parse(xml_file)
        trigger = tree.find('.//trigger')
        assert trigger is not None
        assert trigger.get('type') == 'HORAIRE'

    def test_save_macro_with_multiple_actions(self, temp_dir):
        """Plusieurs actions sont sauvegardées."""
        from unittest.mock import patch

        with patch('model.MACRO_DIR', temp_dir):
            trigger_data = {'type': 'DEMARRAGE', 'label': 'Au démarrage', 'params': {}}
            actions = [
                {'id': '1', 'type': 'NOTIFIER', 'label': 'Notif 1', 'params': {}},
                {'id': '2', 'type': 'COPIER_FICHIER', 'label': 'Copier', 'params': {}}
            ]
            save_macro("Test_Multi_Action", trigger_data, [], actions, [])

        xml_file = temp_dir / "Test_Multi_Action.xml"
        tree = ET.parse(xml_file)
        action_elements = tree.findall('.//actions/action')
        assert len(action_elements) == 2
