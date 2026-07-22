# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: bloc_instructions_base.py
# Description: Classe abstraite Bloc_Instructions_base - expression du besoin
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from abc import ABC, abstractmethod
from typing import List, Any

class Bloc_Instructions_base(ABC):
    """Décrit le minimum nécessaire pour écrire un Bloc_Instructions fonctionnel.
    
    Un Bloc_Instructions contient plusieurs instructions du MÊME type :
    - Bloc_DECLENCHEUR : seulement des déclencheurs
    - Bloc_ACTION : seulement des actions
    - Bloc_CONTRAINTE : seulement des contraintes
    """

    def __init__(self, type_bloc=None):
        """Initialise un bloc vide.
        
        Args:
            type_bloc: Le type de ce bloc (TYPE_DECLENCHEUR, TYPE_ACTION, TYPE_CONTRAINTE)
        """
        self.type_bloc = type_bloc
        self.liste_instructions = []  # Liste des Instruction dans ce bloc

    # ==========================================================================
    # Identification
    # ==========================================================================

    @abstractmethod
    def lire_type(self):
        """Retourne le type de ce bloc.
        
        Retourne :
        - TYPE_DECLENCHEUR
        - TYPE_ACTION
        - TYPE_CONTRAINTE
        """
        pass

    @abstractmethod
    def lire_resume(self):
        """Retourne un résumé court sur une ligne (pour affichage liste)."""
        pass

    # ==========================================================================
    # Gestion des instructions (CRUD)
    # ==========================================================================

    @abstractmethod
    def ajouter_instruction(self, instruction):
        """Ajoute une instruction au bloc.
        
        Args:
            instruction: Instance de Instruction
            
        Retourne:
            True si ajout réussi, False sinon
            
        Lève:
            TypeError si l'instruction n'est pas du type autorisé
        """
        pass

    @abstractmethod
    def supprimer_instruction(self, index: int):
        """Supprime une instruction par son index.
        
        Args:
            index: Position de l'instruction dans la liste
        """
        pass

    @abstractmethod
    def editer_instruction(self, index: int, donnees_macro=None):
        """Ouvre l'édition d'une instruction existante.
        
        Args:
            index: Position de l'instruction dans la liste
            donnees_macro: Dictionnaire des données disponibles dans la Macro
        """
        pass

    @abstractmethod
    def obtenir_instruction(self, index: int):
        """Retourne une instruction par son index.
        
        Args:
            index: Position de l'instruction dans la liste
            
        Retourne:
            Instance de Instruction
            
        Lève:
            IndexError si index hors bornes
        """
        pass

    @abstractmethod
    def lister_instructions(self):
        """Retourne la liste complète des instructions."""
        pass

    @abstractmethod
    def compter(self) -> int:
        """Retourne le nombre d'instructions dans ce bloc."""
        pass

    # ==========================================================================
    # Compilation
    # ==========================================================================

    @abstractmethod
    def compiler_bloc(self):
        """Compile toutes les instructions du bloc en code Bash.
        
        Retourne:
            Chaîne de caractères contenant le code Bash généré.
        """
        pass

    @abstractmethod
    def exporter_bloc(self):
        """Exporte toutes les instructions du bloc vers une liste de dictionnaires XML.
        
        Retourne:
            Liste de dictionnaires, un par instruction.
        """
        pass

    @abstractmethod
    def importer_bloc(self, liste_donnees_xml):
        """Charge toutes les instructions du bloc depuis une liste de dictionnaires XML.
        
        Args:
            liste_donnees_xml: Liste de dictionnaires (un par instruction)
        """
        pass
