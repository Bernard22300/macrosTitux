# macrosTitux

Gestionnaire de macros Bash avec interface graphique style MacroDroid

## Description

Application Python/Tkinter permettant de creer visuellement des declencheurs,
actions et contraintes qui seront compiles en scripts Bash executables sur Linux Debian.

Concue pour des utilisateurs non-experts en informatique, avec une terminologie
100% francaise et une interface guidee (menus deroulants, champs pre-definis).

## Architecture

Le projet suit une architecture **Vue/Moteur** modulaire :

    src/
    ├── macrosTitux.py          # Point dentree (main)
    ├── config.py               # Constantes (declencheurs, actions, contraintes)
    ├── model.py                # Moteur (sauvegarde XML, conversion Bash)
    ├── widgets.py              # Composants GUI (TriggerWidget, ActionFrame...)
    ├── dialogs.py              # Dialogues (creation de macro)
    ├── gui.py                  # Interface principale (MacrosTituxApp)
    └── generate_bash.sh        # Convertisseur XML vers Bash

### Separation Vue/Moteur

| Couche | Fichiers | Role |
|--------|----------|------|
| Vue | gui.py, dialogs.py, widgets.py | Interface Tkinter, interactions utilisateur |
| Moteur | model.py, config.py, generate_bash.sh | Logique metier, sauvegarde, conversion |
| Entree | macrosTitux.py | Initialisation et lancement |

## Installation

### Pre-requis

    sudo apt update
    sudo apt install python3-tk libxml2-utils

### Lancement

    cd macrosTitux
    chmod +x src/macrosTitux.py
    ./src/macrosTitux.py

## Tests

### Installer pytest

    ./scripts/installer_pytest.sh

ou via apt :

    sudo apt install python3-pytest

### Lancer les tests

    pytest tests/ -v

### Structure des tests

    tests/
    ├── conftest.py              # Fixtures communes
    ├── test_config.py           # Tests des constantes
    ├── test_model.py            # Tests sauvegarde/chargement XML
    ├── test_generate_bash.py    # Tests conversion XML vers Bash
    └── test_widgets.py          # Tests composants GUI

## Scripts utilitaires

| Script | Description |
|--------|-------------|
| scripts/sauvegarder_projet.sh | Ajoute, committe et pousse vers GitHub |
| scripts/installer_pytest.sh | Installe pytest proprement (apt ou venv) |
| scripts/refactor_modulaire.sh | Decoupe le code en fichiers modulaires |
| scripts/install_exemples.sh | Installe 4 macros exemple |
| scripts/projet-instantane.sh | Genere un instantane du projet |
| scripts/fix-gitignore.sh | Configure le .gitignore |
| scripts/mise_a_niveau.sh | Synchronise les fichiers du projet |

## Declencheurs disponibles

| Type | Description |
|------|-------------|
| DEMARRAGE | Au demarrage du systeme |
| HORAIRE | Programmation cron (heure, minute, jours) |
| FICHIER_MODIFIE | Sur modification dun fichier |
| FICHIER_CREE | Sur creation dun fichier |
| USB_CONNECTE | Sur connexion dun peripherique USB |
| RESEAU_ACTIF | Sur activation dune interface reseau |
| SORTIE_TUBE | Sur reception de donnees via tube nomme (FIFO) |

## Actions disponibles

| Type | Description |
|------|-------------|
| COPIER_FICHIER | Copier des fichiers (source, motif, destination) |
| DEPLACER_FICHIER | Deplacer des fichiers |
| SUPPRIMER_FICHIER | Supprimer des fichiers |
| NOTIFIER | Afficher une notification systeme |
| EXECUTER_CMD | Executer une commande Bash |
| REDÉMARRER_SERV | Redemarrer un service systeme |
| SORTIR_RESULTAT | Envoyer des donnees dans un tube nomme |

## Contraintes disponibles

| Type | Description |
|------|-------------|
| ESPACE_DISQUE | Verifier lespace disque disponible |
| PLAGE_HORAIRE | Limiter lexcution a une plage horaire |
| PROCESSUS_ACTIF | Verifier quun processus tourne |

## Stockage des donnees

| Emplacement | Contenu |
|-------------|---------|
| ~/.config/macrosTitux/macros/ | Macros utilisateur (XML) |
| ~/.config/macrosTitux/macrosTitux.conf | Configuration de lapplication |
| /tmp/macrosTitux_pipes/ | Tubes nommes (FIFO) temporaires |

## Chainage de macros

Les macros peuvent senchaner via les tubes nommes (FIFO) :

1. Macro A utilise laction SORTIR_RESULTAT pour ecrire dans un tube
2. Macro B utilise le declencheur SORTIE_TUBE pour lire le tube et se declencher

Exemple : Lister_PDF genere une liste puis Archiver_PDF archive les fichiers listes

## Licence

GPL-3.0

## Version

v0.3 (2026)
