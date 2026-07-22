#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: appliMacrosTitux.py
# Description: Point d'entrée principal de l'application
# Version: 0.4c
# License: GPL-3.0
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import sys
import os
from pathlib import Path

# Ajout du dossier src au path
src_dir = Path(__file__).parent
sys.path.insert(0, str(src_dir))

from gui import MacrosTituxApp
from model import initialiser_dossiers
from fonction_loader import charger_fonctions
from tkinter import Tk

def principal():
    """Point d'entrée de l'application."""
    # Initialisation des dossiers
    initialiser_dossiers()
    
    # Chargement des fonctions actives
    print("\n=== Chargement des fonctions ===")
    charger_fonctions()
    print(f"Total: {len(charger_fonctions())} fonction(s) active(s)\n")
    
    # Démarrage de l'interface
    root = Tk()
    app = MacrosTituxApp(root)
    app.pack(fill='both', expand=True)
    app.mainloop()

if __name__ == "__main__":
    principal()
