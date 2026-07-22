# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: bloc_instructions.py
# Description: Classe Bloc_Instructions fonctionnelle (hérite de Bloc_Instructions_base)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

from .bloc_instructions_base import Bloc_Instructions_base
from .instruction_base import Instruction_base
from .instruction import Instruction

class Bloc_Instructions(Bloc_Instructions_base):
    """Bloc contenant plusieurs instructions du MÊME type.
    
    Exemple d'utilisation :
        bloc_decl = Bloc_Instructions(Instruction_base.TYPE_DECLENCHEUR)
        inst = Instruction()
        inst.identificateur = "HORAIRE"
        bloc_decl.ajouter_instruction(inst)
        print(bloc_decl.compter())  # Affiche: 1
    """

    def __init__(self, type_bloc=None):
        super().__init__(type_bloc)

    # ==========================================================================
    # Identification
    # ==========================================================================

    def lire_type(self):
        """Retourne le type de ce bloc."""
        return self.type_bloc if self.type_bloc else "AUCUN"

    def lire_resume(self):
        """Retourne un résumé court sur une ligne."""
        if not self.type_bloc:
            return "Bloc (vide)"

        nb = self.compter()
        if nb == 0:
            return "{} : 0 instruction".format(self.type_bloc)
        elif nb == 1:
            return "{} : 1 instruction".format(self.type_bloc)
        else:
            return "{} : {} instructions".format(self.type_bloc, nb)

    # ==========================================================================
    # Gestion des instructions (CRUD)
    # ==========================================================================

    def ajouter_instruction(self, instruction):
        """Ajoute une instruction au bloc."""
        # Vérifie que l'instruction est du bon type
        if instruction.lire_type() != self.type_bloc:
            raise TypeError(
                "Impossible d'ajouter {} (type {}) dans un bloc {}"
                .format(
                    type(instruction).__name__,
                    instruction.lire_type(),
                    self.type_bloc
                )
            )

        self.liste_instructions.append(instruction)
        return True

    def supprimer_instruction(self, index: int):
        """Supprime une instruction par son index."""
        if 0 <= index < len(self.liste_instructions):
            del self.liste_instructions[index]
            return True
        return False

    def editer_instruction(self, index: int, donnees_macro=None):
        """Ouvre l'édition d'une instruction existante."""
        if 0 <= index < len(self.liste_instructions):
            instruction = self.liste_instructions[index]
            return instruction.editer(donnees_macro=donnees_macro)
        return False

    def obtenir_instruction(self, index: int):
        """Retourne une instruction par son index."""
        if 0 <= index < len(self.liste_instructions):
            return self.liste_instructions[index]
        raise IndexError("Index hors bornes")

    def lister_instructions(self):
        """Retourne la liste complète des instructions."""
        return self.liste_instructions.copy()

    def compter(self) -> int:
        """Retourne le nombre d'instructions dans ce bloc."""
        return len(self.liste_instructions)

    # ==========================================================================
    # Compilation
    # ==========================================================================

    def compiler_bloc(self):
        """Compile toutes les instructions du bloc en code Bash."""
        bash_code = ""
        
        for i, instruction in enumerate(self.liste_instructions):
            # Ajoute un séparateur entre les instructions
            if i > 0:
                bash_code += "\n"
            
            # Compilation individuelle
            bash_code += "# --- Instruction {} ---\n".format(i + 1)
            bash_code += instruction.compiler()
        
        return bash_code

    def exporter_bloc(self):
        """Exporte toutes les instructions du bloc."""
        return [inst.exporter() for inst in self.liste_instructions]

    def importer_bloc(self, liste_donnees_xml):
        """Charge toutes les instructions du bloc depuis XML."""
        self.liste_instructions = []  # Vide le bloc
        
        for donnees_xml in liste_donnees_xml:
            inst = Instruction()
            inst.importer(donnees_xml)
            self.ajouter_instruction(inst)  # Vérifie le type automatiquement

    # ==========================================================================
    # Utilitaires
    # ==========================================================================

    def est_vide(self):
        """Vérifie si le bloc ne contient aucune instruction."""
        return len(self.liste_instructions) == 0

    def effacer(self):
        """Supprime toutes les instructions du bloc."""
        self.liste_instructions = []

    def chercher_par_identificateur(self, identifiant_recherche: str):
        """Recherche toutes les instructions avec un identificateur donné.
        
        Args:
            identifiant_recherche: Identificateur à rechercher
            
        Retourne:
            Liste des index correspondant aux instructions trouvées
        """
        index_trouves = []
        for i, inst in enumerate(self.liste_instructions):
            if inst.identificateur == identifiant_recherche:
                index_trouves.append(i)
        return index_trouves
