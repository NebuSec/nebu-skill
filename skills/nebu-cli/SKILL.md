---
name: nebu-cli
description: Query NebuSec Platform security-scan results and run security scans from
  the command line. Use when asked to scan code with NebuSec Platform, check scan
  progress or cost, list/inspect security findings for a project,
  repository, or scan, or list/inspect cloud security findings raised on
  connected cloud accounts. Provides projects/repos/scans/findings
  subcommands with agent-friendly text output and raw-JSON mode.
---

# NebuSec Platform CLI

`nebu` audits code for security vulnerabilities on the NebuSec Platform backend. Every
subcommand is non-interactive and designed for programmatic use:

- **stdout carries data only** — aligned columns for lists, markdown-style
  sections for details. Progress, warnings, and errors go to **stderr**.
- Add the global `--json` flag to any command to get the **raw backend
  JSON response** instead (compact, one object/array per line).
- IDs are self-describing: projects `pg_…`, repositories `proj_…`, scans
  `scan_…`; public findings use `VEGA-HIGH-00001`-style display IDs.
  Finding display IDs are unique only within a repository. Wherever a `<project>` or `<repo>`
  argument is accepted, a unique name works too.
- `nebu <noun> --help` lists each subcommand; singular aliases work
  (`nebu scan run` = `nebu scans run`).

## Install

The `nebu` binary must be on PATH. If `command -v nebu` fails, install the
latest release (Linux/macOS, x64/arm64):

```
curl -fsSL https://raw.githubusercontent.com/NebuSec/nebu-skill/main/install.sh | sh
```

Installs to `~/.local/bin` (override with `NEBUSEC_PLATFORM_INSTALL_DIR`; pin a version
with `NEBUSEC_PLATFORM_VERSION=vX.Y.Z`). With Node.js available,
`npm install -g @nebusec/nebu` works too. Binaries are also
downloadable directly from
<https://github.com/NebuSec/nebu-skill/releases>.

## Setup

Authentication, in precedence order: `NEBUSEC_PLATFORM_API_KEY` env var, else the
credential stored by `nebu auth login` (`--api-key vega_…` for headless,
`--headless` for browser login over SSH). Backend URL: `NEBUSEC_PLATFORM_API_URL` env
or `--api-url` (defaults to production).

Verify before doing anything else:

```
nebu auth status --json
# {"signed_in":true,"source":"stored OAuth token","user_id":"…","email":"…",…}
# exit 3 when not signed in → run `nebu auth login` or set NEBUSEC_PLATFORM_API_KEY
```

## Reading results (drill-down)

The hierarchy is project → repository → scan → finding.

```
nebu projects list
# PROJECT_ID           NAME         REPOS  OPEN  ACTIVE  LAST_SCAN
# pg_HfPTMSdF1RTuWtk9  nebu-collab  1      8     0       2026-06-29T23:36:00…

nebu projects get <project>          # detail incl. finding_counts by severity
nebu projects repos <project>        # repositories in the project
nebu projects scans <project>        # scans across the project

nebu repos list [--project <p>] [--git-remote github.com/org/repo]
nebu repos get <repo>                # state, snapshot_id, latest_scan_id, …
nebu repos scans <repo>

nebu scans list [--project <p> | --repo <r>] [--limit N]
nebu scans get <scan_id> [--live]    # detail; --live adds live cost/progress
nebu scans get <scan_id> -s          # ONE line — cheapest way to poll:
# scan_NtWy… running 49% "Auditing auth module" findings=8 cost=$260.73
```

## Findings

```
nebu findings list --scan <scan_id>            # or --project <p> / --repo <r>
# FINDING_ID      SCAN_ID    SEV     CONF  STATUS     FILE             TITLE
# VEGA-MEDI-00001 scan_NtWy… medium  high  candidate  app/…/inline.py  Inline publish does…
# (stderr) total: 8  next_cursor: eyJz…
```

Filters keep output (and your token use) small — prefer them over
fetching everything: `--severity critical,high`, `--status confirmed`,
`--file-prefix src/api/`, `--cwe CWE-89`, `-q "sql injection"`,
`--limit N`. Page with `--cursor <next_cursor>` (cursor is on stderr in
text mode, `next_cursor` in the JSON body), or pass `--all` to fetch every
page.

