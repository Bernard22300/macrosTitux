#!/bin/bash
# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Script: creer_modeles.sh
# Description: Cree 5 modeles de macros pret a l'emploi
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODELE_DIR="$PROJECT_ROOT/modeles"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
ok() { log "✅ $*"; }

mkdir -p "$MODELE_DIR"

# Template 1: Sauvegarde Journaliere
cat > "$MODELE_DIR/Sauvegarde_Journaliere.xml" << 'XML1'
<?xml version="1.0" encoding="UTF-8"?>
<macro name="Sauvegarde_Journaliere">
    <trigger type="HORAIRE" label="Horaire (cron)">
        <config>
            <param key="heure">8</param>
            <param key="minute">0</param>
            <param key="jours">* * * * *</param>
        </config>
    </trigger>
    <variables>
        <var name="SOURCE" value="$HOME/Documents"/>
        <var name="DEST" value="$HOME/backup/Documents"/>
    </variables>
    <actions>
        <action id="1" type="COPIER_FICHIER" label="Copier fichier(s)">
            <config>
                <param key="source">/home/bernard/Documents</param>
                <param key="destination">/home/bernard/backup/Documents</param>
                <param key="motif">*</param>
            </config>
        </action>
        <action id="2" type="NOTIFIER" label="Notifier">
            <config>
                <param key="titre">Sauvegarde terminee</param>
                <param key="message">Documents sauvegardes avec succes</param>
            </config>
        </action>
    </actions>
    <constraints>
        <constraint id="1" type="ESPACE_DISQUE" label="Espace disque">
            <config>
                <param key="espace_minimum">10</param>
            </config>
        </constraint>
    </constraints>
</macro>
XML1
ok "Modele 1 cree: Sauvegarde_Journaliere.xml"

# Template 2: Nettoyage Temporaire
cat > "$MODELE_DIR/Nettoyage_Temporaire.xml" << 'XML2'
<?xml version="1.0" encoding="UTF-8"?>
<macro name="Nettoyage_Temporaire">
    <trigger type="HORAIRE" label="Horaire (cron)">
        <config>
            <param key="heure">22</param>
            <param key="minute">0</param>
            <param key="jours">* * * * *</param>
        </config>
    </trigger>
    <variables>
        <var name="TMP_DIR" value="/tmp"/>
    </variables>
    <actions>
        <action id="1" type="NOTIFIER" label="Notifier">
            <config>
                <param key="titre">Nettoyage</param>
                <param key="message">Departement des fichiers temporaires</param>
            </config>
        </action>
        <action id="2" type="EXECUTER_CMD" label="Exécuter commande">
            <config>
                <param key="commande">find /tmp -type f -mtime +7 -delete</param>
            </config>
        </action>
        <action id="3" type="NOTIFIER" label="Notifier">
            <config>
                <param key="titre">Nettoyage terminee</param>
                <param key="message">Fichiers de plus de 7 jours supprimes</param>
            </config>
        </action>
    </actions>
    <constraints>
        <constraint id="1" type="PLAGE_HORAIRE" label="Plage horaire">
            <config>
                <param key="heure_debut">2200</param>
                <param key="heure_fin">2359</param>
            </config>
        </constraint>
    </constraints>
</macro>
XML2
ok "Modele 2 cree: Nettoyage_Temporaire.xml"

# Template 3: Surveillance CPU
cat > "$MODELE_DIR/Surveillance_CPU.xml" << 'XML3'
<?xml version="1.0" encoding="UTF-8"?>
<macro name="Surveillance_CPU">
    <trigger type="HORAIRE" label="Horaire (cron)">
        <config>
            <param key="heure">*</param>
            <param key="minute">*/30</param>
            <param key="jours">* * * * *</param>
        </config>
    </trigger>
    <variables>
        <var name="THRESHOLD" value="90"/>
    </variables>
    <actions>
        <action id="1" type="EXECUTER_CMD" label="Exécuter commande">
            <config>
                <param key="commande">cpu_usage=$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | cut -d'%' -f1); echo CPU: \$cpu_usage</param>
            </config>
        </action>
        <action id="2" type="NOTIFIER" label="Notifier">
            <config>
                <param key="titre">Alerte CPU</param>
                <param key="message">CPU eleve: verifier les programmes en cours</param>
            </config>
        </action>
    </actions>
    <constraints>
        <constraint id="1" type="PROCESSUS_ACTIF" label="Processus actif">
            <config>
                <param key="processus">gnome-system-monitor</param>
            </config>
        </constraint>
    </constraints>
