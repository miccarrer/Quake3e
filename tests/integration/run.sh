#!/usr/bin/env bash
#
# Integration test runner: executes each tests/integration/cases/*.cfg script in
# a headless dedicated server and uses its exit code (driven by the Tier-0
# "assert" commands) as the verdict. Self-contained — no game install or pk3s
# required, just the minimal fixture in fixtures/q3ut4/default.cfg.
#
#   tests/integration/run.sh [server-binary]
#   make smoke                      # from the repo root (builds first)
#
# Exits 0 only if every case passes.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../.." && pwd)"

bin="${1:-${URT_BIN:-}}"
if [ -z "$bin" ]; then
	bin="$(ls -t "$root"/build/release-*/*.ded.* 2>/dev/null | grep -v '\.d$' | head -n1 || true)"
fi
if [ -z "$bin" ] || [ ! -x "$bin" ]; then
	echo "run.sh: no runnable server binary (build with 'make', or pass a path)" >&2
	exit 127
fi
export URT_BIN="$bin"

cases=("$here"/cases/*.cfg)
if [ ! -e "${cases[0]}" ]; then
	echo "run.sh: no test cases in $here/cases" >&2
	exit 1
fi

echo "=== integration tests ($(basename "$bin")) ==="
pass=0
fail=0
failed_names=()

for case in "${cases[@]}"; do
	name="$(basename "$case")"

	# Build a disposable game dir: minimal default.cfg + this case, so the
	# engine can boot and "exec <case>" resolves on the filesystem.
	base="$(mktemp -d)"
	mkdir -p "$base/q3ut4"
	cp "$here/fixtures/q3ut4/default.cfg" "$base/q3ut4/"
	cp "$case" "$base/q3ut4/$name"

	log="$(mktemp)"
	URT_BASEPATH="$base" timeout 30 "$here/../../scripts/headless" \
		+exec "$name" >"$log" 2>&1
	code=$?

	if [ "$code" -eq 0 ]; then
		printf '  PASS  %s\n' "$name"
		pass=$((pass + 1))
	else
		printf '  FAIL  %s (exit %d)\n' "$name" "$code"
		grep -aiE 'ASSERT FAIL|Sys_Error' "$log" | sed 's/^/        /'
		fail=$((fail + 1))
		failed_names+=("$name")
	fi

	rm -rf "$base" "$log"
done

echo "=== $pass passed, $fail failed ==="
[ "$fail" -eq 0 ]
