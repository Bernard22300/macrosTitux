#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fonction : Espace_disponible
Description : Retourne l'espace disque libre sur /home en Go
Plugin pour macrosTitux - Dossier : src/fonctions/possibles/
"""

import shutil
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from fonction_base import Fonction_de_base

class Espace_disponible(Fonction_de_base):
    """Fonction qui retourne l'espace disque libre sur /home."""
    
    def __init__(self) -> None:
        super().__init__(
            identificateur="ESPACE_DISPONIBLE",
            description="Retourne l'espace libre sur /home (en Go)"
        )
    
    def valeur(self) -> float:
        chemin = Path("/home")
        if chemin.exists():
            total, used, libre = shutil.disk_usage(str(chemin))
            return round(libre / (2**30), 2)  # Convertit en Go
        return 0.0
    
    def __repr__(self) -> str:
        return f"Espace_disponible( libre={self.valeur()}Go )"

if __name__ == "__main__":
    fonc = Espace_disponible()
    print(f"Fonction : {fonc.identificateur}")
    print(f"Valeur : {fonc.valeur()} Go")