</macro>
XML3
ok "Modele 3 cree: Surveillance_CPU.xml"

# Template 4: Synchro USB
cat > "$MODELE_DIR/Synchro_USB.xml" << 'XML4'
<?xml version="1.0" encoding="UTF-8"?>
<macro name="Synchro_USB">
    <trigger type="USB_CONNECTE" label="USB connecte">
        <config>
            <param key="peripherique">(tous)</param>
        </config>
    </trigger>
    <variables>
        <var name="USB_PATH" value="/media/bernard/"/>
        <var name="BACKUP_PATH" value="$HOME/backup/USB"/>
    </variables>
    <actions>
        <action id="1" type="NOTIFIER" label="Notifier">
            <config>
                <param key="titre">USB detecte</param>
                <param key="message">Démarrage de la synchro</param>
            </config>
        </action>
        <action id="2" type="COPIER_FICHIER" label="Copier fichier(s)">
            <config>
                <param key="source">/media/bernard/*</param>
                <param key="destination">$HOME/backup/USB</param>
                <param key="motif">*.pdf,*.docx,*.jpg</param>
            </config>
        </action>
        <action id="3" type="NOTIFIER" label="Notifier">
            <config>
                <param key="titre">Synchro terminee</param>
                <param key="message">Fichiers copies vers backup</param>
            </config>
        </action>
    </actions>
</macro>
XML4
ok "Modele 4 cree: Synchro_USB.xml"

# Template 5: Archi Mensuelle
cat > "$MODELE_DIR/Archi_Mensuelle.xml" << 'XML5'
<?xml version="1.0" encoding="UTF-8"?>
<macro name="Archi_Mensuelle">
    <trigger type="HORAIRE" label="Horaire (cron)">
        <config>
            <param key="heure">18</param>
            <param key="minute">0</param>
            <param key="jours">01 * * *</param>
        </config>
    </trigger>
    <variables>
        <var name="MOIS" value="$(date +%Y%m)"/>
        <var name="ARCHIVE_NAME" value="PDF_Archive_${MOIS}.tar.gz"/>
    </variables>
    <actions>
        <action id="1" type="COPIER_FICHIER" label="Copier fichier(s)">
            <config>
                <param key="source">$HOME/Documents/*.pdf</param>
                <param key="destination">/tmp/archi_temp/</param>
                <param key="motif">*.pdf</param>
            </config>
        </action>
        <action id="2" type="EXECUTER_CMD" label="Exécuter commande">
            <config>
                <param key="commande">tar -czf $HOME/Archives/${ARCHIVE_NAME} -C /tmp/archi_temp .</param>
            </config>
        </action>
        <action id="3" type="NOTIFIER" label="Notifier">
            <config>
                <param key="titre">Archive mensuelle</param>
                <param key="message">PDF archives pour ${MOIS}</param>
            </config>
        </action>
    </actions>
    <constraints>
        <constraint id="1" type="ESPACE_DISQUE" label="Espace disque">
            <config>
                <param key="espace_minimum">20</param>
            </config>
        </constraint>
    </constraints>
</macro>
XML5
ok "Modele 5 cree: Archi_Mensuelle.xml"

# README des modeles
cat > "$MODELE_DIR/README.md" << 'README_MODELE'
# Modeles de macrosTitux

5 macros pre-configurees pour demarrer immediatement.

## Installation

    cp *.xml ~/.config/macrosTitux/macros/

Ou utiliser le script:

    ./scripts/install_exemples.sh

## Description des modeles

| Modele | Usage | Frequence |
|----------|-------|----------|
| Sauvegarde_Journaliere | Backup quotidien de Documents | 8h00 tous les jours |
| Nettoyage_Temporaire | Supprime fichiers tmp (>7 jours) | 22h00 tous les jours |
| Surveillance_CPU | Alerte si CPU > 90% | Toutes les 30 minutes |
| Synchro_USB | Backup auto sur connexion USB | Au branchement |
| Archi_Mensuelle | Archive PDF du mois | 1er jour du mois a 18h00 |

## Personnalisation

Modifier les parametres dans les balises `<config>` avant installation.

Licence: GPL-3.0
README_MODELE
ok "README des modeles cree"

log ""
ok "=========================================="
ok " MODELES CREES"
ok "=========================================="
log "Fichiers dans: $MODELE_DIR"
log ""
ls -la "$MODELE_DIR"
log ""
log "Pour installer:"
log "  cp $MODELE_DIR/*.xml ~/.config/macrosTitux/macros/"
log "=========================================="
