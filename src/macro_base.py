#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module pour la gestion des macros abstraites dans macrosTitux.

Classe Macro_base : interface abstraite pour toutes les macros.
Une macro regroupe des déclencheurs, actions et contraintes.
"""

from abc import ABC, abstractmethod
from typing import List, Any
from pathlib import Path

# Imports relatifs (compatibilité pytest avec sys.path)
try:
    from instruction_declencheur_base import InstructionDeclencheur_base
    from instruction_action_base import InstructionAction_base
    from instruction_contrainte_base import InstructionContrainte_base
    from donnee_base import Donnee_base
except ImportError:
    from src.instruction_declencheur_base import InstructionDeclencheur_base
    from src.instruction_action_base import InstructionAction_base
    from src.instruction_contrainte_base import InstructionContrainte_base
    from src.donnee_base import Donnee_base

class Macro_base(ABC):
    """
    Classe abstraite de base pour toutes les macros.
    
    Une macro est un ensemble de :
        - Déclencheurs : définissent QUAND la macro s'exécute
        - Actions : définissent QUOI faire quand elle s'exécute
        - Contraintes : conditions à respecter pour l'exécution
    
    Méthodes abstraites à implémenter :
        compiler() : génère le script Bash correspondant
        exporter() : sérialisation au format XML/JSON
    """
    
    def __init__(self, nom: str = "") -> None:
        """
        Initialise une nouvelle macro.
        
        Args :
            nom : nom de la macro (optionnel)
        """
        self._nom: str = nom
        self._declencheurs: List[InstructionDeclencheur_base] = []
        self._actions: List[InstructionAction_base] = []
        self._contraintes: List[InstructionContrainte_base] = []
        self._donnees: List[Donnee_base] = []
    
    @property
    def nom(self) -> str:
        """Retourne le nom de la macro."""
        return self._nom
    
    @nom.setter
    def nom(self, valeur: str) -> None:
        """Définit le nom de la macro."""
        self._nom = valeur
    
    def obtenir_declencheurs(self) -> List[InstructionDeclencheur_base]:
        """Retourne la liste des déclencheurs."""
        return self._declencheurs.copy()
    
    def obtenir_actions(self) -> List[InstructionAction_base]:
        """Retourne la liste des actions."""
        return self._actions.copy()
    
    def obtenir_contraintes(self) -> List[InstructionContrainte_base]:
        """Retourne la liste des contraintes."""
        return self._contraintes.copy()
    
    def obtenir_donnees(self) -> List[Donnee_base]:
        """Retourne la liste des données."""
        return self._donnees.copy()
    
    def ajouter_declencheur(self, declencheur: InstructionDeclencheur_base) -> None:
        """
        Ajoute un déclencheur à la macro.
        
        Args :
            declencheur : instance d'un déclencheur (hérite de InstructionDeclencheur_base)
        """
        if not isinstance(declencheur, InstructionDeclencheur_base):
            raise TypeError("Doit être une instance de InstructionDeclencheur_base")
        self._declencheurs.append(declencheur)
    
    def ajouter_action(self, action: InstructionAction_base) -> None:
        """
        Ajoute une action à la macro.
        
        Args :
            action : instance d'une action (hérite de InstructionAction_base)
        """
        if not isinstance(action, InstructionAction_base):
            raise TypeError("Doit être une instance de InstructionAction_base")
        self._actions.append(action)
    
    def ajouter_contrainte(self, contrainte: InstructionContrainte_base) -> None:
        """
        Ajoute une contrainte à la macro.
        
        Args :
            contrainte : instance d'une contrainte (hérite de InstructionContrainte_base)
        """
        if not isinstance(contrainte, InstructionContrainte_base):
            raise TypeError("Doit être une instance de InstructionContrainte_base")
        self._contraintes.append(contrainte)
    
    def ajouter_donnee(self, donnee: Donnee_base) -> None:
        """
        Ajoute une donnée à la macro.
        
        Args :
            donnee : instance d'une donnée (hérite de Donnee_base)
        """
        if not isinstance(donnee, Donnee_base):
            raise TypeError("Doit être une instance de Donnee_base")
        self._donnees.append(donnee)
    
    @abstractmethod
    def compiler(self) -> str:
        """
        GÉNÈRE LE CODE BASH COMPLET DE CETTE MACRO.
        
        Cette méthode doit être implémentée pour chaque type de macro
        afin de produire le code Bash approprié.
        
        Returns :
            Chaîne de caractères contenant le script Bash complet
        
        Exemple :
            #!/bin/bash
            # Macro: Test
            # Déclencheur: DEMARRAGE
            notify-send "Bonjour" "Monde"
        """
        pass
    
    @abstractmethod
    def exporter(self) -> dict[str, Any]:
        """
        Exporte cette macro au format dictionnaire.
        
        Utilisé pour la sérialisation (XML, JSON, etc.)
        
        Returns :
            Dictionnaire contenant toutes les infos de la macro
        """
        pass
    
    def obtenir_resume(self) -> str:
        """
        Retourne un résumé court de la macro.
        
        Format : "[NOM] X déclencheur(s), Y action(s), Z contrainte(s)"
        
        Returns :
            Chaîne résumant la macro
        """
        return (
            f"[{self._nom}] {len(self._declencheurs)} déclencheur(s), "
            f"{len(self._actions)} action(s), {len(self._contraintes)} contrainte(s)"
        )
    
    def __repr__(self) -> str:
        """Représentation textuelle pour débogage."""
        return f"Macro(nom='{self._nom}', déclencheurs={len(self._declencheurs)}, actions={len(self._actions)})"
