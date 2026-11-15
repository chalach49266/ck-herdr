#!/bin/sh
# Real hc, fake agent only. All state and prompts stay inside this repository.
set -eu
repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo"
export CK_HERDR_HC="${CK_HERDR_HC:-$HOME/.local/bin/hc}"
export HC_SESSION="ck-herdr-test-$$"
export HC_SOCKET="$repo/tests/.scratch/s$$.sock"
export XDG_CONFIG_HOME="$repo/tests/.scratch/config-$$"
export XDG_STATE_HOME="$repo/tests/.scratch/state-$$"
export XDG_CACHE_HOME="$repo/tests/.scratch/cache-$$"
export XDG_DATA_HOME="$repo/tests/.scratch/data-$$"
unset HC_TERMINAL_ID
scratch="$repo/tests/.scratch/run-$$"
export CK_HERDR_RUNS_DIR="$scratch/runs"
unset CK_HERDR_MODELS
mkdir -p "$CK_HERDR_RUNS_DIR" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"
slug="ck-test-$$"
cleanup() {
    "$CK_HERDR_HC" kill --json "$slug" >/dev/null 2>&1 || :
    "$CK_HERDR_HC" rm --json "$slug" >/dev/null 2>&1 || :
    # This is this test's private core, never the user's session.
    "$CK_HERDR_HC" server stop >/dev/null 2>&1 || :
}
trap cleanup EXIT HUP INT TERM

# Dry-run reads the real alias file and performs no hc calls or writes.
bin/ck-herdr launch --dry-run "$slug" --model sol --cwd "$repo" --ask A-test --title 'Fake fixture only' > "$scratch/sol-dry-run.txt"
grep -q 'codex --no-daemon --sandbox workspace-write --approve-for-me -m gpt-6.1-sol' "$scratch/sol-dry-run.txt"
grep -q 'wait --json' "$scratch/sol-dry-run.txt"
test ! -e "$CK_HERDR_RUNS_DIR/$slug.out"
bin/ck-herdr --dry-run launch "$slug" --model sol --cwd "$repo" > "$scratch/global-dry-run.txt"
echo 'PASS real sol alias dry-run (both flag positions), no output file created'

# Check unsafe configured options and outcome mappings without launching anything.
python3 - <<'PY'
import runpy
m = runpy.run_path('bin/ck-herdr')
argv, dropped = m['agent_command']({'aliases': {'fake': {'command': [
    '/fake/agent', '--dangerously-skip-permissions', '--force',
    '--sandbox=disabled', '--permission-mode', 'bypassPermissions', '-a', 'never'
]}}}, 'fake')
assert argv == ['/fake/agent'] and len(dropped) == 5
for state, code in [('done', 0), ('blocked', 1), ('idle', 1), ('error', 3)]:
    assert m['outcome']({'reason': 'status', 'status': state})[0] == code
for reason in ['exit', 'timeout', 'not_started']:
    assert m['outcome']({'reason': reason, 'exit_code': 0})[0] == 3
for bad in [['/fake/agent', '--print'], ['/fake/agent', 'exec'],
            ['/fake/agent', '-c', 'approval_policy="never"']]:
    try:
        m['agent_command']({'aliases': {'fake': {'command': bad}}}, 'fake')
    except ValueError:
        pass
    else:
        raise AssertionError(bad)
print('PASS unsafe flag removal, interactive-only guard, done/blocked/partial/error/exit/timeout mappings')
PY

