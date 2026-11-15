"""One authorized read-only Grok check; retain evidence, remove only its terminal."""
import json
import os
from pathlib import Path
import subprocess

repo = Path(__file__).resolve().parents[2]
proof = repo / 'tests/artifacts/cursor-hook-real'
proof.mkdir(exist_ok=True)
slug = 'a1115-13-real-grok'

def hc(*args):
    result = subprocess.run(['hc', *args], capture_output=True, text=True, timeout=40)
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)
    return json.loads(result.stdout)

before = hc('ls', '--all', '--json')
(proof/'terminals-before.json').write_text(json.dumps(before, indent=2)+'\n')
assert not any(t.get('name') == slug for t in before['terminals']), 'Refuse reused terminal'
# Prompt/output stay in the allowed repository; the agent cwd is agent_runs.
prompt = proof/(slug+'_prompt.md')
with prompt.open('x') as f:
    f.write('Tiny read-only Herdr check. Do only this:\n'
            'Run pwd and date. Read the first line of ./herdr_ref/hc_skill.md.\n'
            'Reply exactly: HERDR OK grok | <pwd output> | <first line read>\n'
            'Do not write, edit, create, or delete any file. Do not start agents. Then stop.\n')
try:
    env = dict(os.environ, CK_HERDR_RUNS_DIR=str(proof))
    result = subprocess.run([str(repo/'bin/ck-herdr'),'launch',slug,'--model','grok',
                             '--cwd',str(Path.home()/'PhD_local/agent_runs'),
                             '--ask','A-1115-13','--title','Read-only per-launch hook check'],
                            env=env, capture_output=True,text=True,timeout=225)
    (proof/'launcher.txt').write_text(result.stdout+result.stderr)
    (proof/'terminal-final.json').write_text(json.dumps(hc('get','--json',slug),indent=2)+'\n')
    screen = subprocess.run(['hc','read','--lines','100',slug],capture_output=True,text=True,timeout=40)
    (proof/'screen.txt').write_text(screen.stdout+screen.stderr)
    final = '\n'.join((proof/(slug+'.out')).read_text().splitlines()[-2:])
    (proof/'result.txt').write_text('launcher_exit='+str(result.returncode)+'\n'+final+'\n')
    print((proof/'result.txt').read_text(),flush=True)
finally:
    # Only target the fresh test name if it was actually created by this launch.
    current = hc('ls','--all','--json')
    targets = [t for t in current['terminals'] if t.get('name') == slug]
    if targets:
        assert len(targets) == 1
        for command in ['kill','rm']:
            response=hc(command,'--json',targets[0]['address'])
            (proof/(command+'.json')).write_text(json.dumps(response,indent=2)+'\n')
    after=hc('ls','--all','--json')
    (proof/'terminals-after.json').write_text(json.dumps(after,indent=2)+'\n')
    prior={t['address'] for t in before['terminals'] if t.get('state')=='live'}
    live_after={t['address'] for t in after['terminals'] if t.get('state')=='live'}
    assert prior <= live_after, 'A preexisting terminal is no longer live; inspect snapshots'
    assert not any(t.get('name')==slug for t in after['terminals'])
