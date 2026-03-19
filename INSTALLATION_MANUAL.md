# Complete System Installation Guide

After a fresh Linux installation, use this setup to restore the script collection, including the Conky desktop widgets.

## Quick Start

### Step 1: Clone or copy your scripts
```bash
git clone <your-repo-url> ~/Documents/Linux/Scripts
cd ~/Documents/Linux/Scripts

# Or copy the directory from another disk or backup:
# cp -r /path/to/Linux/Scripts ~/Documents/
```

### Step 2: Run the install script
```bash
./INSTALL.sh
```

On first run the installer creates `~/.config/linux-scripts/restore.conf`. That file controls which modules are enabled, including Conky, monitor wallpaper updates, and autostart behavior.

### Step 3: Log out and back in
The autostart entries take effect on the next session.

## What Gets Installed

### 1. Quote updater
- Location: `~/.local/bin/linux-screensaver-quote-updater/`
- Function: Updates the Cinnamon lock-screen quote from `quotes.json`
- Autostart: `~/.config/autostart/linux-scripts-lock-screen.desktop`

### 2. Lock screen slideshow integration
- Location: `~/.local/bin/lock_screen_slideshow.sh`
- Function: Starts the Cinnamon lock-screen slideshow and quote integration
- Autostart: 30 seconds after login when enabled

### 3. Nemo actions
- Location: `~/.local/share/nemo/actions/`
- Function: Installs the bundled Nemo actions and helper scripts

### 4. Monitor wallpaper updater
- Location: `~/.local/bin/monitor_displays.sh`
- Function: Watches display changes and reapplies wallpapers
- Config: `~/.config/monitor_wallpapers.conf`
- Autostart: `~/.config/autostart/linux-scripts-monitor-wallpapers.desktop`

### 5. Conky bundle
- Location: `~/.config/conky/`
- Function: Installs the Conky widget configs, launcher, and helper scripts from `MyConkyConfigs`
- Fonts: `~/.local/share/fonts/`
- Autostart: `~/.config/autostart/linux-scripts-conky.desktop`
- Launcher: `~/.config/conky/conkyx-start.sh`

## Apt Packages Installed

### Core
- `python3`
- `x11-xserver-utils`
- `dbus-x11`

### Nemo and Cinnamon helpers
- `zenity`
- `xdotool`
- `wmctrl`
- `mediainfo-gui`
- `shellcheck`
- `imagemagick`

### Monitor wallpaper updater
- `feh`

### Conky bundle
- `conky-all`
- `jq`
- `curl`
- `net-tools`
- `lm-sensors`
- `mesa-utils`
- `bc`

## What the Install Script Does

When you run `./INSTALL.sh`, it:

1. Creates the needed directories under `~/.local`, `~/.config`, and `~/.config/conky`
2. Installs apt packages for the enabled modules
3. Copies the quote updater, Nemo helpers, monitor wallpaper tools, and Conky bundle
4. Installs Conky fonts into `~/.local/share/fonts`
5. Rewrites copied Conky paths so they point at the current user home directory
6. Creates autostart desktop files for the enabled modules
7. Writes an install summary to `~/.config/linux-scripts/last-install.txt`

## Directory Structure After Installation

```text
~/.local/bin/
├── linux-screensaver-quote-updater/
│   ├── lock_screen_updater
│   ├── get_random_quote.py
│   └── quotes.json
├── lock_screen_slideshow.sh
├── monitor_displays.sh
├── xrandr_event_monitor.sh
└── display_monitor.py

~/.config/conky/
├── conkyx-start.sh
├── conky_cpu.conf
├── conky_ram.conf
├── conky_hdd.conf
├── conky_gpu.conf
├── conky_wifi.conf
├── conky_lan.conf
├── conky_system.conf
├── conky_audio.conf
├── conky_bios.conf
├── audioscript/
├── ipscript/
├── ramscript/
└── storagescript/

~/.config/autostart/
├── linux-scripts-lock-screen.desktop
├── linux-scripts-monitor-wallpapers.desktop
└── linux-scripts-conky.desktop

~/.config/linux-scripts/
├── restore.conf
└── last-install.txt
```

## Configuration After Installation

### Edit the quote list
```bash
nano ~/.local/bin/linux-screensaver-quote-updater/quotes.json
```

### Configure monitor wallpapers
```bash
nano ~/.config/monitor_wallpapers.conf
```

### Configure installer behavior
```bash
nano ~/.config/linux-scripts/restore.conf
```

Important Conky options:
- `ENABLE_CONKY=true`
- `ENABLE_CONKY_AUTOSTART=true`
- `INSTALL_CONKY_FONTS=true`
- `CONKY_WIRED_INTERFACE=""`
- `CONKY_WIFI_INTERFACE=""`

If the installer does not detect the correct network device names, set `CONKY_WIRED_INTERFACE` and `CONKY_WIFI_INTERFACE` explicitly and run:

```bash
./INSTALL.sh upgrade
```

### Run Conky manually
```bash
~/.config/conky/conkyx-start.sh
```

## Managing Services After Installation

### Check what is running
```bash
ps aux | grep -E "slideshow|monitor_displays|conky" | grep -v grep
```

### Disable Conky autostart
```bash
rm ~/.config/autostart/linux-scripts-conky.desktop
```

### Re-enable autostart
```bash
./INSTALL.sh upgrade
```

## Troubleshooting

### Conky does not start at login
- Check that `~/.config/autostart/linux-scripts-conky.desktop` exists
- Run `~/.config/conky/conkyx-start.sh` manually to confirm the configs start
- Verify `conky-all` is installed

### Network widgets show the wrong interface
- Find the correct interface names with `ls /sys/class/net`
- Set `CONKY_WIRED_INTERFACE` and `CONKY_WIFI_INTERFACE` in `~/.config/linux-scripts/restore.conf`
- Re-run `./INSTALL.sh upgrade`

### Fonts or symbols are missing
- Check that the bundled fonts were copied into `~/.local/share/fonts`
- Refresh the font cache with `fc-cache -f ~/.local/share/fonts`
