# Architecture

High-level map of the engine for contributors. It follows the classic
Quake III Arena / ioquake3 / Quake3e structure. The `code/` tree is kept
**aligned with [`ec-/Quake3e`](https://github.com/ec-/Quake3e) upstream** so
upstream fixes can still be cherry-picked; project-specific reorganisation
happens only outside `code/` (root, `docs/`, `tests/`, CI).

## Source layout

```
code/
├── qcommon/        # Shared client/server: VM, network, filesystem, cvars, commands
├── client/         # Client: console, input, sound, parsing, UI, downloads
├── server/         # Dedicated/listen server: game bridge, network, snapshots, commands
├── renderer/       # OpenGL 1.x renderer (modular, dlopen-able)
├── renderer2/      # OpenGL2/3.x renderer (ioq3 original, unmaintained)
├── renderervk/     # Vulkan renderer (modern, recommended)
├── renderercommon/ # Code shared across renderers
├── sdl/            # SDL2 backend (video, audio, input)
├── botlib/         # Bot AI (AAS pathfinding)
├── game/ cgame/ ui/# Shared mod interface headers (g_public.h, bg_public.h, cg_public.h)
├── asm/            # Optimized x86/x64 assembly (audio mixing)
├── unix/  win32/   # Platform-specific code (+ MSVC solution under win32/)
└── lib*/           # Vendored deps: libcurl, libjpeg, libogg, libvorbis, libsdl
```

Non-engine trees:

```
docs/        # Reference docs (BUILD, CVARS, CREDITS, urt-features, legal/, analysis/)
tests/       # Unit (Unity) + fuzz (libFuzzer) harness — outside code/ by design
.context/ # Project state/knowledge for maintainers (brief, progress, patterns…)
.github/     # CI (ci.yml, release.yml, codeql.yml), dependabot, templates, CODEOWNERS
```

## Key subsystems

### Virtual Machines (VM)
Game logic loads as compiled VMs — QVM bytecode or native DLLs.
- `code/qcommon/vm.c` — VM manager
- `code/qcommon/vm_x86.c` — x86/x64 JIT (NaN-safe comparisons; `-fno-fast-math` on QVM modules)
- `code/qcommon/vm_aarch64.c`, `vm_armv7l.c`, `vm_powerpc.c` — other JIT backends

### Modular renderers
Renderers are either **static** (`USE_RENDERER_DLOPEN=0`, linked in) or **dynamic**
(`USE_RENDERER_DLOPEN=1`, default — loaded via `dlopen`, switchable with `\cl_renderer`).
The default renderer is Vulkan (`RENDERER_DEFAULT=vulkan`).

### Cvars & commands
Configuration variables and console commands are managed in
`code/qcommon/cvar.c` and `code/qcommon/cmd.c`. See [docs/CVARS.md](docs/CVARS.md) for the
UrT-specific cvars.

## Build system

The canonical build is the **Makefile** (Linux/macOS/MinGW/Raspberry Pi/PowerPC); native
Windows uses the MSVC solution under `code/win32/msvc2017/`. CMake was dropped — IDE/clangd
integration is via `compile_commands.json` (`bear -- make`). Key Makefile knobs: `CNAME`,
`DNAME`, `ARCH`, `USE_SDL`, `USE_VULKAN`, `USE_OPENGL`, `USE_RENDERER_DLOPEN`,
`RENDERER_DEFAULT`, `BUILD_CLIENT`, `BUILD_SERVER`. The build pins `-std=gnu99` and stamps the
version from `git describe`. Full instructions: [docs/BUILD.md](docs/BUILD.md).

## CI/CD

- **`ci.yml`** — clang-format (changed lines), cppcheck (informational), unit tests + fuzz
  smoke, ASan/UBSan build, and a Linux/macOS/Windows-MinGW build matrix (ccache).
- **`codeql.yml`** — CodeQL c-cpp analysis on PRs and weekly.
- **`release.yml`** — multi-platform release builds (Vulkan + OpenGL) published on `v*` tags.

## Coding style

C, Quake3/ioq3 convention: tabs; opening brace on the same line, closing `}` aligned with the
keyword; `PascalCase` types, `camelCase`/`snake_case` variables; `#ifndef` header guards (no
`#pragma once`). Enforced by `.clang-format` (see [CONTRIBUTING.md](CONTRIBUTING.md)).

```c
void SomeFunction( int arg ) {
	int localVar;

	if ( arg > 0 ) {
		localVar = arg * 2;
	} else {
		localVar = 0;
	}
}
```
