# Cvars — Urban Terror Optimized

Cvars specific to Urban Terror Optimized (on top of the Quake3e / ioquake3 cvar set).
Set them from the console (`\cvar value`) or a config.

> This list covers UrT-specific additions. For the full engine cvar set, see the
> [Quake3e documentation](https://github.com/ec-/Quake3e).

## Client — window placement

CSS-like margins for windowed mode positioning. Value `-1` means *auto* (centered);
a value `>= 0` is a fixed margin in pixels from the corresponding screen edge.

| Cvar | Default | Description |
|------|:-------:|-------------|
| `r_windowMarginTop`    | `-1` | Top margin (px), `-1` = auto |
| `r_windowMarginBottom` | `-1` | Bottom margin (px), `-1` = auto |
| `r_windowMarginLeft`   | `-1` | Left margin (px), `-1` = auto |
| `r_windowMarginRight`  | `-1` | Right margin (px), `-1` = auto |

## Master server / browser visibility

| Cvar | Scope | Description |
|------|:-----:|-------------|
| `modversion`    | client | Engine/mod version identifier reported to the master server |
| `sv_modversion` | server | Mod version advertised by the dedicated server (UrT browser) |

## Server — userinfo filtering

| Cvar | Scope | Description |
|------|:-----:|-------------|
| `sv_filter` | server | Path to a userinfo filter file. Format documented in [filter.txt](filter.txt). |

## Server — optional gameplay / messages

All default to the prior behaviour (prefixes) or off; `CVAR_ARCHIVE_ND`.

| Cvar | Default | Description |
|------|:-------:|-------------|
| `sv_sayprefix` | `console: ` | Prefix prepended to server `say` console messages |
| `sv_tellprefix` | `^6console: ` | Prefix prepended to server `tell` console messages |
| `sv_nofallDamage` | `0` | Disable fall damage server-side (no lemmings) |
| `sv_infiniteStamina` | `0` | Give players infinite stamina (Urban Terror) |

---

*Remaining M5 features (tabbed console, tellme, UrT demo) are tracked in [ROADMAP.md](../ROADMAP.md).*
