# Neo Brutalism · sway dotfiles

Config sway complète au style **neo-brutalism** (bordures noires épaisses, ombres dures sans flou, couleurs plates saturées), avec un thème **clair** et **sombre** basculable en un clic.

- **sway** : bordures 3 px, gaps, fond d'écran à grille généré
- **waybar** : modules en « chips » à ombre portée, icônes seules, bouton ☀/☾
- **Quickshell** : panneaux au clic sur la waybar
  - Bluetooth (on/off, appareils, recherche, appairage)
  - Son (sortie/entrée, volumes)
  - Luminosité (25/50/75/100 %, réglage fin par 5 %)
  - Wi-Fi (on/off, réseaux connus, recherche, mot de passe)
  - Calendrier (lun→dim, n° de semaine, fête du jour)
- **mako**, **wofi**, **rofi**, **wlogout**, **hyprlock** / swaylock
- **alacritty**, **kitty**, **foot**
- **GTK** (clair/sombre) et thème **Chromium**
- **SDDM** : écran de connexion (choix utilisateur et session), suit le mode clair/sombre

## Installation

```sh
git clone https://github.com/XenoX/sway-neobrutalism.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Le script :

1. installe les paquets (`packages/arch.txt` + AUR, ou `packages/ubuntu.txt`) ;
2. installe les polices (JetBrains Mono + Nerd Font) ;
3. sur Ubuntu, **compile Quickshell** (Qt ≥ 6.6, donc Ubuntu 25.04+) ;
4. active NetworkManager et bluetooth ;
5. relie `~/.config/sway` vers `config/sway` du dépôt (lien symbolique ; l'ancienne config est sauvegardée en `~/.config/sway.backup-*`) ;
6. génère les couleurs du thème ;
7. si SDDM est présent, installe le thème de connexion `neobrutal` (`/usr/share/sddm/themes/neobrutal`, activé via `/etc/sddm.conf.d/zz-neobrutal.conf`).

Ensuite, déconnecte-toi et choisis la session **Sway**.

### Options

| Option | Effet |
|---|---|
| `-y`, `--yes` | aucune question |
| `--mode light\|dark` | thème initial (défaut : `dark`) |
| `--copy` | copie la config au lieu de la lier au dépôt |
| `--config-only` | uniquement la config, sans paquets, polices ni services |
| `--no-packages`, `--no-fonts`, `--no-quickshell`, `--no-services`, `--no-sddm` | sauter une étape |

### Distributions

| | Arch (et dérivées) | Ubuntu 25.04+ | Ubuntu 24.04 |
|---|---|---|---|
| sway, waybar, mako… | pacman | apt | apt |
| wlogout | AUR (yay installé si besoin) | apt | apt |
| Quickshell | pacman | compilé depuis les sources | ✗ (Qt trop ancien) |
| hyprlock | pacman | apt | ✗ → swaylock |
| Nerd Font | pacman | téléchargée | téléchargée |

Sans Quickshell, les clics de la waybar ouvrent `blueman-manager`, `pavucontrol` et `nm-connection-editor`.

## Utilisation

| | |
|---|---|
| Thème (mode + couleur principale) | clic sur le bouton ☀/☾ de la waybar : panneau clair/sombre et nuancier |
| Basculer clair/sombre | clic droit sur ☀/☾ ou `$mod+Shift+t` |
| Lanceur | `$mod+r` |
| Menu d'extinction | `$mod+x` |
| Panneaux | clic sur les icônes de la waybar (Échap ou clic à côté pour fermer) |

Le thème en ligne de commande :

```sh
~/.config/sway/theme/neobrutal.sh light|dark|toggle|apply|status
~/.config/sway/theme/neobrutal.sh accent yellow|red|blue|green|purple|orange|cyan|pink|default
```

La couleur principale colore les bordures sway, la barre, les menus, le curseur et l'écran de connexion. `default` revient aux couleurs des palettes.

### Curseur

`theme/cursor/build.sh` (lancé par `install.sh`) génère une variante de [Simp1e](https://gitlab.com/cursors/simp1e) par couleur (`Neobrutal-Yellow`, `Neobrutal-Red`…) : contour noir, ombre noire décalée. Changer de couleur ne fait que basculer de variante.

### Changer les couleurs

Les palettes sont dans `config/sway/theme/neobrutal/{light,dark}.bash`. Après modification :

```sh
~/.config/sway/theme/neobrutal.sh apply
```

Les fichiers de couleurs (`sway-colors`, `waybar/colors.css`, `mako/colors`, `quickshell/colors.json`…) sont **générés** et ignorés par git. Basculer de thème ne modifie donc pas le dépôt.

### Thème Chromium

`chrome://extensions` → Mode développeur → *Charger l'extension non empaquetée* → `~/.config/sway/chromium/neobrutal-theme`.
Chromium relit le thème au redémarrage.

### Écran de connexion (SDDM)

```sh
sddm/install.sh          # installe et active le thème (sudo)
sddm/install.sh --test   # aperçu dans une fenêtre, sans root
```

Les palettes sont reprises de `config/sway/theme/neobrutal/*.bash` à l'installation (relancer `sddm/install.sh` après les avoir modifiées). Le mode clair/sombre, la couleur principale et le curseur suivent le panneau Thème sans sudo. L'avatar affiché est `~/.face`, copié dans `/usr/share/sddm/faces/`.

## Spécifique à la machine

- `config/sway/config` : noms des écrans (`$main_monitor`, `$laptop_monitor`…) et affectation des workspaces. Pour connaître les noms : `swaymsg -t get_outputs`.
- `config/sway/scripts/statusbar` : écrans externes qui déclenchent la config waybar multi-écrans.

## Structure

```
install.sh                  installeur Arch / Ubuntu
packages/                   listes de paquets
config/sway/
├── config, sway-*          sway
├── theme/neobrutal.sh      générateur de thème (clair/sombre, couleur principale)
├── theme/cursor/           curseurs Neobrutal (build depuis Simp1e)
├── theme/neobrutal/        palettes
├── waybar/                 barre + scripts des modules
├── quickshell/             panneaux (QML) + data/fetes.json
├── mako/ wofi/ rofi/ wlogout/
├── alacritty/ kitty/ foot/
├── chromium/               thème Chromium (généré)
└── scripts/                lanceurs, luminosité, son, capture…
```

## Crédits

Base de config et scripts : [Archcraft](https://github.com/archcraft-os) (Aditya Shakya, GPL-3.0).
Fêtes du jour : [calendriergratuit.fr](https://www.calendriergratuit.fr/).
Inspiration : [neubrutalism.com](https://neubrutalism.com/).
