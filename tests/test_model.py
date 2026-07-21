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
from model import sauvegarder_macro, charger_liste_macros, initialiser_dossiers, DOSSIER_MACROS

class TestModel:
    """Tests du modèle de données."""

    def test_sauvegarder_macro_creates_valid_xml(self, dossier_temporaire):
        """Un appel à sauvegarder_macro crée un XML valide."""
        # Mock des dossiers
        from unittest.mock import patch, MagicMock

        with patch('model.DOSSIER_MACROS', dossier_temporaire):
            donnees_declencheur = {
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

            sauvegarder_macro("Test_Macro", donnees_declencheur, variables, actions, constraints)

        # Vérifie que le fichier a été créé
        fichier_xml = dossier_temporaire / "Test_Macro.xml"
        assert fichier_xml.exists()

        # Vérifie que c'est un XML valide
        tree = ET.parse(fichier_xml)
        root = tree.getroot()
        assert root.tag == 'macro'
        assert root.get('name') == 'Test_Macro'

    def test_sauvegarder_macro_preserves_trigger_type(self, dossier_temporaire):
        """Le type de déclencheur est conservé dans le XML."""
        from unittest.mock import patch

        with patch('model.DOSSIER_MACROS', dossier_temporaire):
            donnees_declencheur = {
                'type': 'HORAIRE',
                'label': 'Horaire',
                'params': {'heure': '8', 'minute': '0'}
            }
            sauvegarder_macro("Test_Macro_2", donnees_declencheur, [], [], [])

        fichier_xml = dossier_temporaire / "Test_Macro_2.xml"
        tree = ET.parse(fichier_xml)
        trigger = tree.find('.//declencheur')
        assert trigger is not None
        assert trigger.get('type') == 'HORAIRE'

    def test_sauvegarder_macro_with_multiple_actions(self, dossier_temporaire):
        """Plusieurs actions sont sauvegardées."""
        from unittest.mock import patch

        with patch('model.DOSSIER_MACROS', dossier_temporaire):
            donnees_declencheur = {'type': 'DEMARRAGE', 'label': 'Au démarrage', 'params': {}}
            actions = [
                {'id': '1', 'type': 'NOTIFIER', 'label': 'Notif 1', 'params': {}},
                {'id': '2', 'type': 'COPIER_FICHIER', 'label': 'Copier', 'params': {}}
            ]
            sauvegarder_macro("Test_Multi_Action", donnees_declencheur, [], actions, [])

        fichier_xml = dossier_temporaire / "Test_Multi_Action.xml"
        tree = ET.parse(fichier_xml)
        action_elements = tree.findall('.//actions/action')
        assert len(action_elements) == 2
