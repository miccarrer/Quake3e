# Security: static-analysis triage (CodeQL)

How we handle CodeQL code-scanning findings on this engine.

## Scanner configuration

- CodeQL `c-cpp`, query suite **`security-extended`**, vendored third-party libs
  excluded — see [`.github/codeql/codeql-config.yml`](../.github/codeql/codeql-config.yml).
- Runs on pull requests to `main` and weekly.

## Why a triage policy (and not a mass fix)

This engine descends from id Software Quake III → ioquake3 → `ec-/Quake3e`. `code/` is kept
**aligned with upstream** so fixes can still be cherry-picked. The large majority of CodeQL
findings are long-standing upstream C patterns where a bound is known to the developer but is
not provable by static analysis.

**We do not mass-rewrite upstream code** (e.g. a blanket `strcpy` → `Q_strncpyz` sweep): that
would break cherry-picking and risks introducing regressions, for issues that are mostly
theoretical. Each finding is triaged individually instead.

## Disposition guide

Classify every alert as one of:

- **Fix** — a genuine bug reachable from **untrusted input**. Fix surgically in our code.
- **Won't fix / dismiss** — safe by construction, trusted input (local config / the user's own
  game files), or mitigated by existing sanitization the analyzer can't model. Dismiss in the
  GitHub *Security* tab with a documented reason — never silently.
- **Backlog** — plausible but needs deeper reachability analysis; track and revisit.

Untrusted-input sources to prioritise: `MSG_*` netcode, **downloaded** paks, server-sent
commands/configs, demo files. Trusted sources: the user's own installed paks/config.

## Current state — 2026-06-15

**~172 open alerts** (down from ~1279 before tuning the suite + excluding vendored code).
**24 dismissed on 2026-06-15** after individual review (see "Actions taken" below) → ~148 remain.

| Rule | ~Count | Typical disposition |
|---|---|---|
| `cpp/uncontrolled-arithmetic` | 47 | Noisy query; **16 netcode ones verified + dismissed (FP)**; rest (audio/render) backlog |
| `cpp/unbounded-write` | 18 | Mostly FP — buffer sized to its source, or trusted local files (2 verified + dismissed) |
| `cpp/suspicious-pointer-scaling` | 18 | Mostly FP — intentional engine pointer arithmetic |
| `cpp/uncontrolled-allocation-size` | 5 | Backlog — allocation size from file headers |
| `cpp/potentially-dangerous-function` | 4 | **Dismissed (won't fix)** — `localtime`/`ctime` for log timestamps |
| `cpp/path-injection` | 2 | **Dismissed (FP)** — pak path sanitised via `FS_BuildOSPath`; download traversal mitigated in M0 |
| `cpp/overrunning-write-with-float` | 1 | Hardening candidate (`sprintf("%f")` → `snprintf`) |
| others | few | per case |

### Actions taken (2026-06-15)

**24 alerts dismissed** after individual verification (reversible — reopen if reassessed).

First pass (8):
- `cpp/potentially-dangerous-function` ×4 (`localtime`/`ctime` log timestamps) — *won't fix*.
- `cpp/path-injection` ×2 (`files.c` pak open via `FS_BuildOSPath`) — *false positive*.
- `cpp/unbounded-write` ×2 (`files.c:2763,2764` pak name strcpy, sized to source) — *false positive*.

**Network attack surface review (16)** — every CodeQL alert in network-facing code
(`msg.c`, `net_chan.c`, `net_ip.c`, `sv_main.c`, `sv_client.c`, `cl_main.c`) was read and found
to be a **false positive**; all 16 `cpp/uncontrolled-arithmetic` there were dismissed:
- `msg.c` hash accumulator (benign wraparound) + float write-path (range-checked on the line).
- `net_chan.c` fragment reassembly: `fragmentLength` is a bounded short, validated (`<0`, vs
  `cursize`, vs `sizeof fragmentBuffer`) before the `memcpy` → no overflow can bypass the checks.
- `net_ip.c` `port + i` (i∈0..9, port is a cvar); `sv_main.c`/`cl_main.c` frame/timing
  accumulation (not network input); `sv_client.c` `cmdCap` *is* the reliable-command overflow
  guard (ack validated upstream).

**Result: no genuine memory-safety or integer-overflow bug was found in the netcode** — it holds
up (heavily-audited ioquake3/Quake3e lineage).

### Low-priority items noted (not fixed)
- `cl_main.c:4045` `cpp/non-https-url`: default `cl_dlURL` points to an HTTP community map host;
  user-configurable, and pak download security is enforced by M0 (`FS_GamePak`/`CL_FirstDownload`).
- `net_ip.c:1316` `cpp/system-data-exposure` (`getenv`): low-risk; reads a path env var.

### Backlog (~148)
Mostly non-network code: audio mixing (`snd_mix.c`, `snd_dma.c`), renderer model/image loading
(`tr_*.c`), file loaders — plus **vendored `libjpeg`/`libvorbis`** that still surface because
`paths-ignore` does not reliably exclude *compiled* C from CodeQL (a config limitation to revisit).
None are reachable from network input. Triaged incrementally; not bugs to fix en masse.

### Worked examples (the analysis behind the table)

- **`code/qcommon/files.c:2763`** `strcpy(pack->pakFilename, pakName)` — the destination is
  allocated to `pakName`'s exact length immediately above. **Safe by construction → FP.**
- **`code/qcommon/common.c:231,891`** / **`code/botlib/l_precomp.c:757,771`** `localtime`/`ctime`
  — single-threaded log timestamps copied straight into a bounded `strftime` buffer / log line.
  No reachable threading or overflow issue. **Won't fix.**
- **`code/qcommon/files.c:1490,1500`** path into `unzOpen`/`unzReOpen` — pak paths are built
  through `FS_BuildOSPath` (which sanitises), and download-side path traversal is already
  mitigated by the M0 security work (`FS_GamePak`, `CL_FirstDownload`). **FP.**
- **`code/qcommon/cvar.c:1328`** `sprintf(value, "%f", fval)` — extreme floats could need a large
  buffer. Low real risk; **optional hardening** to `snprintf`.

## Optional hardening (low priority, weigh vs cherry-pick cost)

- `code/qcommon/cvar.c:1328` `sprintf("%f")` → `snprintf`.
- `code/server/sv_filter.c` `sprintf` → `snprintf` (admin-controlled input).

## Process for new alerts

- A CodeQL alert appearing on a PR is triaged before merge: **fix** genuine untrusted-input
  bugs; **dismiss** clear false positives with a reason; otherwise **backlog**.
- Dismissals carry a written rationale and are reversible (reopen if reassessed).
