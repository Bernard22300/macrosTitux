#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fonction : Heure_actuelle
Description : Retourne l'heure du jour au format HH:MM
Plugin pour macrosTitux - Dossier : src/fonctions/possibles/
"""

from datetime import datetime
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from fonction_base import Fonction_de_base

class Heure_actuelle(Fonction_de_base):
    """Fonction qui retourne l'heure actuelle."""
    
    def __init__(self) -> None:
        super().__init__(
            identificateur="HEURE_ACTUELLE",
            description="Retourne l'heure actuelle (HH:MM)"
        )
    
    def valeur(self) -> str:
        return datetime.now().strftime("%H:%M")
    
    def __repr__(self) -> str:
        return f"Heure_actuelle(horloge='{self.valeur()}')"

if __name__ == "__main__":
    fonc = Heure_actuelle()
    print(f"Fonction : {fonc.identificateur}")
    print(f"Valeur : {fonc.valeur()}")
