# 🪟 OSLin

**A lightweight, sleek, modern Linux distribution combining the best of Windows 11 and macOS — without the bloat.**

[![Build ISO](https://github.com/salom600/oslin/actions/workflows/build-iso.yml/badge.svg?branch=main)](https://github.com/salom600/oslin/actions/workflows/build-iso.yml)
[![Release](https://img.shields.io/github/v/release/salom600/oslin?include_prereleases)](https://github.com/salom600/oslin/releases)
[![License](https://img.shields.io/badge/license-GPLv3-blue.svg)](LICENSE)

---

## ✨ Features

| Feature | Detail |
|---|---|
| 🪟 **Hybrid UI** | Switchable Windows 11 (Fluent) and macOS (WhiteSur) themes |
| ⚡ **Lightweight** | XFCE 4 desktop, ~300MB RAM idle, runs on 512MB minimum |
| 🛒 **App Store** | One-click install via bauh (Flatpak + AppImage + Snap unified) |
| 🎮 **Games pre-installed** | SuperTuxKart, 0AD, Wesnoth, Steam client, Lutris |
| 🔧 **Auto hardware detection** | Nvidia / Intel / AMD drivers auto-installed on first boot |
| 🌐 **Multilingual** | English + Arabic built-in (easy to add more) |
| 💾 **Live + Installable** | Try without installing; calamares installer bundled |
| 🖥️ **All devices** | BIOS + UEFI, 32-bit & 64-bit kernels, old & new hardware |
| 🔄 **Auto-repair CI** | Build failures are analyzed and fixed automatically |

---

## 📥 Download

Pre-built ISOs are published on the [Releases page](https://github.com/salom600/oslin/releases).

### Verify the download

```bash
sha256sum -c SHA256SUMS
```

### Flash to USB

```bash
# Linux / macOS
sudo dd if=oslin-*.iso of=/dev/sdX bs=4M status=progress && sync

# Or use balenaEtcher / Rufus on Windows
```

Boot from the USB — OSLin runs in live mode. Double-click the **Install OSLin** icon on the desktop to install permanently.

---

## 🏗️ Build from source

### Local build (Debian/Ubuntu)

```bash
sudo apt install live-build debootstrap xorriso squashfs-tools git curl
git clone https://github.com/salom600/oslin.git
cd oslin
./scripts/build-local.sh
```

Build takes 30–90 minutes depending on bandwidth and produces `out/oslin-*.iso`.

### Cloud build (GitHub Actions)

Every push to `main` triggers an automatic ISO build in GitHub Actions.
Tagged releases (`v2026.1`, etc.) automatically publish to the Releases page.

---

## 📁 Repository structure

```
oslin/
├── .github/workflows/build-iso.yml   ← CI: build, auto-repair, release
├── config/                            ← live-build configuration
│   ├── build                          ← ISO image config (arch, bootloader, etc.)
│   ├── common                         ← Common live-build options
│   ├── package-lists/
│   │   ├── oslin-base.list.chroot     ← Kernel, firmware, base tools
│   │   ├── oslin-desktop.list.chroot  ← XFCE + themes + apps
│   │   ├── oslin-store.list.chroot    ← App store + flatpak + snap
│   │   ├── oslin-games.list.chroot    ← Pre-installed games
│   │   └── oslin-tools.list.chroot    ← Dev & power-user tools
│   ├── hooks/normal/
│   │   ├── 01-setup-user.hook.chroot          ← Creates oslin user
│   │   ├── 02-install-themes.hook.chroot      ← Downloads Fluent + WhiteSur
│   │   ├── 03-install-bauh-store.hook.chroot  ← Universal app store
│   │   └── 04-xfce-customization.hook.chroot  ← Win/macOS hybrid layout
│   └── includes.chroot/
│       ├── etc/apt/sources.list             ← Debian + backports
│       ├── etc/oslin/oslin-common           ← Shared shell helpers
│       ├── etc/systemd/system/*.service     ← systemd units
│       ├── usr/local/bin/                   ← OSLin scripts
│       └── usr/share/
│           ├── applications/                ← .desktop entries
│           ├── icons/hicolor/scalable/apps/ ← OSLin logo + store icon
│           └── wallpapers/oslin-wallpaper.svg
├── scripts/build-local.sh            ← Run a local build
└── README.md
```

---

## 🎨 Theme switching

Press **Super+I** to open the **OSLin Control Center**, then pick:

- **WhiteSur-Light** → macOS Big Sur look
- **WhiteSur-Dark** → macOS dark mode
- **Fluent-Light** → Windows 11 look
- **Fluent-Dark** → Windows 11 dark mode

Or via terminal:
```bash
xfconf-query -c xsettings -p /Net/ThemeName -s "Fluent-Dark"
```

---

## 🔧 Hardware auto-detection

On first boot, `oslin-hw-detect.service` runs and:

1. Detects your GPU vendor (Nvidia / AMD / Intel) via `lspci`
2. Installs the appropriate driver stack (`nvidia-driver`, `firmware-amd-graphics`, `intel-media-va-driver`)
3. Blacklists conflicting drivers (e.g. `nouveau` when Nvidia is detected)
4. Writes a hardware profile to `/etc/oslin/hw-profile`

You can re-run it anytime:
```bash
sudo rm /etc/oslin/hw-profile
sudo systemctl start oslin-hw-detect
```

---

## 🛠️ Auto-repair CI

If a build fails on GitHub Actions:

1. **Log analysis** — the workflow inspects the last 200 lines of the build log
2. **Pattern matching** — looks for common issues:
   - `Unable to locate package` → removes the missing package from list
   - Hook permission errors → makes all hooks executable
   - Network timeout on `git clone` → adds retry flags
   - Disk space issues → flags for manual review
3. **Auto-commit** — if a fix can be applied, the bot commits to `main`
4. **Auto-retry** — a new workflow run is dispatched automatically

Watch the pipeline: <https://github.com/salom600/oslin/actions>

---

## ⌨️ Keyboard shortcuts

| Shortcut | Action |
|---|---|
| `Super + S` | Open App Store |
| `Super + I` | Open Control Center |
| `Super + E` | Open File Manager |
| `Super + T` | Open Terminal |
| `Super + Space` | Application Finder |
| `Super + D` | Show Desktop |
| `Super + V` | Clipboard Manager |
| `Super + H` | Hardware Info |
| `Print` | Screenshot (full) |
| `Shift + Print` | Screenshot (region) |
| `Ctrl + Alt + L` | Lock screen |

---

## 📦 Default credentials

| User | Password |
|---|---|
| `oslin` | `oslin` |
| `root` | locked (use `sudo`) |

**Change these immediately after install!**

```bash
passwd    # change your password
sudo passwd root   # unlock & set root password (optional)
```

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first.

1. Fork the repo
2. Create your branch: `git checkout -b feature/my-feature`
3. Commit: `git commit -am 'Add my-feature'`
4. Push: `git push origin feature/my-feature`
5. Open a Pull Request

CI will automatically build a test ISO from your PR.

---

## 📜 License

GPL-3.0 — see [LICENSE](LICENSE).

Individual packages retain their own licenses.

---

## 🙏 Acknowledgements

- [Debian Project](https://www.debian.org/) — base distribution
- [live-build](https://live-team.pages.debian.net/live-manual/) — ISO build tooling
- [XFCE](https://www.xfce.org/) — desktop environment
- [vinceliuice](https://github.com/vinceliuice) — WhiteSur & Fluent themes
- [bauh](https://github.com/vinifmor/bauh) — universal app store
- [Flathub](https://flathub.org/) — Flatpak application repository

---

**OSLin 2026.1 Aurora** · Built with ❤️ on GitHub Actions


