#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: fonctions_base.py
# Description: Classe abstraite de base pour le gestionnaire de plugins
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from abc import ABC, abstractmethod
from pathlib import Path
from typing import Dict, Any, List

class Fonctions_base(ABC):
    """
    Classe abstraite définissant l'interface pour le gestionnaire de plugins.
    
    Cette classe impose que chaque gestionnaire concret implémente :
    - Le chargement des plugins depuis src/fonctions/actives/ et src/fonctions/possibles/
    - La récupération des types disponibles (déclencheurs, actions, contraintes)
    - L'instanciation des plugins par identificateur
    - La compilation vers Bash
    """
    
    @abstractmethod
    def charger_tout(self) -> bool:
        """
        Scan et chargement dynamique de tous les plugins actifs et possibles.
        
        Returns :
            True si le chargement a réussi, False en cas d'erreur critique
        """
        pass
    
    @abstractmethod
    def obtenir_declencheurs(self) -> Dict[str, str]:
        """
        Retourne le dictionnaire des déclencheurs disponibles.
        
        Returns :
            Dictionnaire {TYPE_CODE: libelle_affiche} ex: {"DEMARRAGE_APP": "Au démarrage"}
        """
        pass
    
    @abstractmethod
    def obtenir_actions(self) -> Dict[str, str]:
        """
        Retourne le dictionnaire des actions disponibles.
        
        Returns :
            Dictionnaire {TYPE_CODE: libelle_affiche} ex: {"NOTIFIER": "Notifier"}
        """
        pass
    
    @abstractmethod
    def obtenir_contraintes(self) -> Dict[str, str]:
        """
        Retourne le dictionnaire des contraintes disponibles.
        
        Returns :
            Dictionnaire {TYPE_CODE: libelle_affiche} ex: {"HEURE": "Heure actuelle"}
        """
        pass
    
    @abstractmethod
    def instancier(self, type_code: str, categorie: str, **kwargs) -> Any:
        """
        Crée une instance d'un plugin par son identificateur et sa catégorie.
        
        Args :
            type_code : identificateur du plugin (ex: "DEMARRAGE_APP", "NOTIFIER")
            categorie : "declencheur", "action" ou "contrainte"
            kwargs : paramètres optionnels spécifiques au plugin
        
        Returns :
            Instance du plugin configuré
            
        Raises :
            KeyError : si le type_code n'existe pas dans cette catégorie
        """
        pass
    
    @abstractmethod
    def obtenir_fonctions_actives(self) -> List[Any]:
        """
        Retourne la liste de toutes les instances de plugins actifs chargés.
        
        Returns :
            Liste d'instances de plugins
        """
        pass
    
    @abstractmethod
    def est_charge(self, type_code: str, categorie: str) -> bool:
        """
        Vérifie si un type de plugin est disponible dans une catégorie donnée.
        
        Args :
            type_code : identificateur du plugin
            categorie : "declencheur", "action" ou "contrainte"
        
        Returns :
            True si le type existe et est chargé
        """
        pass
    
    @abstractmethod
    def compiler_xml(self, fichier_xml: Path, fichier_sortie: Path) -> bool:
        """
        Compile un fichier XML contenant une macro en script Bash exécutable.
        
        Args :
            fichier_xml : chemin du fichier XML source
            fichier_sortie : chemin du fichier Bash destination
        
        Returns :
            True si la compilation a réussi
        """
        pass
    
    def __repr__(self) -> str:
        """Représentation textuelle du gestionnaire."""
        return f"Fonctions_base(actif={len(self.obtenir_fonctions_actives())})"
