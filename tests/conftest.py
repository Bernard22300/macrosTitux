# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: conftest.py
# Description: Fixtures communes pour les tests pytest + configuration du chemin
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import pytest
import tempfile
import os
import sys
from pathlib import Path

# IMPORTANT : Ajouter src/ au path Python AVANT l'exécution des tests
SRC_DIR = Path(__file__).parent.parent / 'src'
sys.path.insert(0, str(SRC_DIR))

@pytest.fixture
def temp_dir():
    """Crée un dossier temporaire pour les tests."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)

@pytest.fixture
def sample_macro_xml(temp_dir):
    """Crée un XML exemple pour les tests."""
    xml_content = '''<?xml version="1.0" encoding="UTF-8"?>
<macro name="Test_Macro">
    <trigger type="DEMARRAGE" label="Au démarrage">
        <config/>
    </trigger>
    <variables>
        <var name="TEST_VAR" value="Hello World"/>
    </variables>
    <actions>
        <action id="1" type="NOTIFIER" label="Notifier">
            <config>
                <param key="titre" value="Test"/>
                <param key="message" value="Message de test"/>
            </config>
        </action>
    </actions>
    <constraints>
        <constraint id="1" type="ESPACE_DISQUE" label="Espace disque">
            <config>
                <param key="espace_minimum" value="10"/>
            </config>
        </constraint>
    </constraints>
</macro>'''

    xml_file = temp_dir / "test_macro.xml"
    xml_file.write_text(xml_content, encoding='utf-8')
    return xml_file

@pytest.fixture
def mock_generate_bash_script(temp_dir):
    """Crée un générateur Bash minimaliste pour les tests."""
    script_path = temp_dir / "generate_bash.sh"
    script_content = '''#!/bin/bash
echo "#!/bin/bash" > "$2"
echo "echo TEST_MODE" >> "$2"
chmod +x "$2"
'''
    script_path.write_text(script_content)
    os.chmod(script_path, 0o755)
    return script_path
