# Tests

Standalone test harness, deliberately kept **outside `code/`** so the engine tree
stays aligned with `ec-/Quake3e` upstream (preserves cherry-picking). It compiles
individual, dependency-light `qcommon` translation units against the
[Unity](https://github.com/ThrowTheSwitch/Unity) framework and libFuzzer, plus
**headless integration tests** that drive the dedicated server through `.cfg`
scripts (see `integration/README.md`).

## Layout

```
tests/
├── Makefile                  # build + run, ASan/UBSan on by default
├── unit/
│   ├── test_q_math.c         # unit tests for code/qcommon/q_math.c
│   └── vendor/unity/         # vendored Unity 2.6.x (3 files)
├── support/
│   └── stubs.c               # Com_Error/Com_Printf stubs for linking q_shared.c
├── fuzz/
│   ├── fuzz_info.c           # libFuzzer target: userinfo parsers (q_shared.c)
│   └── corpus/info/          # seed inputs
└── integration/             # headless runtime tests (drive the dedicated server)
    ├── run.sh                # runner: exec each case, exit code = verdict
    ├── fixtures/q3ut4/       # minimal default.cfg so the server boots paklessly
    └── cases/*.cfg           # assert-driven scripts (see integration/README.md)
```

## Running

```bash
make -C tests                 # build + run unit tests (ASan/UBSan)
make -C tests fuzz CC=clang   # build the libFuzzer target (clang required)
./tests/build/fuzz_info -runs=200000 tests/fuzz/corpus/info
make -C tests clean

make smoke                    # (repo root) build the server + run integration tests
```

## Adding tests

- **Unit**: target translation units that have few engine dependencies (pure math,
  string/parse helpers, hashing). If a unit references `Com_Error`/`Com_Printf`, link
  `support/stubs.c`. For heavier dependencies, add focused stubs rather than pulling in
  the whole engine.
- **Fuzz**: each target defines `LLVMFuzzerTestOneInput`. Arm `com_error_ready` +
  `setjmp(com_error_jmp)` so a legitimately-rejected input is not flagged as a crash.
  Commit a small seed corpus.
- **Integration**: drop a `cases/<name>.cfg` ending in `quit` that asserts engine
  behaviour via the `assert` / `assert_cvar` commands. See `integration/README.md`.

CI runs the unit tests, a short fuzzing smoke run, and the headless integration
tests on every PR (see `.github/workflows/ci.yml`).
