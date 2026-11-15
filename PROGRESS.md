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
