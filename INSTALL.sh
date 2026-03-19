#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="${HOME}/.local/bin"
LOCAL_SHARE="${HOME}/.local/share"
LOCAL_FONTS_DIR="${LOCAL_SHARE}/fonts"
CONFIG_ROOT="${HOME}/.config/linux-scripts"
RESTORE_CONFIG="${CONFIG_ROOT}/restore.conf"
SUMMARY_FILE="${CONFIG_ROOT}/last-install.txt"
AUTOSTART_DIR="${HOME}/.config/autostart"
CONKY_CONFIG_DIR="${HOME}/.config/conky"
NEMO_ACTIONS_DIR="${LOCAL_SHARE}/nemo/actions"
NEMO_ACTION_SCRIPTS_DIR="${NEMO_ACTIONS_DIR}/action_scripts"
GTK_CONFIG_DIR="${HOME}/.config/gtk-3.0"
LEGACY_MONITOR_CONFIG="${HOME}/.config/monitor_wallpapers.conf"
LOCK_AUTOSTART_FILE="${AUTOSTART_DIR}/linux-scripts-lock-screen.desktop"
MONITOR_AUTOSTART_FILE="${AUTOSTART_DIR}/linux-scripts-monitor-wallpapers.desktop"
CONKY_AUTOSTART_FILE="${AUTOSTART_DIR}/linux-scripts-conky.desktop"

CORE_APT_PACKAGES=(python3 x11-xserver-utils dbus-x11)
NEMO_APT_PACKAGES=(zenity xdotool wmctrl mediainfo-gui shellcheck imagemagick)
MONITOR_APT_PACKAGES=(feh)
CONKY_APT_PACKAGES=(conky-all jq curl net-tools lm-sensors mesa-utils bc)

print_header() {
    printf '\n== %s ==\n' "$1"
}

print_step() {
    printf '%s\n' "-- $1"
}

print_info() {
    printf '%s\n' "$1"
}

die() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

ensure_directories() {
    mkdir -p \
        "$LOCAL_BIN" \
        "$LOCAL_SHARE" \
        "$LOCAL_FONTS_DIR" \
        "$CONFIG_ROOT" \
        "$AUTOSTART_DIR" \
        "$CONKY_CONFIG_DIR" \
        "$NEMO_ACTIONS_DIR" \
        "$NEMO_ACTION_SCRIPTS_DIR" \
        "$GTK_CONFIG_DIR"
}

write_default_config() {
    cat > "$RESTORE_CONFIG" << EOF
# Shared restore config for Linux/Scripts

CONFIG_VERSION=1

# Installer behavior
INSTALL_APT_DEPENDENCIES=true
INSTALL_NEMO_ACTIONS=true
ENABLE_MONITOR_UPDATER=true
ENABLE_LOCK_SCREEN_AUTOSTART=true
ENABLE_MONITOR_AUTOSTART=true
ENABLE_CONKY=true
ENABLE_CONKY_AUTOSTART=true
INSTALL_CONKY_FONTS=true
INSTALL_GTK_OVERRIDE=false
EDIT_CONFIG_ON_CREATE=false

# Conky
CONKY_WIRED_INTERFACE=""
CONKY_WIFI_INTERFACE=""

# Lock screen slideshow
STATIC_BACKGROUND="/usr/share/backgrounds/linuxmint/default_background.jpg"
SLIDESHOW=true
SLIDESHOW_DIR="/usr/share/backgrounds"
SLIDESHOW_RANDOM=true
PERSISTENT_INDEX=true
INTERVAL=10
LOCK_SCREEN_INDEX_FILE="\${HOME}/.config/smurphos_lock_screen_index"
QUOTE_UPDATER_CMD="\${HOME}/.local/bin/linux-screensaver-quote-updater/lock_screen_updater"

# Monitor wallpapers
WALLPAPER_LEFT="/usr/share/backgrounds/xfce/xfce-teal.jpg"
WALLPAPER_RIGHT="/usr/share/backgrounds/xfce/xfce-verticals.jpg"
WALLPAPER_SINGLE="/usr/share/backgrounds/xfce/xfce-teal.jpg"
PICTURE_OPTIONS="zoom"
MONITOR_POLL_INTERVAL=2
MONITOR_TRIGGER_MODE="xrandr_active_monitors"
MONITOR_TRIGGER_CONNECTOR=""
EOF
}

