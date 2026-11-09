# ⢞⡷ Omarchy Paletty ⣱⢏

> Dynamic theme generation and perceptual wallpaper matching engine for Omarchy Linux, powered by **paletty.dev**, the self-hosted **wallpaper-api** (CIEDE2000 color space matching), and **Wallhaven.cc**.

---

## ⠕⣀ Overview

**omarchy-paletty** brings random, mathematically harmonious theming to Omarchy Linux desktop and the Antigravity CLI (`agy`). Just like the Android `omarchy-launcher`, it rolls a random palette from `paletty.dev`, matches high-resolution wallpapers using perceptual color space distances (CIEDE2000 in CIELAB), applies full system colors across Hyprland, Foot, Alacritty, Kitty, Ghostty, Neovim, and VS Code, and synchronizes the active `agy` AI interface live without restarting.

It also integrates seamlessly into the Omarchy Image Picker (`paletty.image-picker`), enabling users to roll themes on demand with `Ctrl+R` and cycle through matched wallpapers with `Ctrl+W`.

---

## ⢄⠎ Features

- **⠶ Random Paletty.dev Integration**: Fetches diverse color palettes with an offline fallback catalog.
- **⠶ Perceptual Wallpaper Matching**: Queries the self-hosted Docker `wallpaper-api` using CIEDE2000 $\Delta E$ in CIELAB color space, with automatic fallback to Wallhaven public search.
- **⠶ Live Antigravity CLI Retinting**: Custom theme hook dynamically discovers running `agy` processes via Linux `/proc/<pid>/fd` PTY enumeration and broadcasts OSC color escape sequences without restarting the process.
- **⠶ Wallpaper Cycler (`Ctrl+W`)**: Caches all candidate wallpapers in `wallpapers.json` and allows instant cycling with desktop notifications and resolution/$\Delta E$ readouts.
- **⠶ Zero-Latency Theme Switcher Integration**: Pre-stages the next theme in the background via `theme-set.d` hooks so rolls appear instantaneous.
- **⠶ Quickshell Modal Shortcuts**: Custom `paletty.image-picker` Quickshell plugin with tactile Braille iconography and direct keyboard shortcuts.

---

## ⢾⢷ Architecture

```mermaid
flowchart TD
    subgraph Trigger ["⢞⡷ Invocation"]
        A1["Theme Chooser: Ctrl+R"] --> B
        A2["Desktop: SUPER+ALT+W"] --> W
        A3["Theme Chooser: Ctrl+W"] --> W
        A4["CLI: omarchy-paletty-roll"] --> B
    end

    subgraph RollEngine ["⠕⣀ Paletty Engine"]
        B["Fetch Palette (paletty.dev)"] --> C["Build Omarchy colors.toml"]
        C --> D["Search Wallpaper (wallpaper-api / Wallhaven)"]
        D --> E["Save wallpapers.json & Download Media"]
        E --> F["Apply Theme (omarchy-theme-set)"]
    end

    subgraph CyclerEngine ["⣱⢏ Wallpaper Cycler"]
        W["omarchy-paletty-wallpaper-cycle"] --> W1["Read wallpapers.json"]
        W1 --> W2["Increment (active_index + 1)"]
        W2 --> W3["Download & Set Background (omarchy-theme-bg-set)"]
        W3 --> W4["Update preview.jpg & Send Notification"]
    end

    subgraph Hooks ["⢄⠎ Theme Hooks (theme-set.d)"]
        F --> H1["15-agy-theme: Live Retint Antigravity CLI via PTY OSC"]
        F --> H2["20-paletty-roll: Background Pre-Stager"]
    end
```

---

## ⠪⡕ Keybindings & Controls

| Context | Shortcut / Command | Action |
| :--- | :--- | :--- |
| **Theme Chooser** | `Ctrl + R` | Roll brand new random Paletty palette and wallpaper match |
| **Theme Chooser** | `Ctrl + W` | Cycle to next matched wallpaper in the current list |
| **Desktop / Hyprland** | `SUPER + ALT + W` | Cycle matched wallpaper globally |
| **Desktop / Hyprland** | `SUPER + CTRL + T` | Open Omarchy Theme Chooser |
| **Terminal / CLI** | `omarchy-paletty-roll` | Roll and apply a new theme immediately |
| **Terminal / CLI** | `omarchy-paletty-wallpaper-cycle` | Cycle to next matched wallpaper |
| **Terminal / CLI** | `omarchy-paletty-roll --prepare-next` | Pre-stage next theme without applying |
| **Omarchy Menu** | *Appearance → Roll Paletty Theme* | Roll new theme from launcher menu |
| **Omarchy Menu** | *Appearance → Cycle Matched Wallpaper* | Cycle wallpaper from launcher menu |

---

## ⢞⡷ Installation

Clone and run the idempotent installer:

```bash
git clone https://github.com/camkerr81/omarchy-paletty.git
cd omarchy-paletty
./install.sh
```

The installer:
1. Installs `omarchy-paletty-roll` and convenience symlinks to `~/.local/bin/`.
2. Installs automation hooks to `~/.config/omarchy/hooks/theme-set.d/`.
3. Installs the `paletty.image-picker` Quickshell plugin to `~/.config/omarchy/plugins/`.
4. Appends `SUPER + ALT + W` keybinding to `~/.config/hypr/bindings.lua` and reloads Hyprland.
5. Pre-stages the initial theme candidate in the background.

---

## ⠶ CLI Reference

