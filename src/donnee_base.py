# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: donnee_base.py
# Description: Classe abstraite Donnee_base - expression du besoin
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from abc import ABC, abstractmethod
from typing import Any

class Donnee_base(ABC):
    """Décrit le minimum nécessaire pour écrire une Donnee fonctionnelle.
    
    Une Donnee représente une donnée manipulée par les instructions
    d'une Macro. La Macro est propriétaire de ses données et les
    propose aux instructions lors de leur édition.
    
    Exemples de données :
    - SOURCE : chemin d'un dossier source
    - DEST : chemin d'un dossier destination
    - MESSAGE : texte d'une notification
    - SEUIL : valeur numérique d'un seuil
    """

    # Types de données connus
    TYPE_CHAINE = "CHAINE"
    TYPE_ENTIER = "ENTIER"
    TYPE_BOOLEEN = "BOOLEEN"
    TYPE_CHEMIN = "CHEMIN"

    def __init__(self):
        self.cle = ""               # Identifiant unique de la donnée (ex: "SOURCE")
        self.type_donnee = ""        # Type de la donnée (TYPE_CHAINE, TYPE_ENTIER...)
        self.valeur = None           # Valeur courante
        self.commentaire = ""        # Description facultative

    # ==========================================================================
    # Identification
    # ==========================================================================

    @abstractmethod
    def lire_cle(self) -> str:
        """Retourne la clé unique de cette donnée."""
        pass

    @abstractmethod
    def lire_type(self) -> str:
        """Retourne le type de cette donnée.
        
        Retour possible :
        - Donnee_base.TYPE_CHAINE
        - Donnee_base.TYPE_ENTIER
        - Donnee_base.TYPE_BOOLEEN
        - Donnee_base.TYPE_CHEMIN
        """
        pass

    @abstractmethod
    def lire_resume(self) -> str:
        """Retourne un résumé court sur une ligne (pour affichage liste)."""
        pass

    # ==========================================================================
    # Accès à la valeur
    # ==========================================================================

    @abstractmethod
    def lire_valeur(self) -> Any:
        """Retourne la valeur courante de cette donnée."""
        pass

    @abstractmethod
    def definir_valeur(self, nouvelle_valeur: Any):
        """Modifie la valeur courante de cette donnée.
        
        Args:
            nouvelle_valeur: La nouvelle valeur à assigner.
        """
        pass

    # ==========================================================================
    # Édition
    # ==========================================================================

    @abstractmethod
    def editer(self):
        """Ouvre l'édition de cette donnée.
        
        Retourne:
            True si édition réussie, False si annulée.
        """
        pass

    # ==========================================================================
    # Persistance
    # ==========================================================================

    @abstractmethod
    def exporter(self) -> dict:
        """Exporte cette donnée vers un dictionnaire.
        
        Retourne:
            Dictionnaire avec cle, type, valeur, commentaire.
        """
        pass

    @abstractmethod
    def importer(self, donnees: dict):
        """Charge cette donnée depuis un dictionnaire.
        
        Args:
            donnees: Dictionnaire contenant cle, type, valeur, commentaire.
        """
        pass

    # ==========================================================================
    # Utilitaires
    # ==========================================================================

    def __str__(self):
        """Retourne le résumé pour affichage."""
        return self.lire_resume()
