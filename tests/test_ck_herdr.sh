#!/bin/sh
# Stub regressions plus real hc, fake agent only. All state and prompts stay inside this repository.
set -eu
repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo"
# The launching agent's Herdr terminal must not leak in: --place beside would touch the real window.
unset HC_TERMINAL_ID
python3 tests/test_beside.py
# No real app/core calls in these regressions, including the dry-run cases.
# Normal Cursor launches use the summary wrapper, never the parked plugin.
python3 - <<'PYWRAPPER'
import runpy
m = runpy.run_path('bin/ck-herdr')
for spec in [{'agent':'cursor','model':'grok'},
             {'agent':'cursor','command':['/fake/cursor']}]:
    argv, _ = m['agent_command']({'aliases':{'test':spec}}, 'test')
    assert '--plugin-dir' not in argv, argv
print('PASS normal Cursor argv omits parked plugin')
PYWRAPPER
# A real controlling PTY, no hc or model; check stability and interactive I/O.
python3 - <<'PYPTY'
import errno,json,os,pathlib,pty,select,signal,sys,tempfile,time
repo=pathlib.Path.cwd()
(repo/'tests/.scratch').mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(dir=repo/'tests/.scratch') as tmp:
    root=pathlib.Path(tmp)
    def run_case(mode,code):
        folder=root/mode;folder.mkdir()
        fake=folder/'child.py'
        fake.write_text(r'''import pathlib,sys,time
folder=pathlib.Path(sys.argv[1]); mode=sys.argv[2]
assert sys.stdin.isatty() and sys.stdout.isatty()
print('CHILD READY',flush=True)
if mode=='interactive':
    assert input()=='steer child'
    print('STEERED',flush=True)
if mode in ('complete','interactive','on-exit'):
    (folder/'result.md').write_text('result')
    (folder/'summary.md').write_text('summary')
elif mode=='changing':
    (folder/'result.md').write_text('result')
    for i in range(8):
        (folder/'summary.md').write_text('changing '+str(i));time.sleep(.2)
    print('WRITING FINISHED',flush=True)
elif mode=='no-result': (folder/'summary.md').write_text('summary')
elif mode=='empty':
    (folder/'result.md').write_text('result');(folder/'summary.md').touch()
if mode != 'on-exit': time.sleep(2)
sys.exit(int(sys.argv[3]))
''')
        pid,fd=pty.fork()
        if pid==0:
            os.execv(sys.executable,[sys.executable,str(repo/'bin/ck-herdr-cursor'),str(folder),'--',sys.executable,str(fake),str(folder),mode,str(code)])
        output=b'';status=None;deadline=time.monotonic()+12;steered=False
        try:
            while time.monotonic()<deadline:
                if select.select([fd],[],[],.1)[0]:
                    try: part=os.read(fd,65536)
                    except OSError as exc:
                        if exc.errno!=errno.EIO: raise
                        break
                    if not part: break
                    output+=part
                    if mode=='interactive' and b'CHILD READY' in output and not steered:
                        os.write(fd,b'steer child\n');steered=True
                who,status=os.waitpid(pid,os.WNOHANG)
                if who: break
            if not who: _,status=os.waitpid(pid,0)
        finally: os.close(fd)
        assert os.waitstatus_to_exitcode(status)==code,(mode,status,output)
        assert b'state=working:app=ck-summary-wrapper' in output,(mode,output)
        done=b'state=done:app=ck-summary-wrapper' in output
        assert done==(mode in ('complete','interactive','changing','on-exit')),(mode,output)
        if not done: assert b'state=error:app=ck-summary-wrapper' in output,(mode,output)
        if mode=='changing': assert output.index(b'WRITING FINISHED')<output.index(b'state=done'),output
        if mode=='interactive': assert b'STEERED' in output,output
        print('PASS wrapper PTY '+mode+' preserves child exit='+str(code),flush=True)
    for mode,code in [('complete',0),('interactive',0),('changing',0),('on-exit',7),('missing',7),('empty',0),('no-result',0)]:
        run_case(mode,code)
    # No controlling tty: fallback exec preserves the child code, no fake done.
    result=__import__('subprocess').run([sys.executable,str(repo/'bin/ck-herdr-cursor'),str(root),'--',sys.executable,'-c','raise SystemExit(7)'],start_new_session=True,capture_output=True,text=True)
    assert result.returncode==7 and 'completion unknown' in result.stderr and '7501' not in result.stdout
    print('PASS wrapper unavailable tty falls back honestly and preserves child exit')
