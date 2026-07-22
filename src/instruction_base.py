# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: instruction_base.py
# Description: Classe abstraite Instruction_base - expression du besoin
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from abc import ABC, abstractmethod

class Instruction_base(ABC):
    """Décrit le minimum nécessaire pour écrire une Instruction fonctionnelle."""

    # Constantes pour les types d'instruction
    TYPE_DECLENCHEUR = "DECLENCHEUR"
    TYPE_ACTION = "ACTION"
    TYPE_CONTRAINTE = "CONTRAINTE"

    def __init__(self):
        self.identificateur = ""       # Ex: "HORAIRE", "NOTIFIER"...
        self.arguments = {}            # Arguments spécifiques
        self.commentaire = ""          # Commentaire facultatif

    # ==========================================================================
    # Identification
    # ==========================================================================

    @abstractmethod
    def lire_type(self):
        """Retourne le type de cette instruction.
        
        Retour possible :
        - Instruction_base.TYPE_DECLENCHEUR
        - Instruction_base.TYPE_ACTION
        - Instruction_base.TYPE_CONTRAINTE
        """
        pass

    @abstractmethod
    def lire_resume(self):
        """Retourne un résumé court sur une ligne pour affichage liste."""
        pass

    # ==========================================================================
    # Édition
    # ==========================================================================

    @abstractmethod
    def editer(self, donnees_macro=None):
        """Ouvre l'édition de cette instruction.
        
        Args:
            donnees_macro: Dictionnaire des données disponibles dans la Macro.
                          La Macro propose ces données pour être associées.
                          
        Retourne:
            True si édition réussie, False si annulée.
        """
        pass

    @abstractmethod
    def importer(self, donnees_xml):
        """Charge cette instruction depuis un dictionnaire XML.
        
        Args:
            donnees_xml: Dictionnaire contenant identificateur et arguments.
        """
        pass

    @abstractmethod
    def exporter(self):
        """Exporte cette instruction vers un dictionnaire XML.
        
        Retourne:
            Dictionnaire avec identificateur et arguments.
        """
        pass

    # ==========================================================================
    # Compilation
    # ==========================================================================

    @abstractmethod
    def compiler(self):
        """Compile cette instruction en code Bash exécutable.
        
        Retourne:
            Chaîne de caractères contenant du code Bash.
        """
        pass

    # ==========================================================================
    # Utilitaires
    # ==========================================================================

    def __str__(self):
        """Retourne le résumé pour affichage."""
        return self.lire_resume()
