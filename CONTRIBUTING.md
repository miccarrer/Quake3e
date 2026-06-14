# Contributing to Urban Terror Optimized

Thanks for your interest in contributing! This document describes the workflow and conventions.

## Project layout

- `code/` — engine source, kept **aligned with [ec-/Quake3e](https://github.com/ec-/Quake3e)
  upstream** so upstream fixes can be cherry-picked. Avoid gratuitous restructuring here.
- `docs/` — documentation (`docs/BUILD.md`, `docs/legal/`, `docs/analysis/`).
- `scripts/` — helper scripts (macOS packaging, …).

## Build & verify

The build system is the **Makefile** (Linux/macOS/MinGW) plus the MSVC solution for native
Windows. See [docs/BUILD.md](docs/BUILD.md).

```bash
make                  # build into build/
make -j$(nproc)       # parallel
```

After any change to C code, **verify it compiles** before committing. For faster loops install
`ccache` and `mold`, and generate `compile_commands.json` with `bear -- make` (see docs/BUILD.md).

## Code style

C, Quake3/ioquake3 convention — see `.clang-format` and the *Coding Style* section of
[CLAUDE.md](CLAUDE.md):

- tabs for indentation; opening brace on the same line; `#ifndef` header guards
- spaces inside parentheses: `if ( x )`, `Func( arg )`

Format edited files with `clang-format -i <file>`. Static analysis: `cppcheck` / `clang-tidy`
(config in `.clang-tidy`).

## Git workflow

- Primary branch: **`main`**.
- Feature branches: `feature/<short-name>` ; fixes: `fix/<short-name>`.
- **Conventional Commits**: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `ci:`, `build:`.
- Keep commits atomic (one logical change per commit) with a clear message.

## Pull requests

1. Branch from `main`, make your change, ensure `make` compiles.
2. Run `clang-format` on touched files; keep the diff focused.
3. Open a PR following the template; describe what and why.
4. Note if your change touches `code/` in a way that could affect upstream cherry-picks.

## Shell note

The maintainer's default shell is **fish** (not POSIX). When sharing multi-step commands,
prefer `bash -c '...'` for portability.
