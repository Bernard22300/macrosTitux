#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fonction : Utilisateur_courant
Description : Retourne le nom d'utilisateur Linux actuel
Plugin pour macrosTitux - Dossier : src/fonctions/possibles/
"""

import os
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from fonction_base import Fonction_de_base

class Utilisateur_courant(Fonction_de_base):
    """Fonction qui retourne le nom d'utilisateur actuel."""
    
    def __init__(self) -> None:
        super().__init__(
            identificateur="UTILISATEUR_COURANT",
            description="Retourne le nom d'utilisateur Linux"
        )
    
    def valeur(self) -> str:
        return os.environ.get("USER", "inconnu")
    
    def __repr__(self) -> str:
        return f"Utilisateur_courant(user='{self.valeur()}')"

if __name__ == "__main__":
    fonc = Utilisateur_courant()
    print(f"Fonction : {fonc.identificateur}")
    print(f"Valeur : {fonc.valeur()}")
