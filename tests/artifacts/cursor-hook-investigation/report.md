# Cursor skipped-hook investigation

Outcome: **partial**. The skipped-hook cause is established. No production fix
was applied because the demonstrated dispatch workaround needs protected global
configuration. A separate real-hook tty failure also prevents a done claim.
Verification: **fake_or_tests**, plus the real interactive experiments below.

## Root cause

The installed interactive Cursor CLI gates `beforeSubmitPrompt` and `stop` on
the presence of **user or project hooks only**. Plugin hooks are absent from
that predicate. The plugin loads successfully, but these events never reach its
executor when only plugin configuration supplies them.

Installed version: `2026.11.13-eacade1` (`agent-version.txt:1`).
The exact call sites, including completed, aborted, and error stop paths, are
in `callsite-excerpts.txt:1-14`, extracted from the installed
`/Users/ckasemtantikul/.local/share/cursor-agent/versions/2026.11.13-eacade1/2986.index.js:1`.
The startup path uses the executor's hook check instead (`callsite-excerpts.txt:13-14`).
`loader-excerpts.txt` records that the plugin loader accepts the hooks file and
merges its hooks into the executor. It is the interactive caller that skips them.

The opt-in test `../../probe_cursor_hook_gate.py` executes the installed guard
against fake configurations. `gate-test.txt` shows plugin-only rejected and
user/project configurations admitted for both events. This is a reproduction of
the upstream defect, not an end-to-end fix or an installed-binary modification.

## Real experiments

The scratch plugin under `tests/.scratch/a1115-15/probe-plugin` used the same
manifest and hook schema as production. Its hooks only appended event names and
status fields to a local file. A fresh interactive Grok session used:

```sh
hc run --json --bg --outlive-parent --no-notify \
  --name a1115-15-probe --cwd /Users/ckasemtantikul/PhD_local/agent_runs -- \
  agent --auto-review --sandbox enabled --model grok-4.7-high \
  --plugin-dir /Users/ckasemtantikul/PhD_local/ck-herdr/tests/.scratch/a1115-15/probe-plugin \
  'Read-only hook probe. Reply exactly HOOK PROBE FINISHED. Do not use tools, write files, or start agents. Then stop.'
```

`probe-events.jsonl` contains the startup event; it has no prompt, response, or
stop event. `probe-screen.txt` shows the requested reply and input prompt.
`probe-hooks.json` records the CLI's successful startup-hook diagnostic.
`probe-terminal.json` still has no Herdr status report. The screen is observation
evidence only; it is not a completion signal. These observations establish that
the plugin was loaded and could execute a simple file write without a trust or
enablement change in this workspace.

A second fresh session supplied no model prompt. Its startup hook only attempted
to open `/dev/tty` and wrote the result to a file. `tty-probe-event.json` shows
that the Herdr terminal identity was inherited but `/dev/tty` could not be opened.
Its source and configuration are retained in `tty-probe-plugin/`; launch,
screen, terminal, and cleanup records use the `tty-probe-` prefix.

This is a separate transport bug in the existing bridge. The fake fixture invokes
the hook as a normal subprocess with its controlling tty still attached; real
Cursor hook execution does not preserve that condition in this check. Fixing
dispatch alone does **not** prove the existing bridge will emit a done status.
No attempt was made to infer completion from text, process exit, or startup.

## Exact global proposal — NOT APPLIED

Merge the entries in `proposed-user-hooks.json` into
`/Users/ckasemtantikul/.cursor/hooks.json`, preserving existing entries and
configuration. Do not replace the entire file. These entries return inert JSON:

```json
{
  "version": 1,
  "hooks": {
    "beforeSubmitPrompt": [{"command": "printf '%s\\n' '{\"continue\":true}'"}],
    "stop": [{"command": "printf '%s\\n' '{}'"}]
  }
}
```

They satisfy the installed user-hook gate so the executor can dispatch the
repo-local plugin too. They do not report status, grant tool permissions, request
a follow-up, or change trust. The gate behavior is tested with fake inputs and
the commands' JSON output is tested in `proposal-command-test.txt`.
**Live effectiveness remains UNVERIFIED because the proposal was not installed.**
It applies to other Cursor sessions as global configuration, which is why it
requires chalach's explicit approval. Repair and test the tty transport before
claiming completion after this change.

Official references checked: [Cursor hooks](https://cursor.com/docs/hooks)
documents user/project/plugin hooks and JSON exchange;
[Cursor plugin reference](https://cursor.com/docs/reference/plugins) documents
the manifest, hooks path, and hook events. The installed `agent --help`
(`agent-help.txt`) advertises local plugin loading but no hook-config override.
The mismatch here is established by the installed code and real experiments,
not by assuming that IDE documentation guarantees CLI behavior.

## Tests, cleanup, and limits

`fake-suite.txt` records the unchanged full fake suite passing in an isolated
repo-local copy. `suite-sources.json` records the copied source paths and hashes.
The first copy could not create its private core because the socket path was too
long; `fake-suite-path-limit.txt` preserves that failed attempt. The successful
copy uses a shorter path. No user's core was stopped or restarted.

`cleanup-check.txt`, the before/after terminal snapshots, and the kill/remove
records show that only this task's probe terminals were removed and every
preexisting live terminal address remained live. The no-prompt probe did not
submit a model task. The requested final `a1115-15-real-grok` acceptance run was
not launched because no permitted dispatch fix was installed.

No launcher, production plugin, exit-code mapping, global config, protected
workspace, or ck-dispatch file changed. Prior evidence and untracked `research/`
were retained. README and PROGRESS were updated; the diagnostic test and evidence
are new. No push, deployment, message, or installation was performed.

Later, not done: repair the separate tty transport, install an approved dispatch
workaround or obtain an upstream fix, then run the named real Grok acceptance
check. No production done result is claimed.

## Questions for chalach

Approve merging the exact inert activation entries in `proposed-user-hooks.json`
into `~/.cursor/hooks.json` in a follow-up run? The task explicitly forbids that
global edit in this run. The separate tty repair and real completion retest would
still be required.
