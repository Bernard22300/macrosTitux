#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module de chargement dynamique des fonctions actives dans macrosTitux.

Ce module scanne le dossier src/fonctions/actives/ et charge
automatiquement toutes les classes de fonctions trouvées.
"""

import os
from pathlib import Path
from importlib import import_module
from typing import Dict, Type, Any

# Import absolu (compatible pytest)
from fonction_base import Fonction_de_base

# Registry global des fonctions chargées
FONCTIONS_CHARGEES: Dict[str, Type[Fonction_de_base]] = {}
FONCTIONS_INSTITANCES: Dict[str, Fonction_de_base] = {}

def obtenir_chemin_actives() -> Path:
    """Retourne le chemin absolu du dossier des fonctions actives."""
    src_dir = Path(__file__).parent
    return src_dir / "fonctions" / "actives"

def scanner_fonctions_actives() -> list[str]:
    """
    Scanne le dossier actives/ et retourne la liste des modules Python.
    
    Returns :
        Liste des noms de modules (sans .py) trouvés dans actives/
    """
    chemin = obtenir_chemin_actives()
    if not chemin.exists():
        return []
    
    modules = []
    for f in chemin.glob("*.py"):
        if f.name.startswith("_"):
            continue  # Ignore __init__.py et fichiers spéciaux
        modules.append(f.stem)
    
    return modules

def charger_fonctions() -> Dict[str, Type[Fonction_de_base]]:
    """
    Charge dynamiquement toutes les fonctions actives.
    
    Scanne le dossier actives/, importe chaque module et extrait
    la classe de fonction.
    
    Returns :
        Dictionnaire {identificateur: classe_fonction}
    """
    global FONCTIONS_CHARGEES, FONCTIONS_INSTITANCES
    FONCTIONS_CHARGEES.clear()
    FONCTIONS_INSTITANCES.clear()
    
    src_dir = Path(__file__).parent
    actives_dir = obtenir_chemin_actives()
    
    # Ajouter actives/ au sys.path pour import dynamique
    if str(actives_dir) not in [p for p in __import__('sys').path]:
        __import__('sys').path.insert(0, str(actives_dir))
    
    modules = scanner_fonctions_actives()
    
    for module_name in modules:
        try:
            module = import_module(module_name)
            
            # Trouver la classe qui hérite de Fonction_de_base
            for attr_name in dir(module):
                attr = getattr(module, attr_name)
                
                # Vérifier si c'est une classe descendant de Fonction_de_base
                if (
                    isinstance(attr, type) and 
                    issubclass(attr, Fonction_de_base) and
                    attr != Fonction_de_base
                ):
                    instance = attr()
                    FONCTIONS_INSTITANCES[instance.identificateur] = instance
                    FONCTIONS_CHARGEES[instance.identificateur] = attr
                    
                    print(f"[fonction_loader] ✓ Chargé : {instance.identificateur}")
                    
        except Exception as e:
            print(f"[fonction_loader] ✗ Erreur chargement {module_name}: {e}")
    
    return FONCTIONS_CHARGEES

def obtenir_toutes_les_fonctions() -> Dict[str, Fonction_de_base]:
    """
    Retourne toutes les instances de fonctions chargées.
    
    Returns :
        Dictionnaire {identificateur: instance_fonction}
    """
    return FONCTIONS_INSTITANCES

def obtenir_fonction(identificateur: str) -> Fonction_de_base | None:
    """
    Retourne l'instance d'une fonction par son identificateur.
    
    Args :
        identificateur : nom unique de la fonction (ex: 'DATE_DU_JOUR')
        
    Returns :
        Instance de la fonction ou None si non trouvée
    """
    return FONCTIONS_INSTITANCES.get(identificateur)

def evaluer_fonction(identificateur: str) -> Any:
    """
    Évalue une fonction et retourne sa valeur calculée.
    
    Args :
        identificateur : nom unique de la fonction
        
    Returns :
        Valeur calculée par la fonction
        
    Raises :
        KeyError : si la fonction n'est pas chargée
    """
    fonc = obtenir_fonction(identificateur)
    if not fonc:
        raise KeyError(f"Fonction '{identificateur}' non chargée")
    
    return fonc.valeur()

def est_chargee(identificateur: str) -> bool:
    """
    Vérifie si une fonction est chargée.
    
    Args :
        identificateur : nom unique de la fonction
        
    Returns :
        True si la fonction est chargée, False sinon
    """
    return identificateur in FONCTIONS_CHARGEES
