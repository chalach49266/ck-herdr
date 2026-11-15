# Sources for A-1114-11

Videos before 2026-10-29 are the old terminal app. The desktop app and `hc` were announced 2026-10-29 (Flavio). Every transcript below is still that old app, including NetworkChuck. Publish dates taken from YouTube's own page are marked UNKNOWN. Aggregator dates are not YouTube's date field.

## Videos (transcripts in `research/transcripts/`)

1. https://www.youtube.com/watch?v=9_FzA-J9S2E — NetworkChuck, "you need to use Herdr RIGHT NOW!!". Date 2026-11-06 as reported by https://feedmedata.ai/videos/watch/9_FzA-J9S2E and https://jaluri.com/i/5454500/ (not read from YouTube). Old terminal app: sound, status filter, an agent driving other agents, worktrees, one machine talking to another.
2. https://www.youtube.com/watch?v=sarqGVfDFsI — Fahd Mirza, "Herdr: Run Multiple AI Coding Agents in Parallel from Your Terminal". Date 2026-07-30 from the path of https://openclawdatabase.com/news/videos/2026-07-30-herdr-terminal-multiplexer-for-agents/ (YouTube date not read). Old app: sidebar states, SSH from a phone, agents spawning panes.
3. https://www.youtube.com/watch?v=tA7COD7l6o8 — Hal Shin, "Herdr + Hermes: Agent Orchestration... on your Phone?!". Date 2026-06-30 as stated by https://zolotube.com/watch?v=tA7COD7l6o8 (YouTube date not read). Old app plus Hermes, Telegram, voice, and Notion. The phone path is a chat app, not the Herdr phone app.
4. https://www.youtube.com/watch?v=of8Fjozikok — Data with Marc, "Is This The Best TMUX for Running Multiple AI Agents?". Date UNKNOWN. Old app: a bell when an agent is blocked, and the agent skill opening panes.
5. https://www.youtube.com/watch?v=XoitaexiCi0 — Hal Shin, "Herdr: the Tmux for AI Agents". Date UNKNOWN. Old app: `herdr --remote` over SSH. His "Unix only" line is the old app. The new app's download page lists Windows.
6. https://www.youtube.com/watch?v=GYDh2tALWpA — Elie Steinbock, "Why everyone's talking about Herdr + pro tips". Date UNKNOWN. Old app: an agent opens many worktrees, then a remote server. He also says the agent got confused until the skill was installed.
7. https://www.youtube.com/watch?v=wx8EQ42qB1E — Panda Making Money, "Herdr: I Had No Idea You Could Run AI Agents Like This". Date UNKNOWN. Old app narration: toasts and sounds, remote attach, and screen guessing for Cursor and Grok. That guessing is not how `hc` works.

Authors and titles are YouTube oEmbed `author_name` and `title`, fetched 2026-11-14.

Practical AI's weekly video is named in the 2026-08-12 newsletter. The fetched page's "Watch the video" link had no YouTube id. No transcript.

Tobi Lütke's demo was not found as a YouTube video. Flavio quotes it: open a workspace, tell the agent to read `herdr --skill`, split more panes. That quote is the old terminal skill. Digg mirror: https://digg.com/ai/hmx7ez31 (no date read from Digg).

## Written

1. https://flaviocopes.com/herdr/ — Flavio Copes, updated 2026-11-10. Best current write-up. Desktop app on 2026-10-29, phone app on 2026-11-09, and a long section of old `herdr` commands. Says a coordinator on one machine prompting an agent on another is planned, not built, for that old CLI. Layout table: Board, Chat, Mission, Pasture. He does not use worktrees on his own site.
2. https://buttondown.com/practical-ai/archive/herdr-one-terminal-for-every-coding-agent/ — Practical AI (Damian), 2026-08-12. An agent creates worktrees and starts another agent. Phone path in the letter is Termius SSH plus dictation, into the old app. Different agent types can check each other's work.
3. https://www.developersdigest.tech/blog/herdr-deep-dive-agent-terminal-multiplexer — Developers Digest, published 2026-08-23, updated 2026-10-08. Old app: why guessing "done" from a quiet pane fails, and why wait-on-status is the real tool. Star and download counts in that post were not re-checked.
4. https://herdr.dev/blog/connecting-the-machines — Herdr, 2026-09-07. Old 0.9 client shows several machines. The agent CLI in that post still sees one server. Herdr Cloud is a waitlist, not a product you have.
5. https://herdr.dev/mobile/ — Herdr phone app page, fetched 2026-11-14 (page itself has no date; Flavio dates the release 2026-11-09). Inbox, SSH to `hc`, dictate, photos. Does not show agents started in the old terminal app.
6. https://herdr.dev/gallery/ — Gallery, fetched 2026-11-14. Official example names include Board, Call, Code, Mission, Pasture, Threads. Community mods are unreviewed JavaScript.
7. https://github.com/herdrdev/herdr-layout-examples/blob/main/README.md — Herdr layout examples. Board = cards in Needs you / Working / Done / Idle. Chat = spaces as channels. Threads = an inbox with pins. No page date read.

## Local notes (what this Mac actually has)

- `~/PhD_local/ck-herdr/README.md` — today's launcher. One CK space. Later already lists a board mod, templates per lane, and simbox as a machine.
- `~/PhD_local/agent_runs/herdr_ref/hc_skill.md` — `hc`: children, reviewer template, `hc run --on`, status only from OSC 7501, no guess from the screen.
- `~/PhD_local/agent_runs/herdr_ref/herdr_app_skill.md` — spaces, tabs, splits, mods.
- `~/.config/herdr-app/AGENTS.md` — sounds, settled tabs, pin, sub-agents, worktree mod. The app rewrites this file.
- `~/PhD_local/ck-dispatch/docs/v4.md` — asks, budgets, one iTerm window per ask, the board view.

## Not used as proof

https://www.bitdoze.com/herdr-app-layouts-mods/ quotes layout and mod counts. Those counts were not checked against the gallery, so they are not used.
