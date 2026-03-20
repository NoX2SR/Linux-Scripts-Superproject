# Linux Scripts

Small Cinnamon-focused script collection, including a full Conky desktop widget setup.

## Projects

### `linux-screensaver-quote-updater`
- Sets the Cinnamon lock-screen message from `quotes.json`
- Main entry: `lock_screen_updater`
- Docs: `linux-screensaver-quote-updater/README.md`

### `monitor-wallpaper-updater`
- Updates wallpapers when monitor layout changes
- Main entry: `monitor_displays.sh`
- Optional helpers: `xrandr_event_monitor.sh`, `display_monitor.py`
- Docs: `monitor-wallpaper-updater/README.md`

### `MyConkyConfigs`
- Installs a multi-widget Conky layout into `~/.config/conky`
- Includes the launcher, widget configs, helper scripts, and bundled fonts
- Creates a login autostart entry for the Conky launcher
- Docs: `MyConkyConfigs/README.md`

### `nemo_actions_and_cinnamon_scripts`
- Local copy of upstream Nemo/Cinnamon scripts
- Used here mainly for `lock_screen_slideshow.sh` and Nemo actions
- Docs: `nemo_actions_and_cinnamon_scripts/README.md`

## Install

```bash
cd ~/Documents/Linux/Scripts
./INSTALL.sh
```

The installer can:
- Install apt dependencies for the enabled modules
- Copy the Conky bundle into `~/.config/conky`
- Install bundled Conky fonts into `~/.local/share/fonts`
- Create autostart entries in `~/.config/autostart`

## Manual Use

```bash
linux-screensaver-quote-updater/lock_screen_updater
monitor-wallpaper-updater/monitor_displays.sh update
monitor-wallpaper-updater/monitor_displays.sh daemon
~/.config/conky/conkyx-start.sh
```

## Notes

- The monitor updater uses `gsettings` and `xrandr`.
- The monitor updater now switches between `WALLPAPER_SINGLE` and `WALLPAPER_DUAL`.
- The Conky installer creates `~/.config/autostart/linux-scripts-conky.desktop`.
- Conky network interface names can be overridden in `~/.config/linux-scripts/restore.conf`.
