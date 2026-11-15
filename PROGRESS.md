# Progress

Done:
- Read required worker, bug-fix, wiki/rule, and Herdr reference guides; none missing.
- Reproduced missing launch-time herdr.space label with fake hc/app stubs before changing the launcher.
- Added default CK lookup, optional --space NAME, conditional space creation, launch-time label, and warning fallback.
- Dry-run previews lookup/create/label without app/core calls or file writes.
- Stub regressions and the existing isolated real-hc fake-agent suite pass.
- Updated the stale dry-run assertion to match the preceding committed Codex flag fix.
- Real app check passed with the existing fake fixture kept open using Python -i; its live terminal appeared under CK.
- Killed and removed only this run's fake terminals. Protected terminals remain present. No app/core restart or real model launch.
- Updated README with a short paragraph and corrected the obsolete space-mapping row.

Evidence:
- tests/artifacts/space-regression-before.txt (failure on old launcher)
- tests/artifacts/space-regression-after.txt and test-results.txt (passing tests)
- tests/artifacts/live-space-check.json, live-app-during.json, live-terminal.json, live-space-run.out (real app proof)
- tests/artifacts/live-kill.json, live-remove.json, live-app-after.json (cleanup)
- tests/artifacts/live-short-fixture-observations.json (earlier short-lived checks did not show tabs)

Limits:
- Verification: fake_or_tests plus a real-app check; real model startup/execution remains UNVERIFIED.
- Short-lived fixture snapshots did not show a tab; the retained interactive fake did. Window import latency was not measured.
- Socket checks ran under safety-reviewed execution. Tests stopped only their private core.

Finalization:
- Implementation and checks complete; local commit and outbox result/summary recorded at completion.
- No questions need chalach's decision.

Later (not done):
- Existing idle-to-done mapping, Grok completion, Cursor viewer items remain deferred.
- README still contains the older Codex invocation in its unrelated agent-command table; not changed in this space-tab task.

## Active task: A-1115-12 status and space lock

Done:
- Read worker, bug-fix, Herdr manuals, wiki entry/rules and open questions; no required guide missing.
- Confirmed supplied old logs return startup idle while work continues; hc turn counts completed working transitions.
- Read installed hc/agent help and official Cursor hooks/plugin docs. Existing research/ is unrelated and retained.

Remaining:
- Add failing regressions for worked-to-idle, no-work idle, missing Cursor status, and concurrent space creation.
- Implement smallest supported fixes and run isolated fake suite.
- Run only a1115-12-real-sonnet and a1115-12-real-grok, launched eight seconds apart, then clean up those terminals.
- Update README, commit locally, write result.md then summary.md in the authorized outbox.

Status-fix progress:
- Reproduced all reported gaps with fake hc/app regressions on the old launcher.
- Added hc event/turn completion, startup-idle handling, distinct Cursor unknown, and advisory space lock.
- New stub regressions and full private-core fake-agent suite pass (tests/artifacts/test-results.txt).
- Official Cursor docs describe stop hooks and plugin hooks; no protected configuration was edited.
- Cursor fallback is explicit unknown immediately after launch, never a completion claim.
- README updated. Remaining: final suite after review, scoped real checks, cleanup, local commit, outbox.

Completion evidence for A-1115-12:
- Final fake suite passed: tests/artifacts/final-suite.txt (also copied to test-results.txt at finalization).
- Real Sonnet ended done / exit=0; real Grok ended unknown / exit=2. Final lines: tests/artifacts/real-check-results.txt.
- Both read-only replies captured; Grok still has no hc status report.
- Launch spacing recorded in tests/artifacts/real-runs/launch-timing.json. Both launches used the same CK space.
- Only a1115-12-real-sonnet and a1115-12-real-grok were killed and removed. All preexisting live terminal IDs remain present afterward.
- The repo-local suite's sandboxed retry could not open its private core; diagnostic retained in sandbox-suite-attempt.txt. Safety-reviewed final suite passed.
- Existing research/ and prior live terminals were not modified. No ck-dispatch change, push, deployment, or install.
- Cursor plugin hook bridge remains UNVERIFIED, listed as later; the requested honest fallback is complete.

Remaining finalization:
- Confirm final diff, record local commit, write outbox result then summary.

Questions for chalach: none.

