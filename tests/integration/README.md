# Integration tests (headless)

Runtime tests that drive the **dedicated server** binary headlessly and assert on
engine behaviour through the Tier-0 test harness (`assert` / `assert_cvar` /
`quit <code>`). Each test is a `.cfg` script whose process exit code is the verdict.

Self-contained: no game install or pk3s required — the engine boots against the
minimal `fixtures/q3ut4/default.cfg`.

## Layout

```
tests/integration/
├── run.sh                      # runner: executes each case, aggregates pass/fail
├── fixtures/q3ut4/default.cfg  # minimal cfg so the server boots without paks
└── cases/
    └── smoke.cfg               # asserts over cvar/command paths
```

## Running

```bash
make smoke                      # from repo root: builds the server, runs the suite
tests/integration/run.sh        # run against the newest build/release-*/ binary
tests/integration/run.sh path/to/server.ded.x64
```

The runner exits 0 only if every case passes.

## Adding a case

Drop a `cases/<name>.cfg` that ends with `quit`. Use the assert commands; a
mismatch prints `ASSERT FAIL` and raises the exit code, failing the case:

```
assert_cvar com_maxfps == 125
assert foo eq foo
quit
```

`assert` operators: `== != < <= > >=` (numeric) and `eq` / `ne` (string).

## How it works

`run.sh` builds a disposable game dir (the fixture `default.cfg` + the case),
launches `scripts/headless` with `+exec <case>`, and reads the exit code. The
`scripts/headless` wrapper sets dummy SDL drivers and headless cvars
(`dedicated 1`, `net_enabled 0`, `com_logTimestamps 0`) and an isolated temp
homepath. This suite covers non-rendering subsystems (cvars, commands,
filesystem, parsing) and needs no game assets, so it runs in CI.

## Headless client (local)

To exercise **client-only** code (binds, demo playback, console, client netcode)
the wrapper has a client mode backed by the null renderer (`code/renderernull/`,
`cl_renderer null`) — the full client boots without a window, UI/cgame VMs
included. It needs a real install (QVMs/pk3s), so it is **not** part of the CI
suite:

```bash
URT_CLIENT=1 URT_BASEPATH=/path/to/UrbanTerror \
  scripts/headless +assert_cvar cl_renderer eq null +quit
```

