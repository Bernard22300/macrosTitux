#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: macrosTitux.sh
# Description: Lanceur de l'application macrosTitux
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

cd "$(dirname "$0")" || exit 1

python3 src/appliMacrosTitux.py
