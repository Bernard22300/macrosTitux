#!/bin/bash
# =============================================================================
# implenter_demo_test.sh
# Implémente :
#   1. Déclencheur Demarrage_application (lance au démarrage de l'app)
#   2. Fonction afficher_date_du_jour (affiche date dans un dialogue)
#   3. Macro test pour valider les 2 implémentations
# =============================================================================

set -e

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJET="$(dirname "$SCRIPTS_DIR")"
SRC="$PROJET/src"

ROUGE='\033[0;31m'
VERT='\033[0;32m'
JAUNE='\033[1;33m'
NEUTRE='\033[0m'

echo -e "${JAUNE}[demo] Démarrage de la démo d'implémentation${NEUTRE}"
echo -e "${JAUNE}[demo] Projet: $PROJET${NEUTRE}"
echo ""

# ------------------------------------------------------------------------------
# 1. Création du déclencheur Demarrage_application
# ------------------------------------------------------------------------------
echo -e "${VERT}[demo] 1. Création déclencheur Demarrage_application...${NEUTRE}"

cat > "$SRC/instruction_declencheur_demarrage.py" <<'DECLENCHEUR'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Déclencheur : Demarrage_application
Description : Se déclenche automatiquement au démarrage de l'application macrosTitux

Plugin pour macrosTitux - Dossier : src/

Utilisation :
    decl = InstructionDemarrageApplicationDeclencheur()
    decl.compiler()  # Retourne le code Bash à exécuter au démarrage
