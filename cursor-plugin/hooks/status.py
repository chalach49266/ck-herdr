#!/usr/bin/env python3
"""Cursor JSON hook -> Herdr OSC on the controlling tty, never JSON stdout.

No prompt/transcript storage, no hc commands, and no follow-up prompts.
Sources: https://cursor.com/docs/hooks and https://herdr.dev/core/
"""
import json
import os
import sys


def main():
    action = sys.argv[1]
    response = {"continue": True} if action == "working" else {}
    try:
        event = json.load(sys.stdin)
    except (ValueError, OSError):
        event = {}
    # Do not turn missing, malformed, aborted, or subagent input into success.
    state = None
    if isinstance(event, dict) and not event.get("subagent_id"):
        if action == "working" and isinstance(event.get("prompt"), str):
            state = "working"
        elif action == "stop":
            state = {"completed": "done", "error": "error", "aborted": "blocked"}.get(event.get("status"))
    if state and os.environ.get("HC_TERMINAL_ID"):
        try:
            # Hook stdout belongs to Cursor's JSON parser. /dev/tty reaches the
            # hc PTY even when Cursor captures hook stdout and stderr.
            with open("/dev/tty", "wb", buffering=0) as tty:
                tty.write(f"\x1b]7501;state={state}:app=ck-cursor-hook\x1b\\".encode())
        except OSError as exc:
            print(f"ck-herdr hook: status unavailable: {exc}", file=sys.stderr)
    print(json.dumps(response))


if __name__ == "__main__":
    main()
