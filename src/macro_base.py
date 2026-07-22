# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: macro_base.py
# Description: Classe abstraite Macro_base - expression du besoin
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from abc import ABC, abstractmethod
from typing import List, Dict, Any

class Macro_base(ABC):
    """Décrit le minimum nécessaire pour écrire une classe Macro fonctionnelle."""

    def __init__(self):
        # Informations générales
        self.nom = ""
        self.commentaire = ""

        # Les 4 listes
        self.liste_donnees = []
        self.liste_declencheurs = []
        self.liste_actions = []
        self.liste_contraintes = []

        # État d'exécution
        self.est_actif = False
        self.en_cours = False

    # ==========================================================================
    # Gestion des données
    # ==========================================================================

    @abstractmethod
    def ajouter_donnee(self, cle: str, type_donnee: str, valeur_par_defaut: Any):
        """Ajoute une donnée dans la macro."""
        pass

    @abstractmethod
    def supprimer_donnee(self, index: int):
        """Supprime une donnée par son index."""
        pass

    @abstractmethod
    def editer_donnee(self, index: int, nouvelle_valeur: Any):
        """Modifie une donnée par son index."""
        pass

    @abstractmethod
    def lister_donnees(self) -> List[Dict[str, Any]]:
        """Retourne la liste complète des données."""
        pass

    # ==========================================================================
    # Gestion des déclencheurs
    # ==========================================================================

    @abstractmethod
    def ajouter_declencheur(self, type_declencheur: str, parametres: Dict[str, Any]):
        """Ajoute un déclencheur."""
        pass

    @abstractmethod
    def supprimer_declencheur(self, index: int):
        """Supprime un déclencheur par son index."""
        pass

    @abstractmethod
    def editer_declencheur(self, index: int, donnees_macro: Dict[str, Any]):
        """Modifie un déclencheur par son index. La Macro propose ses données."""
        pass

    @abstractmethod
    def lister_declencheurs(self) -> List[str]:
        """Retourne la liste des résumés des déclencheurs (une ligne chacun)."""
        pass

    # ==========================================================================
    # Gestion des actions
    # ==========================================================================

    @abstractmethod
    def ajouter_action(self, type_action: str, parametres: Dict[str, Any]):
        """Ajoute une action."""
        pass

    @abstractmethod
    def supprimer_action(self, index: int):
        """Supprime une action par son index."""
        pass

    @abstractmethod
    def editer_action(self, index: int, donnees_macro: Dict[str, Any]):
        """Modifie une action par son index. La Macro propose ses données."""
        pass

    @abstractmethod
    def lister_actions(self) -> List[str]:
        """Retourne la liste des résumés des actions (une ligne chacun)."""
        pass

    # ==========================================================================
    # Gestion des contraintes
    # ==========================================================================

    @abstractmethod
    def ajouter_contrainte(self, type_contrainte: str, parametres: Dict[str, Any]):
        """Ajoute une contrainte."""
        pass

    @abstractmethod
    def supprimer_contrainte(self, index: int):
        """Supprime une contrainte par son index."""
        pass

    @abstractmethod
    def editer_contrainte(self, index: int, donnees_macro: Dict[str, Any]):
        """Modifie une contrainte par son index. La Macro propose ses données."""
        pass

    @abstractmethod
    def lister_contraintes(self) -> List[str]:
        """Retourne la liste des résumés des contraintes (une ligne chacun)."""
        pass

    # ==========================================================================
    # Gestion de l'état d'exécution
    # ==========================================================================

    @abstractmethod
    def activer(self):
        """Marque la macro comme active."""
        pass

    @abstractmethod
    def desactiver(self):
        """Marque la macro comme inactive."""
        pass

    @abstractmethod
    def lancer(self):
        """Démarre l'exécution de la macro."""
        pass

    @abstractmethod
    def arreter(self):
        """Arrête l'exécution de la macro."""
        pass

    # ==========================================================================
    # Affichage et résumés
    # ==========================================================================

    @abstractmethod
    def lire_commentaire(self) -> str:
        """Retourne le commentaire de la macro."""
        pass

    @abstractmethod
    def lire_resume(self) -> str:
        """Retourne un résumé texte sur une ligne (pour l'affichage liste)."""
        pass

    # ==========================================================================
    # Persistance
    # ==========================================================================

    @abstractmethod
    def sauvegarder(self, chemin_fichier: str):
        """Sauvegarde la macro dans un fichier."""
        pass

    @abstractmethod
    def charger(self, chemin_fichier: str):
        """Charge la macro depuis un fichier."""
        pass
