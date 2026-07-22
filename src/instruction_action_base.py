#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module pour la gestion des actions abstraites dans macrosTitux.

Classe InstructionAction_base : interface de base pour toutes les actions.
Une action est ce qu'une macro exécute lorsque ses déclencheurs sont activés
(ex: notifier, lancer un script, écrire dans un fichier).

ATTENTION : Aucun type d'action n'est pré-défini ici.
Les types disponibles sont gérés dans un module de configuration séparé
et chargés dynamiquement via importation.
"""

from abc import ABC, abstractmethod
from typing import Any
from instruction_base import Instruction_base

class InstructionAction_base(Instruction_base, ABC):
    """
    Classe abstraite de base pour tous les types d'actions.
    
    Une action est une instruction qui définit QUOI faire
    lorsqu'une macro est déclenchée.
    
    Attributs dérivés de Instruction_base :
        _identificateur (str) : type unique de l'action (ex: 'NOTIFIER', 'LANCER_SCRIPT')
        _arguments (dict[str, Any]) : paramètres spécifiques à l'action
    
    Méthodes abstraites à implémenter :
        executer() : exécute l'action directement (pour test)
        compiler() : génère le code Bash correspondant
    
    NOTE IMPORTANTE :
        Ce module ne contient AUCUN type d'action pré-défini.
        Pour connaître les types disponibles, utiliser les modules suivants :
        - config.py : registre des types enregistrés
        - model.py : chargement dynamique des actions
    """
    
    def __init__(self, identificateur: str, arguments: dict[str, Any] | None = None) -> None:
        """
        Initialise une nouvelle action abstraite.
        
        Args :
            identificateur : type unique de l'action (doit être enregistré ailleurs)
            arguments : paramètres spécifiques (vide par défaut)
        """
        super().__init__(identificateur=identificateur, arguments=arguments)
    
    @abstractmethod
    def executer(self) -> bool:
        """
        EXÉCUTE L'ACTION DIRECTEMENT.
        
        Utilisé notamment par le bouton <Tester> de l'interface
        pour valider une macro sans générer de script Bash.
        
        Returns :
            True si l'action s'est exécutée avec succès, False sinon
        
        Exemple :
            - Action NOTIFIER : affiche une notification via notify-send
            - Action LANCER_SCRIPT : exécute un script shell
            - Action ECRIRE_FICHIER : écrit du contenu dans un fichier
        """
        pass
    
    @abstractmethod
    def compiler(self) -> str:
        """
        GÉNÈRE LE CODE BASH CORRESPONDANT À L'ACTION.
        
        Cette méthode doit être implémentée pour chaque type d'action
        afin de produire le code Bash approprié dans le script généré.
        
        Returns :
            Chaîne de caractères contenant le code Bash pour cette action
        
        Exemple pour NOTIFIER :
            'notify-send "Titre" "Message"'
        
        Exemple pour ECRIRE_FICHIER :
            'echo "contenu" > /chemin/fichier'
        """
        pass
    
    def obtenir_type(self) -> str:
        """
        Retourne le type de l'action comme chaîne de caractères.
        
        Returns :
            Le nom de la classe sans le préfixe 'Instruction' ni 'Action'
            Ex: 'Notifier' pour 'InstructionNotifierAction'
        """
        classe_nom = self.__class__.__name__
        if classe_nom.startswith('Instruction'):
            classe_nom = classe_nom[11:]
        if classe_nom.endswith('Action'):
            classe_nom = classe_nom[:-6]
        return classe_nom
    
    def obtenir_resume(self) -> str:
        """
        Retourne un résumé court pour affichage dans la GUI.
        
        Format : "[IDENTIFICATEUR] arg1=valeur1, arg2=valeur2"
        
        Returns :
            Chaîne résumant l'action
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
        Exporte cette action au format dictionnaire.
        
        Utilisé pour la sérialisation (XML, JSON, etc.)
        
        Returns :
            Dictionnaire avec 'type', 'identificateur' et 'arguments'
        """
        return {
            "type": "action",
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
