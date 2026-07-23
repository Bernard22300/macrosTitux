#!/bin/bash
# creer_journal_bord.sh - Cree le journal de bord du projet macrosTitux
# Usage : ./scripts/creer_journal_bord.sh

PROJET="/Data/Compte/Bernard_ROLLAND/Développement/macrosTitux"
JOURNAL="$PROJET/JOURNAL.md"

if [ -f "$JOURNAL" ]; then
    echo "Le journal de bord existe deja : $JOURNAL"
    echo "Utilisez votre editeur pour ajouter de nouvelles entrees."
    exit 0
fi

cat > "$JOURNAL" <<'CONTENU'
# Journal de bord - macrosTitux

Historique des decisions et changements structurels du projet.

## 2026-07-20

- Creation du projet macrosTitux
- Architecture initiale : fichier unique macrosTitux.py
- Interface Tkinter avec onglets Macros, Modeles, Parametres

## 2026-07-22

- Refonte modulaire de l'architecture (Vue/Moteur)
- Renommage du fichier principal : macrosTitux.py -> appliMacrosTitux.py
  Raison : eviter la multiplication de fichiers prefixes par "macro"
- Creation de classes abstraites : Instruction_base, Bloc_instructions_base, Donnee_base, Fonction_de_base
- Mise en place de l'architecture plugin : src/fonctions/actives et src/fonctions/possibles
- Separation un fichier par classe dans src/
- Renommage widgets.py -> fenetreEditionMacro.py
  Classes renommees : WidgetDeclencheur -> EditionDeclencheur, CadreAction -> EditionAction,
  CadreContrainte -> EditionContrainte, CadreVariable -> EditionVariable
- Renommage Template/Templates -> Modele/Modeles dans l'interface et le code

## 2026-07-23

- generate_bash.sh v1.1 avec xmllint pour le parse XML
- Actions supportees par generate_bash.sh : NOTIFIER, AFFICHER_DATE, EXECUTER_CMD, COPIER_FICHIER, DEPLACER_FICHIER, SUPPRIMER_FICHIER
- Macro test_demo_datingue fonctionnelle
- Commit 41417b8 pousse sur GitHub
- Creation du journal de bord du projet

CONTENU

chmod 644 "$JOURNAL"
echo "Journal de bord cree : $JOURNAL"
