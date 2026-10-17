#!/usr/bin/env bash
#
# Neo Brutalism sway dotfiles — installer
#
#   ./install.sh                 full install (packages, fonts, configs, theme)
#   ./install.sh --help          options
#
# Supports Arch Linux (and derivatives) and Ubuntu (24.04+, Quickshell needs 25.04+).

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="$CONFIG_HOME/sway"
QUICKSHELL_REF="v0.3.2"

# options
YES=0
DO_PACKAGES=1
DO_FONTS=1
DO_QUICKSHELL=1
DO_SERVICES=1
DO_SDDM=1
LINK_MODE="link"
THEME_MODE="dark"

# ------------------------------------------------------------------ helpers --
if [[ -t 1 ]]; then
	B=$'\e[1m'; R=$'\e[31m'; G=$'\e[32m'; Y=$'\e[33m'; C=$'\e[36m'; N=$'\e[0m'
else
	B=""; R=""; G=""; Y=""; C=""; N=""
fi
step() { printf '\n%s■ %s%s\n' "$B$C" "$*" "$N"; }
info() { printf '  %s\n' "$*"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$N" "$*"; }
warn() { printf '  %s!%s %s\n' "$Y" "$N" "$*" >&2; }
die()  { printf '%s✗ %s%s\n' "$R" "$*" "$N" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# read a package list : strip comments / blank lines
read_list() { sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^$' || true; }

confirm() {
	(( YES )) && return 0
	local reply
	read -r -p "  $1 [Y/n] " reply
	[[ -z "$reply" || "$reply" =~ ^[YyOo] ]]
}

usage() {
	cat <<- EOF
		${B}Neo Brutalism sway dotfiles${N}

		Usage: ./install.sh [options]

		  -y, --yes            don't ask for confirmation
		      --copy           copy the config instead of symlinking it to this repo
		      --mode MODE      initial theme : dark (default) or light
		      --no-packages    skip system packages
		      --no-fonts       skip fonts (Nerd Font download on Ubuntu)
		      --no-quickshell  skip building Quickshell on Ubuntu
		      --no-services    don't enable NetworkManager / bluetooth
		      --no-sddm        don't install the SDDM login theme
		      --config-only    same as --no-packages --no-fonts --no-quickshell --no-services --no-sddm
		  -h, --help           this help
	EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		-y|--yes)        YES=1 ;;
		--copy)          LINK_MODE="copy" ;;
		--mode)          shift; THEME_MODE="${1:-}"; [[ "$THEME_MODE" == light || "$THEME_MODE" == dark ]] || die "--mode : light or dark" ;;
		--no-packages)   DO_PACKAGES=0 ;;
		--no-fonts)      DO_FONTS=0 ;;
		--no-quickshell) DO_QUICKSHELL=0 ;;
		--no-services)   DO_SERVICES=0 ;;
		--no-sddm)       DO_SDDM=0 ;;
		--config-only)   DO_PACKAGES=0; DO_FONTS=0; DO_QUICKSHELL=0; DO_SERVICES=0; DO_SDDM=0 ;;
		-h|--help)       usage; exit 0 ;;
		*)               usage; die "unknown option : $1" ;;
	esac
	shift
done

[[ $EUID -eq 0 ]] && die "run as your normal user (sudo is used when needed), not as root"

# ------------------------------------------------------------------ distro ---
detect_distro() {
	[[ -r /etc/os-release ]] || die "/etc/os-release not found"
	# shellcheck source=/dev/null
	. /etc/os-release
	local ids=" ${ID:-} ${ID_LIKE:-} "
	if [[ "$ids" == *" arch "* ]]; then
		DISTRO="arch"
	elif [[ "$ids" == *" ubuntu "* || "$ids" == *" debian "* ]]; then
		DISTRO="ubuntu"
	else
		die "unsupported distribution : ${PRETTY_NAME:-$ID} (Arch or Ubuntu only)"
	fi
	DISTRO_NAME="${PRETTY_NAME:-$ID}"
}

# ------------------------------------------------------------------ arch -----
aur_helper() {
	if have paru; then echo paru; elif have yay; then echo yay; fi
}