PYPTY
python3 - <<'PYTEST'
import json, os, pathlib, subprocess, sys, tempfile
repo = pathlib.Path.cwd()
(repo/'tests/.scratch').mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(dir=repo/'tests/.scratch') as tmp:
    root = pathlib.Path(tmp)
    calls = root/'calls.jsonl'
    stub = root/'stub'
    stub.write_text('#!' + sys.executable + '\n' + r'''import json, os, pathlib, sys
p = pathlib.Path(os.environ['STUB_ROOT'])
a = sys.argv[1:]
app = pathlib.Path(sys.argv[0]).name == 'herdr-app'
with (p/'calls.jsonl').open('a') as f:
    f.write(json.dumps(['app' if app else 'hc', *a]) + "\n")
mode = os.environ['STUB_MODE']
if app:
    if mode == 'no-window':
        print('no Herdr window', file=sys.stderr)
        sys.exit(1)
    if a == ['ls']:
        spaces = [] if mode == 'created' and not (p/'created').exists() else [
            {'name': 'Other', 'id': 'wrong'},
            {'name': os.environ.get('STUB_SPACE', 'CK'), 'id': 'space-test'}]
        print(json.dumps({'spaces': spaces}))
    elif a[:2] == ['do', 'space.new']:
        (p/'created').touch()
        print(json.dumps({'space': 'space-test'}))
    else:
        sys.exit(2)
else:
    if a[0] == 'events':
        print(json.dumps({'terminals':[{'address':'fake', 'state':'live', 'turn':1, 'status':{'state':'done'}}]}))
    elif a[0] == 'read':
        print('fake done')
    else:
        print('{}')
''')
    stub.chmod(0o755)
    app = root/'herdr-app'
    hc = root/'hc'
    app.symlink_to(stub)
    hc.symlink_to(stub)
    models = root/'models.json'
    models.write_text(json.dumps({'aliases': {'fake': {'command': ['/fake/agent']}}}))
    env = dict(os.environ, CK_HERDR_APP=str(app), CK_HERDR_HC=str(hc),
               CK_HERDR_MODELS=str(models), CK_HERDR_RUNS_DIR=str(root), STUB_ROOT=str(root))
    for mode in ['found', 'created', 'no-window', 'missing', 'custom']:
        calls.unlink(missing_ok=True)
        env.update(STUB_MODE=mode, STUB_SPACE='Research' if mode == 'custom' else 'CK')
        env['CK_HERDR_APP'] = str(root/'missing-app') if mode == 'missing' else str(app)
        slug = 'stub-' + mode
        (root/(slug+'_prompt.md')).write_text('Fake only')
        argv = ['bin/ck-herdr', 'launch', slug, '--model', 'fake', '--cwd', str(repo)]
        if mode == 'custom':
            argv += ['--space', 'Research']
        result = subprocess.run(argv, env=env, capture_output=True, text=True)
        assert result.returncode == 0, (mode, result.stdout, result.stderr)
        records = [json.loads(x) for x in calls.read_text().splitlines()]
        run = next(x for x in records if x[:2] == ['hc', 'run'])
        label = 'herdr.space=space-test'
        if mode in ['found', 'created', 'custom']:
            assert label in run[:run.index('--')], (mode, run)
            assert not result.stderr, result.stderr
        else:
            assert not any(x.startswith('herdr.space=') for x in run)
            assert len(result.stderr.splitlines()) == 1 and 'warning:' in result.stderr
        creates = [x for x in records if x[:3] == ['app', 'do', 'space.new']]
        assert len(creates) == (1 if mode == 'created' else 0), records
        if creates:
            assert creates[0] == ['app', 'do', 'space.new', '--name', 'CK', '--folder',
                                  str(pathlib.Path.home()/'PhD_local/agent_runs')]
        print('PASS stub space ' + mode)
    for prefix in [[], ['--dry-run']]:
        calls.unlink(missing_ok=True)
        env.update(CK_HERDR_APP=str(app), STUB_MODE='created')
        slug = 'dry-preview'
        argv = ['bin/ck-herdr', *prefix, 'launch', slug, '--model', 'fake', '--cwd', str(repo)]
        if not prefix:
            argv += ['--dry-run']
        result = subprocess.run(argv, env=env, capture_output=True, text=True)
        assert result.returncode == 0, result.stderr
        assert not calls.exists() and not (root/(slug+'.out')).exists()
        assert 'herdr.space=' in result.stdout and 'space.new' in result.stdout and ' ls' in result.stdout
    print('PASS stub dry-run previews space lookup/create/label with no calls or writes')