python3 - "$scratch" <<'PY'
import json, pathlib, shutil, sys
p = pathlib.Path(sys.argv[1])
python = shutil.which('python3')
(p/'fake-agent.py').write_text('''import select, sys
def report(state):
    sys.stdout.write("\\x1b]7501;state=" + state + ":app=ck-fake\\x1b\\\\")
    sys.stdout.flush()
report("working")
print("fake work", flush=True)
# Simulated work and a visible done interval; never poll hc.
select.select([], [], [], 0.2)
report("done")
print("fake done", flush=True)
select.select([], [], [], 2)
print("fake exiting", flush=True)
''')
(p/'models.json').write_text(json.dumps({'aliases': {'fake': {
    'command': [python, str(p/'fake-agent.py')]
}}}))
PY
export CK_HERDR_MODELS="$scratch/models.json"
printf '%s\n' 'Fake task. Emit working then done and exit. Do not start a model.' > "$CK_HERDR_RUNS_DIR/${slug}_prompt.md"
set +e
bin/ck-herdr launch "$slug" --model fake --cwd "$repo" --ask A-test --title 'OSC fake agent' > "$scratch/launch.txt" 2>&1
code=$?
set -e
cat "$scratch/launch.txt"
if test "$code" -ne 0; then
    cat "$CK_HERDR_RUNS_DIR/$slug.out"
    echo 'LIVE TEST FAILED or NOT RUN: inspect hc diagnostics above; no model was launched.'
    exit "$code"
fi
test "$(tail -n 1 "$CK_HERDR_RUNS_DIR/$slug.out")" = 'ck-run exit=0'
grep -q '"status":"done"' "$CK_HERDR_RUNS_DIR/$slug.out"
"$CK_HERDR_HC" get --json "$slug" > "$scratch/terminal.json"
"$CK_HERDR_HC" ls --json --label ck-herdr=true > "$scratch/hc-list.json"
bin/ck-herdr ls > "$scratch/list.txt"
grep -q "$slug" "$scratch/list.txt"
python3 - "$scratch/terminal.json" <<'PY'
import json, sys
t = json.load(open(sys.argv[1]))
assert t['labels']['ask'] == 'A-test'
assert t['labels']['model'] == 'fake'
assert t['labels']['ck-herdr'] == 'true'
assert t['reported'] is True
assert t['status']['state'] == 'done'
assert t['argv'][0].endswith('python3')
assert t['die_with_parent'] is False
print('PASS real hc OSC working-to-done, labels, listing, persistent terminal, .out final exit=0')
PY
# A duplicate launch must leave the previous output untouched.
cp "$CK_HERDR_RUNS_DIR/$slug.out" "$scratch/first.out"
set +e
bin/ck-herdr launch "$slug" --model fake --cwd "$repo" > "$scratch/duplicate.txt" 2>&1
duplicate=$?
set -e
test "$duplicate" -eq 3
cmp "$CK_HERDR_RUNS_DIR/$slug.out" "$scratch/first.out"
echo 'PASS reused slug refuses to overwrite output'

# Wait for the fake program's own exit, even though its task already reported done.
"$CK_HERDR_HC" wait --json --output '__ck_fake_process_exit__' "$slug" > "$scratch/fake-exit.json"
python3 - "$scratch/fake-exit.json" <<'PY'
import json, sys
wait = json.load(open(sys.argv[1]))
assert wait['reason'] == 'exit' and wait['exit_code'] == 0
PY
"$CK_HERDR_HC" kill --json "$slug" >/dev/null 2>&1 || :
"$CK_HERDR_HC" rm --json "$slug" > "$scratch/removed.json"
"$CK_HERDR_HC" ls --all --json > "$scratch/cleanup.json"
python3 - "$scratch/cleanup.json" "$slug" <<'PY'
import json, sys
assert all(t.get('name') != sys.argv[2] for t in json.load(open(sys.argv[1]))['terminals'])
PY
"$CK_HERDR_HC" server stop > "$scratch/core-stopped.txt"
trap - EXIT HUP INT TERM
mkdir -p tests/artifacts
cp "$CK_HERDR_RUNS_DIR/$slug.out" tests/artifacts/fake-run.out
cp "$scratch/terminal.json" tests/artifacts/fake-terminal.json
cp "$scratch/fake-exit.json" tests/artifacts/fake-exit.json
cp "$scratch/list.txt" tests/artifacts/fake-list.txt
cp "$scratch/cleanup.json" tests/artifacts/cleanup.json
cp "$scratch/sol-dry-run.txt" tests/artifacts/sol-dry-run.txt
echo 'PASS test terminal killed/removed and private core stopped'
echo "EVIDENCE $scratch"
echo 'ALL CHECKS PASSED (fake_or_tests; no real model launched)'
