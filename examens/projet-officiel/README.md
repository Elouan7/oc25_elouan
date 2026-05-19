# Datacenter Rack — Godot 4.6.2
Rack de datacenter 42U procédural avec LEDs animées.

## Installation rapide

1. Copie `DatacenterRack.gd` et `DatacenterRack.tscn` dans `res://` de ton projet.
2. Ouvre `DatacenterRack.tscn` dans l'éditeur Godot.
3. Lance la scène (F6) — le rack se construit automatiquement.

Ou intègre-le dans une scène existante :
- Ajoute un `Node3D`
- Attache `DatacenterRack.gd` dessus
- C'est tout.

## Paramètres exportés (Inspector)

| Propriété | Défaut | Description |
|---|---|---|
| `rack_units` | 42 | Hauteur du rack en U |
| `unit_height` | 0.04445 | Hauteur d'1U en mètres (standard réel) |
| `rack_width` | 0.482 | Largeur intérieure 19 pouces |
| `rack_depth` | 0.900 | Profondeur du rack |
| `led_light_range` | 0.08 | Portée des OmniLight3D des LEDs |
| `led_light_energy` | 1.2 | Intensité max des lumières LED |
| `enable_lights` | true | Active/désactive les OmniLight3D (perf) |

## Types de LEDs

| Couleur | Type | Comportement |
|---|---|---|
| 🔵 Bleu | `power` | Pulsation lente — alimentation OK |
| 🟢 Vert | `network` | Clignotement rapide irrégulier — trafic réseau |
| 🟠 Orange | `disk` | Flashs courts — accès disque |
| 🔴 Rouge | `alert` | Blink on/off — erreur / alerte |

## Ajouter des types de serveurs

Dans `SERVER_TEMPLATES`, chaque entrée est :
```gdscript
[nb_U, "Nom", couleur_hex, ["type_led1", "type_led2", ...]]
```

Exemple — ajouter un GPU Server 4U :
```gdscript
[4, "GPU Server", 0x0d0d1a, ["power", "power", "network", "disk", "disk"]],
```

## Performance

- Par défaut, chaque LED crée un `OmniLight3D`. Sur un rack complet (~80 LEDs),
  ça peut peser selon ta scène. Passe `enable_lights = false` dans l'Inspector
  pour garder uniquement l'émission des mesh (très léger, encore beau).
- Les matériaux sont recréés par LED — pour un usage en production avec
  beaucoup de racks, mutualise-les dans un dictionnaire statique.

## Intégration dans un datacenter complet

```gdscript
# Instancie plusieurs racks en rangée
var rack_scene = preload("res://DatacenterRack.tscn")
for i in 5:
    var rack = rack_scene.instantiate()
    rack.position = Vector3(i * 0.7, 0, 0)
    add_child(rack)
```
