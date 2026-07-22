#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module pour la gestion des fonctions reutilisables dans macrosTitux.

Classe Fonction_de_base : interface abstraite pour toutes les fonctions.
Une fonction fournit une valeur calculee dynamiquement utilisable par
les declencheurs, actions et contraintes.

Les implementations concretes vivent dans src/fonctions/possibles/ (plugins).
Les fonctions activees sont copiees dans src/fonctions/actives/ et chargees
dynamiquement au demarrage de l'application.

ATTENTION : Aucune fonction n'est pre-definie ici.
Les fonctions disponibles sont gerees via le systeme de plugins.
"""

from abc import ABC, abstractmethod
from typing import Any

class Fonction_de_base(ABC):
    """
    Classe abstraite de base pour toutes les fonctions reutilisables.
    
    Une fonction fournit une valeur calculee dynamiquement qui peut etre
    utilisee par les declencheurs, actions et contraintes.
    
    Services minimums a implementer par les sous-classes :
        valeur() : retourne la valeur calculee
        identificateur : nom unique de la fonction (passe au constructeur)
        description : description humaine de ce que fait la fonction
    
    Attributs :
        _identificateur (str) : nom unique de la fonction
        _description (str) : description pour l'affichage
    """
    
    def __init__(self, identificateur: str, description: str = "") -> None:
        """
        Initialise une nouvelle fonction.
        
        Args :
            identificateur : nom unique de la fonction (ex: 'DATE_DU_JOUR')
            description : description humaine (ex: 'Retourne la date du jour')
        """
        self._identificateur: str = identificateur
        self._description: str = description
    
    @property
    def identificateur(self) -> str:
        """Retourne l'identificateur unique de la fonction."""
        return self._identificateur
    
    @property
    def description(self) -> str:
        """Retourne la description de la fonction."""
        return self._description
    
    @abstractmethod
    def valeur(self) -> Any:
        """
        RETOURNE LA VALEUR CALCULEE PAR CETTE FONCTION.
        
        Cette methode doit etre implementee par chaque sous-classe
        pour definir la logique de calcul de la valeur.
        
        Returns :
            La valeur calculee (str, int, bool, etc.)
        
        Exemple :
            - Date_du_jour : retourne "2026-07-22"
            - Heure_actuelle : retourne "18:15"
            - Utilisateur_courant : retourne "bernard"
        """
        pass
    
    def obtenir_resume(self) -> str:
        """
        Retourne un resume court pour affichage dans la GUI.
        
        Format : "[IDENTIFICATEUR] description"
        
        Returns :
            Chaine resumeant la fonction
        """
        return f"[{self._identificateur}] {self._description}"
    
    def exporter(self) -> dict[str, Any]:
        """
        Exporte cette fonction au format dictionnaire.
        
        Utilise pour la serialisation (XML, JSON, etc.)
        
        Returns :
            Dictionnaire avec 'identificateur' et 'description'
        """
        return {
            "identificateur": self._identificateur,
            "description": self._description
        }
    
    def __repr__(self) -> str:
        """Representation textuelle pour debogage."""
        return f"{self.__class__.__name__}(identificateur='{self._identificateur}')"

# ============================================================================
# PAS DE FONCTIONS PRE-DEFINIES ICI - GERE VIA LE SYSTEME DE PLUGINS
# ============================================================================
# Les fonctions concretes vivent dans src/fonctions/possibles/
# Les fonctions activees sont dans src/fonctions/actives/
# Le chargement dynamique se fait au demarrage de l'application.
