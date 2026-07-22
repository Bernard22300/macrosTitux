#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module pour la gestion des contraintes abstraites dans macrosTitux.

Classe InstructionContrainte_base : interface de base pour toutes les contraintes.
Une contrainte est une condition qui doit être satisfaite pour qu'une macro
s'exécute (ex: réseau connecté, batterie > 20%, fichier présent).

ATTENTION : Aucun type de contrainte n'est pré-défini ici.
Les types disponibles sont gérés dans un module de configuration séparé
et chargés dynamiquement via importation.
"""

from abc import ABC, abstractmethod
from typing import Any
from instruction_base import Instruction_base

class InstructionContrainte_base(Instruction_base, ABC):
    """
    Classe abstraite de base pour tous les types de contraintes.
    
    Une contrainte est une instruction qui définit SOUS QUELLE CONDITION
    une macro peut s'exécuter. Contrairement au déclencheur (QUAND) et à
    l'action (QUOI), la contrainte répond à la question : EST-CE QUE ?
    
    Attributs dérivés de Instruction_base :
        _identificateur (str) : type unique de la contrainte (ex: 'RESEAU_CONNECTE', 'BATTERIE')
        _arguments (dict[str, Any]) : paramètres spécifiques à la contrainte
    
    Méthodes abstraites à implémenter :
        evaluer() : évalue si la contrainte est satisfaite
        compiler() : génère le code Bash correspondant
    
    NOTE IMPORTANTE :
        Ce module ne contient AUCUN type de contrainte pré-défini.
        Pour connaître les types disponibles, utiliser les modules suivants :
        - config.py : registre des types enregistrés
        - model.py : chargement dynamique des contraintes
    """
    
    def __init__(self, identificateur: str, arguments: dict[str, Any] | None = None) -> None:
        """
        Initialise une nouvelle contrainte abstraite.
        
        Args :
            identificateur : type unique de la contrainte (doit être enregistré ailleurs)
            arguments : paramètres spécifiques (vide par défaut)
        """
        super().__init__(identificateur=identificateur, arguments=arguments)
    
    @abstractmethod
    def evaluer(self) -> bool:
        """
        ÉVALUE SI LA CONTRAINTE EST SATISFAITE.
        
        Cette méthode doit être implémentée par chaque sous-classe
        pour définir la logique de vérification de la contrainte.
        
        Returns :
            True si la contrainte est satisfaite, False sinon
        
        Exemple :
            - Contrainte RESEAU_CONNECTE : vérifie la connectivité réseau
            - Contrainte BATTERIE : vérifie que le niveau de batterie est suffisant
            - Contrainte FICHIER_PRESENT : vérifie qu'un fichier existe
        """
        pass
    
    @abstractmethod
    def compiler(self) -> str:
        """
        GÉNÈRE LE CODE BASH CORRESPONDANT À LA CONTRAINTE.
        
        Dans le script Bash généré, une contrainte se traduit généralement
        par une condition 'if' qui doit être vraie pour que les actions
        s'exécutent.
        
        Returns :
            Chaîne de caractères contenant le code Bash pour cette contrainte
        
        Exemple pour RESEAU_CONNECTE :
            'ping -c 1 google.com >/dev/null 2>&1'
        
        Exemple pour FICHIER_PRESENT :
            'test -f /chemin/vers/fichier'
        """
        pass
    
    def obtenir_type(self) -> str:
        """
        Retourne le type de la contrainte comme chaîne de caractères.
        
        Returns :
            Le nom de la classe sans le préfixe 'Instruction' ni 'Contrainte'
            Ex: 'ReseauConnecte' pour 'InstructionReseauConnecteContrainte'
        """
        classe_nom = self.__class__.__name__
        if classe_nom.startswith('Instruction'):
            classe_nom = classe_nom[11:]
        if classe_nom.endswith('Contrainte'):
            classe_nom = classe_nom[:-10]
        return classe_nom
    
    def obtenir_resume(self) -> str:
        """
        Retourne un résumé court pour affichage dans la GUI.
        
        Format : "[IDENTIFICATEUR] arg1=valeur1, arg2=valeur2"
        
        Returns :
            Chaîne résumant la contrainte
        """
        if not self._arguments:
            return f"[{self._identificateur}]"
        
        arguments_reduits = ", ".join(
            f"{cle}={valeur}" 
            for cle, valeur in self._arguments.items()
        )
        return f"[{self._identificateur}] {arguments_reduits}"
    
    def exporter(self) -> dict[str, Any]:
        """
        Exporte cette contrainte au format dictionnaire.
        
        Utilisé pour la sérialisation (XML, JSON, etc.)
        
        Returns :
            Dictionnaire avec 'type', 'identificateur' et 'arguments'
        """
        return {
            "type": "contrainte",
            "identificateur": self._identificateur,
            "arguments": self._arguments.copy(),
            "resume": self.obtenir_resume()
        }
    
    def __repr__(self) -> str:
        """Représentation textuelle pour débogage."""
        return f"{self.__class__.__name__}(identificateur='{self._identificateur}', arguments={self._arguments})"

# ============================================================================
# PAS DE LISTES DE TYPES ICI - GÉRÉ DANS config.py ET model.py
# ============================================================================
