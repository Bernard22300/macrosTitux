#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: install_exemples.sh
# Description: Installe deux macros d'exemple pour tester macrosTitux
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -euo pipefail

MACRO_DIR="${HOME}/.config/macrosTitux/macros"
mkdir -p "$MACRO_DIR"

#==============================================================================
# Exemple 1 : Notification au démarrage (simple)
#==============================================================================
cat > "$MACRO_DIR/Test_Notification.xml" << 'XML_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<macro name="Test_Notification">
    <trigger type="DEMARRAGE" label="Au démarrage">
        <config/>
    </trigger>
    <actions>
        <action id="1" type="NOTIFIER" label="Notifier">
            <config>
                <param key="titre">macrosTitux</param>
                <param key="message">Premiere macro fonctionne !</param>
            </config>
        </action>
    </actions>
    <constraints/>
</macro>
XML_EOF

#==============================================================================
# Exemple 2 : Sauvegarde avec contrainte d'espace disque (complet)
#==============================================================================
cat > "$MACRO_DIR/Sauvegarde_PDF.xml" << 'XML_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<macro name="Sauvegarde_PDF">
    <trigger type="DEMARRAGE" label="Au démarrage">
        <config/>
    </trigger>
    <variables>
        <var name="SOURCE_DIR" value="$HOME/Documents"/>
        <var name="DEST_DIR" value="$HOME/backup_pdf"/>
    </variables>
    <actions>
        <action id="1" type="COPIER_FICHIER" label="Copier PDF">
            <config>
                <param key="source">$HOME/Documents</param>
                <param key="motif">*.pdf</param>
                <param key="destination">$HOME/backup_pdf</param>
            </config>
        </action>
        <action id="2" type="NOTIFIER" label="Confirmer">
            <config>
                <param key="titre">Sauvegarde</param>
                <param key="message">Copie des PDF terminee</param>
            </config>
        </action>
    </actions>
    <constraints>
        <constraint id="1" type="ESPACE_DISQUE" label="Espace disque">
            <config>
                <param key="espace_minimum">5</param>
            </config>
        </constraint>
    </constraints>
</macro>
XML_EOF

#==============================================================================
# Exemple 3 : Chainage avec tube nomme (SORTIE_TUBE)
#==============================================================================
cat > "$MACRO_DIR/Lister_PDF.xml" << 'XML_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<macro name="Lister_PDF">
    <trigger type="DEMARRAGE" label="Au démarrage">
        <config/>
    </trigger>
    <actions>
        <action id="1" type="EXECUTER_CMD" label="Lister PDF">
            <config>
                <param key="commande">find $HOME/Documents -name "*.pdf"</param>
            </config>
        </action>
        <action id="2" type="SORTIR_RESULTAT" label="Envoyer dans tube">
            <config>
                <param key="tube">lister_pdf</param>
                <param key="donnees">RESULTAT_CMD</param>
            </config>
        </action>
    </actions>
    <constraints/>
</macro>
XML_EOF

cat > "$MACRO_DIR/Archiver_PDF.xml" << 'XML_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<macro name="Archiver_PDF">
    <trigger type="SORTIE_TUBE" label="Sortie de tube">
        <config>
            <param key="macro_source">Lister PDF</param>
            <param key="variable_reception">FICHIERS_RECUS</param>
        </config>
    </trigger>
    <actions>
        <action id="1" type="COPIER_FICHIER" label="Archiver">
            <config>
                <param key="source">$FICHIERS_RECUS</param>
                <param key="motif">*</param>
                <param key="destination">$HOME/backup_pdf</param>
            </config>
        </action>
        <action id="2" type="NOTIFIER" label="Confirmer">
            <config>
                <param key="titre">Archivage</param>
                <param key="message">PDF archives depuis le tube</param>
            </config>
        </action>
    </actions>
    <constraints>
        <constraint id="1" type="ESPACE_DISQUE" label="Espace disque">
            <config>
                <param key="espace_minimum">5</param>
            </config>
        </constraint>
    </constraints>
</macro>
XML_EOF

echo "=========================================="
echo " MACROS INSTALLÉES"
echo "=========================================="
echo ""
echo " Emplacement: $MACRO_DIR"
echo ""
echo " Macros créées :"
ls -1 "$MACRO_DIR"/*.xml | xargs -I{} basename {}
echo ""
echo " Pour tester :"
echo "   1. Lancez l'application : ./src/macrosTitux.py"
echo "   2. Sélectionnez une macro dans la liste"
echo "   3. Cliquez sur 'Tester'"
echo ""
echo " Ou testez directement en ligne de commande :"
echo "   ./src/generate_bash.sh ~/.config/macrosTitux/macros/Test_Notification.xml /tmp/test.sh"
echo "   bash /tmp/test.sh"
echo "=========================================="

