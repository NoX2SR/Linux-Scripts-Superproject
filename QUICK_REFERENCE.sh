#!/usr/bin/env bash
# QUICK REFERENCE CARD - Linux Scripts Installation
# Save this and display it when needed

cat << 'EOF'

╔════════════════════════════════════════════════════════════════════════╗
║                    QUICK REFERENCE CARD                                ║
║           One-Click Linux Scripts Installation System                  ║
╚════════════════════════════════════════════════════════════════════════╝

📍 LOCATION: ~/Documents/Linux/Scripts/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 FIRST TIME SETUP (New System)

  1. Copy scripts (git or backup):
     $ git clone <repo> ~/Documents/Linux/Scripts
     $ cd ~/Documents/Linux/Scripts

  2. Run installer:
     $ ./INSTALL.sh

  3. Answer prompts (especially monitor wallpaper option)

  4. Log out and back in

  ✓ Done! Everything will auto-run

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 FILES & DOCUMENTATION

  INSTALL.sh
    → Main installation script (just run it!)
    
  README.md
    → Project overview & quick start
    
  INSTALLATION_MANUAL.md
    → Detailed setup guide (read after install)
    
  Projects/:
    monitor-wallpaper-updater/       (README_SETUP.md)
    linux-screensaver-quote-updater/ (README.md)
    nemo_actions_and_cinnamon_scripts/ (README.md)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 WHAT GETS INSTALLED

  ✓ Quote Updater
    • Lock screen shows new quotes on each unlock
    • Location: ~/.local/bin/linux-screensaver-quote-updater/

  ✓ Lock Screen Slideshow
    • Animated backgrounds while locked
    • Quotes update when unlocked
    • Auto-runs 30 sec after login

  ✓ Nemo Actions
    • Custom file manager menus
    • Located in ~/.local/share/nemo/

  ✓ Monitor Wallpaper Updater (Optional)
    • Auto-changes wallpaper on display changes
    • Only if you enable during installation
    • Location: ~/.local/bin/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️  MANAGE AFTER INSTALLATION

  Check what's running:
    $ ps aux | grep -E "slideshow|monitor" | grep -v grep

  View logs:
    $ tail -f ~/.local/share/monitor_displays.log

  Edit quotes:
    $ nano ~/.local/bin/linux-screensaver-quote-updater/quotes.json

  Edit wallpaper config:
    $ nano ~/.config/monitor_wallpapers.conf

  Update wallpapers immediately:
    $ ~/.local/bin/monitor_displays.sh update

  Installation details:
    $ cat ~/.config/SCRIPTS_INSTALLATION_SUMMARY.txt

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ KEY POINTS

  • One-click installation: Just run ./INSTALL.sh
  • Automatic integration: Quotes auto-run with slideshow
  • Auto-start: Services run automatically on login
  • Portable: Works with any username
  • Configurable: Easy to customize after install
  • Documented: Full guides included
  • Ready for reinstall: Back up folder and restore anytime

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❓ COMMON TASKS

  "How do I install?"
    → ./INSTALL.sh

  "How do I change my quotes?"
    → nano ~/.local/bin/linux-screensaver-quote-updater/quotes.json

  "How do I set wallpaper paths?"
    → nano ~/.config/monitor_wallpapers.conf
    → Set WALLPAPER_SINGLE and WALLPAPER_DUAL
    → ~/Documents/Linux/Scripts/monitor-wallpaper-updater/monitor_displays.sh config

  "How do I test it?"
    → Lock screen (Ctrl+Alt+L) to see quotes
    → Plug/unplug monitor to test wallpaper
    → Check logs: tail -f ~/.local/share/monitor_displays.log

  "How do I disable autostart?"
    → rm ~/.config/autostart/LockScreenUpdater.desktop
    → rm ~/.config/autostart/monitor-wallpapers.desktop

  "How do I backup for reinstall?"
    → cp -r ~/Documents/Linux/Scripts /backup/location
    → Or: git push to your repo

  "How do I restore on new system?"
    → Copy Scripts folder back
    → Run ./INSTALL.sh
    → Log out and back in

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📞 HELP & DOCUMENTATION

  In project folders:
    • monitor-wallpaper-updater/README_SETUP.md
    • monitor-wallpaper-updater/QUICK_START.sh
    • linux-screensaver-quote-updater/README.md

  Installation guide:
    • INSTALLATION_MANUAL.md (after installation)

  General overview:
    • README.md

  After install details saved at:
    • ~/.config/SCRIPTS_INSTALLATION_SUMMARY.txt

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 WORKFLOW SUMMARY

  Fresh System → Copy Scripts → Run INSTALL.sh → Log In → Done!
                                  ↓
                            Auto-runs all services
                            ↓
                        Lock screen = New quotes
                        Plug monitor = Auto wallpaper
                        Everything works!

╔════════════════════════════════════════════════════════════════════════╗
║                    You're all set! 🎉                                  ║
╚════════════════════════════════════════════════════════════════════════╝

EOF
