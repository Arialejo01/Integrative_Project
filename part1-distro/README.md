# Part 1 — Custom Distro with Cubic

Reference: [How to Create a Custom Linux Distro with Cubic](https://www.youtube.com/watch?v=zlInz7c83K8) · [Cubic on GitHub](https://github.com/PJ-Singh-001/Cubic)

## One-line build

> Cubic is a GUI tool — run it inside Ubuntu or Linux Mint (bare metal or VM).

```bash
sudo apt-add-repository ppa:cubic-wizard/release && sudo apt update && sudo apt install cubic -y
```

Then launch:

```bash
cubic
```

## Repository structure

```
part1-distro/
├── README.md                        # This file
├── chroot-setup.sh                  # All chroot commands applied inside Cubic
├── skel/
│   └── .config/
│       ├── nvim/
│       │   └── init.vim             # Neovim config deployed to /etc/skel
│       └── gtk-3.0/
│           └── settings.ini         # GTK dark theme deployed to /etc/skel
└── screenshots/
    ├── 01-boot-screen.png
    ├── 02-desktop.png
    ├── 03-librewolf.png
    ├── 04-neovim.png
    └── 05-dark-theme.png
```

## Base ISO

| Field | Value |
|-------|-------|
| Base distro | Linux Mint 22.1 Cinnamon (64-bit) |
| Original ISO | `linuxmint-22.1-cinnamon-64bit.iso` |
| Custom ISO | `ArielOS-22.1-amd64.iso` |
| Cubic version | 2026.06.105 |
| Compression | XZ |

## Modifications (inside Cubic chroot)

### 1 — Firefox → LibreWolf

```bash
add-apt-repository ppa:mozillateam/ppa -y
apt update
apt remove --purge firefox -y
apt install librewolf -y
```

**Why:** LibreWolf is a hardened Firefox fork with no telemetry, no sponsored content, and uBlock Origin pre-installed. It replaces a proprietary-leaning default with a fully free-software alternative.

---

### 2 — Neovim pre-installed + skel config

```bash
apt install neovim -y
mkdir -p /etc/skel/.config/nvim
cat > /etc/skel/.config/nvim/init.vim << 'VIMEOF'
set number
set tabstop=4
set shiftwidth=4
set expandtab
syntax on
VIMEOF
```

**Why:** Neovim is a lightweight keyboard-driven editor standard in developer environments. Placing the config in `/etc/skel` ensures every new user account inherits it automatically.

---

### 3 — Mint-Y-Dark theme as system default

```bash
mkdir -p /etc/skel/.config/gtk-3.0
cat > /etc/skel/.config/gtk-3.0/settings.ini << 'GTKEOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Mint-Y-Dark
gtk-icon-theme-name=Mint-Y-Dark
GTKEOF
```

**Why:** The default Mint theme applies only to the live session. Writing to `/etc/skel` makes the dark theme permanent for every user created after installation.

---

## Build flow

```
Base ISO (Linux Mint 22.1 Cinnamon)
  └─ Cubic: extract squashfs
        ├─ chroot terminal  ←  run chroot-setup.sh
        │    ├─ [1/3] add PPA → remove Firefox → install LibreWolf
        │    ├─ [2/3] install Neovim → write /etc/skel/.config/nvim/init.vim
        │    └─ [3/3] write /etc/skel/.config/gtk-3.0/settings.ini
        └─ Cubic: repack squashfs (XZ) → generate ISO
                        │
                        ▼
              ArielOS-22.1-amd64.iso
                        │
                        ▼
        qemu-system-x86_64 -m 2048 -cdrom ArielOS-22.1-amd64.iso -boot d
```

## Test in QEMU

```bash
qemu-system-x86_64 -m 2048 -cdrom ArielOS-22.1-amd64.iso -boot d
```

## ISO download & checksum

> The ISO exceeds GitHub's file size limit.  
> **Download:** *(add Google Drive / MEGA link here)*

```
sha256sum ArielOS-22.1-amd64.iso
(paste output here after generating)
```

## Boot screenshot

*(add after QEMU test)*