"""

from pathlib import Path
import sys

# Ajoute src/ au path pour imports
sys.path.insert(0, str(Path(__file__).parent))

from instruction_declencheur_base import InstructionDeclencheur_base

class InstructionDemarrageApplicationDeclencheur(InstructionDeclencheur_base):
    """
    Déclencheur qui se lance automatiquement au démarrage de l'application.
    
    Ce déclencheur est spécial : il ne vérifie pas de condition en continu,
    mais se déclenche immédiatement quand l'application démarre.
    
    Exemple XML :
        <declencheur type="DEMARRAGE_APP" label="Au démarrage">
            <config>
                <parametre key="delai" value="0"/>
            </config>
        </declencheur>
    """
    
    def __init__(self, delai: int = 0) -> None:
        """
        Initialise le déclencheur Démarrage.
        
        Args :
            delai : délai en secondes avant exécution (défaut: 0 = immédiat)
        """
        super().__init__(
            identificateur="DEMARRAGE_APP",
            description=f"Déclencheur au démarrage (délai: {delai}s)"
        )
        self._delai: int = delai
    
    @property
    def delai(self) -> int:
        """Retourne le délai avant exécution."""
        return self._delai
    
    def verifier_condition(self) -> bool:
        """
        VÉRIFIE SI LE DÉCLENCHEUR DOIT SE PRODUIRE.
        
        Pour DEMARRAGE_APP : toujours True (car on s'exécute une seule fois au départ)
        
        Returns :
            True - le déclencheur s'est produit (au démarrage)
        """
        return True
    
    def compiler(self) -> str:
        """
        GÉNÈRE LE CODE BASH CORRESPONDANT AU DÉCLENCHEUR.
        
        Returns :
            Code Bash pour attendre le délai puis signaler le démarrage
        """
        if self._delai > 0:
            return (
                "# === DÉCLENCHEUR: Démarrage application ===\n"
                f"echo 'Démarrage en cours... Attendre {self._delai} seconde(s).'\n"
                f"sleep {self._delai}\n"
                "echo 'Démarrage effectué.'\n"
                ""
            )
        else:
            return (
                "# === DÉCLENCHEUR: Démarrage application ===\n"
                "echo 'Démarrage immédiat.'\n"
                ""
            )
    
    def obtenir_resume(self) -> str:
        """Retourne un résumé court pour la GUI."""
        return f"[{self._identificateur}] Délai: {self._delai}s"
    
    def exporter(self) -> dict:
        """Exporte le déclencheur au format dictionnaire."""
        return {
            "type": "declencheur",
            "identificateur": self._identificateur,
            "description": self._description,
            "arguments": {"delai": self._delai},
            "resume": self.obtenir_resume()
        }
    
    def __repr__(self) -> str:
        return f"InstructionDemarrageApplicationDeclencheur(delai={self._delai})"


# Pour tester directement
if __name__ == "__main__":
    print("=== Test déclencheur Demarrage_application ===")
    decl = InstructionDemarrageApplicationDeclencheur(delai=2)
    print(f"Fonction: {decl.identificateur}")
    print(f"Description: {decl.description}")
    print(f"Vérification condition: {decl.verifier_condition()}")
    print(f"Résumé: {decl.obtenir_resume()}")
    print(f"\nCode Bash généré:\n{decl.compiler()}")
DECLENCHEUR

# ------------------------------------------------------------------------------
# 2. Création de la fonction afficher_date_du_jour
# ------------------------------------------------------------------------------
echo -e "${VERT}[demo] 2. Création fonction afficher_date_du_jour...${NEUTRE}"

cat > "$SRC/fonctions/possibles/afficher_date_du_jour.py" <<'FONCTION'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fonction : afficher_date_du_jour
Description : Affiche la date du jour dans une boîte de dialogue Tkinter
Plugin pour macrosTitux - Dossier : src/fonctions/possibles/

Pour activer cette fonction :
1. Lancer l'application macrosTitux
2. Aller dans l'onglet "Fonctionnalités"
3. Cliquer sur "Activer sélectionnée" pour afficher_date_du_jour
4. Redémarrer l'application
"""

from pathlib import Path
import sys
from datetime import date

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from fonction_base import Fonction_de_base

class afficher_date_du_jour(Fonction_de_base):
    """
    Fonction qui affiche la date du jour dans une boîte de dialogue.
    
    Utilise Tkinter pour afficher une fenêtre popup avec la date.
    
    Utilisation :
        fonc = afficher_date_du_jour()
        fonc.valeur()  # Affiche une popup avec la date et retourne la date en str
    """
    
    def __init__(self) -> None:
        """Initialise la fonction."""
        super().__init__(
            identificateur="AFFICHER_DATE_DU_JOUR",
            description="Affiche la date du jour dans une dialogue Tkinter"
        )
    
    def valeur(self) -> str:
        """
        Affiche une boîte de dialogue avec la date et retourne la date.
        
        Returns :
            Date du jour au format ISO (YYYY-MM-DD)
        """
        try:
            import tkinter as tk
            from tkinter import messagebox
            
            date_str = date.today().strftime("%Y-%m-%d")
            
            root = tk.Tk()
            root.withdraw()  # Cacher la fenêtre principale
            root.attributes('-topmost', True)  # Au premier plan
            
            messagebox.showinfo(
                "Date du jour",
                f"Aujourd'hui, nous sommes le :\n\n{date_str}"
            )
            
            root.destroy()
            
            return date_str
            
        except ImportError:
            # Si tkinter n'est pas disponible, retourne juste la date
            date_str = date.today().strftime("%Y-%m-%d")
            print(f"[afficher_date_du_jour] Date: {date_str}")
            return date_str
        except Exception as e:
            print(f"[afficher_date_du_jour] Erreur: {e}")
            return date.today().strftime("%Y-%m-%d")
    
    def __repr__(self) -> str:
        return f"afficher_date_du_jour(date='{self.valeur()}')"


# Pour tester directement
if __name__ == "__main__":
    print("=== Test fonction afficher_date_du_jour ===")
    fonc = afficher_date_du_jour()
    print(f"Fonction: {fonc.identificateur}")
    print(f"Description: {fonc.description}")
    print(f"Valeur: {fonc.valeur()}")
FONCTION

# ------------------------------------------------------------------------------
# 3. Création d'un script pour activer et créer la macro test
# ------------------------------------------------------------------------------
echo -e "${VERT}[demo] 3. Activation des plugins...${NEUTRE}"

# Activer le déclencheur (on le copie dans actives pour compatibilité avec l'ancien système)
cp "$SRC/instruction_declencheur_demarrage.py" "$SRC/fonctions/actives/instruction_declencheur_demarrage.py" 2>/dev/null || true

# Activer la fonction
ln -sf "../possibles/afficher_date_du_jour.py" "$SRC/fonctions/actives/afficher_date_du_jour.py" 2>/dev/null || rm -f "$SRC/fonctions/actives/afficher_date_du_jour.py" && ln -s "../possibles/afficher_date_du_jour.py" "$SRC/fonctions/actives/afficher_date_du_jour.py"

echo -e "  ${VERT}✓${NEUTRE} instruction_declencheur_demarrage.py"
echo -e "  ${VERT}✓${NEUTRE} afficher_date_du_jour.py"

# ------------------------------------------------------------------------------
# 4. Script pour créer la macro test
# ------------------------------------------------------------------------------
echo -e "${VERT}[demo] 4. Génération du script de test...${NEUTRE}"

cat > "$SCRIPTS_DIR/creer_macro_test_demo.sh" <<'SCRIPT_TEST'
#!/bin/bash
# =============================================================================
# creer_macro_test_demo.sh
# Crée une macro XML de test qui utilise :
#   - Déclencheur: DEMARRAGE_APP
#   - Action: NOTIFIER avec utilisation de AFFICHER_DATE_DU_JOUR
# =============================================================================

set -e

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJET="$(dirname "$SCRIPTS_DIR")"
SRC="$PROJET/src"

ROUGE='\033[0;31m'
VERT='\033[0;32m'
JAUNE='\033[1;33m'
NEUTRE='\033[0m'

echo -e "${JAUNE}[test] Création de la macro de démo...${NEUTRE}"

# Dossier de config utilisateur
DOSSIER_CONFIG="$HOME/.config/macrosTitux/macros/"
mkdir -p "$DOSSIER_CONFIG"

# Fichier XML de la macro test
FICHIER_XML="$DOSSIER_CONFIG/test_demo_datingue.xml"

cat > "$FICHIER_XML" <<'XML_MACRO'
<?xml version="1.0" encoding="utf-8"?>
<macro name="Test_Demo_Date">
    <!-- Déclencheur: Au démarrage de l'application -->
    <declencheur type="DEMARRAGE_APP" label="Au démarrage">
        <config>
            <parametre key="delai" value="0"/>
        </config>
    </declencheur>
    
    <!-- Variables -->
    <variables>
        <variable name="DATE_AUJOURDHUI" value=""/>
    </variables>
    
    <!-- Actions -->
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
    
    <!-- Contraintes: aucune -->
    <contraintes/>
</macro>
XML_MACRO

echo -e "  ${VERT}✓${NEUTRE} Macro créée: $FICHIER_XML"
echo ""
echo "Pour tester la macro :"
echo "  1. Lancer l'application: ./src/appliMacrosTitux.py"
echo "  2. Aller dans l'onglet 'Macros'"
echo "  3. Sélectionner 'Test_Demo_Date'"
echo "  4. Cliquer sur 'Tester'"
echo ""
echo "Résultat attendu :"
echo "  - Une notification s'affiche"
echo "  - Une boîte de dialogue montre la date du jour"
SCRIPT_TEST

chmod +x "$SCRIPTS_DIR/creer_macro_test_demo.sh"

# Exécuter la création de la macro test
"$SCRIPTS_DIR/creer_macro_test_demo.sh"

echo ""
echo -e "${VERT}[demo] ==========================================${NEUTRE}"
echo -e "${VERT}[demo]  DÉMO D'IMPLÉMENTATION TERMINÉE${NEUTRE}"
echo -e "${VERT}[demo] ==========================================${NEUTRE}"
echo ""
echo "Fichiers créés :"
echo "  - $SRC/instruction_declencheur_demarrage.py"
echo "  - $SRC/fonctions/possibles/afficher_date_du_jour.py"
echo "  - $SCRIPTS_DIR/creer_macro_test_demo.sh"
echo ""
echo "Prochaines étapes :"
echo "  1. Lancer l'application: ./src/appliMacrosTitux.py"
echo "  2. Activer la fonction 'afficher_date_du_jour' dans l'onglet Fonctionnalités"
echo "  3. Relancer l'application"
echo "  4. Tester la macro 'Test_Demo_Date'"
echo ""
echo "Sauvegarde GitHub recommandée :"
echo "  ./scripts/sauvegarder_projet.sh \"Implémentation démo - Demarrage_app + afficher_date_du_jour\""