```bash
# Roll and apply a random theme immediately:
omarchy-paletty-roll

# Cycle to the next matched wallpaper for the active theme:
omarchy-paletty-wallpaper-cycle
# or:
omarchy-paletty-roll --cycle

# Override target Wallpaper API endpoint:
WALLPAPER_API_URL="https://wallpapers.yourdomain.com" omarchy-paletty-roll

# Filter wallpapers by category (general, anime, people):
omarchy-paletty-roll --category anime

# Save/archive rolled theme under a permanent unique name:
omarchy-paletty-roll --save

# Pre-stage next roll in background without immediately applying:
omarchy-paletty-roll --prepare-next
```

---

## ⣠⣇ Installing & Running the `wallpaper-api` Docker Stack

The wallpaper matching engine connects to **wallpaper-api**, a standalone FastAPI + PostgreSQL (with CIELAB `cube` vector matching) + Redis + Celery crawler engine.

### 1. Prerequisites
- Docker Engine 24+ & Docker Compose v2
- Network access to `wallhaven.cc`

### 2. Clone and Configure
In your workspace or server:

```bash
git clone https://github.com/camkerr81/wallpaper-api.git
cd wallpaper-api

# Create environment configuration
cp .env.example .env
```

Verify your `.env` settings:
```env
API_PORT=8001
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=wallpapers
POSTGRES_PORT=5432
REDIS_URL="redis://redis:6379/0"
WALLHAVEN_API_KEY=""  # Optional: raises rate limits
```

### 3. Start the Docker Stack
```bash
docker compose up -d --build
```

The stack launches 4 containers:
1. **`wallpaper_db`**: PostgreSQL 16 + Alpine with `cube` extension initialized via `init-db.sql`.
2. **`wallpaper_redis`**: Redis 7 Alpine caching and task queue broker.
3. **`wallpaper_api`**: FastAPI application exposed on host port `8001`.
4. **`wallpaper_worker`**: Celery worker executing background ingestion and CIELAB color vectorization.

### 4. Verify Health
```bash
curl -s http://localhost:8001/health | jq .
```
Expected response:
```json
{
  "status": "ok",
  "app": "Wallhaven Palette Wallpaper API",
  "version": "1.0.0",
  "database": "healthy",
  "redis": "healthy"
}
```

### 5. Trigger Initial Wallhaven Ingestion
Populate your database with wallpapers and their extracted dominant color palettes:
```bash
# Start background crawl of top wallpapers (e.g. 10 pages)
curl -X POST "http://localhost:8001/api/v1/sync/start?pages=10&categories=110&purity=100"
```

Check ingestion progress:
```bash
curl -s http://localhost:8001/api/v1/stats | jq .
```

---

## ⢾⢷ Deploying `wallpaper-api` on Cloudflare (Public API)

To make `wallpaper-api` globally accessible over HTTPS without exposing home router ports or dealing with dynamic IP changes, use a **Cloudflare Tunnel**:

### Architecture:
```
[ Client / Desktop ]
        │ HTTPS (443)
        ▼
[ Cloudflare Edge: https://wallpapers.yourdomain.com ]
        │ Encrypted Noise Tunnel (cloudflared)
        ▼
[ Host / Server: http://localhost:8001 ]
        │
   ┌────┴──────────────────────────┐
   │ Docker: wallpaper-api stack   │
   │ (FastAPI, Postgres, Redis)    │
   └───────────────────────────────┘
```

### Setup Steps:
1. **Using Cloudflare Tunnel (`cloudflared`)**:
   Add a public hostname route to your Cloudflare tunnel configuration:
   ```yaml
   # ingress rule in /etc/cloudflared/config.yml or Cloudflare Zero Trust Dashboard:
   - hostname: wallpapers.yourdomain.com
     service: http://localhost:8001
   ```
2. **Zero Trust Dashboard Route**:
   - Go to **Cloudflare Zero Trust** → **Networks** → **Tunnels**.
   - Select your active tunnel.
   - Add a Public Hostname:
     - **Subdomain:** `wallpapers`
     - **Domain:** `yourdomain.com`
     - **Service:** `HTTP://localhost:8001` (or your internal server IP:port)
3. **Public Endpoint Ready**:
   - Once configured, your API is available worldwide at:
     `https://wallpapers.yourdomain.com/api/v1/search`
   - Point the desktop client to your tunnel via `WALLPAPER_API_URL`:
     `export WALLPAPER_API_URL="https://wallpapers.yourdomain.com"`

---

## ⣠⣇ Project Structure

```
omarchy-paletty/
├── bin/
│   ├── omarchy-paletty-roll              # Main Python engine & cycler
│   ├── omarchy-paletty-wallpaper-cycle   # Symlink to cycle mode
│   ├── omarchy-theme-roll                # Generic theme roll symlink
│   └── omarchy-theme-wallpaper-cycle     # Generic cycler symlink
├── hooks/
│   └── theme-set.d/
│       ├── 15-agy-theme                  # Live agy terminal PTY/OSC retinter
│       └── 20-paletty-roll               # Pre-stages next roll on theme activation
├── plugins/
│   └── paletty.image-picker/             # Quickshell overlay with Ctrl+R & Ctrl+W
├── config/
│   ├── hypr/
│   │   └── bindings.lua                  # Hyprland keybinding snippet
│   └── omarchy/
│       └── omarchy-menu.jsonc            # Omarchy menu extension snippet
├── install.sh                            # Automated installer
├── uninstall.sh                          # Clean removal script
├── LICENSE                               # MIT License
└── README.md
```

---

## ⢾⢷ License

MIT License (c) 2026 Cameron Kerr.
