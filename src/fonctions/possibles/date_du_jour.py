#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fonction : Date_du_jour
Description : Retourne la date du jour au format ISO (YYYY-MM-DD)
Plugin pour macrosTitux - Dossier : src/fonctions/possibles/

Pour activer cette fonction :
1. Copie ce fichier dans src/fonctions/actives/
2. Redemarre l'application
"""

from datetime import date
from pathlib import Path
import sys

# Ajoute src/ au path pour import de fonction_base
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from fonction_base import Fonction_de_base

class Date_du_jour(Fonction_de_base):
    """
    Fonction qui retourne la date du jour.
    
    Format de sortie : YYYY-MM-DD (ISO)
    Exemple : '2026-07-22'
    
    Utilisation :
        fonc = Date_du_jour()
        print(fonc.valeur())  # Affiche "2026-07-22"
    """
    
    def __init__(self) -> None:
        """Initialise la fonction Date_du_jour."""
        super().__init__(
            identificateur="DATE_DU_JOUR",
            description="Retourne la date du jour (YYYY-MM-DD)"
        )
    
    def valeur(self) -> str:
        """
        Retourne la date du jour au format ISO.
        
        Returns :
            Date sous forme de chaîne "YYYY-MM-DD"
        """
        return date.today().strftime("%Y-%m-%d")
    
    def __repr__(self) -> str:
        """Représentation textuelle pour débogage."""
        return f"Date_du_jour(date='{self.valeur()}')"

# Pour tester la fonction directement :
if __name__ == "__main__":
    fonc = Date_du_jour()
    print(f"Fonction : {fonc.identificateur}")
    print(f"Description : {fonc.description}")
    print(f"Valeur actuelle : {fonc.valeur()}")
