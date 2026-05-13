# managed-settings tests

A set of container-based tests that validates Claude Code's **managed settings** feature that administrator-deployed configuration rules are enforced and cannot be bypassed by user-level settings or CLI flags. In particular, tests that the `managed-settings` can be stored elsewhere and symlinked to `/etc` where Claude Code requires them to be. 

Requires a [CBorg](https://cborg.lbl.gov) API key stored as `$CBORG_API_KEY`.

## Usage

```sh
./run-tests.sh
```

## Tests

| Test | What it validates |
|------|-------------------|
| 1 | `--dangerously-skip-permissions` flag is blocked by managed settings |
| 2 | Local settings cannot override managed settings (even `null` values) |
| 3 | Normal mode still prompts for permissions (bypass not active) |
| 4 | Files not in the deny list are readable (`greetings.md`) |
| 5 | Files in the deny list are blocked (`secrets.md`) |
| 6 | Dynamic deny rule updates — modifying the managed settings file at runtime blocks previously-allowed files |
