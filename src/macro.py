#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module pour la gestion des macros concrètes dans macrosTitux.

Classe Macro : implémentation concrète de Macro_base.
Gère la sauvegarde, chargement et compilation des macros.
"""

from typing import Any
from pathlib import Path
from datetime import datetime

# Imports relatifs (compatibilité pytest avec sys.path)
try:
    from macro_base import Macro_base
    from instruction_declencheur_base import InstructionDeclencheur_base
    from instruction_action_base import InstructionAction_base
    from instruction_contrainte_base import InstructionContrainte_base
    from donnee_base import Donnee_base
    from fonction_base import Fonction_de_base
    import fonction_loader
except ImportError:
    from src.macro_base import Macro_base
    from src.instruction_declencheur_base import InstructionDeclencheur_base
    from src.instruction_action_base import InstructionAction_base
    from src.instruction_contrainte_base import InstructionContrainte_base
    from src.donnee_base import Donnee_base
    from src.fonction_base import Fonction_de_base
    from src import fonction_loader

class Macro(Macro_base):
    """
    Classe concrète représentant une macro complète.
    
    Hérète de Macro_base et implémente :
        - compiler() : génère le script Bash
        - exporter() : sérialisation en dict (pour XML)
    """
    
    def __init__(self, nom: str = "") -> None:
        """
        Initialise une nouvelle macro concrète.
        
        Args :
            nom : nom de la macro (optionnel)
        """
        super().__init__(nom=nom)
    
    def compiler(self) -> str:
        """
        Génère le script Bash complet de cette macro.
        
        Structure :
            #!/bin/bash
            # Commentaire : nom, déclencheurs, actions, contraintes
            # Code compilé des déclencheurs
            # Code compilé des contraintes
            # Code compilé des actions
        """
        lignes = []
        
        # En-tête
        lignes.append("#!/bin/bash")
        lignes.append(f"# Macro : {self._nom}")
        lignes.append(f"# Généré le : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lignes.append("")
        
        # Compilation des déclencheurs
        if self._declencheurs:
            lignes.append("# === DÉCLENCHEURS ===")
            for decl in self._declencheurs:
                code = decl.compiler()
                if code:
                    lignes.append(code)
            lignes.append("")
        
        # Compilation des contraintes
        if self._contraintes:
            lignes.append("# === CONTRAINTES ===")
            for contr in self._contraintes:
                code = contr.compiler()
                if code:
                    lignes.append(f"if [ {code} ]; then")
                    # Les actions seront indentées plus tard
            lignes.append("# Fin des contraintes")
            # Note: l'indentation sera gérée par le compilateur réel
        
        # Compilation des actions
        if self._actions:
            lignes.append("# === ACTIONS ===")
            for act in self._actions:
                code = act.compiler()
                if code:
                    lignes.append(code)
        
        return "\n".join(lignes)
    
    def exporter(self) -> dict[str, Any]:
        """
        Exporte cette macro au format dictionnaire.
        
        Returns :
            Dictionnaire structuré pour sérialisation XML
        """
        return {
            "nom": self._nom,
            "declencheurs": [d.exporter() for d in self._declencheurs],
            "actions": [a.exporter() for a in self._actions],
            "contraintes": [c.exporter() for c in self._contraintes],
            "donnees": [d.exporter() for d in self._donnees],
            "resume": self.obtenir_resume()
        }
    
    def verifier_macre_valide(self) -> tuple[bool, list[str]]:
        """
        Vérifie si la macro est valide (avoir au moins un déclencheur + une action).
        
        Returns :
            Tuple (est_valide, liste_erreurs)
        """
        erreurs = []
        
        if not self._nom:
            erreurs.append("La macro n'a pas de nom")
        
        if not self._declencheurs:
            erreurs.append("La macro n'a aucun déclencheur")
        
        if not self._actions:
            erreurs.append("La macro n'a aucune action")
        
        return len(erreurs) == 0, erreurs
    
    def __repr__(self) -> str:
        """Représentation textuelle pour débogage."""
        return f"Macro(nom='{self._nom}', déclencheurs={len(self._declencheurs)}, actions={len(self._actions)}, contraintes={len(self._contraintes)})"

# ============================================================================
# FONCTIONS UTILITAIRES
# ============================================================================

def creer_macre_vide(nom: str = "Nouvelle_Macro") -> Macro:
    """
    Crée une nouvelle macro vide prête à être configurée.
    
    Args :
        nom : nom de la macro
        
    Returns :
        Instance de Macro vierge
    """
    return Macro(nom=nom)

def importer_macro_de_dict(donnees: dict[str, Any]) -> Macro:
    """
    Importe une macro depuis un dictionnaire (XML/JSON déserialisé).
    
    Args :
        donnees : dictionnaire contenant les infos de la macro
        
    Returns :
        Instance de Macro reconstruite
    """
    macro = Macro(nom=donnees.get("nom", ""))
    
    # Note: la reconstruction des déclencheurs/actions nécessite le système
    # de plugin, donc c'est à implémenter ultérieurement
    
    return macro
