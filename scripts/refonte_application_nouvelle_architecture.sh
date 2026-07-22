#!/bin/bash
# =============================================================================
# refonte_application_nouvelle_architecture.sh
# Refonte complète de src/macro_base.py et src/macro.py avec les nouveaux types
# =============================================================================

set -e

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJET="$(dirname "$SCRIPTS_DIR")"
SRC="$PROJET/src"

ROUGE='\033[0;31m'
VERT='\033[0;32m'
JAUNE='\033[1;33m'
NEUTRE='\033[0m'

echo -e "${JAUNE}[refonte] Démarrage de la refonte architecture v0.4c${NEUTRE}"
echo -e "${JAUNE}[refonte] Projet: $PROJET${NEUTRE}"
echo ""

# ------------------------------------------------------------------------------
# Génération de src/macro_base.py (classe abstraite)
# ------------------------------------------------------------------------------
echo -e "${VERT}[refonte] Création ${SRC}/macro_base.py${NEUTRE}"

cat > "$SRC/macro_base.py" <<'MACRO_BASE'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module pour la gestion des macros abstraites dans macrosTitux.

Classe Macro_base : interface abstraite pour toutes les macros.
Une macro regroupe des déclencheurs, actions et contraintes.
"""

from abc import ABC, abstractmethod
from typing import List, Any
from pathlib import Path

# Imports relatifs (compatibilité pytest avec sys.path)
try:
    from instruction_declencheur_base import InstructionDeclencheur_base
    from instruction_action_base import InstructionAction_base
    from instruction_contrainte_base import InstructionContrainte_base
    from donnee_base import Donnee_base
except ImportError:
    from src.instruction_declencheur_base import InstructionDeclencheur_base
    from src.instruction_action_base import InstructionAction_base
    from src.instruction_contrainte_base import InstructionContrainte_base
    from src.donnee_base import Donnee_base

class Macro_base(ABC):
    """
    Classe abstraite de base pour toutes les macros.
    
    Une macro est un ensemble de :
        - Déclencheurs : définissent QUAND la macro s'exécute
        - Actions : définissent QUOI faire quand elle s'exécute
        - Contraintes : conditions à respecter pour l'exécution
    
    Méthodes abstraites à implémenter :
        compiler() : génère le script Bash correspondant
        exporter() : sérialisation au format XML/JSON
    """
    
    def __init__(self, nom: str = "") -> None:
        """
        Initialise une nouvelle macro.
        
        Args :
            nom : nom de la macro (optionnel)
        """
        self._nom: str = nom
        self._declencheurs: List[InstructionDeclencheur_base] = []
        self._actions: List[InstructionAction_base] = []
        self._contraintes: List[InstructionContrainte_base] = []
        self._donnees: List[Donnee_base] = []
    
    @property
    def nom(self) -> str:
        """Retourne le nom de la macro."""
        return self._nom
    
    @nom.setter
    def nom(self, valeur: str) -> None:
        """Définit le nom de la macro."""
        self._nom = valeur
    
    def obtenir_declencheurs(self) -> List[InstructionDeclencheur_base]:
        """Retourne la liste des déclencheurs."""
        return self._declencheurs.copy()
    
    def obtenir_actions(self) -> List[InstructionAction_base]:
        """Retourne la liste des actions."""
        return self._actions.copy()
    
    def obtenir_contraintes(self) -> List[InstructionContrainte_base]:
        """Retourne la liste des contraintes."""
        return self._contraintes.copy()
    
    def obtenir_donnees(self) -> List[Donnee_base]:
        """Retourne la liste des données."""
        return self._donnees.copy()
    
    def ajouter_declencheur(self, declencheur: InstructionDeclencheur_base) -> None:
        """
        Ajoute un déclencheur à la macro.
        
        Args :
            declencheur : instance d'un déclencheur (hérite de InstructionDeclencheur_base)
        """
        if not isinstance(declencheur, InstructionDeclencheur_base):
            raise TypeError("Doit être une instance de InstructionDeclencheur_base")
        self._declencheurs.append(declencheur)
    
    def ajouter_action(self, action: InstructionAction_base) -> None:
        """
        Ajoute une action à la macro.
        
        Args :
            action : instance d'une action (hérite de InstructionAction_base)
        """
        if not isinstance(action, InstructionAction_base):
            raise TypeError("Doit être une instance de InstructionAction_base")
        self._actions.append(action)
    
    def ajouter_contrainte(self, contrainte: InstructionContrainte_base) -> None:
        """
        Ajoute une contrainte à la macro.
        
        Args :
            contrainte : instance d'une contrainte (hérite de InstructionContrainte_base)
        """
        if not isinstance(contrainte, InstructionContrainte_base):
            raise TypeError("Doit être une instance de InstructionContrainte_base")
        self._contraintes.append(contrainte)
    
    def ajouter_donnee(self, donnee: Donnee_base) -> None:
        """
        Ajoute une donnée à la macro.
        
        Args :
            donnee : instance d'une donnée (hérite de Donnee_base)
        """
        if not isinstance(donnee, Donnee_base):
            raise TypeError("Doit être une instance de Donnee_base")
        self._donnees.append(donnee)
    
    @abstractmethod
    def compiler(self) -> str:
        """
        GÉNÈRE LE CODE BASH COMPLET DE CETTE MACRO.
        
        Cette méthode doit être implémentée pour chaque type de macro
        afin de produire le code Bash approprié.
        
        Returns :
            Chaîne de caractères contenant le script Bash complet
        
        Exemple :
            #!/bin/bash
            # Macro: Test
            # Déclencheur: DEMARRAGE
            notify-send "Bonjour" "Monde"
        """
        pass
    
    @abstractmethod
    def exporter(self) -> dict[str, Any]:
        """
        Exporte cette macro au format dictionnaire.
        
        Utilisé pour la sérialisation (XML, JSON, etc.)
        
        Returns :
            Dictionnaire contenant toutes les infos de la macro
        """
        pass
    
    def obtenir_resume(self) -> str:
        """
        Retourne un résumé court de la macro.
        
        Format : "[NOM] X déclencheur(s), Y action(s), Z contrainte(s)"
        
        Returns :
            Chaîne résumant la macro
        """
        return (
            f"[{self._nom}] {len(self._declencheurs)} déclencheur(s), "
            f"{len(self._actions)} action(s), {len(self._contraintes)} contrainte(s)"
        )
    
    def __repr__(self) -> str:
        """Représentation textuelle pour débogage."""
        return f"Macro(nom='{self._nom}', déclencheurs={len(self._declencheurs)}, actions={len(self._actions)})"
MACRO_BASE

# ------------------------------------------------------------------------------
# Génération de src/macro.py (classe concrète)
# ------------------------------------------------------------------------------
echo -e "${VERT}[refonte] Création ${SRC}/macro.py${NEUTRE}"

cat > "$SRC/macro.py" <<'MACRO_CONCRETE'
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
MACRO_CONCRETE

# ------------------------------------------------------------------------------
# Vérifications finales
# ------------------------------------------------------------------------------
echo ""
echo -e "${JAUNE}[refonte] Vérification des fichiers générés...${NEUTRE}"

if [ -f "$SRC/macro_base.py" ]; then
    echo -e "  ${VERT}✓${NEUTRE} $SRC/macro_base.py"
else
    echo -e "  ${ROUGE}✗${NEUTRE} $SRC/macro_base.py non trouvé"
    exit 1
fi

if [ -f "$SRC/macro.py" ]; then
    echo -e "  ${VERT}✓${NEUTRE} $SRC/macro.py"
else
    echo -e "  ${ROUGE}✗${NEUTRE} $SRC/macro.py non trouvé"
    exit 1
fi

echo ""
echo -e "${VERT}[refonte] ==========================================${NEUTRE}"
echo -e "${VERT}[refonte]  REFINTE ARCHITECTURE TERMINÉE${NEUTRE}"
echo -e "${VERT}[refonte] ==========================================${NEUTRE}"
echo ""
echo "Fichiers générés :"
echo "  - $SRC/macro_base.py (classe abstraite Macro_base)"
echo "  - $SRC/macro.py (classe concrète Macro)"
echo ""
echo "Prochaine étape recommandée :"
echo "  ./scripts/sauvegarder_projet.sh \"Refonte architecture - macro_base.py + macro.py\""
