# -*- coding: utf-8 -*-
#------------------------------------------------------------------------------
# Fichier: model.py
# Description: Logique métier (sauvegarde, chargement, conversion)
# Encodage: fr_FR.UTF-8
#------------------------------------------------------------------------------

import json
import xml.etree.ElementTree as ET
from pathlib import Path

# IMPORT ABSOLU (compatible pytest)
from config import APP_NAME, DEFAULT_CONFIG

CONFIG_DIR = Path.home() / ".config" / APP_NAME
MACRO_DIR = CONFIG_DIR / "macros"
CONF_FILE = CONFIG_DIR / "macrosTitux.conf"

def init_dirs():
    """Crée les dossiers de configuration."""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    MACRO_DIR.mkdir(parents=True, exist_ok=True)
    if not CONF_FILE.exists():
        with open(CONF_FILE, 'w') as f:
            json.dump(DEFAULT_CONFIG, f, indent=4, ensure_ascii=False)

def load_config():
    """Charge la configuration utilisateur."""
    with open(CONF_FILE, 'r') as f:
        return json.load(f)

def load_macros_list():
    """Liste toutes les macros enregistrées."""
    macros = []
    for f in MACRO_DIR.glob("*.xml"):
        tree = ET.parse(f)
        root = tree.getroot()
        name = root.get('name')
        trigger_label = root.find('trigger').get('label', '-') if root.find('trigger') is not None else '-'
        actions = root.findall('actions/action')
        action_label = actions[0].get('label', '-') if actions else '-'
        macros.append((name, trigger_label, action_label))
    return macros

def save_macro(name, trigger_data, variables, actions, constraints):
    """Sauvegarde une macro au format XML."""
    root = ET.Element("macro")
    root.set('name', name)

    # Trigger
    trigger = ET.SubElement(root, "trigger")
    trigger.set('type', trigger_data['type'])
    trigger.set('label', trigger_data['label'])
    trigger_cfg = ET.SubElement(trigger, "config")
    for k, v in trigger_data['params'].items():
        param = ET.SubElement(trigger_cfg, "param")
        param.set('key', k)
        param.set('value', str(v))

    # Variables
    vars_elem = ET.SubElement(root, "variables")
    for var in variables:
        if var.get('name'):
            v = ET.SubElement(vars_elem, "var")
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
            p = ET.SubElement(cfg, "param")
            p.set('key', k)
            p.set('value', str(v))

    # Contraintes
    constraints_elem = ET.SubElement(root, "constraints")
    for constraint in constraints:
        c_el = ET.SubElement(constraints_elem, "constraint")
        c_el.set('id', constraint.get('id', '1'))
        c_el.set('type', constraint['type'])
        c_el.set('label', constraint.get('label', ''))
        cfg = ET.SubElement(c_el, "config")
        for k, v in constraint.get('params', {}).items():
            p = ET.SubElement(cfg, "param")
            p.set('key', k)
            p.set('value', str(v))

    tree = ET.ElementTree(root)
    ET.indent(tree, space="    ")
    with open(MACRO_DIR / f"{name}.xml", 'wb') as f:
        tree.write(f, encoding='utf-8', xml_declaration=True)
