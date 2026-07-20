# Templates de macrosTitux

5 macros pre-configurees pour demarrer immediatement.

## Installation

    cp *.xml ~/.config/macrosTitux/macros/

Ou utiliser le script:

    ./scripts/install_exemples.sh

## Description des templates

| Template | Usage | Frquence |
|----------|-------|----------|
| Sauvegarde_Journaliere | Backup quotidien de Documents | 8h00 tous les jours |
| Nettoyage_Temporaire | Supprime fichiers tmp (>7 jours) | 22h00 tous les jours |
| Surveillance_CPU | Alerte si CPU > 90% | Toutes les 30 minutes |
| Synchro_USB | Backup auto sur connexion USB | Au branchement |
| Archi_Mensuelle | Archive PDF du mois | 1er jour du mois à 18h00 |

## Personnalisation

Modifier les parametres dans les balises `<config>` avant installation.

Licence: GPL-3.0