install_arch() {
	step "Packages (pacman)"
	local pkgs; mapfile -t pkgs < <(read_list "$REPO/packages/arch.txt")
	local flags=(--needed); (( YES )) && flags+=(--noconfirm)
	sudo pacman -Syu "${flags[@]}" "${pkgs[@]}"
	ok "${#pkgs[@]} packages"

	step "Packages (AUR)"
	local aur; mapfile -t aur < <(read_list "$REPO/packages/arch-aur.txt")
	(( ${#aur[@]} )) || return 0

	local helper; helper="$(aur_helper)"
	if [[ -z "$helper" ]]; then
		info "no AUR helper found, bootstrapping yay-bin"
		local tmp; tmp="$(mktemp -d)"
		git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
		(cd "$tmp/yay-bin" && makepkg -si --noconfirm)
		rm -rf "$tmp"
		helper="yay"
	fi
	local aflags=(--needed); (( YES )) && aflags+=(--noconfirm)
	"$helper" -S "${aflags[@]}" "${aur[@]}"
	ok "AUR : ${aur[*]}"
}

# ------------------------------------------------------------------ ubuntu ---
apt_install_available() {
	# install every package of the list that exists in the configured repos
	local list="$1" pkgs=() missing=() p
	while read -r p; do
		if apt-cache show "$p" >/dev/null 2>&1; then pkgs+=("$p"); else missing+=("$p"); fi
	done < <(read_list "$list")
	(( ${#missing[@]} )) && warn "not available on this release, skipped : ${missing[*]}"
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${pkgs[@]}"
	ok "${#pkgs[@]} packages"
}

install_ubuntu() {
	step "Packages (apt)"
	sudo apt-get update -qq
	have apt-add-repository || sudo apt-get install -y software-properties-common >/dev/null
	sudo add-apt-repository -y universe >/dev/null 2>&1 || true
	sudo apt-get update -qq
	apt_install_available "$REPO/packages/ubuntu.txt"
}

qt_version_ok() {
	local v
	v="$(apt-cache policy qt6-base-dev 2>/dev/null | awk '/Candidate:/{print $2}')"
	[[ -n "$v" && "$v" != "(none)" ]] && dpkg --compare-versions "$v" ge 6.6
}

build_quickshell_ubuntu() {
	step "Quickshell (build from source)"
	if have qs; then ok "already installed : $(qs --version 2>/dev/null | head -1)"; return; fi
	if ! qt_version_ok; then
		warn "Qt >= 6.6 required (Ubuntu 25.04+) — skipping. Waybar clicks fall back to pavucontrol / blueman / nm-connection-editor."
		return
	fi

	apt_install_available "$REPO/packages/ubuntu-quickshell-build.txt"

	if ( _build_quickshell ); then
		ok "$(qs --version 2>/dev/null | head -1)"
	else
		warn "Quickshell build failed — waybar clicks fall back to classic tools (retry : ./install.sh --no-packages)"
	fi
}

_build_quickshell() {
	set -e
	local tmp multiarch
	tmp="$(mktemp -d)"
	multiarch="$(dpkg-architecture -qDEB_HOST_MULTIARCH 2>/dev/null || echo x86_64-linux-gnu)"
	git clone --depth 1 --branch "$QUICKSHELL_REF" https://github.com/quickshell-mirror/quickshell.git "$tmp/quickshell" \
		|| git clone --depth 1 https://github.com/quickshell-mirror/quickshell.git "$tmp/quickshell"

	cmake -S "$tmp/quickshell" -B "$tmp/build" -G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DINSTALL_QML_PREFIX="lib/$multiarch/qt6/qml" \
		-DDISTRIBUTOR="neobrutal-dotfiles" \
		-DCRASH_HANDLER=OFF \
		-DHYPRLAND=OFF
	cmake --build "$tmp/build"
	sudo cmake --install "$tmp/build"
	rm -rf "$tmp"
}

install_nerd_font_ubuntu() {
	step "Fonts"
	local dir="$HOME/.local/share/fonts/JetBrainsMonoNerd"
	if fc-list : family | grep -qi "JetBrainsMono Nerd Font"; then
		ok "JetBrainsMono Nerd Font already installed"
	else
		mkdir -p "$dir"
		curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
			| tar -xJ -C "$dir"
		ok "JetBrainsMono Nerd Font → $dir"
	fi
	fc-cache -f >/dev/null
}

# ------------------------------------------------------------------ common ---
enable_services() {
	step "Services"
	local s
	for s in NetworkManager bluetooth; do
		if sudo systemctl enable --now "$s" >/dev/null 2>&1; then ok "$s enabled"; else warn "could not enable $s"; fi
	done
	# brightness without root (brightnessctl udev rules use the video group)
	if getent group video >/dev/null && ! id -nG "$USER" | grep -qw video; then
		sudo usermod -aG video "$USER" && ok "$USER added to group video (re-login needed)"
	fi
}

link_config() {
	step "Config → $TARGET ($LINK_MODE)"
	mkdir -p "$CONFIG_HOME"

	if [[ -L "$TARGET" && "$(readlink -f "$TARGET")" == "$REPO/config/sway" ]]; then
		ok "already linked"
	else
		if [[ -e "$TARGET" || -L "$TARGET" ]]; then
			local backup="$TARGET.backup-$(date +%Y%m%d-%H%M%S)"
			mv "$TARGET" "$backup"
			info "existing config moved to $backup"
		fi
		if [[ "$LINK_MODE" == "link" ]]; then
			ln -s "$REPO/config/sway" "$TARGET"
		else
			cp -a "$REPO/config/sway" "$TARGET"
		fi
		ok "installed"
	fi

	find "$TARGET/" -path '*/scripts/*' -type f -exec chmod +x {} +
	chmod +x "$TARGET"/theme/*.sh "$TARGET"/waybar/{player,spotify,themeswitch} "$TARGET"/wlogout/actions 2>/dev/null || true
	have xdg-user-dirs-update && xdg-user-dirs-update || true
}

init_theme() {
	step "Theme ($THEME_MODE)"
	# outside of a sway session the live-reload calls just fail silently
	"$TARGET/theme/neobrutal.sh" "$THEME_MODE" >/dev/null 2>&1 || true
	[[ -f "$TARGET/sway-colors" ]] || die "theme generation failed (try : $TARGET/theme/neobrutal.sh $THEME_MODE)"
	ok "colors generated for sway, waybar, mako, wofi, rofi, terminals, quickshell, chromium"
}

install_sddm_theme() {
	step "Login screen (SDDM)"
	if ! have sddm; then
		info "sddm not installed, skipped (theme : sddm/install.sh)"
		return
	fi
	if "$REPO/sddm/install.sh"; then
		ok "neobrutal theme set as the SDDM theme"
	else
		warn "SDDM theme install failed (retry : sddm/install.sh)"
	fi
}

check_tools() {
	step "Check"
	local t missing=()
	for t in sway waybar mako wofi swaybg jq grim slurp playerctl notify-send; do
		have "$t" || missing+=("$t")
	done
	have magick || have convert || missing+=("imagemagick")
	have brightnessctl || have light || missing+=("brightnessctl")
	have hyprlock || have swaylock || missing+=("swaylock")
	have qs || warn "quickshell missing : waybar clicks use fallback tools"
	have wlogout || warn "wlogout missing : power menu (\$mod+x) won't open"
	if (( ${#missing[@]} )); then warn "missing : ${missing[*]}"; else ok "all core tools found"; fi
}

# ------------------------------------------------------------------ main -----
detect_distro

printf '%s\n' "${B}Neo Brutalism sway dotfiles${N}"
info "distro  : $DISTRO_NAME ($DISTRO)"
info "repo    : $REPO"
info "target  : $TARGET ($LINK_MODE)"
info "theme   : $THEME_MODE"
info "steps   : packages=$DO_PACKAGES fonts=$DO_FONTS quickshell=$DO_QUICKSHELL services=$DO_SERVICES sddm=$DO_SDDM"
confirm "Continue ?" || exit 0

if (( DO_PACKAGES )); then
	have sudo || die "sudo is required"
	case "$DISTRO" in
		arch)   install_arch ;;
		ubuntu) install_ubuntu ;;
	esac
fi

if [[ "$DISTRO" == "ubuntu" ]]; then
	(( DO_FONTS )) && install_nerd_font_ubuntu
	(( DO_QUICKSHELL )) && build_quickshell_ubuntu
elif (( DO_FONTS )); then
	have fc-cache && fc-cache -f >/dev/null
fi

(( DO_SERVICES )) && enable_services
link_config
init_theme
(( DO_SDDM )) && install_sddm_theme
check_tools

step "Done"
info "Log out and pick ${B}Sway${N} in your display manager (or run ${B}sway${N} from a TTY)."
info "Toggle light/dark : waybar ☀/☾ button or \$mod+Shift+t"
info "Chromium theme    : chrome://extensions → Developer mode → Load unpacked → $TARGET/chromium/neobrutal-theme"
