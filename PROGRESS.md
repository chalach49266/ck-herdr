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
