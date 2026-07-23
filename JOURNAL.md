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


## 2026-07-23 (suite)

- Creation de la classe abstraite Fonctions_base pour standardiser l'interface des gestionnaires de plugins
- Implementation de la classe Functions (singleton) chargeant dynamiquement les plugins
- refonte config.py pour populer automatiquement DECLENCHEURS, ACTIONS, CONTRAINTES via le gestionnaire
- Diagnostic : DEMARRAGE_APP definie dans src/fonctions/actives/instruction_declencheur_demarrage.py
- Prochaines etapes : adapter dialogs.py et fenetreEditionMacro.py pour utiliser Functions.obtenir_declencheurs()