ensure_config() {
    if [ ! -f "$RESTORE_CONFIG" ]; then
        print_step "Creating $RESTORE_CONFIG"
        write_default_config
        CONFIG_CREATED=true
    else
        CONFIG_CREATED=false
    fi
}

load_config() {
    # shellcheck disable=SC1090
    source "$RESTORE_CONFIG"
}

maybe_edit_config() {
    if [ "${CONFIG_CREATED:-false}" = true ] && [ "${EDIT_CONFIG_ON_CREATE:-true}" = true ]; then
        print_step "Opening config for review"
        "${EDITOR:-nano}" "$RESTORE_CONFIG"
        load_config
    fi
}

unique_packages() {
    awk '!seen[$0]++'
}

install_apt_dependencies() {
    [ "${INSTALL_APT_DEPENDENCIES:-true}" = true ] || return 0

    local -a packages=("${CORE_APT_PACKAGES[@]}")
    if [ "${INSTALL_NEMO_ACTIONS:-true}" = true ]; then
        packages+=("${NEMO_APT_PACKAGES[@]}")
    fi
    if [ "${ENABLE_MONITOR_UPDATER:-true}" = true ]; then
        packages+=("${MONITOR_APT_PACKAGES[@]}")
    fi
    if [ "${ENABLE_CONKY:-true}" = true ]; then
        packages+=("${CONKY_APT_PACKAGES[@]}")
    fi

    mapfile -t packages < <(printf '%s\n' "${packages[@]}" | unique_packages)
    [ "${#packages[@]}" -gt 0 ] || return 0

    print_header "APT Dependencies"
    print_info "Packages: ${packages[*]}"
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
}

copy_tree_contents() {
    local src="$1"
    local dest="$2"

    [ -d "$src" ] || return 0
    mkdir -p "$dest"
    cp -a "$src"/. "$dest"/
}