PYTEST
# Regressions for A-1115-12. Each case exercises the launcher, never model text.
python3 - <<'PYREG'
import json, os, pathlib, subprocess, sys, tempfile
repo = pathlib.Path.cwd()
failures = []
with tempfile.TemporaryDirectory(dir=repo/'tests/.scratch') as tmp:
    root = pathlib.Path(tmp)
    stub = root/'stub'
    stub.write_text('#!' + sys.executable + '\n' + r'''import json, os, pathlib, sys, time
p = pathlib.Path(os.environ['STUB_ROOT']); a = sys.argv[1:]
mode = os.environ['STATUS_CASE']
if pathlib.Path(sys.argv[0]).name == 'herdr-app':
    if a == ['ls']:
        exists = (p/'space').exists()
        if mode == 'race' and not exists:
            time.sleep(.25) # Deliberately widen the lookup/create race.
        print(json.dumps({'spaces': [{'name':'CK','id':'space-shared'}] if exists else []}))
    else:
        with (p/'creates').open('a') as f: f.write('create\n')
        (p/'space').touch(); print('{}')
elif a[0] == 'run':
    with (p/'runs').open('a') as f: f.write(json.dumps(a)+'\n')
    print(json.dumps({'address':a[a.index('--name')+1], 'turn':0}))
elif a[0] == 'label':
    print('{}')
elif a[0] == 'read':
    print('done success finished 100%') # Must NEVER be parsed for status.
elif a[0] == 'wait':
    if mode == 'cursor':
        print(json.dumps({'reason':'timeout','ended':False,'status':None,'turn':0}))
    else:
        print(json.dumps({'reason':'status','ended':True,'status':'idle','turn':1 if mode == 'idle-worked' else 0}))
elif a[0] == 'events':
    t = a[a.index('--terminal')+1]
    def emit(v): print(json.dumps(v),flush=True)
    if mode == 'idle-startup':
        emit({'terminals':[{'address':t,'state':'live','turn':0,'status':{'state':'idle'}}]})
        for typ,data in [('status',{'status':{'state':'working'}}),('status',{'status':{'state':'idle'}}),('turn',{'turn':1,'state':'idle'})]:
            emit({'method':'event','params':{'terminal':t,'type':typ,'data':data}})
    else:
        state = 'idle' if mode.startswith('idle-') else ('done' if mode != 'cursor' else None)
        emit({'terminals':[{'address':t,'state':'live','turn':1 if mode == 'idle-worked' else 0,'status':{'state':state} if state else None}]})
    # A never-worked agent stays alive until the launcher's bounded observation ends.
    time.sleep(5)
''')
    stub.chmod(0o755)
    for name in ['hc','herdr-app']: (root/name).symlink_to(stub)
    models = root/'models.json'
    models.write_text(json.dumps({'aliases':{
        'fake':{'command':['/fake/agent']},
        'cursor-fake':{'agent':'cursor','command':['/fake/cursor']}}}))
    env = dict(os.environ,CK_HERDR_HC=str(root/'hc'),CK_HERDR_APP=str(root/'herdr-app'),
               CK_HERDR_MODELS=str(models),CK_HERDR_RUNS_DIR=str(root),STUB_ROOT=str(root),
               CK_HERDR_WAIT_TIMEOUT='0.15')
    for mode,expected,word in [('idle-worked',0,'done'),('idle-startup',0,'done'),
                               ('idle-never',1,'partial'),('cursor',2,'unknown')]:
        slug='status-'+mode; (root/(slug+'_prompt.md')).write_text('fake only')
        result=subprocess.run(['bin/ck-herdr','launch',slug,'--model',
            'cursor-fake' if mode == 'cursor' else 'fake','--cwd',str(repo)],
            env=dict(env,STATUS_CASE=mode),capture_output=True,text=True,timeout=10)
        out=(root/(slug+'.out')).read_text()
        ok=result.returncode == expected and 'status='+word in out
        if mode == 'cursor': ok=ok and 'read the tab' in out and '"reason": "timeout"' not in out
        print(('PASS' if ok else 'FAIL')+' regression '+mode,flush=True)
        if not ok: failures.append(mode+': '+out[-350:])
    (root/'space').unlink(missing_ok=True);(root/'creates').unlink(missing_ok=True)
    (root/'runs').unlink(missing_ok=True)
    procs=[]
    for slug in ['race-a','race-b']:
        (root/(slug+'_prompt.md')).write_text('fake only')
        procs.append(subprocess.Popen(['bin/ck-herdr','launch',slug,'--model','fake','--cwd',str(repo)],
            env=dict(env,STATUS_CASE='race'),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True))
    results=[p.communicate(timeout=10) for p in procs]
    creates=(root/'creates').read_text().splitlines()
    runs=[json.loads(x) for x in (root/'runs').read_text().splitlines()]
    ok=all(p.returncode == 0 for p in procs) and len(creates)==1 and len(runs)==2 and all('herdr.space=space-shared' in r for r in runs)
    print(('PASS' if ok else 'FAIL')+' regression concurrent space lookup/create',flush=True)
    if not ok: failures.append('space creates='+str(len(creates))+'; codes='+str([p.returncode for p in procs]))
