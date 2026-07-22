#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Déclencheur : Demarrage_application
Description : Se déclenche automatiquement au démarrage de l'application macrosTitux

Plugin pour macrosTitux - Dossier : src/

Utilisation :
    decl = InstructionDemarrageApplicationDeclencheur()
    decl.compiler()  # Retourne le code Bash à exécuter au démarrage
"""

from pathlib import Path
import sys

# Ajoute src/ au path pour imports
sys.path.insert(0, str(Path(__file__).parent))

from instruction_declencheur_base import InstructionDeclencheur_base

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
        """
        Initialise le déclencheur Démarrage.
        
        Args :
            delai : délai en secondes avant exécution (défaut: 0 = immédiat)
        """
        super().__init__(
            identificateur="DEMARRAGE_APP",
            description=f"Déclencheur au démarrage (délai: {delai}s)"
        )
        self._delai: int = delai
    
    @property
    def delai(self) -> int:
        """Retourne le délai avant exécution."""
        return self._delai
    
    def verifier_condition(self) -> bool:
        """
        VÉRIFIE SI LE DÉCLENCHEUR DOIT SE PRODUIRE.
        
        Pour DEMARRAGE_APP : toujours True (car on s'exécute une seule fois au départ)
        
        Returns :
            True - le déclencheur s'est produit (au démarrage)
        """
        return True
    
    def compiler(self) -> str:
        """
        GÉNÈRE LE CODE BASH CORRESPONDANT AU DÉCLENCHEUR.
        
        Returns :
            Code Bash pour attendre le délai puis signaler le démarrage
        """
        if self._delai > 0:
            return (
                "# === DÉCLENCHEUR: Démarrage application ===\n"
                f"echo 'Démarrage en cours... Attendre {self._delai} seconde(s).'\n"
                f"sleep {self._delai}\n"
                "echo 'Démarrage effectué.'\n"
                ""
            )
        else:
            return (
                "# === DÉCLENCHEUR: Démarrage application ===\n"
                "echo 'Démarrage immédiat.'\n"
                ""
            )
    
    def obtenir_resume(self) -> str:
        """Retourne un résumé court pour la GUI."""
        return f"[{self._identificateur}] Délai: {self._delai}s"
    
    def exporter(self) -> dict:
        """Exporte le déclencheur au format dictionnaire."""
        return {
            "type": "declencheur",
            "identificateur": self._identificateur,
            "description": self._description,
            "arguments": {"delai": self._delai},
            "resume": self.obtenir_resume()
        }
    
    def __repr__(self) -> str:
        return f"InstructionDemarrageApplicationDeclencheur(delai={self._delai})"


# Pour tester directement
if __name__ == "__main__":
    print("=== Test déclencheur Demarrage_application ===")
    decl = InstructionDemarrageApplicationDeclencheur(delai=2)
    print(f"Fonction: {decl.identificateur}")
    print(f"Description: {decl.description}")
    print(f"Vérification condition: {decl.verifier_condition()}")
    print(f"Résumé: {decl.obtenir_resume()}")
    print(f"\nCode Bash généré:\n{decl.compiler()}")
