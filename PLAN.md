# Koretoggle

A KDE Plasma 6 panel widget for enabling and disabling individual CPU cores at runtime, inspired by the per-core toggle in Haiku's task manager.

## Goal

A Plasma 6 panel widget that lists the system's CPU cores and lets the user enable or disable each one with a click. Authentication is required once per session, not per toggle.

## Scope

v1 covers enable/disable of individual CPU cores. Nothing else.

## Architecture

Two components: an unprivileged QML widget that runs in the Plasma panel, and a small privileged helper script invoked via `pkexec`. The helper writes to `/sys/devices/system/cpu/cpuN/online`; the widget reads the same files directly (reads are unprivileged).

A polkit `.policy` file registers the helper with pkexec, supplies the dialog text shown to the user, and sets `auth_admin_keep` so a single authentication covers subsequent toggles for roughly five minutes. `cpu0` is treated as always-on and rendered as a non-interactive row, since it typically lacks an `online` sysfs entry on x86.

## Components

**Plasmoid (`koretoggle`)** — QML panel widget. Compact representation is a small icon in the panel; full representation is a popup listing cores with toggle controls. State is read on popup open from sysfs. Toggling a core invokes the helper via `pkexec`.

**Helper (`koretoggle-helper`)** — small script installed to `/usr/libexec/`. Takes a core number and a target state as arguments, validates them, and writes to the corresponding sysfs file. Returns a non-zero exit code on failure.

**Polkit policy** — XML file installed to `/usr/share/polkit-1/actions/org.koretoggle.toggle.policy`. Registers the action `org.koretoggle.toggle`, binds it to the helper's path, and sets `auth_admin_keep` for active sessions.

## Identifiers

- Project / repo name: `koretoggle`
- Package name: `plasma-koretoggle`
- Polkit action ID: `org.koretoggle.toggle`
- Helper path: `/usr/libexec/koretoggle-helper`
- Plasmoid ID: `org.koretoggle.plasmoid`

## Deployment

Two artifacts. The `.plasmoid` is published to the KDE Store and installs to `~/.local/share/plasma/plasmoids/` via "Get New Widgets." The helper and polkit policy ship separately as a git repo with an `install.sh` that copies the files into system paths and requires `sudo`. The widget detects the missing helper on first launch and displays a setup message with the install command.

## Timeline (weekend)

**Phase 1 — Setup.** Get a "hello world" Plasma 6 widget loading in the panel. `metadata.json`, minimal `main.qml`, install/reload loop via `kpackagetool6`.

**Phase 2 — Helper and policy.** Write the helper script, the `.policy` file, and `install.sh`. Test invocation via `pkexec` from the command line before touching the widget.

**Phase 3 — Widget logic.** Read core state from sysfs on popup open. Wire toggle clicks to `pkexec` invocations of the helper. Handle the helper-not-installed case with a setup-required message.

**Phase 4 — UI.** Compact representation icon. Full representation popup with one row per core showing core number, current state, and a toggle. `cpu0` rendered as always-on.

**Phase 5 — Packaging.** README with install steps, screenshots, GPL-compatible license. Build a `.plasmoid` zip for the KDE Store.

## Risks

The privilege handling will take more time than the UI. If the polkit and helper plumbing isn't working by Saturday evening, fall back to running the helper via `pkexec` with a minimal policy and skip the `auth_admin_keep` refinement. Per-toggle prompts are acceptable for an initial release.
