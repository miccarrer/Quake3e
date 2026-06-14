# Urban Terror features

Features specific to Urban Terror Optimized, beyond the stock Quake3e / ioquake3 engine.

## Available now

- **Game directory** — defaults to `q3ut4` (`BASEGAME` / `DEFAULT_GAME`).
- **Master server / browser visibility** — `modversion` / `sv_modversion` reporting so the
  engine appears correctly in the Urban Terror server browser. See [CVARS.md](CVARS.md).
- **Window margins** — CSS-like windowed-mode positioning (`r_windowMargin*`). See
  [CVARS.md](CVARS.md).
- **Download security** — UrT paks are not downloaded from modded servers
  (`FS_CheckIdPaks` disabled, `FS_GamePak` + `CL_FirstDownload` filtering).

## Planned (M5 — see [ROADMAP.md](../ROADMAP.md))

- Tabbed console (multiple consoles)
- `tellme` command
- Urban Terror demo format support
- Optional server cvars: `sv_sayprefix` / `sv_tellprefix`, `sv_nofalldamage`,
  `sv_infiniteStamina`, referee fix
- Optional: dmaHD high-quality audio mixer

This document will grow as M5 features are integrated.