assert not failures, '\n'.join(failures)
PYREG
if test "${CK_HERDR_STUB_ONLY:-}" = 1; then exit 0; fi

mkdir -p tests/artifacts/summary-wrapper-fakes
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
export CK_HERDR_APP="$repo/tests/.scratch/no-app-for-private-core"
mkdir -p "$CK_HERDR_RUNS_DIR" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"
slug="ck-test-$$"
cleanup() {
    "$CK_HERDR_HC" kill --json "$slug" >/dev/null 2>&1 || :
    "$CK_HERDR_HC" rm --json "$slug" >/dev/null 2>&1 || :
    for extra in idle never cursor cursor-summary; do
        "$CK_HERDR_HC" kill --json "$slug-$extra" >/dev/null 2>&1 || :
        "$CK_HERDR_HC" rm --json "$slug-$extra" >/dev/null 2>&1 || :
    done
    # This is this test's private core, never the user's session.
    "$CK_HERDR_HC" server stop >/dev/null 2>&1 || :
}
trap cleanup EXIT HUP INT TERM

# Dry-run reads the real alias file and performs no hc calls or writes.
bin/ck-herdr launch --dry-run "$slug" --model sol --cwd "$repo" --ask A-test --title 'Fake fixture only' > "$scratch/sol-dry-run.txt"
grep -q 'codex --no-daemon --approve-for-me -m gpt-6.1-sol' "$scratch/sol-dry-run.txt"
grep -q 'events --json --terminal' "$scratch/sol-dry-run.txt"
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
assert m['outcome']({'reason': 'status', 'status': 'idle', 'turn': 1}) == (0, 'done')
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
grep -q '"state":"done"' "$CK_HERDR_RUNS_DIR/$slug.out"
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
# Real hc fake agents cover startup idle, completed idle, no work, and no OSC.
python3 - "$scratch" <<'PY'
import json, pathlib, shutil, sys
p=pathlib.Path(sys.argv[1])
(p/'fake-idle.py').write_text(r'''import sys,time
mode=sys.argv[1]
def report(s):
    print("\x1b]7501;state="+s+":app=ck-fake\x1b\\",flush=True)
if mode != "cursor": report("idle")
time.sleep(.3)
if mode == "idle":
    report("working"); time.sleep(.3); report("idle")
print("done success finished",flush=True) # Text cannot make no-work idle complete.
time.sleep(10)
''')
models=json.loads((p/'models.json').read_text())
for mode in ['idle','never','cursor']:
    models['aliases'][mode]={'command':[shutil.which('python3'),str(p/'fake-idle.py'),mode]}
