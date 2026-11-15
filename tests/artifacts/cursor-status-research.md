# Cursor completion signal investigation

Sources read:
- Installed `agent --help`: cursor-help.txt. Interactive mode, auto-review, sandbox enabled, and local --plugin-dir exist; no direct hc/OSC completion option is advertised.
- Installed hc help/schema: wait-help.txt, events-help.txt, hc-schema.json. hc status is the program's OSC root record; the turn counter advances when working ends. No screen inference is used.
- https://cursor.com/docs/hooks : stop runs when the agent loop ends and receives a structured completed/aborted/error status. Command hooks exchange JSON over stdio. Project and user hook configuration live in .cursor/hooks.json.
- https://cursor.com/docs/reference/plugins : Cursor plugin manifests can contain hook configuration.

Decision: use the explicitly permitted honest unknown fallback. This task forbids modifying .cursor/ and user configuration. A scoped --plugin-dir stop-hook-to-OSC bridge has not been implemented or verified; we do not claim it is impossible. No hooks, global configuration, trust flags, or print-mode agent were added. Verifying that bridge is later work.

Current measured evidence: real-runs/a1115-12-real-grok.terminal-final.json has reported=false, status=null. The retained screen contains the requested reply, but that text is only inspection evidence. The launcher returns unknown immediately after launch and makes no claim that the work has finished. real-runs/grok-observation-wait.json is a separate bounded observation after launch, never used as the launcher result.
