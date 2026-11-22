---
name: nebu-cli
description: Use the NebuSec Platform from the command line in place of its web app.
  Use when asked to add a repository to NebuSec Platform, estimate or run a security
  scan (full, project, pull request or diff), follow a scan, list, pick and mark code
  or cloud findings, generate patches and fix pull requests, or set up pull request
  triggers. Agent-friendly text output and a JSON mode.
---

# NebuSec Platform CLI

`nebu` does most of the NebuSec Platform web app's work on the command line.
This file holds the rules for every task; each task's commands are in the file the table below names, read when the task comes up.
A command's other options are in its `--help` (`nebu scans run --help`): read that rather than guess a flag.

## Before anything

- Run `nebu --version`: if it prints 1.0.15 or older, run `nebu upgrade` (or install it, [setup.md](references/setup.md)) first.
  This guide's commands arrive with the release after 1.0.15; an older `nebu` takes some of them with another meaning (another default depth, no `depth:` line) or asks for other arguments.
  Later, a command or flag refused as unrecognized or unexpected (exit 2) is the same sign.
- Run `nebu auth status --json`; when `nebu` is missing or not signed in, follow [setup.md](references/setup.md).
- Data goes to stdout; progress, prices and errors to stderr.
  The global `--json` gives JSON instead (`findings export` always prints Markdown).
- Ids: projects `pg_…`, repositories `proj_…`, scans `scan_…`; a unique name works for a `<project>` or `<repo>`.
- `nebu chat` is a full-screen program for people; never start it from an agent or a pipeline.
- Read only what the task needs: find one repository with `nebu repos list --git-remote <remote>` (its clone URL or host and path) or `nebu projects repos <project>` rather than listing every repository, filter finding lists (`--severity`, `--limit`), and poll a scan with `scans get -s`.
  Take the text output unless you must parse a field; `--json` prints far more.

## Tasks

| Task | Read |
|---|---|
| Install, sign in, permission levels, API keys | [setup.md](references/setup.md) |
| Add a repository (GitHub, GitLab, Git URL, local upload) | [repositories.md](references/repositories.md) |
| Estimate, run, follow and control a scan (full, project, pull request, diff) | [scans.md](references/scans.md) |
| Read, pick and mark code findings | [findings.md](references/findings.md) |
| Generate patches and open fix pull requests | [patches.md](references/patches.md) |
| Pull request triggers | [triggers.md](references/triggers.md) |
| Cloud findings | [cloud-findings.md](references/cloud-findings.md) |

## Rules for every task

- **Money.** A scan you launch is charged exactly the fixed price it was quoted, never more.
  A request to scan is not approval of its price: launch with `--max-cost <approved_usd>`, the amount the user approved, not `--yes`, which accepts any new quote.
  Without `--max-cost`, `scans run` outside a terminal prints the quote and stops (exit 6, nothing launched): tell the user the depth and price.
  The launch quotes again and stops (exit 6) above `--max-cost`; a budget the user gave first ("up to 5 USD") is an approval: a quote within it launches.
  Only a quote not in USD, which `--max-cost` refuses (exit 6), takes `--yes`, once the user approved it.
- **Never run `scans run` again to look at a scan**: each one is a new scan and a new charge; follow it as [scans.md](references/scans.md) says.
- **Uploads.** `repos add --path`, and `scans estimate` or `scans run` without `--repo`, upload the directory as a new repository each time.
  Upload only when the user asked to scan or add local code, after telling them; for a repository already on the platform, always pass `--repo`.
- **Triggers** start paid scans with no price shown first: create or enable one only when the user asked for a trigger, after telling them that and what it will run, its depth and which pull requests ([triggers.md](references/triggers.md)).
- **`Next:` lines** are the CLI's suggestion for the task at hand: relay them.
  Act on one only when it is a read, or a write or paid work the user asked for or approved (a pull request, a patch, a scan, a retry, a deletion, a status change).
- **Finding status** follows what happened:
  - When the user says a finding is wrong, a false positive or not needed, mark it invalid at once with the user's reason as `--note`; your own suspicion is not enough.
  - Mark it fixed only after a fix (local, a generated patch, or a merged fix pull request) was verified and the user accepted it; a patch or an opened pull request is not a fix.
  - When the user asks for a change without giving a reason, make it without `--note` and `--reason`, or ask them once for one (also when a `Next:` line asks for a reason); never write a note or pick a reason the user did not give, even where a command recommends one.
  - Make any other status or severity change only when the user asked for it or confirmed it; a request that names the change is the confirmation.
- **Secrets.** Never ask for, accept, print, store or pass on a command line or in a file an API key, a password, a token or a cloud access key: when a task needs a key, tell the user to set it in the environment where `nebu` runs ([setup.md](references/setup.md)), and if one is pasted into the conversation, do not use it and tell the user to revoke it in the web app.
- **Deleting, cancelling, pausing, retrying** only when the user asks; a deletion needs `--yes` outside a terminal.
- **Exit 8**: the user must first finish a step in the web app; give them the `Next:` line, which names the page, and stop.

## When something refuses

Errors print on stderr as `error[<code>]: <message> (request_id=…)` or `error: <message>`, often followed by a `Next:` line.
Quote the error's `request_id`, if it shows one, when reporting a problem.

| exit | meaning | what to do |
|---|---|---|
| 0 | success | |
| 1 | refused or failed (permission level, billing, a quote that cannot launch, a skipped finding, network) | read the message and `Next:`; a level or billing refusal is the user's |
| 2 | wrong usage, an ambiguous name, or a duplicate | fix the arguments (`--help`), use the id, or use the existing object named |
| 3 | not signed in, or the sign-in ended | sign in again ([setup.md](references/setup.md)) |
| 4 | not found | check the id or name |
| 5 | a waited scan, `repos add --wait`'s fetch, or a `--ref`/`--commit`/`--pr`/diff snapshot failed or was cancelled | read the detail's reason |
| 6 | price not approved: no `--yes` or `--max-cost`, or a quote above `--max-cost` or not in USD with it | show the user the quoted price and ask |
| 7 | a wait timed out; the work goes on | run the command stderr prints, if any, or look with `repos get` or `scans get` |
| 8 | a step the user must take in the web app | give the user the `Next:` page and stop |
| 130 | a local wait was interrupted; the work goes on | as for 7 |

`error[cli_upgrade_required]` means this `nebu` is too old for the platform: run `nebu upgrade` (or the command the message names), then retry.
`error[session_ended]` (exit 3) says why the sign-in ended; the user signs in again.
