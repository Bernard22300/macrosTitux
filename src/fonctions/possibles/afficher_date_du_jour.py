#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fonction : afficher_date_du_jour
Description : Affiche la date du jour dans une boîte de dialogue Tkinter
Plugin pour macrosTitux - Dossier : src/fonctions/possibles/

Pour activer cette fonction :
1. Lancer l'application macrosTitux
2. Aller dans l'onglet "Fonctionnalités"
3. Cliquer sur "Activer sélectionnée" pour afficher_date_du_jour
4. Redémarrer l'application
"""

from pathlib import Path
import sys
from datetime import date

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from fonction_base import Fonction_de_base

class afficher_date_du_jour(Fonction_de_base):
    """
    Fonction qui affiche la date du jour dans une boîte de dialogue.
    
    Utilise Tkinter pour afficher une fenêtre popup avec la date.
    
    Utilisation :
        fonc = afficher_date_du_jour()
        fonc.valeur()  # Affiche une popup avec la date et retourne la date en str
    """
    
    def __init__(self) -> None:
        """Initialise la fonction."""
        super().__init__(
            identificateur="AFFICHER_DATE_DU_JOUR",
            description="Affiche la date du jour dans une dialogue Tkinter"
        )
    
    def valeur(self) -> str:
        """
        Affiche une boîte de dialogue avec la date et retourne la date.
        
        Returns :
            Date du jour au format ISO (YYYY-MM-DD)
        """
        try:
            import tkinter as tk
            from tkinter import messagebox
            
            date_str = date.today().strftime("%Y-%m-%d")
            
            root = tk.Tk()
            root.withdraw()  # Cacher la fenêtre principale
            root.attributes('-topmost', True)  # Au premier plan
            
            messagebox.showinfo(
                "Date du jour",
                f"Aujourd'hui, nous sommes le :\n\n{date_str}"
            )
            
            root.destroy()
            
            return date_str
            
        except ImportError:
            # Si tkinter n'est pas disponible, retourne juste la date
            date_str = date.today().strftime("%Y-%m-%d")
            print(f"[afficher_date_du_jour] Date: {date_str}")
            return date_str
        except Exception as e:
            print(f"[afficher_date_du_jour] Erreur: {e}")
            return date.today().strftime("%Y-%m-%d")
    
    def __repr__(self) -> str:
        return f"afficher_date_du_jour(date='{self.valeur()}')"


# Pour tester directement
if __name__ == "__main__":
    print("=== Test fonction afficher_date_du_jour ===")
    fonc = afficher_date_du_jour()
    print(f"Fonction: {fonc.identificateur}")
    print(f"Description: {fonc.description}")
    print(f"Valeur: {fonc.valeur()}")
