# Koretoggle
> 🚨🚨🚨 AI SLOP 🚨🚨🚨  
> This repo was entirely made with Claude

A KDE Plasma 6 panel widget for enabling and disabling individual CPU cores at runtime, inspired by Haiku's [ProcessController](https://www.haiku-os.org/docs/userguide/en/desktop-applets/processcontroller.html).

![Koretoggle popup showing 12 CPU cores. CPU 0 is labeled "always on". CPUs 1–3 and 5-11 are enabled, CPU 4 is disabled.](screenshot.png)

## Requirements
- KDE Plasma 6
- Qt 6 development packages (`qt6-base`, `qt6-declarative`)
- `cmake`
- `polkit` (for privilege escalation)

## Installation
Koretoggle has two parts: a privileged helper and native QML plugin that must be installed system-wide, and the plasmoid itself.

### 1. Install the helper and QML plugin
Clone this repository and run the install script:

```bash
git clone https://github.com/yourusername/koretoggle.git
cd koretoggle
chmod +x install.sh
sudo ./install.sh
```

This builds and installs the native QML plugin, the helper binary, and the polkit policy.

### 2. Install the plasmoid

```bash
kpackagetool6 --install . --type Plasma/Applet
```

Then right-click your panel → *Add Widgets* → search for *Koretoggle*.

## Usage
Click the widget icon in the panel to open the popup. Each CPU core is listed with a toggle switch. CPU 0 is always-on and cannot be disabled. The first toggle per session requires authentication; subsequent toggles within ~5 minutes proceed silently.

## Uninstall
```bash
sudo ./uninstall.sh
kpackagetool6 --remove org.koretoggle.toggle --type Plasma/Applet
```

## License
GPL-2.0-or-later — see [LICENSE](LICENSE).
