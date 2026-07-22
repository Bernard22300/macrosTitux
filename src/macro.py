# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: macro.py
# Description: Classe Macro fonctionnelle (hérite de Macro_base)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import json
from typing import List, Dict, Any
from .macro_base import Macro_base

class Macro(Macro_base):
    """Macro fonctionnelle : implémente le contrat défini par Macro_base."""

    # -------------------------------------------------------------------------
    # Constructeur
    # -------------------------------------------------------------------------

    def __init__(self):
        super().__init__()
        self.chemin_fichier = None

    # -------------------------------------------------------------------------
    # Gestion des données
    # -------------------------------------------------------------------------

    def ajouter_donnee(self, cle: str, type_donnee: str, valeur_par_defaut: Any):
        """Ajoute une donnée dans la macro."""
        donnee = {
            "cle": cle,
            "type": type_donnee,
            "valeur": valeur_par_defaut
        }
        self.liste_donnees.append(donnee)

    def supprimer_donnee(self, index: int):
        """Supprime une donnée par son index."""
        if 0 <= index < len(self.liste_donnees):
            del self.liste_donnees[index]

    def editer_donnee(self, index: int, nouvelle_valeur: Any):
        """Modifie une donnée par son index."""
        if 0 <= index < len(self.liste_donnees):
            self.liste_donnees[index]["valeur"] = nouvelle_valeur

    def lister_donnees(self) -> List[Dict[str, Any]]:
        """Retourne la liste complète des données."""
        return self.liste_donnees.copy()

    # -------------------------------------------------------------------------
    # Gestion des déclencheurs
    # -------------------------------------------------------------------------

    def ajouter_declencheur(self, type_declencheur: str, parametres: Dict[str, Any]):
        """Ajoute un déclencheur."""
        declencheur = {
            "type": type_declencheur,
            "params": parametres.copy() if parametres else {}
        }
        self.liste_declencheurs.append(declencheur)

    def supprimer_declencheur(self, index: int):
        """Supprime un déclencheur par son index."""
        if 0 <= index < len(self.liste_declencheurs):
            del self.liste_declencheurs[index]

    def editer_declencheur(self, index: int, donnees_macro: Dict[str, Any]):
        """Modifie un déclencheur par son index. La Macro propose ses données."""
        # TODO: Ouvrir dialogue d'édition avec contexte des données
        pass

    def lister_declencheurs(self) -> List[str]:
        """Retourne la liste des résumés des déclencheurs (une ligne chacun)."""
        resumes = []
        for d in self.liste_declencheurs:
            resume = "{}: {}".format(d["type"], d["params"])
            resumes.append(resume)
        return resumes

    # -------------------------------------------------------------------------
    # Gestion des actions
    # -------------------------------------------------------------------------

    def ajouter_action(self, type_action: str, parametres: Dict[str, Any]):
        """Ajoute une action."""
        action = {
            "type": type_action,
            "params": parametres.copy() if parametres else {}
        }
        self.liste_actions.append(action)

    def supprimer_action(self, index: int):
        """Supprime une action par son index."""
        if 0 <= index < len(self.liste_actions):
            del self.liste_actions[index]

    def editer_action(self, index: int, donnees_macro: Dict[str, Any]):
        """Modifie une action par son index. La Macro propose ses données."""
        # TODO: Ouvrir dialogue d'édition avec contexte des données
        pass

    def lister_actions(self) -> List[str]:
        """Retourne la liste des résumés des actions (une ligne chacun)."""
        resumes = []
        for a in self.liste_actions:
            resume = "{}: {}".format(a["type"], a["params"])
            resumes.append(resume)
        return resumes

    # -------------------------------------------------------------------------
    # Gestion des contraintes
    # -------------------------------------------------------------------------

    def ajouter_contrainte(self, type_contrainte: str, parametres: Dict[str, Any]):
        """Ajoute une contrainte."""
        contrainte = {
            "type": type_contrainte,
            "params": parametres.copy() if parametres else {}
        }
        self.liste_contraintes.append(contrainte)

    def supprimer_contrainte(self, index: int):
        """Supprime une contrainte par son index."""
        if 0 <= index < len(self.liste_contraintes):
            del self.liste_contraintes[index]

    def editer_contrainte(self, index: int, donnees_macro: Dict[str, Any]):
        """Modifie une contrainte par son index. La Macro propose ses données."""
        # TODO: Ouvrir dialogue d'édition avec contexte des données
        pass

    def lister_contraintes(self) -> List[str]:
        """Retourne la liste des résumés des contraintes (une ligne chacun)."""
        resumes = []
        for c in self.liste_contraintes:
            resume = "{}: {}".format(c["type"], c["params"])
            resumes.append(resume)
        return resumes

    # -------------------------------------------------------------------------
    # Gestion de l'état d'exécution
    # -------------------------------------------------------------------------

    def activer(self):
        """Marque la macro comme active."""
        self.est_actif = True

    def desactiver(self):
        """Marque la macro comme inactive."""
        self.est_actif = False

    def lancer(self):
        """Démarre l'exécution de la macro."""
        if not self.est_actif:
            return
        self.en_cours = True

    def arreter(self):
        """Arrête l'exécution de la macro."""
        self.en_cours = False

    # -------------------------------------------------------------------------
    # Affichage et résumés
    # -------------------------------------------------------------------------

    def lire_commentaire(self) -> str:
        """Retourne le commentaire de la macro."""
        return self.commentaire

    def lire_resume(self) -> str:
        """Retourne un résumé texte sur une ligne (pour l'affichage liste)."""
        nb_declencheurs = len(self.liste_declencheurs)
        nb_actions = len(self.liste_actions)
        return "{} : {} déclencheur(s), {} action(s)".format(
            self.nom,
            nb_declencheurs,
            nb_actions
        )

    # -------------------------------------------------------------------------
    # Persistance
    # -------------------------------------------------------------------------

    def sauvegarder(self, chemin_fichier: str):
        """Sauvegarde la macro dans un fichier."""
        donnees = {
            "nom": self.nom,
            "commentaire": self.commentaire,
            "liste_donnees": self.liste_donnees,
            "liste_declencheurs": self.liste_declencheurs,
            "liste_actions": self.liste_actions,
            "liste_contraintes": self.liste_contraintes,
            "est_actif": self.est_actif,
            "en_cours": self.en_cours
        }

        with open(chemin_fichier, "w", encoding="utf-8") as f:
            json.dump(donnees, f, ensure_ascii=False, indent=2)

        self.chemin_fichier = chemin_fichier

    def charger(self, chemin_fichier: str):
        """Charge la macro depuis un fichier."""
        with open(chemin_fichier, "r", encoding="utf-8") as f:
            donnees = json.load(f)

        self.nom = donnees.get("nom", "")
        self.commentaire = donnees.get("commentaire", "")
        self.liste_donnees = donnees.get("liste_donnees", [])
        self.liste_declencheurs = donnees.get("liste_declencheurs", [])
        self.liste_actions = donnees.get("liste_actions", [])
        self.liste_contraintes = donnees.get("liste_contraintes", [])
        self.est_actif = donnees.get("est_actif", False)
        self.en_cours = donnees.get("en_cours", False)
        self.chemin_fichier = chemin_fichier
