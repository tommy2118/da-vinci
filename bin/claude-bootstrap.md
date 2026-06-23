# Claude session bootstrap (manual fallback)

Claude Code auto-loads the workshop's `CLAUDE.md` when launched in any subdirectory of the workshop. If you need to bootstrap manually — for instance, when using a different AI tool, or when Claude's context seems to have drifted — paste the following (the workshop root is the directory holding `CLAUDE.md`):

---

We're pairing in a craft workshop. Before doing anything, read these in order (the first four live at the workshop root):

1. `CLAUDE.md`
2. `PAIRING_PROTOCOL.md`
3. `ROCK_DRILL_PROTOCOL.md`
4. `.workshoprc` (global defaults; also `.workshoprc.local` if present)
5. The `.workshoprc` in my current working directory, if present (overrides)
6. The `ANATOMY.md` in my current working directory, if present

Then reply with:
- The active **mode** (`WORKSHOP_MODE`, possibly overridden per-slice).
- The signal vocabulary you'll respond to.
- A one-line **"where we are"**: latest ANATOMY.md verification checkboxes, last commit subject, current red/green status.

Then wait for a signal. Do not act until I issue one.
