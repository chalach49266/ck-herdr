# Progress

Done:
- Read all required guides; no named guide was missing.
- Built bin/ck-herdr with interactive aliases, dry-run, labels, blocking hc wait, output completion lines, and filtered listing.
- Kept ck-dispatch and other runs read-only.
- Passed tests/test_ck_herdr.sh on this Mac with real hc and a fake OSC agent only.
- Verified real sol dry-run, normal fake-process exit, and removal of the test terminal.
- Stopped private test cores. No real model was launched.
- Wrote README with mappings, Mermaid diagram, limits, and later items.
- Retained test proof in tests/artifacts; scratch state is ignored by git.

Finalization:
- Local commit and outbox result/summary are recorded by the final git log and assigned outbox files.
- No further implementation work remains. No questions need chalach's decision.

Evidence:
- tests/artifacts/test-results.txt
- tests/artifacts/fake-run.out
- tests/artifacts/fake-exit.json
- tests/artifacts/cleanup.json
- tests/artifacts/sol-dry-run.txt

Limits:
- Verification is fake_or_tests. Real model startup and execution remain UNVERIFIED.
- Default sandbox startup failed; safety-reviewed execution of the isolated test succeeded.
- Ledger, budgets, andon, and reviews remain in ck-run; this launcher does not enforce them.
