#!/bin/bash
# =============================================================================
# creer_macro_test_demo.sh
# Crée une macro XML de test qui utilise :
#   - Déclencheur: DEMARRAGE_APP
#   - Action: AFFICHER_DATE + NOTIFIER
# =============================================================================

set -e

echo -e "\033[1;33m[test] Création de la macro de démo...\033[0m"

DOSSIER_CONFIG="$HOME/.config/macrosTitux/macros/"
mkdir -p "$DOSSIER_CONFIG"

FICHIER_XML="$DOSSIER_CONFIG/test_demo_datingue.xml"

cat > "$FICHIER_XML" <<'XML_MACRO'
<?xml version="1.0" encoding="utf-8"?>
<macro name="Test_Demo_Date">
    <declencheur type="DEMARRAGE_APP" label="Au demarrage">
        <config>
            <parametre key="delai" value="0"/>
        </config>
    </declencheur>
    
    <variables>
        <variable name="DATE_AUJOURDHUI" value=""/>
    </variables>
    
    <actions>
        <action id="1" type="AFFICHER_DATE" label="Afficher date du jour">
            <config>
                <parametre key="format" value="%Y-%m-%d"/>
                <parametre key="titre" value="Date du jour"/>
            </config>
        </action>
        
        <action id="2" type="NOTIFIER" label="Notifier l'utilisateur">
            <config>
                <parametre key="titre" value="Macro de test"/>
                <parametre key="message" value="La macro Demo Date fonctionne !"/>
            </config>
        </action>
    </actions>
    
    <contraintes/>
</macro>
XML_MACRO

echo -e "  \033[0;32m✓\033[0m Macro créée: $FICHIER_XML"
echo ""
echo "Pour tester la macro :"
echo "  1. Lancer l'application: ./src/appliMacrosTitux.py"
echo "  2. Aller dans l'onglet 'Macros'"
echo "  3. Sélectionner 'Test_Demo_Date'"
echo "  4. Cliquer sur 'Tester'"
