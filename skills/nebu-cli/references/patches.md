# Patches and fix pull requests

They take a finding's repository id and its `--scan` ([findings.md](findings.md)).

```
nebu findings patch generate <finding_id> --scan <scan_id>                    # starts it, returns
nebu findings patch generate <finding_id> --scan <scan_id> --wait -o fix.patch
nebu findings patch get <finding_id> --scan <scan_id> [--wait] [-o <file>]   # never starts one
nebu findings patch status <finding_id> --scan <scan_id>
nebu findings pr create <finding_id>... --scan <scan_id>                     # one pull request, a commit per finding
nebu findings pr status [<finding_id>] --scan <scan_id> [--wait]
```

- `generate` reuses a patch that exists or is being made; `--regenerate` starts a new one unless one is running.
  Patch waits default to 60 minutes, pull request waits to 20 (`--timeout 10m` sets another).
- `pr create` needs a ready patch for every finding; otherwise it prints the `patch generate` or `patch get --wait` command for each one missing.
- The CLI does not touch local Git and marks nothing fixed: a patch or an opened pull request is not a fix (the status rules in [SKILL.md](../SKILL.md)).
- A wait that times out (exit 7) or is interrupted (130) leaves the work running; stderr prints the command that picks it up again.