Visibility: findings still waiting in the dedup queue are hidden by
default (add `--include-dedup-pending` to see them, e.g. while a scan is
running); findings confirmed as duplicates are never listed.

```
nebu findings get --scan <scan_id> <finding_id>      # summary/root cause/evidence/fix
nebu findings get --scan <scan_id> <id1> <id2>       # several from one scan;
                                                      # --json emits NDJSON
nebu findings get --scan <scan_id> <finding_id> --full  # adds buggy code,
                                                         # attack path and long sections
nebu findings export --scan <scan_id> [--finding <id>]   # markdown report
```

Finding display IDs are repository-local, so `get` requires the scan that
contains them. Fetch `get` only for findings you will act on; use `export` for
a full human-readable report.

Triage is repository-level and requires an explicit repository scope:

```
nebu findings mark --repo <repo> pending|valid|invalid|fixed <finding...>
nebu findings triage --repo <repo> <status> <finding...>  # mark alias
nebu findings mark-fixed --repo <repo> <finding...>
nebu findings invalid --repo <repo> <finding...>
nebu findings ack --repo <repo> <finding...>              # valid, still open
```

`mark-fixed`, `invalid`, and `ack` are shortcuts for `fixed`, `invalid`, and `valid`.
Multiple IDs run in argument order and are not transactional: on failure,
earlier successful changes remain. With `--json`, multiple results are NDJSON.
These commands change server state; confirm the exact repository, finding IDs,
and desired status with the user before invoking them.

## Cloud findings

`nebu findings cloud` reads findings that cloud-sec raised on a customer's
connected cloud accounts. It is a **different resource** from code
findings: no scan/repo, camelCase JSON, lifecycle + disposition instead of
triage. Same conventions apply (columns, `--json`, `--limit`/`--all`, exit
codes) and the same credentials: a browser sign-in, or
`NEBUSEC_PLATFORM_API_KEY`. A scoped key needs `cloudsec:read` — both
dashboard presets ("Read only", "Run scans and triage findings") include
it; a key without it gets `403 insufficient_scope` (exit 1). The account
must also be enabled for Cloud Security (`403 cloudsec_forbidden`
otherwise).

```
nebu findings cloud list                                  # tenant with one cloud project
nebu findings cloud list --project <cloud_project_id>     # every inventory of that project
nebu findings cloud list --env <env_id>                   # one inventory (not with --project)
nebu findings cloud list --severity critical,high --status open --status in_progress
nebu findings cloud list --class exposure --flag new --source agent --sort newest --limit 20
nebu findings cloud list --run <run_id>                   # only findings confirmed by that run
nebu findings cloud list -q "public bucket" --resource "sec://…"   # search / asset filter
nebu findings cloud list --all --json | jq '.findings[] | {findingId, severity, title}'
nebu findings cloud get <finding_id> [<id2> …] [--env <env_id>] [--full]
```

Columns: `FINDING_ID SEVERITY RISK STATUS FLAG CLASS RESOURCE TITLE`.
`STATUS` is `open|in_progress|resolved|disposed (<disposition>)`; `FLAG`
is `new|changed|regressed` since the previous analysis; `RESOURCE` is the
first affected asset with `sec://<tenant>/` stripped and `+N` for more.
`--json` list output is the same `{findings, returned_count, total_count,
truncated}` envelope as code findings; rows are the raw backend objects.
`get` prints explanation, suggestion, remediation (markdown) and recheck
history; `--full` adds the attack-path and report JSON. Analysis internals
(rule id, last run id, verification plan, evidence refs, provenance) are
never shown in text mode — customers receive them redacted anyway, and
`--json` still returns whatever the backend sent.

Scope flags take **ids only** and are mutually exclusive: `--project` or
`--env`, never both (clap rejects the pair with exit 2). Omit both when the
tenant has a single cloud project; exit 2 with a hint means several match
and one must be named.

## Patches and pull requests

Patch generation returns immediately by default. Add `--wait` only when the
complete unified diff is needed now:

