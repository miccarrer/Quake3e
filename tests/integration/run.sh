#!/usr/bin/env bash
#
# Integration test runner: executes each .cfg case in a headless engine and uses
# its exit code (driven by the Tier-0 "assert" commands) as the verdict. Both
# modes are self-contained — no game install or pk3s required, just the minimal
# fixture in fixtures/q3ut4/default.cfg.
#
#   tests/integration/run.sh [--client] [engine-binary]
#   make smoke          # server cases (dedicated)        — from the repo root
#   make smoke-client   # client cases (null renderer, no UI VM)
#
# Server cases live in cases/*.cfg and run in the dedicated server.
# Client cases live in cases/client/*.cfg and run in the headless client
# (null renderer, UI VM skipped), exercising client-only subsystems.
#
# Exits 0 only if every case passes.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../.." && pwd)"

mode="server"
if [ "${1:-}" = "--client" ]; then
	mode="client"
	shift
fi

bin="${1:-${URT_BIN:-}}"
if [ -z "$bin" ]; then
	if [ "$mode" = "client" ]; then
		bin="$(ls -t "$root"/build/release-*/* 2>/dev/null | grep -vE '\.(d|so|ded\.[^/]*)$' | grep -E '\.[a-z0-9]+$' | head -n1 || true)"
	else
		bin="$(ls -t "$root"/build/release-*/*.ded.* 2>/dev/null | grep -v '\.d$' | head -n1 || true)"
	fi
fi
if [ -z "$bin" ] || [ ! -x "$bin" ]; then
	echo "run.sh: no runnable $mode binary (build with 'make', or pass a path)" >&2
	exit 127
fi
export URT_BIN="$bin"

if [ "$mode" = "client" ]; then
	casedir="$here/cases/client"
else
	casedir="$here/cases"
fi
cases=("$casedir"/*.cfg)
if [ ! -e "${cases[0]}" ]; then
	echo "run.sh: no $mode test cases in $casedir" >&2
	exit 1
fi

echo "=== integration tests [$mode] ($(basename "$bin")) ==="
pass=0
fail=0

for case in "${cases[@]}"; do
	name="$(basename "$case")"

	# Build a disposable game dir: minimal default.cfg + this case, so the
	# engine can boot and "exec <case>" resolves on the filesystem.
	base="$(mktemp -d)"
	mkdir -p "$base/q3ut4"
	cp "$here/fixtures/q3ut4/default.cfg" "$base/q3ut4/"
	cp "$case" "$base/q3ut4/$name"

	log="$(mktemp)"
	if [ "$mode" = "client" ]; then
		URT_CLIENT=1 URT_BASEPATH="$base" timeout 40 "$root/scripts/headless" \
			+exec "$name" >"$log" 2>&1
	else
		URT_BASEPATH="$base" timeout 30 "$root/scripts/headless" \
			+exec "$name" >"$log" 2>&1
	fi
	code=$?

	if [ "$code" -eq 0 ]; then
		printf '  PASS  %s\n' "$name"
		pass=$((pass + 1))
	else
		printf '  FAIL  %s (exit %d)\n' "$name" "$code"
		grep -aiE 'ASSERT FAIL|Sys_Error|ERROR:' "$log" | sed 's/^/        /'
		fail=$((fail + 1))
	fi

	rm -rf "$base" "$log"
done

echo "=== $pass passed, $fail failed ==="
[ "$fail" -eq 0 ]
