# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: instruction.py
# Description: Classe Instruction fonctionnelle (hérite de Instruction_base)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from .instruction_base import Instruction_base

class Instruction(Instruction_base):
    """Instruction fonctionnelle : implémente le contrat défini par Instruction_base.
    
    Cette classe générique peut représenter n'importe quelle instruction.
    Le comportement exact dépend de la valeur de 'identificateur'.
    
    Exemple d'utilisation :
        inst = Instruction()
        inst.identificateur = "HORAIRE"
        inst.arguments = {"heure": "8", "minute": "0"}
        print(inst.lire_resume())
    """

    def __init__(self):
        super().__init__()

    # ==========================================================================
    # Identification
    # ==========================================================================

    def lire_type(self):
        """Retourne le type de cette instruction."""
        return self.identificateur if self.identificateur else "AUCUN"

    def lire_resume(self):
        """Retourne un résumé court sur une ligne pour affichage liste."""
        if not self.identificateur:
            return "(Non défini)"

        resume = self.identificateur

        # Ajoute les arguments principaux au résumé
        if self.arguments:
            args_str = ", ".join([
                "{}={}".format(k, v)
                for k, v in list(self.arguments.items())[:3]
            ])
            resume += " ({})".format(args_str)

        return resume

    # ==========================================================================
    # Édition
    # ==========================================================================

    def editer(self, donnees_macro=None):
        """Ouvre l'édition de cette instruction.
        
        TODO: À implémenter avec Tkinter - dialogue interactif
        
        Args:
            donnees_macro: Dictionnaire des données disponibles.
        """
        print("Édition de l'instruction: {}".format(self.identificateur))
        print("  Arguments actuels: {}".format(self.arguments))
        print("  Données Macro disponibles: {}".format(
            list(donnees_macro.keys()) if donnees_macro else []
        ))
        return True

    def importer(self, donnees_xml):
        """Charge cette instruction depuis un dictionnaire XML."""
        self.identificateur = donnees_xml.get("identificateur", "")
        self.arguments = donnees_xml.get("arguments", {}).copy()
        self.commentaire = donnees_xml.get("commentaire", "")

    def exporter(self):
        """Exporte cette instruction vers un dictionnaire XML."""
        return {
            "identificateur": self.identificateur,
            "arguments": self.arguments.copy() if self.arguments else {},
            "commentaire": self.commentaire
        }

    # ==========================================================================
    # Compilation
    # ==========================================================================

    def compiler(self):
        """Compile cette instruction en code Bash.
        
        TODO: À implémenter avec une logique selon l'identificateur
        """
        if not self.identificateur:
            return "# Instruction non définie\n"

        bash_code = "# {}: {}\n".format(
            self.identificateur,
            self.arguments
        )

        # TODO: Logique spécifique selon l'identificateur
        # Exemple: HORAIRE → cron, NOTIFIER → notify-send

        return bash_code

    # ==========================================================================
    # Utilitaires
    # ==========================================================================

    def est_complet(self):
        """Vérifie si l'instruction a toutes les informations nécessaires."""
        return bool(self.identificateur)

    def obtenir_argument(self, cle, defaut=None):
        """Retourne un argument par sa clé."""
        return self.arguments.get(cle, defaut)

    def definir_argument(self, cle, valeur):
        """Modifie un argument."""
        self.arguments[cle] = valeur

    def supprimer_argument(self, cle):
        """Supprime un argument."""
        if cle in self.arguments:
            del self.arguments[cle]