```
nebu findings patch generate <finding-id> --scan <scan-id>
nebu findings patch generate <finding-id> --scan <scan-id> --wait
nebu findings patch generate <finding-id> --scan <scan-id> --wait -o fix.patch
nebu findings patch get <finding-id> --scan <scan-id> [--wait] [-o <file>]
nebu findings patch status <finding-id> --scan <scan-id>
```

`generate` reuses an available patch or running task unless `--regenerate` is set, and reports the
reuse on stderr.
`get` never starts generation. `-o` on `generate` requires `--wait`; `-o -`
means stdout. `--json` and file output are mutually exclusive. Waits default to
60 minutes and accept explicit overrides such as `--timeout 30s` / `--timeout 10m`.
Before waiting, the CLI reminds the user that Ctrl+C stops only the local wait and prints the exact
scan-specific `patch get ... --wait` recovery command.

Create a backend GitHub PR (one finding uses the single endpoint; several use
one batch PR with one commit per finding):

```
nebu findings pr create <finding-id>... --scan <scan-id> [--timeout 10m]
nebu findings pr status [<finding-id>] --scan <scan-id> [--wait]
```

PR creation waits for the PR job by default, but it never generates patches. Every selected
finding must already have an available patch; otherwise the error prints the exact `patch generate`
or `patch get --wait` command needed for each blocked finding. A custom `--commit-message` is valid
only for one finding. The CLI does not touch local Git and does not mark findings fixed.

## Running a scan

```
nebu scans run --path . --yes --max-cost 20 --cost-cap 30 --wait
```

Steps performed: index + zip the directory (respects `.nebuignore`) →
upload as a new repository (`--project <p>` attaches it; `--repo <r>`
reuses an existing repository instead of uploading) → wait for snapshot →
cost estimate → server-issued fixed-price quote → consent gate → create scan.

**Cost consent (scans cost real money):**
- The estimate always prints first: `estimated cost: $1.86 (p10 $0.70 – p90 $4.91), …`
- The binding offer prints next: `quoted price: $1.92 USD`. Confirmation
  and automation limits use this server-issued price.
- `--max-cost <usd>`: abort with **exit 6** if the quoted price exceeds it;
  otherwise counts as consent. This is the safest flag for agents.
- `--yes`: unconditional consent. Without either, a non-TTY run exits 6.
- `--cost-cap <usd>`: independent server-side spend cap (also settable
  later via `nebu scans cost-cap <scan_id> <usd>`).
- `--estimate-only` (or `nebu scans estimate`): print the estimate and
  stop — free, no scan created.

**Watching progress:**
- default: prints `scan created: scan_…` and returns immediately; poll
  with `nebu scans get <scan_id> -s`.
- `--wait`: poll until done; state changes on stderr, final scan detail
  on stdout.
- `--follow`: stream backend events; with `--json` each event is one
  NDJSON line on stdout and the final scan detail is the last line.
- `nebu scans follow <scan_id>` attaches to an already-running scan.

## Scan control

```
nebu scans pause|resume|cancel|retry <scan_id>    # prints "scan_… <new state>"
nebu scans cost-cap <scan_id> <usd>
```

## Exit codes

| code | meaning | typical reaction |
|---|---|---|
| 0 | success | — |
| 1 | API/transport error (incl. 403 permission/billing denials — message says why) | read stderr |
| 2 | usage error / ambiguous name / ambiguous cloud scope | fix arguments, or use the id (`--project`/`--env`) |
| 3 | not authenticated (HTTP 401 / no credential) | `nebu auth login` or set `NEBUSEC_PLATFORM_API_KEY` |
| 4 | not found (bad id or unknown name) | check the id |
| 5 | scan ended failed/cancelled under `--wait`/`--follow` | inspect `failure_reason` in the printed detail |
| 6 | cost consent refused or `--max-cost` exceeded | raise `--max-cost` or pass `--yes` |
| 7 | patch/PR wait timed out; backend work continues | run the recovery command printed on stderr |
| 130 | local wait interrupted with Ctrl+C; backend work continues | run the recovery command printed on stderr |

Errors print as `error[<code>]: <message> (request_id=…)` on stderr —
include the `request_id` when reporting backend issues.
