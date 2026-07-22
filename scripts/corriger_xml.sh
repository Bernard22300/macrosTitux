#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: corriger_xml.sh
# Description: Corrige les tags XML mal migrés (ouverture + fermeture)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

corriger_xml() {
    local fichier="$1"

    # Balises d'ouverture avec attributs
    sed -i 's/<trigger /<declencheur /g' "$fichier"
    sed -i 's/<trigger>/<declencheur>/g' "$fichier"
    sed -i 's/<\/trigger>/<\/declencheur>/g' "$fichier"

    sed -i 's/<param /<parametre /g' "$fichier"
    sed -i 's/<param>/<parametre>/g' "$fichier"
    sed -i 's/<\/param>/<\/parametre>/g' "$fichier"
    sed -i 's/<param\/>/<parametre\/>/g' "$fichier"

    sed -i 's/<constraints>/<contraintes>/g' "$fichier"
    sed -i 's/<\/constraints>/<\/contraintes>/g' "$fichier"
    sed -i 's/<constraints\/>/<contraintes\/>/g' "$fichier"

    sed -i 's/<constraint /<contrainte /g' "$fichier"
    sed -i 's/<constraint>/<contrainte>/g' "$fichier"
    sed -i 's/<\/constraint>/<\/contrainte>/g' "$fichier"

    sed -i 's/<var /<variable /g' "$fichier"
    sed -i 's/<var>/<variable>/g' "$fichier"
    sed -i 's/<\/var>/<\/variable>/g' "$fichier"

    # Nettoyer les doubles remplacements (ex: <declencheur /> déjà ok)
    sed -i 's/<declencheurdeclencheur/<declencheur/g' "$fichier"
    sed -i 's/<parametreparametre/<parametre/g' "$fichier"
    sed -i 's/<contraintecontrainte/<contrainte/g' "$fichier"
    sed -i 's/<variablevariable/<variable/g' "$fichier"
}

echo "=== Correction des modèles ==="
for f in modèles/*.xml; do
    [[ -f "$f" ]] && echo "  Correction: $(basename "$f")" && corriger_xml "$f"
done

echo "=== Correction des macros utilisateur ==="
for f in ~/.config/macrosTitux/macros/*.xml; do
    [[ -f "$f" ]] && echo "  Correction: $(basename "$f")" && corriger_xml "$f"
done

echo "=== Vérification ==="
for f in ~/.config/macrosTitux/macros/*.xml; do
    [[ -f "$f" ]] && echo "--- $(basename "$f") ---" && cat "$f"
done
