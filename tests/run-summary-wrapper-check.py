"""Only the authorized read-only Grok acceptance check; never part of the suite."""
import json
import os
from pathlib import Path
import subprocess

repo = Path(__file__).resolve().parents[1]
proof = repo / 'tests/artifacts/summary-wrapper-real'
proof.mkdir(exist_ok=True)
slug = 'a1115-17-real-grok'


def hc(*args):
    result = subprocess.run(['hc', *args], capture_output=True, text=True, timeout=40)
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)
    return json.loads(result.stdout)


def save(name, data):
    (proof/name).write_text(json.dumps(data, indent=2)+'\n')


before = hc('ls', '--all', '--json')
save('terminals-before.json', before)
assert not any(t.get('name') == slug for t in before['terminals']), 'Refuse reused terminal'
with (proof/(slug+'_prompt.md')).open('x') as prompt:
    prompt.write('Tiny read-only Herdr check. Do only this:\n'
                 'Run pwd and date. Read the first line of ./herdr_ref/hc_skill.md.\n'
                 'Include exactly this line in your reply and result: HERDR OK grok | <pwd output> | <first line read>\n'
                 'Do not edit, create, or delete any other files. The launcher-authorized result.md and summary.md writes are required.\n'
                 'Do not start agents. Then stop.\n')
try:
    env = dict(os.environ, CK_HERDR_RUNS_DIR=str(proof))
    result = subprocess.run([str(repo/'bin/ck-herdr'), 'launch', slug, '--model', 'grok',
                             '--cwd', str(Path.home()/'PhD_local/agent_runs'),
                             '--ask', 'A-1115-17', '--title', 'Read-only summary wrapper check'],
                            env=env, capture_output=True, text=True, timeout=225)
    (proof/'launcher.txt').write_text(result.stdout+result.stderr)
    terminal = hc('get', '--json', slug)
    save('terminal-final.json', terminal)
    save('wait-final.json', hc('wait', '--json', '--timeout', '1', slug))
    save('app-final.json', json.loads(subprocess.run(['herdr-app', 'ls'], capture_output=True,
                                                   text=True, check=True, timeout=40).stdout))
    screen = subprocess.run(['hc', 'read', '--lines', '100', slug], capture_output=True, text=True, timeout=40)
    (proof/'screen.txt').write_text(screen.stdout+screen.stderr)
    final = '\n'.join((proof/(slug+'.out')).read_text().splitlines()[-2:])
    (proof/'result.txt').write_text('launcher_exit='+str(result.returncode)+'\n'+final+'\n'
                                   +'hc_status='+str((terminal.get('status') or {}).get('state'))+'\n'
                                   +'hc_status_app='+str((terminal.get('status') or {}).get('app'))+'\n')
    print((proof/'result.txt').read_text(), flush=True)
    assert result.returncode == 0, 'Real launch did not complete successfully'
    assert terminal['state'] == 'live' and terminal['reported']
    assert terminal['status']['state'] == 'done'
    assert terminal['status']['app'] == 'ck-summary-wrapper'
    assert (proof/slug/'result.md').is_file() and (proof/slug/'summary.md').stat().st_size
finally:
    current = hc('ls', '--all', '--json')
    targets = [t for t in current['terminals'] if t.get('name') == slug]
    if targets:
        assert len(targets) == 1
        assert targets[0]['address'] not in {t['address'] for t in before['terminals']}
        for command in ['kill', 'rm']:
            save(command+'.json', hc(command, '--json', targets[0]['address']))
    after = hc('ls', '--all', '--json')
    save('terminals-after.json', after)
    prior = {t['address'] for t in before['terminals'] if t.get('state') == 'live'}
    live_after = {t['address'] for t in after['terminals'] if t.get('state') == 'live'}
    assert prior <= live_after, 'A preexisting terminal ended; inspect snapshots'
    assert not any(t.get('name') == slug for t in after['terminals'])
    (proof/'cleanup.txt').write_text('PASS only the new test terminal killed and removed; all preexisting live addresses remain live\n')
