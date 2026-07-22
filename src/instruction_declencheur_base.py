#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module pour la gestion des déclencheurs abstraits dans macrosTitux.

Classe InstructionDeclencheur_base : interface de base pour tous les déclencheurs.
Un déclencheur est ce qui lance l'exécution d'une macro (ex: démarrage, horaire, named pipe).

ATTENTION : Aucun type de déclencheur n'est pré-défini ici.
Les types disponibles sont gérés dans un module de configuration séparé
et chargés dynamiquement via importation.
"""

from abc import ABC, abstractmethod
from typing import Any
from instruction_base import Instruction_base

class InstructionDeclencheur_base(Instruction_base, ABC):
    """
    Classe abstraite de base pour tous les types de déclencheurs.
    
    Un déclencheur est une instruction spéciale qui définit QUAND
    une macro doit être exécutée.
    
    Attributs dérivés de Instruction_base :
        _identificateur (str) : type unique du déclencheur (ex: 'DEMMARRAGE', 'HORRAIRE')
        _arguments (dict[str, Any]) : paramètres spécifiques au déclencheur
        _nom_affichage (str) : nom convivial pour l'interface
    
    Méthodes abstraites à implémenter :
        verifier_condition() : vérifie si le déclencheur doit se déclencher
        compiler() : génère le code Bash correspondant
    
    NOTE IMPORTANTE :
        Ce module ne contient AUCUN type de déclencheur pré-défini.
        Pour connaître les types disponibles, utiliser les modules suivants :
        - config.py : registre des types enregistrés
        - model.py : chargement dynamique des déclencheurs
    """
    
    def __init__(self, identificateur: str, arguments: dict[str, Any] | None = None) -> None:
        """
        Initialise un nouveau déclencheur abstrait.
        
        Args :
            identificateur : type unique du déclencheur (doit être enregistré ailleurs)
            arguments : paramètres spécifiques (vide par défaut)
        """
        super().__init__(identificateur=identificateur, arguments=arguments)
    
    @abstractmethod
    def verifier_condition(self) -> bool:
        """
        VÉRIFIE SI LE DÉCLENCHEUR DOIT SE PRODUIRE.
        
        Cette méthode doit être implémentée par chaque sous-classe
        pour définir la logique de détection du déclenchement.
        
        Returns :
            True si le déclencheur s'est produit, False sinon
        
        Exemple :
            - Déclencheur HORRAIRE : vérifie si l'heure correspond
            - Déclencheur NAMED_PIPE : vérifie si des données sont disponibles
            - Déclencheur DEMARRAGE : toujours True au lancement
        """
        pass
    
    @abstractmethod
    def compiler(self) -> str:
        """
        GÉNÈRE LE CODE BASH CORRESPONDANT AU DÉCLENCHEUR.
        
        Cette méthode doit être implémentée pour chaque type de déclencheur
        afin de produire le code Bash approprié.
        
        Returns :
            Chaîne de caractères contenant le code Bash pour ce déclencheur
        
        Exemple pour DEMARRAGE :
            "# Déclencheur au démarrage\nsleep 5  # Attendre le démarrage système"
        
        Exemple pour HORRAIRE :
            "# Déclencheur horaire\nwhile true; do\n  sleep 3600\n  # ... actions ...\ndone"
        """
        pass
    
    def obtenir_type(self) -> str:
        """
        Retourne le type du déclencheur comme chaîne de caractères.
        
        Returns :
            Le nom de la classe sans le préfixe 'Instruction' ni '_Declencheur'
            Ex: 'Demarrage' pour 'InstructionDemarrageDeclencheur'
        """
        classe_nom = self.__class__.__name__
        # Enlever les prefixes/suffixes pour obtenir le type pur
        if classe_nom.startswith('Instruction'):
            classe_nom = classe_nom[11:]  # "Instruction"
        if classe_nom.endswith('Declencheur'):
            classe_nom = classe_nom[:-11]  # "Declencheur"
        return classe_nom
    
    def obtenir_resume(self) -> str:
        """
        Retourne un résumé court pour affichage dans la GUI.
        
        Format : "[IDENTIFICATEUR] arg1=valeur1, arg2=valeur2"
        
        Returns :
            Chaîne résumant le déclencheur
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
        Exporte ce déclencheur au format dictionnaire.
        
        Utilisé pour la sérialisation (XML, JSON, etc.)
        
        Returns :
            Dictionnaire avec 'type', 'identificateur' et 'arguments'
        """
        return {
            "type": "declencheur",
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
# Les types de déclencheurs disponibles sont définis dans des fichiers séparés
# et chargés dynamiquement selon les besoins.