cleanup_nemo_bundle_files() {
    local nemo_root="${SCRIPT_DIR}/nemo_actions_and_cinnamon_scripts"
    local path
    local base

    for path in "$nemo_root"/.local/share/nemo/actions/*.nemo_action; do
        [ -f "$path" ] || continue
        rm -f "$NEMO_ACTIONS_DIR/$(basename "$path")"
    done

    for path in "$nemo_root"/.local/share/nemo/actions/action_scripts/*; do
        [ -f "$path" ] || continue
        rm -f "$NEMO_ACTION_SCRIPTS_DIR/$(basename "$path")"
    done

    for path in "$nemo_root"/.local/bin/*.sh; do
        [ -f "$path" ] || continue
        base="$(basename "$path")"
        [ "$base" = "lock_screen_slideshow.sh" ] && continue
        rm -f "$LOCAL_BIN/$base"
    done

    rmdir "$NEMO_ACTION_SCRIPTS_DIR" 2>/dev/null || true
}

install_nemo_bundle() {
    [ "${INSTALL_NEMO_ACTIONS:-true}" = true ] || return 0

    local nemo_root="${SCRIPT_DIR}/nemo_actions_and_cinnamon_scripts"
    [ -d "$nemo_root" ] || die "Missing nemo_actions_and_cinnamon_scripts"

    print_header "Nemo Bundle"

    print_step "Removing bundled Nemo actions and extra helpers"
    cleanup_nemo_bundle_files

    print_step "Installing lock screen slideshow helper"
    install -m 755 "$nemo_root/.local/bin/lock_screen_slideshow.sh" "$LOCAL_BIN/lock_screen_slideshow.sh"

    print_step "Integrating quote updater with slideshow script"
    if [ -n "${QUOTE_UPDATER_CMD:-}" ]; then
        sed -i '/gsettings set org.cinnamon.desktop.background picture-options "\$DESK_MODE"/a \
      # Update lock screen quote\n\
      if command -v "'"$QUOTE_UPDATER_CMD"'" >/dev/null 2>&1; then\n\
        "'"$QUOTE_UPDATER_CMD"'"\n\
      fi' "$LOCAL_BIN/lock_screen_slideshow.sh"
    fi

    if [ "${INSTALL_GTK_OVERRIDE:-false}" = true ] && [ -f "$nemo_root/.config/gtk-3.0/gtk.css" ]; then
        print_step "Installing GTK override"
        install -m 644 "$nemo_root/.config/gtk-3.0/gtk.css" "$GTK_CONFIG_DIR/gtk.css"
    fi
}

install_quote_updater() {
    local source_dir="${SCRIPT_DIR}/linux-screensaver-quote-updater"
    local dest_dir="${LOCAL_BIN}/linux-screensaver-quote-updater"

    [ -d "$source_dir" ] || die "Missing linux-screensaver-quote-updater"

    print_header "Quote Updater"
    mkdir -p "$dest_dir"

    install -m 755 "$source_dir/lock_screen_updater" "$dest_dir/lock_screen_updater"
    install -m 755 "$source_dir/get_random_quote.py" "$dest_dir/get_random_quote.py"
    install -m 644 "$source_dir/quotes.json" "$dest_dir/quotes.json"
}

install_monitor_updater() {
    [ "${ENABLE_MONITOR_UPDATER:-true}" = true ] || return 0

    local source_dir="${SCRIPT_DIR}/monitor-wallpaper-updater"
    [ -d "$source_dir" ] || die "Missing monitor-wallpaper-updater"

    print_header "Monitor Wallpaper Updater"
    install -m 755 "$source_dir/monitor_displays.sh" "$LOCAL_BIN/monitor_displays.sh"
    install -m 755 "$source_dir/xrandr_event_monitor.sh" "$LOCAL_BIN/xrandr_event_monitor.sh"
    install -m 755 "$source_dir/display_monitor.py" "$LOCAL_BIN/display_monitor.py"
    install -m 755 "$source_dir/setup_monitor_wallpapers.sh" "$LOCAL_BIN/setup_monitor_wallpapers.sh"

    ln -sfn "$RESTORE_CONFIG" "$LEGACY_MONITOR_CONFIG"
}

detect_monitor_trigger() {
    [ "${ENABLE_MONITOR_UPDATER:-true}" = true ] || die "Monitor updater is disabled in config."
    [ -x "$LOCAL_BIN/monitor_displays.sh" ] || die "Install the monitor updater first."

    print_header "Monitor Trigger Detection"
    print_info "Flip the KVM while the detector samples monitor state."
    "$LOCAL_BIN/monitor_displays.sh" detect-trigger "${1:-20}" "${2:-1}"
}

detect_default_interface() {
    local kind="$1"
    local iface

    for iface in /sys/class/net/*; do
        iface="$(basename "$iface")"
        [ "$iface" != "lo" ] || continue

        case "$kind" in
            wifi)
                [ -d "/sys/class/net/$iface/wireless" ] && {
                    printf '%s\n' "$iface"
                    return 0
                }
                ;;
            wired)
                [ ! -d "/sys/class/net/$iface/wireless" ] && {
                    printf '%s\n' "$iface"
                    return 0
                }
                ;;
        esac
    done

    return 1
}

replace_in_file() {
    local file="$1"
    local search="$2"
    local replace="$3"

    [ -f "$file" ] || return 0
    sed -i "s|$search|$replace|g" "$file"
}

configure_conky_files() {
    local wired_iface="${CONKY_WIRED_INTERFACE:-}"
    local wifi_iface="${CONKY_WIFI_INTERFACE:-}"

    if [ -z "$wired_iface" ]; then
        wired_iface="$(detect_default_interface wired || true)"
    fi
    if [ -z "$wifi_iface" ]; then
        wifi_iface="$(detect_default_interface wifi || true)"
    fi

    replace_in_file "$CONKY_CONFIG_DIR/conky_audio.conf" "/home/xcfvujvpqtaq" "$HOME"
    replace_in_file "$CONKY_CONFIG_DIR/conky_hdd.conf" "/home/xcfvujvpqtaq" "$HOME"
    replace_in_file "$CONKY_CONFIG_DIR/conky_lan.conf" "/home/xcfvujvpqtaq" "$HOME"
    replace_in_file "$CONKY_CONFIG_DIR/conky_wifi.conf" "/home/xcfvujvpqtaq" "$HOME"
    replace_in_file "$CONKY_CONFIG_DIR/conky.conf" "/home/nemanja" "$HOME"
    replace_in_file "$CONKY_CONFIG_DIR/conky.conf" "/media/nemanja" "/media/$USER"

    replace_in_file "$CONKY_CONFIG_DIR/ipscript/ipscript.sh" "/home/xcfvujvpqtaq" "$HOME"
    replace_in_file "$CONKY_CONFIG_DIR/storagescript/storagescript.sh" "/media/xcfvujvpqtaq" "/media/$USER"

    if [ -n "$wired_iface" ]; then
        replace_in_file "$CONKY_CONFIG_DIR/conky_lan.conf" "eno2" "$wired_iface"
    fi
    if [ -n "$wifi_iface" ]; then
        replace_in_file "$CONKY_CONFIG_DIR/conky_wifi.conf" "wlo1" "$wifi_iface"
    fi
}

install_conky_bundle() {
    [ "${ENABLE_CONKY:-true}" = true ] || return 0

    local conky_root="${SCRIPT_DIR}/MyConkyConfigs"

    [ -d "$conky_root" ] || die "Missing MyConkyConfigs"

    print_header "Conky Bundle"

    print_step "Installing Conky configs"
    copy_tree_contents "$conky_root/Configs" "$CONKY_CONFIG_DIR"

    print_step "Installing Conky helper scripts"
    copy_tree_contents "$conky_root/Scripts/audioscript" "$CONKY_CONFIG_DIR/audioscript"
    copy_tree_contents "$conky_root/Scripts/ipscript" "$CONKY_CONFIG_DIR/ipscript"
    copy_tree_contents "$conky_root/Scripts/ramscript" "$CONKY_CONFIG_DIR/ramscript"
    copy_tree_contents "$conky_root/Scripts/storagescript" "$CONKY_CONFIG_DIR/storagescript"

    configure_conky_files

    find "$CONKY_CONFIG_DIR" -type f \( -name '*.sh' -o -name '*.conf' \) -exec chmod 755 {} +
    [ -f "$CONKY_CONFIG_DIR/conkyx-start.sh" ] && chmod 755 "$CONKY_CONFIG_DIR/conkyx-start.sh"

    if [ "${INSTALL_CONKY_FONTS:-true}" = true ] && [ -d "$conky_root/Fonts" ]; then
        print_step "Installing Conky fonts"
        copy_tree_contents "$conky_root/Fonts" "$LOCAL_FONTS_DIR"
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -f "$LOCAL_FONTS_DIR" >/dev/null 2>&1 || true
        fi
    fi
}

write_lock_screen_autostart() {
    if [ "${INSTALL_NEMO_ACTIONS:-true}" = true ] && [ "${ENABLE_LOCK_SCREEN_AUTOSTART:-true}" = true ]; then
        cat > "$LOCK_AUTOSTART_FILE" << EOF
[Desktop Entry]
Type=Application
Name=Lock Screen Slideshow
Exec=${LOCAL_BIN}/lock_screen_slideshow.sh
Comment=Cinnamon lock screen slideshow with quote updater
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=30
EOF
    else
        rm -f "$LOCK_AUTOSTART_FILE"
    fi
}

write_monitor_autostart() {
    if [ "${ENABLE_MONITOR_UPDATER:-true}" = true ] && [ "${ENABLE_MONITOR_AUTOSTART:-true}" = true ]; then
        cat > "$MONITOR_AUTOSTART_FILE" << EOF
[Desktop Entry]
Type=Application
Name=Monitor Wallpaper Updater
Exec=${LOCAL_BIN}/monitor_displays.sh daemon
Comment=Update wallpapers when monitor layout changes
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=10
EOF
    else
        rm -f "$MONITOR_AUTOSTART_FILE"
    fi
}

write_conky_autostart() {
    if [ "${ENABLE_CONKY:-true}" = true ] && [ "${ENABLE_CONKY_AUTOSTART:-true}" = true ]; then
        cat > "$CONKY_AUTOSTART_FILE" << EOF
[Desktop Entry]
Type=Application
Name=Conky Startup
Exec=${CONKY_CONFIG_DIR}/conkyx-start.sh
Comment=Start Conky widgets at login
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=0
OnlyShowIn=X-Cinnamon;
EOF
    else
        rm -f "$CONKY_AUTOSTART_FILE"
    fi
}

setup_autostart() {
    print_header "Autostart"
    write_lock_screen_autostart
    write_monitor_autostart
    write_conky_autostart
}

write_summary() {
    local lock_autostart_enabled=false
    local monitor_autostart_enabled=false
    local conky_autostart_enabled=false

    if [ "${INSTALL_NEMO_ACTIONS:-true}" = true ] && [ "${ENABLE_LOCK_SCREEN_AUTOSTART:-true}" = true ]; then
        lock_autostart_enabled=true
    fi

    if [ "${ENABLE_MONITOR_UPDATER:-true}" = true ] && [ "${ENABLE_MONITOR_AUTOSTART:-true}" = true ]; then
        monitor_autostart_enabled=true
    fi

    if [ "${ENABLE_CONKY:-true}" = true ] && [ "${ENABLE_CONKY_AUTOSTART:-true}" = true ]; then
        conky_autostart_enabled=true
    fi

    cat > "$SUMMARY_FILE" << EOF
Date: $(date '+%Y-%m-%d %H:%M:%S')
Config: $RESTORE_CONFIG

Installed:
- Nemo bundle: ${INSTALL_NEMO_ACTIONS:-true}
- Quote updater: true
- Monitor updater: ${ENABLE_MONITOR_UPDATER:-true}
- Conky bundle: ${ENABLE_CONKY:-true}

Autostart:
- Lock screen: ${lock_autostart_enabled}
- Monitor updater: ${monitor_autostart_enabled}
- Conky: ${conky_autostart_enabled}

Key files:
- ${LOCAL_BIN}/lock_screen_slideshow.sh
- ${LOCAL_BIN}/linux-screensaver-quote-updater/lock_screen_updater
- ${LOCAL_BIN}/monitor_displays.sh
- ${CONKY_CONFIG_DIR}/conkyx-start.sh
- ${LOCK_AUTOSTART_FILE}
- ${MONITOR_AUTOSTART_FILE}
- ${CONKY_AUTOSTART_FILE}
EOF
}

show_summary() {
    print_header "Summary"
    cat "$SUMMARY_FILE"
}

maybe_run_usb_mount_blocker() {
    local blocker_script="${SCRIPT_DIR}/usb-mount-blocker/usb_mount_blocker.sh"
    local reply

    [ -t 0 ] || return 0
    [ -x "$blocker_script" ] || return 0

    print_header "USB Mount Blocker"
    printf 'Do you want to block some USB devices from automount now? (yes/no): '
    read -r reply

    case "${reply,,}" in
        y|yes)
            "$blocker_script" block
            ;;
        *)
            print_info "Skipping USB device blocking."
            ;;
    esac
}

run_modules() {
    local -a modules=(
        install_nemo_bundle
        install_quote_updater
        install_monitor_updater
        install_conky_bundle
    )
    local module
    for module in "${modules[@]}"; do
        "$module"
    done
}

run_install() {
    print_header "Linux Scripts Restore"
    ensure_directories
    ensure_config
    load_config
    maybe_edit_config
    install_apt_dependencies
    run_modules
    setup_autostart
    write_summary
    show_summary
    maybe_run_usb_mount_blocker
    print_info ""
    print_info "Next:"
    print_info "- Review config: ${RESTORE_CONFIG}"
    print_info "- Log out and log back in"
    print_info "- Test lock screen quotes, monitor wallpaper updates, and Conky startup"
}

show_usage() {
    cat << EOF
Usage: $(basename "$0") [command]

Commands:
  install   Full restore flow (default)
  upgrade   Re-run install steps using existing config
  detect-monitor-trigger  Sample monitor signals while you switch the KVM
  deps      Install apt dependencies only
  config    Open shared config
  summary   Show last install summary
  help      Show this help

Config file:
  $RESTORE_CONFIG
EOF
}

main() {
    local command="${1:-install}"

    case "$command" in
        install|upgrade)
            run_install
            ;;
        deps)
            ensure_directories
            ensure_config
            load_config
            install_apt_dependencies
            ;;
        detect-monitor-trigger)
            ensure_directories
            ensure_config
            load_config
            install_monitor_updater
            detect_monitor_trigger "${2:-20}" "${3:-1}"
            ;;
        config)
            ensure_directories
            ensure_config
            "${EDITOR:-nano}" "$RESTORE_CONFIG"
            ;;
        summary)
            [ -f "$SUMMARY_FILE" ] || die "No summary yet. Run install first."
            cat "$SUMMARY_FILE"
            ;;
        help|-h|--help)
            show_usage
            ;;
        *)
            die "Unknown command: $command"
            ;;
    esac
}

main "$@"
