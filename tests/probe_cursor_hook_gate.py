#!/usr/bin/env python3
"""Opt-in installed-Cursor call-site probe; no model, settings, or network.

Run with the installed 2986.index.js bundle as the argument. This executes the
exact guard extracted from the installed code against fake configurations.
It documents an upstream limitation, not a passing end-to-end hook bridge.
"""
import json
from pathlib import Path
import re
import subprocess
import sys


bundle = Path(sys.argv[1])
source = bundle.read_text()
for step in ("beforeSubmitPrompt", "stop"):
    pattern = (
        r"e\.hookExecutor&&e\.hooksConfig&&\("
        rf"e\.hooksConfig\.userHooks\?\.hooks\.{step}\?\.length\|\|"
        rf"e\.hooksConfig\.projectHooks\?\.hooks\.{step}\?\.length\)"
    )
    matches = list(re.finditer(pattern, source))
    assert matches, f"Installed {step} guard changed; inspect before using this probe"
    expression = matches[0].group()
    script = """
const step = process.argv[1];
const guard = new Function('e', 'return Boolean(' + process.argv[2] + ')');
const command = {command: "printf '%s\\\\n' '{}'"};
const plugin = {config: {hooks: {[step]: [command]}}};
const base = {hookExecutor: {}, hooksConfig: {pluginHooks: [plugin]}};
const results = {};
results.plugin_only = guard(base);
for (const scope of ['userHooks', 'projectHooks']) {
  results[scope] = guard({hookExecutor: {}, hooksConfig: {
    ...base.hooksConfig, [scope]: {hooks: {[step]: [command]}}
  }});
}
if (results.plugin_only || !results.userHooks || !results.projectHooks) {
  throw new Error(JSON.stringify(results));
}
console.log(JSON.stringify({step, ...results}));
"""
    result = subprocess.run(
        ["node", "-e", script, step, expression],
        check=True, capture_output=True, text=True,
    )
    print(f"Source: {bundle}:1; character offset {matches[0].start()}")
    print(expression)
    print(result.stdout.strip())
    print("PASS reproduced: plugin-only rejected; user/project gate admitted")