models['aliases']['cursor']['agent']='cursor'
# Cursor child writes files but emits no OSC: only the wrapper can report done.
(p/'fake-cursor-summary.py').write_text(r'''import pathlib,re,sys,time
folder=pathlib.Path(re.search(r"OUTBOX: (.*?)\. When you are finished:",sys.argv[-1]).group(1))
print("interactive child visible",flush=True)
time.sleep(.3)
(folder/'result.md').write_text('Fake result only\n')
(folder/'summary.md').write_text('Fake summary complete\n')
time.sleep(10)
''')
models['aliases']['cursor-summary']={'agent':'cursor','command':[shutil.which('python3'),str(p/'fake-cursor-summary.py')]}
(p/'models.json').write_text(json.dumps(models))
PY
for mode in idle never cursor cursor-summary; do
    printf '%s\n' 'Fake only. No model.' > "$CK_HERDR_RUNS_DIR/$slug-${mode}_prompt.md"
    set +e
    CK_HERDR_WAIT_TIMEOUT=2 bin/ck-herdr launch "$slug-$mode" --model "$mode" --cwd "$repo" > "$scratch/$mode-launch.txt" 2>&1
    code=$?
    set -e
    case "$mode" in
        idle) expected=0 ;;
        never) expected=1 ;;
        cursor) expected=3 ;;
        cursor-summary) expected=0 ;;
    esac
    if test "$code" -ne "$expected"; then
        cat "$CK_HERDR_RUNS_DIR/$slug-$mode.out"
        exit 1
    fi
    cp "$CK_HERDR_RUNS_DIR/$slug-$mode.out" "tests/artifacts/summary-wrapper-fakes/fake-$mode.out"
    if test "$mode" = cursor-summary; then
        "$CK_HERDR_HC" get --json "$slug-$mode" > tests/artifacts/fake-cursor-summary-terminal.json
        "$CK_HERDR_HC" wait --json "$slug-$mode" > tests/artifacts/fake-cursor-summary-wait.json
        python3 - <<'PYCHECK'
import json
record=json.load(open('tests/artifacts/fake-cursor-summary-terminal.json'))
assert record['reported'] and record['status']['state']=='done'
assert record['status']['app']=='ck-summary-wrapper'
assert record['state']=='live'
assert any(x.endswith('/ck-herdr-cursor') for x in record['argv'])
wait=json.load(open('tests/artifacts/fake-cursor-summary-wait.json'))
assert wait['reason']=='status' and wait['status']=='done'
print('PASS summary-file wrapper reports real hc root done to get and wait while child stays interactive')
PYCHECK
    fi
    "$CK_HERDR_HC" kill --json "$slug-$mode" > "$scratch/$mode-kill.json"
    "$CK_HERDR_HC" rm --json "$slug-$mode" > "$scratch/$mode-rm.json"
    echo "PASS real hc fake $mode final exit=$expected"
done
"$CK_HERDR_HC" server stop > "$scratch/core-stopped.txt"
trap - EXIT HUP INT TERM
mkdir -p tests/artifacts
cp "$CK_HERDR_RUNS_DIR/$slug.out" tests/artifacts/summary-wrapper-fakes/fake-run.out
cp "$scratch/terminal.json" tests/artifacts/summary-wrapper-fakes/fake-terminal.json
cp "$scratch/fake-exit.json" tests/artifacts/summary-wrapper-fakes/fake-exit.json
cp "$scratch/list.txt" tests/artifacts/summary-wrapper-fakes/fake-list.txt
cp "$scratch/cleanup.json" tests/artifacts/summary-wrapper-fakes/cleanup.json
cp "$scratch/sol-dry-run.txt" tests/artifacts/summary-wrapper-fakes/sol-dry-run.txt
echo 'PASS test terminal killed/removed and private core stopped'
echo "EVIDENCE $scratch"
echo 'ALL CHECKS PASSED (fake_or_tests; no real model launched)'
