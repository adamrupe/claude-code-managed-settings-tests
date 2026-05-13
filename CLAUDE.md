# CLAUDE.md

The intent of this repo is to test claude code managed-settings configurations within a Docker container.

## Running the tests

```bash
./run-tests.sh
```

This builds the Docker image, then runs `test.sh` inside the container. Requires `CBORG_API_KEY` to be set in the environment — the script passes it as `ANTHROPIC_AUTH_TOKEN` and sets `ANTHROPIC_BASE_URL` to `https://api.cborg.lbl.gov`.

## Architecture

The test harness verifies that Claude Code's **managed-settings** feature (admin-controlled policy) works correctly and cannot be overridden by local user settings.

**Key files:**

- `Dockerfile` — builds a `node:20-slim` image, installs the `@anthropic-ai/claude-code` CLI, writes a settings file to `/etc/claude-code/managed-settings.json` (the Linux path Claude Code reads for managed settings), and runs as a non-root user (`testuser`) so `--dangerously-skip-permissions` isn't blocked by the root guard before the managed-settings check fires.
- `first-settings.json` / `second-settings.json` — two alternative managed-settings payloads. The Dockerfile currently copies `first-settings.json`. Swap which file is used by editing the `COPY` line in the Dockerfile.
- `test.sh` — five bash tests that run `claude` inside the container and assert expected behavior (see below).
- `greetings.md` / `secrets.md` — fixture files used by the deny-list tests.

**What the tests verify:**

| Test | Assertion |
|------|-----------|
| 1 | `--dangerously-skip-permissions` is blocked when `disableBypassPermissionsMode: "disable"` is set in managed settings |
| 2 | A local `~/.claude/settings.json` that tries to null out `disableBypassPermissionsMode` cannot override the managed setting |
| 3 | Without the flag, normal permission prompts still apply |
| 4 | `greetings.md` is readable when not in the managed deny list |
| 5 | `secrets.md` is blocked when listed in the managed `deny` array |

**Settings file difference:** `second-settings.json` denies only `secrets.md`; `first-settings.json` also attempts to deny `greetings.md` (note: the deny rule for `greetings.md` in `first-settings.json` is missing its closing parenthesis, so it may not match as expected).