Finalization complete:
- Evidence consistency checks passed: tests/artifacts/final-verification.json.
- All tests and real checks have ended; no helper terminal remains.
- Local commit records the implementation and evidence. Outbox result.md is written before summary.md.
- No implementation work remains. Questions for chalach: none.

## Active task: A-1115-13 per-launch Cursor completion hook

Done:
- Read supplied worker, bug-fix, hc, prior research, README and wiki/rule guides; none missing.
- Confirmed installed agent --help supports --plugin-dir and official plugin docs support beforeSubmitPrompt/stop hooks.
- Mechanism (measured prior evidence): Cursor launches return unknown immediately without an OSC status bridge.

Remaining:
- Reproduce missing plugin path in a fake regression; implement repo-local hooks and bounded status observation.
- Run fake suite and only a1115-13-real-grok with read-only task; collect final status, then kill/remove only it.
- Update README/evidence, commit locally, write result.md followed by summary.md.

A-1115-13 outcome: partial; requested real-done criterion NOT met.
Done:
- Added repo-local Cursor plugin and Cursor-only --plugin-dir; no protected config changes.
- Hook JSON stdout stays separate from OSC on /dev/tty. Missing status cannot report success.
- Launcher now observes Cursor events until its existing deadline and retains unknown/read-the-tab fallback.
- Missing plugin argv regression failed before and passes after; full private-core fake suite passed under safety review.
- Single real a1115-13-real-grok produced requested read-only reply but ended status=unknown / ck-run exit=2.
- Real hc final record: reported=false, status=null. CLI log has no stop/beforeSubmitPrompt execution event.
- Underlying Cursor hook omission reason UNKNOWN. Do not call all CLI plugin hooks unsupported from this check.
- Killed/removed only the fresh test terminal; before/after snapshots confirm preexisting live terminals remain.
- Stopped implementation/model checks as requested on failure; no retry or global Cursor changes.
Evidence:
- tests/artifacts/cursor-hook-before.txt, cursor-hook-after.txt, cursor-hook-suite-reviewed.txt
- tests/artifacts/fake-cursor-hook-terminal.json, fake-cursor-hook.out
- tests/artifacts/cursor-hook-real/{result.txt,terminal-final.json,hook-diagnostics.json,screen.txt,kill.json,rm.json,terminals-before.json,terminals-after.json}
Remaining finalization:
- Review final diff, commit locally, write result.md then summary.md to the authorized outbox.
Verification: fake_or_tests plus a failed real-model completion check. No real hook completion claim.
Questions for chalach: none.
Later (not done): investigate Cursor's missing hook event in interactive Grok mode; exit-code changes remain separate.

A-1115-13 finalization:
- Final evidence consistency and cleanup checks pass (cursor-hook-final-verification.txt); git diff --check passes.
- No implementation or live-test work remains within scope. The failed real completion criterion is reported explicitly.
- Local commit and ordered outbox writes are the final recording steps; no push.

## Active task: A-1115-15 Cursor skipped-hook investigation

Done:
- Read required worker/playbook, wiki entry/rules/open questions, prior summary, hook evidence, and hc manual. No named guide missing.
- Confirmed clean tracked baseline; preexisting untracked research/ is preserved.
- Captured installed agent help/version and checked official Cursor hook/plugin documentation.
- Prior real run had no stop/prompt execution event; current plugin matches the documented Cursor manifest shape.

Remaining:
- Inspect installed local-plugin discovery and run bounded interactive file-write probes outside OneDrive.
- State measured cause before any implementation change. Apply only a repo-local fix if supported.
- Run fake regressions and the authorized real Grok completion check; clean up only this task's terminals.
- Update README/evidence, commit locally, write outbox result.md then summary.md.

Limits: no global configuration, trust/bypass flags, exit-code changes, ck-dispatch edits, or other live-terminal mutations.

A-1115-15 investigation outcome: partial; root cause established, real done still unverified.
Done:
- Real plugin-only Grok probe wrote a sessionStart event and replied, but no prompt/stop hook fired.
- Installed interactive call sites check only user/project hook arrays; plugin-only configuration fails the guard.
- Exact extracted guard reproduced with fake inputs; user/project entries admit the call.
- No-prompt real startup probe inherited HC_TERMINAL_ID but could not open /dev/tty. This separate transport bug is later work.
- Unchanged full fake suite passes in an isolated source copy; initial long-socket-path failure retained separately.
- Removed only this task's probe terminals; all preexisting live addresses remained live.
- Added an unapplied, tested JSON-command proposal for global hook activation. No production code or global configuration changed.
- README and evidence report explain the actual limits. Preexisting research/ and earlier evidence preserved.

