"""
Module pour la gestion des données concrètes dans macrosTitux.

Classe Donnée : implémentation concrète de Donnee_base.
Utilisée pour stocker les déclencheurs, actions et contraintes.
"""

from typing import Any
from donnee_base import Donnee_base

class Donnee(Donnee_base):
    """
    Classe concrète représentant une donnée dans une macro.
    
    Une donnée contient un identificateur (type d'instruction) 
    et des arguments spécifiques à ce type.
    
    Attributs :
        _identificateur (str) : type de la donnée (ex: 'NOTIFIER', 'NAMED_PIPE')
        _arguments (dict[str, Any]) : paramètres spécifiques à cette donnée
    """
    
    def __init__(self, identificateur: str, arguments: dict[str, Any] | None = None) -> None:
        """
        Initialise une nouvelle donnée.
        
        Args :
            identificateur : type de la donnée (doit correspondre à un type enregistré)
            arguments : dictionnaire des paramètres (vide par défaut)
        """
        super().__init__()
        self._identificateur: str = identificateur
        self._arguments: dict[str, Any] = arguments.copy() if arguments else {}
    
    @property
    def identificateur(self) -> str:
        """Retourne l'identificateur (type) de cette donnée."""
        return self._identificateur
    
    @property
    def arguments(self) -> dict[str, Any]:
        """Retourne le dictionnaire des arguments de cette donnée."""
        return self._arguments
    
    def obtenir_valeur(self, cle: str, valeur_par_defaut: Any = None) -> Any:
        """
        Retourne la valeur d'un argument spécifique.
        
        Args :
            cle : clé de l'argument à récupérer
            valeur_par_defaut : valeur retournée si la clé n'existe pas
            
        Returns :
            La valeur associée à la clé, ou valeur_par_defaut
        """
        return self._arguments.get(cle, valeur_par_defaut)
    
    def definir_valeur(self, cle: str, valeur: Any) -> None:
        """
        Définit ou modifie la valeur d'un argument.
        
        Args :
            cle : clé de l'argument
            valeur : nouvelle valeur à assigner
        """
        self._arguments[cle] = valeur
    
    def obtenir_resume(self) -> str:
        """
        Retourne un résumé court de cette donnée pour affichage GUI.
        
        Format : "[identificateur] arg1=val1, arg2=val2"
        
        Returns :
            Chaîne de caractères résumant la donnée
        """
        if not self._arguments:
            return f"[{self._identificateur}]"
        
        arguments_reduits = ", ".join(
            f"{cle}={valeur}" 
            for cle, valeur in self._arguments.items()
        )
        return f"[{self._identificateur}] {arguments_reduits}"
    
    def exporter(self) -> dict[str, Any]:
        """
        Exporte cette donnée au format dictionnaire (pour sérialisation XML/JSON).
        
        Returns :
            Dictionnaire contenant identificateur et arguments
        """
        return {
            "identificateur": self._identificateur,
            "arguments": self._arguments.copy()
        }
    
    def __eq__(self, autre: object) -> bool:
        """
        Vérifie l'égalité entre deux données.
        
        Deux données sont égales si elles ont même identificateur 
        et mêmes arguments.
        """
        if not isinstance(autre, Donnee):
            return False
        
        return (
            self._identificateur == autre._identificateur and
            self._arguments == autre._arguments
        )
    
    def __repr__(self) -> str:
        """Représentation textuelle pour débogage."""
        return f"Donnee(identificateur='{self._identificateur}', arguments={self._arguments})"

# ============================================================================
# FONCTIONS UTILITAIRES POUR LA CONVERSION (compatibilité avec ancienne version)
# ============================================================================

def convertir_en_donnee(
    identificateur: str, 
    arguments: dict[str, Any] | None = None
) -> Donnee:
    """
    Fonction utilitaire pour créer une nouvelle instance de Donnee.
    
    Permet de simplifier la création de données depuis d'autres modules.
    
    Args :
        identificateur : type de la donnée
        arguments : paramètres spécifiques
        
    Returns :
        Nouvelle instance de Donnee
    """
    return Donnee(identificateur=identificateur, arguments=arguments)

def convertir_de_tuple(tuple_data: tuple[str, dict[str, Any]]) -> Donnee:
    """
    Convertit un tuple (identificateur, arguments) en objet Donnee.
    
    Utile pour migrer d'anciennes structures de données vers la nouvelle.
    
    Args :
        tuple_data : tuple contenant (identificateur, arguments_dict)
        
    Returns :
        Instance de Donnee correspondante
    """
    identificateur, arguments = tuple_data
    return Donnee(identificateur=identificateur, arguments=arguments)
