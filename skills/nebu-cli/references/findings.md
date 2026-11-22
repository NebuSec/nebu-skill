# Read, pick and mark findings

```
nebu findings summary                                   # open findings by severity, code and cloud
nebu findings list --severity critical,high --status triage
# ID                                    SOURCE  SEVERITY  STATUS  PATCH  PINNED  TITLE                         LOCATION
# code:proj_exampleRepo0001:NEBU-00012  code    high      triage  no     false   SQL built from request input  src/example/handler.py:10
```

With no scope, `findings list` shows code and cloud findings together in the platform's order (pinned, then newest; `--sort severity` ranks by severity, with no scope only: a scoped list refuses it with exit 2).
Filter rather than read everything; `nebu findings list --help` has the filters, `--limit N` (default 50) and `--all`.

Two kinds of finding id:

- **List ids** (`code:proj_…:NEBU-00012`, `cloud:…`), from `findings list` with no scope, as printed: for marking and pinning.
- **Repository ids** (`NEBU-00012`, unique within one repository), from a scoped list `findings list --repo <repo>`, `--scan <scan_id>` or `--project <project>`, which prints `FINDING_ID` and `SCAN_ID`: for detail, export, severity, patches and fix pull requests, which also take that `--scan`.

```
nebu findings list --repo <repo> --severity high        # FINDING_ID, SCAN_ID, …
nebu findings get --scan <scan_id> NEBU-00012            # impact, description, root cause, evidence, fix
nebu findings get --scan <scan_id> NEBU-00012 --full     # adds buggy code and the attack path
nebu findings export --scan <scan_id> [--finding <finding_id>]   # markdown report
```

Cloud findings have their own reads: [cloud-findings.md](cloud-findings.md).

## Mark findings

```
nebu findings ack <id>...                               # valid, still open
nebu findings invalid <id>... [--reason <reason>] [--note "<the user's words>"]
nebu findings mark-fixed <id>...
nebu findings mark <pending|valid|invalid|fixed> <id>...
nebu findings pin <id>... [--unpin]                     # pinned for the whole team
cat ids.txt | nebu findings ack -                       # ids from standard input, one per line
nebu findings ack --repo <repo> NEBU-00012              # a repository's own ids
nebu findings severity --scan <scan_id> <critical|high|medium|low|info> <finding_id> [--note "<the user's words>"]
```

`--reason` takes list ids only, not `--repo` (`findings invalid --help` lists the reasons); `--note` takes either.
`findings list` shows `triage`, `acknowledged`, `invalid` or `fixed`; `mark` takes `pending` (back to `triage`), `valid` (what `ack` does; shows `acknowledged`), `invalid` or `fixed`; a scoped list's `--status` words are in `findings list --help`.
With list ids, each changed id prints `updated <id>` (stdout), each unchanged one `skipped <id>: <reason>` (stderr), and any skip makes the exit 1: report exactly what changed and what did not.
A request failing part way prints `unknown <id>` and `not sent <id>` lines; run the command again with those ids.
With `--repo`, each id prints `<id> <status>` (`NEBU-00012 valid`) as it changes; a failure stops there and earlier changes stay.

The status rules in [SKILL.md](../SKILL.md) say when to mark what.
To fix a finding: [patches.md](patches.md).