Evidence: tests/artifacts/cursor-hook-investigation/report.md, gate-test.txt,
probe-events.jsonl, probe-hooks.json, tty-probe-event.json, fake-suite.txt,
proposed-user-hooks.json, proposal-command-test.txt, cleanup-check.txt.

Final consistency checks pass: evidence JSON, proposal/report agreement, fake-suite completion, unchanged production files, and final live-terminal preservation. See verification.txt in the evidence folder.
Implementation stopped at the protected-global-change boundary. Local commit and ordered outbox result.md then summary.md are the final recording steps.
Deferred: approved global activation, separate tty transport repair, then a1115-15-real-grok acceptance run.
Questions for chalach: approve the exact global hook merge documented in the report? No global edit was made.

## Active task: A-1115-17 Grok summary-file status wrapper

Done:
- Read required worker/playbook, hc guide, README/progress, parked hook investigation, wiki/rules/open questions, and ck-dispatch completion loop. No named guide missing.
- Baseline is local commit 0b18dd6; preexisting untracked research/ is preserved.
- Mechanism (measured prior evidence): interactive Grok supplies no status to hc; plugin-only hooks are skipped and real hooks cannot open their tty. That route is PARKED.

Remaining:
- Reproduce missing summary wrapper / obsolete plugin wiring with a fake regression.
- Add Cursor-only run-folder contract and a tty-owning wrapper; preserve other launch paths and exit mappings.
- Run fake suite, then only a1115-17-real-grok; inspect hc status, clean up only that terminal.
- Update README/evidence, commit locally, write result.md then summary.md in this run's authorized outbox.

Implementation/testing:
- Added a Cursor-only fresh run folder and result-then-summary contract, plus bin/ck-herdr-cursor as hc's root program. No production plugin wiring remains.
- Wrapper inherits interactive tty I/O, emits working/done/error, checks a nonempty stable summary with result present, and preserves the child exit/signal.
- Baseline regression failed in summary-wrapper-before.txt; full fake suite passes in summary-wrapper-suite.txt under safety-reviewed PTY/core access.
- Sandboxed PTY attempt could not open /dev/tty; retained in summary-wrapper-stubs.txt. It is not a pass.
- hc schema and installed app guide confirm root status consumers; official core/mobile docs explicitly support wrapper OSC and phone Inbox status. Phone UI remains UNVERIFIED.
Remaining: single authorized real Grok check, review, local commit, ordered outbox writes.

Acceptance completed:
- Final suite passes: tests/artifacts/summary-wrapper-suite-final.txt. Generic new fake evidence is versioned under summary-wrapper-fakes/; prior artifacts were restored.
- Single a1115-17-real-grok launch returned ck-run exit=0. hc get status=done, app=ck-summary-wrapper; hc wait independently returned done. Cursor was live until cleanup.
- The child required individual approval for its authorized result.md and summary.md writes outside cwd; approved only those displayed writes. No allowlist, global config, trust, or bypass change.
- Immediate app snapshot still showed working while hc's final root reports showed done; desktop done rendering and phone UI are UNVERIFIED. Acceptance requires hc status and passes.
- Killed/removed only this test terminal; cleanup snapshots confirm every preexisting live address remains live.
- No ck-dispatch, Claude/Codex path, parked plugin, research/, protected workspace, push, install, or send change.
Remaining: final diff/evidence consistency check, local commit, result.md then summary.md outbox finalization.
Questions for chalach: none.

Final checks complete:
- tests/artifacts/summary-wrapper-verification.txt confirms acceptance evidence, cleanup, unchanged parked hook work, unchanged outcome/space/list functions, and unchanged non-Cursor argv.
- No implementation or live checks remain. Local commit and ordered outbox writes are the final recording steps; the outbox records the commit hash.
- Verification: fake_or_tests plus the single successful real Grok/hc check. Desktop rendering of done and phone UI were not verified.
- Questions for chalach: none.
