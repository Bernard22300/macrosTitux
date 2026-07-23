#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: fonctions.py
# Description: Gestionnaire central de plugins (déclencheurs, actions, contraintes)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from pathlib import Path
from importlib import import_module
from typing import Dict, Any, List, Type
import sys

from fonctions_base import Fonctions_base
from instruction_declencheur_base import InstructionDeclencheur_base
from instruction_action_base import InstructionAction_base
from instruction_contrainte_base import InstructionContrainte_base


class Functions(Fonctions_base):
    """
    Gestionnaire concret de plugins pour macrosTitux.
    
    Scanne dynamiquement src/fonctions/actives/ et src/fonctions/possibles/,
    charge les classes et les expose via des méthodes d'accès typées.
    """
    
    def __init__(self) -> None:
        """Initialise les registres vides."""
        self._declencheurs: Dict[str, Type[InstructionDeclencheur_base]] = {}
        self._actions: Dict[str, Type[InstructionAction_base]] = {}
        self._contraintes: Dict[str, Type[InstructionContrainte_base]] = {}
        
        self._instances_declencheurs: Dict[str, InstructionDeclencheur_base] = {}
        self._instances_actions: Dict[str, InstructionAction_base] = {}
        self._instances_contraintes: Dict[str, InstructionContrainte_base] = {}
        
        self._charge = False
        self._dossier_actives: Path = Path(__file__).parent / "fonctions" / "actives"
        self._dossier_possibles: Path = Path(__file__).parent / "fonctions" / "possibles"
    
    def charger_tout(self) -> bool:
        """
        Scan et chargement dynamique de tous les plugins.
        
        Returns :
            True si le chargement a réussi
        """
        if self._charge:
            return True
        
        try:
            # Ajouter le dossier actives/ au path pour imports relatifs
            actives_str = str(self._dossier_actives.resolve())
            if actives_str not in sys.path:
                sys.path.insert(0, actives_str)
            
            # Charger les plugins actifs
            if self._dossier_actives.exists():
                for f in self._dossier_actives.glob("*.py"):
                    if f.name.startswith("_"):
                        continue
                    self._charger_module(f.stem, "actif")
            
            # Charger les plugins possibles (optionnel)
            if self._dossier_possibles.exists():
                for f in self._dossier_possibles.glob("*.py"):
                    if f.name.startswith("_"):
                        continue
                    self._charger_module(f.stem, "possible")
            
            self._charge = True
            print(f"[Functions] ✓ Chargement terminé : {self.nb_total()} plugins")
            return True
            
        except Exception as e:
            print(f"[Functions] ✗ Erreur chargement: {e}")
            return False
    
    def _charger_module(self, module_name: str, statut: str) -> None:
        """
        Charge un module Python et extrait ses classes.
        
        Args :
            module_name : nom du module (sans .py)
            statut : "actif" ou "possible"
        """
        try:
            module = import_module(module_name)
            
            # Examiner toutes les attributs du module
            for attr_name in dir(module):
                attr = getattr(module, attr_name)
                
                # Identifier les classes héritant des bases appropriées
                if (isinstance(attr, type) and 
                    issubclass(attr, InstructionDeclencheur_base) and
                    attr != InstructionDeclencheur_base):
                    instance = attr()
                    self._declencheurs[instance.identificateur] = attr
                    self._instances_declencheurs[instance.identificateur] = instance
                    print(f"[Functions] ✓ {statut} Declencheur: {instance.identificateur}")
                
                elif (isinstance(attr, type) and 
                      issubclass(attr, InstructionAction_base) and
                      attr != InstructionAction_base):
                    instance = attr()
                    self._actions[instance.identificateur] = attr
                    self._instances_actions[instance.identificateur] = instance
                    print(f"[Functions] ✓ {statut} Action: {instance.identificateur}")
                
                elif (isinstance(attr, type) and 
                      issubclass(attr, InstructionContrainte_base) and
                      attr != InstructionContrainte_base):
                    instance = attr()
                    self._contraintes[instance.identificateur] = attr
                    self._instances_contraintes[instance.identificateur] = instance
                    print(f"[Functions] ✓ {statut} Contrainte: {instance.identificateur}")
                    
        except Exception as e:
            print(f"[Functions] ✗ Erreur chargement {module_name}: {e}")
    
    def obtenir_declencheurs(self) -> Dict[str, str]:
        """Retourne {TYPE_CODE: libelle} pour les déclencheurs."""
        return {
            ident: inst.libelle
            for ident, inst in self._instances_declencheurs.items()
        }
    
    def obtenir_actions(self) -> Dict[str, str]:
        """Retourne {TYPE_CODE: libelle} pour les actions."""
        return {
            ident: inst.libelle
            for ident, inst in self._instances_actions.items()
        }
    
    def obtenir_contraintes(self) -> Dict[str, str]:
        """Retourne {TYPE_CODE: libelle} pour les contraintes."""
        return {
            ident: inst.libelle
            for ident, inst in self._instances_contraintes.items()
        }
    
    def instancier(self, type_code: str, categorie: str, **kwargs) -> Any:
        """
        Crée une instance d'un plugin.
        
        Args :
            type_code : identificateur (ex: "DEMARRAGE_APP")
            categorie : "declencheur", "action" ou "contrainte"
            kwargs : paramètres pour l'initialisation
        
        Returns :
            Instance configurée
        
        Raises :
            KeyError : si le type n'existe pas dans cette catégorie
        """
        if categorie == "declencheur":
            classe = self._declencheurs.get(type_code)
            if not classe:
                raise KeyError(f"Declencheur '{type_code}' inexistant")
            return classe(**kwargs)
        
        elif categorie == "action":
            classe = self._actions.get(type_code)
            if not classe:
                raise KeyError(f"Action '{type_code}' inexistante")
            return classe(**kwargs)
        
        elif categorie == "contrainte":
            classe = self._contraintes.get(type_code)
            if not classe:
                raise KeyError(f"Contrainte '{type_code}' inexistante")
            return classe(**kwargs)
        
        else:
            raise ValueError(f"Categorie invalide: {categorie}")
    
    def obtenir_fonctions_actives(self) -> List[Any]:
        """Retourne toutes les instances chargées."""
        return (
            list(self._instances_declencheurs.values()) +
            list(self._instances_actions.values()) +
            list(self._instances_contraintes.values())
        )
    
    def est_charge(self, type_code: str, categorie: str) -> bool:
        """Vérifie si un type est disponible."""
        if categorie == "declencheur":
            return type_code in self._declencheurs
        elif categorie == "action":
            return type_code in self._actions
        elif categorie == "contrainte":
            return type_code in self._contraintes
        return False
    
    def nb_total(self) -> int:
        """Nombre total de plugins chargés."""
        return len(self._declencheurs) + len(self._actions) + len(self._contraintes)
    
    def compiler_xml(self, fichier_xml: Path, fichier_sortie: Path) -> bool:
        """
        Compile un XML en Bash.
        
        Délegation au script generate_bash.sh pour l'instant.
        À réimplémenter en Python pure plus tard.
        """
        import subprocess
        
        generate_script = Path(__file__).parent / "generate_bash.sh"
        try:
            result = subprocess.run(
                [str(generate_script), str(fichier_xml), str(fichier_sortie)],
                capture_output=True,
                text=True,
                timeout=30
            )
            return result.returncode == 0
        except Exception as e:
            print(f"[Functions] Erreur compilation: {e}")
            return False
    
    def __repr__(self) -> str:
        return (f"Functions(decl={len(self._declencheurs)}, "
                f"act={len(self._actions)}, con={len(self._contraintes)})")


# Instance globale singleton pour compatibilité
_GESTIONNAIRE_FONCTIONS: Functions | None = None

def obtenir_gestionnaire_fonctions() -> Functions:
    """
    Retourne l'instance singleton du gestionnaire.
    
    Charge automatiquement les plugins au premier appel.
    """
    global _GESTIONNAIRE_FONCTIONS
    if _GESTIONNAIRE_FONCTIONS is None:
        _GESTIONNAIRE_FONCTIONS = Functions()
        _GESTIONNAIRE_FONCTIONS.charger_tout()
    return _GESTIONNAIRE_FONCTIONS
