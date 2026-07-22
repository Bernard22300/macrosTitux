# -*- coding: utf-8 -*-
import os
#------------------------------------------------------------------------------
# Fichier: model.py
# Description: Logique métier (sauvegarde, chargement, conversion)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import json
import xml.etree.ElementTree as ET
from pathlib import Path

# IMPORT ABSOLU (compatible pytest)
from config import NOM_APPLICATION, CONFIG_DEFAUT

DOSSIER_CONFIG = Path.home() / ".config" / NOM_APPLICATION
DOSSIER_MACROS = DOSSIER_CONFIG / "macros"
FICHIER_CONF = DOSSIER_CONFIG / "macrosTitux.conf"

def initialiser_dossiers():
    """Crée les dossiers de configuration."""
    DOSSIER_CONFIG.mkdir(parents=True, exist_ok=True)
    DOSSIER_MACROS.mkdir(parents=True, exist_ok=True)
    if not FICHIER_CONF.exists():
        with open(FICHIER_CONF, 'w', encoding='utf-8') as f:
            json.dump(CONFIG_DEFAUT, f, indent=4, ensure_ascii=False)

def charger_config():
    """Charge la configuration utilisateur."""
    with open(FICHIER_CONF, 'r', encoding='utf-8') as f:
        return json.load(f)

def charger_liste_macros():
    """Liste toutes les macros enregistrées."""
    macros = []
    for f in DOSSIER_MACROS.glob("*.xml"):
        tree = ET.parse(f)
        root = tree.getroot()
        name = root.get('name')
        trigger_label = root.find('declencheur').get('label', '-') if root.find('declencheur') is not None else '-'
        actions = root.findall('actions/action')
        action_label = actions[0].get('label', '-') if actions else '-'
        macros.append((name, trigger_label, action_label))
    return macros

def sauvegarder_macro(name, donnees_declencheur, variables, actions, constraints):
    """Sauvegarde une macro au format XML."""
    root = ET.Element("macro")
    root.set('name', name)

    # Trigger
    trigger = ET.SubElement(root, "declencheur")
    trigger.set('type', donnees_declencheur['type'])
    trigger.set('label', donnees_declencheur['label'])
    trigger_cfg = ET.SubElement(trigger, "config")
    for k, v in donnees_declencheur['params'].items():
        param = ET.SubElement(trigger_cfg, "parametre")
        param.set('key', k)
        param.set('value', str(v))

    # Variables
    vars_elem = ET.SubElement(root, "variables")
    for var in variables:
        if var.get('name'):
            v = ET.SubElement(vars_elem, "variable")
            v.set('name', var['name'])
            v.set('value', var.get('value', ''))

    # Actions
    actions_elem = ET.SubElement(root, "actions")
    for action in actions:
        action_el = ET.SubElement(actions_elem, "action")
        action_el.set('id', action.get('id', '1'))
        action_el.set('type', action['type'])
        action_el.set('label', action.get('label', ''))
        cfg = ET.SubElement(action_el, "config")
        for k, v in action.get('params', {}).items():
            p = ET.SubElement(cfg, "parametre")
            p.set('key', k)
            p.set('value', str(v))

    # Contraintes
    constraints_elem = ET.SubElement(root, "contraintes")
    for constraint in constraints:
        c_el = ET.SubElement(constraints_elem, "contrainte")
        c_el.set('id', constraint.get('id', '1'))
        c_el.set('type', constraint['type'])
        c_el.set('label', constraint.get('label', ''))
        cfg = ET.SubElement(c_el, "config")
        for k, v in constraint.get('params', {}).items():
            p = ET.SubElement(cfg, "parametre")
            p.set('key', k)
            p.set('value', str(v))

    tree = ET.ElementTree(root)
    ET.indent(tree, space="    ")
    with open(DOSSIER_MACROS / f"{name}.xml", 'wb') as f:
        tree.write(f, encoding='utf-8', xml_declaration=True)

def supprimer_macro(nom_macro):
    """Supprime une macro XML."""
    macro_path = DOSSIER_MACROS / f"{nom_macro}.xml"
    if macro_path.exists():
        macro_path.unlink()
        # Supprimer aussi le fichier Bash associé
        chemin_sh = DOSSIER_MACROS / f"{nom_macro}.sh"
        if chemin_sh.exists():
            chemin_sh.unlink()

def generer_bash_depuis_xml(chemin_xml, chemin_sortie=None, simulation=False):
    """Convertit un XML en script Bash et retourne les infos de la macro.

    Args:
        chemin_xml: Chemin vers le fichier XML
        chemin_sortie: Chemin de sortie du script (optionnel)
        simulation: Si True, retourne seulement les infos sans générer

    Returns:
        dict: Informations sur la macro (name, type_declencheur, actions...)
    """
    # Parser le XML pour extraire les infos
    tree = ET.parse(chemin_xml)
    root = tree.getroot()

    info = {
        'name': root.get('name', ''),
        'type_declencheur': root.find('declencheur').get('type', 'Inconnu') if root.find('declencheur') is not None else 'Inconnu',
        'actions': []
    }

    actions_elem = root.find('actions')
    if actions_elem is not None:
        for action in actions_elem.findall('action'):
            info['actions'].append({
                'id': action.get('id'),
                'type': action.get('type'),
                'label': action.get('label', '')
            })

    if not simulation:
        # Générer le script Bash via le shell script
        chemin_script = Path(__file__).parent / "generate_bash.sh"
        if chemin_sortie is None:
            chemin_sortie = str(chemin_xml).replace('.xml', '.sh')

        result = os.system(f"bash \"{chemin_script}\" \"{chemin_xml}\" \"{chemin_sortie}\"")
        if result != 0:
            raise RuntimeError(f"Échec de génération du script Bash: {chemin_xml}")

        info['chemin_sortie'] = chemin_sortie

    return info
