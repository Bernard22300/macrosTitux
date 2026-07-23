#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Déclencheur : Demarrage_application
Description : Se déclenche automatiquement au démarrage de l'application macrosTitux

Plugin pour macrosTitux - Dossier : fonctions/actives/

Utilisation :
    decl = InstructionDemarrageApplicationDeclencheur()
    decl.compiler()  # Retourne le code Bash à exécuter au démarrage
"""

from pathlib import Path
import sys

# Ajoute src/ au path pour imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from instruction_declencheur_base import InstructionDeclencheur_base
from instruction_base import Instruction_base

class InstructionDemarrageApplicationDeclencheur(InstructionDeclencheur_base):
    """
    Déclencheur qui se lance automatiquement au démarrage de l'application.
    
    Ce déclencheur est spécial : il ne vérifie pas de condition en continu,
    mais se déclenche immédiatement quand l'application démarre.
    
    Exemple XML :
        <declencheur type="DEMARRAGE_APP" label="Au démarrage">
            <config>
                <parametre key="delai" value="0"/>
            </config>
        </declencheur>
    """
    
    def __init__(self, delai: int = 0) -> None:
        super().__init__(
            identificateur="DEMARRAGE_APP",
            arguments={"delai": str(delai)}
        )
        self._delai: int = delai
    
    @property
    def delai(self) -> int:
        """Retourne le délai avant exécution."""
        return self._delai
    
    @property
    def libelle(self) -> str:
        """Libellé affiché dans l'interface."""
        return "Au démarrage"
    
    def lire_type(self) -> str:
        """Retourne le type de cette instruction."""
        return Instruction_base.TYPE_DECLENCHEUR
    
    def lire_resume(self) -> str:
        """Retourne un résumé court sur une ligne."""
        return f"Au démarrage (délai: {self._delai}s)"
    
    def verifier_condition(self) -> bool:
        """
        Pour DEMARRAGE_APP : toujours True
        (car on s'exécute une seule fois au départ)
        """
        return True
    
    def editer(self, donnees_macro=None) -> bool:
        """
        Édition du déclencheur.
        Pour l'instant, pas d'édition graphique — retourne True.
        """
        return True
    
    def importer(self, donnees_xml: dict) -> None:
        """
        Charge le déclencheur depuis un dictionnaire XML.
        
        Args :
            donnees_xml : dictionnaire avec 'arguments' contenant 'delai'
        """
        args = donnees_xml.get("arguments", {})
        delai_str = args.get("delai", "0")
        try:
            self._delai = int(delai_str)
        except (ValueError, TypeError):
            self._delai = 0
    
    def exporter(self) -> dict:
        """
        Exporte le déclencheur vers un dictionnaire XML.
        
        Returns :
            Dictionnaire avec identificateur et arguments
        """
        return {
            "identificateur": self.identificateur,
            "arguments": {"delai": str(self._delai)}
        }
    
    def compiler(self) -> str:
        """
        Génère le code Bash correspondant au déclencheur.
        
        Returns :
            Code Bash pour exécuter les actions au démarrage
        """
        if self._delai > 0:
            return f'sleep {self._delai}'
        return ''
    
    def __repr__(self) -> str:
        return f"InstructionDemarrageApplicationDeclencheur(délai={self._delai}s)"
