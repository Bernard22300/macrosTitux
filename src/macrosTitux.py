#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: macrosTitux.py
# Description: Point d'entrée principal de l'application
# Version: 0.3 (Modulaire)
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
from model import init_dirs
from tkinter import Tk

def main():
    """Point d'entrée de l'application."""
    init_dirs()

    root = Tk()
    app = MacrosTituxApp(root)
    app.pack(fill='both', expand=True)
    app.mainloop()

if __name__ == "__main__":
    main()
