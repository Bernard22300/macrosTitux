#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Action: NOTIFIER
Description : Envoie une notification systeme via notify-send

Plugin pour macrosTitux - Dossier : fonctions/actives/

Utilisation :
    action = ActionNotifier(message="Bonjour", titre="Test")
    action.executer()  # Envoi immediat de la notification
    action.compiler()  # Retourne: notify-send "Test" "Bonjour"
"""

import sys
from pathlib import Path
import subprocess

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from instruction_action_base import InstructionAction_base
from instruction_base import Instruction_base

class ActionNotifier(InstructionAction_base):
    """
    Action qui envoie une notification systeme.
    
    Exemple XML :
        <action type="NOTIFIER" label="Notification">
            <config>
                <parametre key="titre" value="Alerte"/>
                <parametre key="message" value="Termine"/>
            </config>
        </action>
    """
    
    def __init__(self, titre: str = "", message: str = "") -> None:
        super().__init__(
            identificateur="NOTIFIER",
            arguments={"titre": titre, "message": message}
        )
        self._titre: str = titre
        self._message: str = message
    
    @property
    def libelle(self) -> str:
        """Libelle affiche dans l'interface."""
        return "Notifier"
    
    def lire_type(self) -> str:
        """Retourne le type de cette instruction."""
        return Instruction_base.TYPE_ACTION
    
    def lire_resume(self) -> str:
        """Retourne un resume court sur une ligne."""
        if self._titre:
            return f"Notification: {self._titre}"
        return "Notification"
    
    def executer(self) -> bool:
        """
        Execute l'action immediatement.
        
        Returns :
            True si la notification a ete envoyee, False sinon
        """
        if not self._message:
            return False
        try:
            subprocess.run(
                ["notify-send", self._titre, self._message],
                capture_output=True,
                timeout=5
            )
            return True
        except Exception as e:
            print(f"[ActionNotifier] Erreur: {e}")
            return False
    
    def editer(self, donnees_macro=None) -> bool:
        """
        Edition de l'action.
        Pour l'instant, retourne True sans editeur graphique.
        """
        return True
    
    def importer(self, donnees_xml: dict) -> None:
        """
        Charge l'action depuis un dictionnaire XML.
        
        Args :
            donnees_xml : dictionnaire avec 'arguments' contenant 'titre' et 'message'
        """
        args = donnees_xml.get("arguments", {})
        self._titre = args.get("titre", "")
        self._message = args.get("message", "")
    
    def exporter(self) -> dict:
        """
        Exporte l'action vers un dictionnaire XML.
        
        Returns :
            Dictionnaire avec identificateur et arguments
        """
        return {
            "identificateur": self.identificateur,
            "arguments": {
                "titre": self._titre,
                "message": self._message
            }
        }
    
    def compiler(self) -> str:
        """
        Genere le code Bash correspondant a l'action.
        
        Returns :
            Code Bash pour envoyer la notification
        """
        if not self._message:
            return ""
        titre_esc = self._titre.replace('"', '\\"')
        message_esc = self._message.replace('"', '\\"')
        return f'notify-send "{titre_esc}" "{message_esc}"'
    
    def __repr__(self) -> str:
        return f"ActionNotifier(titre='{self._titre}', message='{self._message}')"
