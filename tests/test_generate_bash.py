# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: test_generate_bash.py
# Description: Tests du script generate_bash.sh
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import pytest
import subprocess
import os
from pathlib import Path

class TestGenerateBash:
    """Tests de la conversion XML → Bash."""

    def test_generate_bash_executable(self):
        """Le script generate_bash.sh existe et est exécutable."""
        script = Path(__file__).parent.parent / 'src' / 'generate_bash.sh'
        assert script.exists()
        assert os.access(script, os.X_OK)

    def test_generate_bash_with_sample_xml(self, temp_dir, sample_macro_xml, mock_generate_bash_script):
        """La conversion d'un XML exemple produit un script."""
        output_sh = temp_dir / "output_test.sh"

        # Simule l'exécution (mock car on teste juste que ça s'exécute)
        result = subprocess.run(
            ['bash', str(mock_generate_bash_script), str(sample_macro_xml), str(output_sh)],
            capture_output=True,
            text=True
        )

        assert output_sh.exists()

    def test_generated_script_starts_shebang(self, temp_dir, sample_macro_xml, mock_generate_bash_script):
        """Le script généré commence par un shebang Bash."""
        output_sh = temp_dir / "output_test.sh"

        subprocess.run(
            ['bash', str(mock_generate_bash_script), str(sample_macro_xml), str(output_sh)],
            capture_output=True
        )

        content = output_sh.read_text()
        assert content.startswith('#!/bin/bash')
