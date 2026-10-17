# Neo Brutalism · sway dotfiles

A complete sway setup in the **neo-brutalism** style (thick black borders, hard shadows with no blur, flat saturated colors), with a **light** and a **dark** theme, a choice of main color and a system-wide zoom.

- **sway**: 3 px borders, gaps, generated grid wallpaper
- **waybar**: modules as "chips" with drop shadows, icons only, ☀/☾ button
- **Quickshell**: panels opened from the waybar
  - Theme (light/dark, main color, cursor size, zoom)
  - Bluetooth (on/off, devices, scan, pairing)
  - Sound (output/input, volumes)
  - Brightness (25/50/75/100 %, fine-tuning in 5 % steps)
  - Wi-Fi (on/off, known networks, scan, password)
  - Calendar (Mon→Sun, week numbers, French name day of the day)
- **Cursor**: Simp1e recolored with the main color, hard offset shadow
- **mako**, **wofi**, **rofi**, **wlogout**, **hyprlock** / swaylock
- **alacritty**, **kitty**, **foot**
- **GTK** (light/dark) and a **Chromium** theme
- **SDDM**: login screen (user and session picker), follows the theme

## Installation

```sh
git clone https://github.com/XenoX/sway-neobrutalism.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script:

1. installs the packages (`packages/arch.txt` + AUR, or `packages/ubuntu.txt`);
2. installs the fonts (JetBrains Mono + Nerd Font);
3. on Ubuntu, **builds Quickshell** (Qt ≥ 6.6, so Ubuntu 25.04+);
4. enables NetworkManager and bluetooth;
5. links `~/.config/sway` to the repo's `config/sway` (symlink; the previous config is backed up as `~/.config/sway.backup-*`);
6. builds the Neobrutal cursors;
7. generates the theme colors;
8. if SDDM is installed, installs the `neobrutal` login theme (`/usr/share/sddm/themes/neobrutal`, enabled through `/etc/sddm.conf.d/zz-neobrutal.conf`).

Then log out and pick the **Sway** session.

### Options

| Option | Effect |
|---|---|
| `-y`, `--yes` | no questions |
| `--mode light\|dark` | initial theme (default: `dark`) |
| `--copy` | copy the config instead of linking it to the repo |
| `--config-only` | config only, no packages, fonts or services |
| `--no-packages`, `--no-fonts`, `--no-quickshell`, `--no-services`, `--no-sddm` | skip a step |

### Distributions

| | Arch (and derivatives) | Ubuntu 25.04+ | Ubuntu 24.04 |
|---|---|---|---|
| sway, waybar, mako… | pacman | apt | apt |
| wlogout | AUR (yay installed if needed) | apt | apt |
| Quickshell | pacman | built from source | ✗ (Qt too old) |
| hyprlock | pacman | apt | ✗ → swaylock |
| Nerd Font | pacman | downloaded | downloaded |

Without Quickshell, waybar clicks open `blueman-manager`, `pavucontrol` and `nm-connection-editor`, and the ☀/☾ button toggles light/dark.

## Usage

| | |
|---|---|
| Theme (mode, color, cursor, zoom) | click the ☀/☾ waybar button: light/dark, color picker, cursor size, zoom |
| Toggle light/dark | right click on ☀/☾ or `$mod+Shift+t` |
| Launcher | `$mod+r` |
| Power menu | `$mod+x` |
| Panels | click the waybar icons (Esc or click outside to close) |

The theme from the command line:

```sh
~/.config/sway/theme/neobrutal.sh light|dark|toggle|apply|status
~/.config/sway/theme/neobrutal.sh accent yellow|red|blue|green|purple|orange|cyan|pink|default
~/.config/sway/theme/neobrutal.sh cursor-size 24|32|48|72|default
~/.config/sway/theme/neobrutal.sh zoom 80|90|100|110|120|default
```

The main color is used for the sway borders, the bar, the menus, the cursor and the login screen. `default` goes back to the palette colors.

The zoom is the sway output scale, applied to every screen. The `output … pos` lines of `config/sway/config` are meant for 100 %: they are divided by the zoom in the generated `sway-zoom`, so the screens stay side by side.

### Cursor

`theme/cursor/build.sh` (run by `install.sh`) builds one variant of [Simp1e](https://gitlab.com/cursors/simp1e) per color (`Neobrutal-Yellow`, `Neobrutal-Red`…): black outline, offset black shadow. Changing the color just switches variants.

### Changing the colors

The palettes live in `config/sway/theme/neobrutal/{light,dark}.bash`. After editing them:

```sh
~/.config/sway/theme/neobrutal.sh apply
```

The color files (`sway-colors`, `waybar/colors.css`, `mako/colors`, `quickshell/colors.json`…) are **generated** and ignored by git, so switching themes doesn't touch the repo.

### Chromium theme

`chrome://extensions` → Developer mode → *Load unpacked* → `~/.config/sway/chromium/neobrutal-theme`.
Chromium reloads the theme on restart.

### Login screen (SDDM)

```sh
sddm/install.sh          # install and enable the theme (sudo)
sddm/install.sh --test   # preview in a window, no root needed
```

The palettes are taken from `config/sway/theme/neobrutal/*.bash` at install time (run `sddm/install.sh` again after editing them). The light/dark mode, the main color and the cursor follow the Theme panel without sudo. The avatar is `~/.face`, copied to `/usr/share/sddm/faces/`.

## Machine-specific

- `config/sway/config`: screen names (`$main_monitor`, `$laptop_monitor`…), their positions and the workspace assignments. To get the names: `swaymsg -t get_outputs`.
- `config/sway/scripts/statusbar`: external screens that trigger the multi-screen waybar config.

## Layout

```
install.sh                  Arch / Ubuntu installer
packages/                   package lists
config/sway/
├── config, sway-*          sway
├── theme/neobrutal.sh      theme generator (light/dark, main color, cursor, zoom)
├── theme/cursor/           Neobrutal cursors (built from Simp1e)
├── theme/neobrutal/        palettes
├── waybar/                 bar + module scripts
├── quickshell/             panels (QML) + data/fetes.json
├── mako/ wofi/ rofi/ wlogout/
├── alacritty/ kitty/ foot/
├── chromium/               Chromium theme (generated)
└── scripts/                launchers, brightness, sound, screenshots…
```

## Credits

Config base and scripts: [Archcraft](https://github.com/archcraft-os) (Aditya Shakya, GPL-3.0).
Name days: [calendriergratuit.fr](https://www.calendriergratuit.fr/).
Cursors: [Simp1e](https://gitlab.com/cursors/simp1e) (GPL-3.0).
Inspiration: [neubrutalism.com](https://neubrutalism.com/).
