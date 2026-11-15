"""Scoped, read-only A-1115-12 live check; only its two terminals are cleaned up."""
import json
import os
from pathlib import Path
import subprocess
import time

repo = Path(__file__).resolve().parents[2]
proof = repo / 'tests/artifacts/real-runs'
proof.mkdir(exist_ok=True)
names = ['a1115-12-real-sonnet', 'a1115-12-real-grok']

def hc(*args):
    result = subprocess.run(['hc', *args], capture_output=True, text=True, timeout=40)
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)
    return json.loads(result.stdout)

before = hc('ls', '--all', '--json')
(proof/'terminals-before.json').write_text(json.dumps(before, indent=2)+'\n')
assert not any(t.get('name') in names for t in before['terminals']), 'Refuse reused live-check terminals'
env = dict(os.environ, CK_HERDR_RUNS_DIR=str(proof))
# Keep prompts and .out inside the authorized repository; cwd is agent_runs as requested.
for slug, model in zip(names, ['sonnet', 'grok']):
    prompt = proof / (slug + '_prompt.md')
    with prompt.open('x') as f:
        f.write('Tiny read-only Herdr check for A-1115-12. Do only this:\n'
                'Run pwd and date. Read the first line of ./herdr_ref/hc_skill.md.\n'
                f'Reply exactly: HERDR OK {model} | <pwd output> | <first line read>\n'
                'Do not write, edit, create, or delete any file. Do not start agents. Then stop.\n')

processes = []
started = []
timing = []
try:
    for slug, model in zip(names, ['sonnet', 'grok']):
        if timing:
            time.sleep(max(0, 8 - (time.monotonic() - timing[0]['monotonic'])))
        timing.append({'slug':slug, 'unix_seconds':time.time(), 'monotonic':time.monotonic()})
        output = (proof/(slug+'.launcher.txt')).open('x')
        p = subprocess.Popen([str(repo/'bin/ck-herdr'), 'launch', slug, '--model', model,
                              '--cwd', str(Path.home()/'PhD_local/agent_runs'),
                              '--ask', 'A-1115-12', '--title', 'Read-only Herdr check'],
                             env=env, stdout=output, stderr=subprocess.STDOUT)
        processes.append((slug,p,output))
        started.append(slug)
    (proof/'launch-timing.json').write_text(json.dumps(timing,indent=2)+'\n')
    results = {}
    for slug,p,output in processes:
        results[slug] = p.wait(timeout=220)
        output.close()
        (proof/(slug+'.terminal.json')).write_text(json.dumps(hc('get','--json',slug),indent=2)+'\n')
    # The Cursor launcher deliberately returns unknown immediately. Allow its tiny
    # read-only task to run before capturing its tab and cleaning up. This wait's
    # timeout is observation only; it is never interpreted as task completion.
    observed = subprocess.run(['hc','wait','--json','--timeout','30',names[1]],
                              capture_output=True,text=True,timeout=40)
    (proof/'grok-observation-wait.json').write_text(observed.stdout+observed.stderr)
    for slug in names:
        screen=subprocess.run(['hc','read','--lines','100',slug],capture_output=True,text=True,timeout=40)
        (proof/(slug+'.screen.txt')).write_text(screen.stdout+screen.stderr)
        (proof/(slug+'.terminal-final.json')).write_text(json.dumps(hc('get','--json',slug),indent=2)+'\n')
    app=subprocess.run(['herdr-app','ls'],capture_output=True,text=True,timeout=40)
    (proof/'app-during.json').write_text(app.stdout+app.stderr)
    (proof/'launcher-results.json').write_text(json.dumps(results,indent=2)+'\n')
    for slug in names:
        print(slug, 'process_exit='+str(results[slug]), flush=True)
        print('\n'.join((proof/(slug+'.out')).read_text().splitlines()[-2:]), flush=True)
    assert results[names[0]] == 0, results
    assert results[names[1]] in (0,2), results
finally:
    for slug,p,output in processes:
        if p.poll() is None:
            p.terminate();p.wait(timeout=10)
        output.close()
    for slug in started:
        # Preflight proved these names absent. Never target any earlier or other terminal.
        for command in ['kill','rm']:
            result=subprocess.run(['hc',command,'--json',slug],capture_output=True,text=True,timeout=40)
            (proof/(slug+'.'+command+'.json')).write_text(result.stdout+result.stderr)
    after=hc('ls','--all','--json')
    (proof/'terminals-after.json').write_text(json.dumps(after,indent=2)+'\n')
    assert not any(t.get('name') in names for t in after['terminals'])
