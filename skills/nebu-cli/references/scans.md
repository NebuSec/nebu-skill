# Scan it

The money rule in [SKILL.md](../SKILL.md) applies to every command here.
An estimate is free: it launches and charges nothing (without `--repo` it first uploads: the upload rule in [SKILL.md](../SKILL.md)); it is for comparing depths or repositories, not the amount to approve.
The price to get approved is the `quoted price:` of `scans run`, which can be higher than `estimated price:`.

```
nebu scans estimate --repo <repo>
nebu scans run --repo <repo>                            # prints the quote, exit 6
nebu scans run --repo <repo> --max-cost <approved_usd>
```

```
depth: deep (the default; --depth chooses another)
commit: 0123456789abcdef0123456789abcdef01234567 (the repository's current snapshot; --ref <branch> scans a branch's latest commit)
estimated price: $10.00 (p10 $5.00 – p90 $20.00), 100 files
quoted price: $20.00
This is the final amount charged for this scan. It will not change after launch.
scan created: scan_exampleScan0001
```

- `depth:` is the depth priced: deep for a full or Project scan, quick for a pull request or diff; `--depth quick|standard|deep` chooses another, and depth changes the price.
  Without `--depth`, a full scan uses standard when the repository's plan does not include deep, and a Project scan lowers deep only for a trial account, each saying so here; otherwise the server's price or refusal answers.
- `commit:` is the code the repository last fetched; `--ref <branch-or-tag>` scans its latest commit, `--commit <sha>` one commit (full 40-character SHA).
- `quoted price:` is what is charged; some accounts see `scope: <n> files` instead of an estimated price.
- The scan audits the platform's default selection of files; keep that unless the user asks otherwise.
- A quote that cannot launch now prints why and, if there is one, a `Next:` line, exit 1: relay it.

## Follow it

`scans run` returns at `scan created: <id>`; the scan goes on without it.
Poll it with `nebu scans get <scan_id> -s`: it is done at `completed`, `failed` or `cancelled`; `paused` waits for the user (the detail's `pause_reason` says why).
`nebu scans list --repo <repo>` finds one you lost.
`--wait`, `--follow` and `nebu scans follow <scan_id>` return only when the scan ends, which a paused one does not: only for a shell without a time limit.

```
nebu scans get <scan_id> -s                            # one line, cheap to poll
# scan_exampleScan0001 running 49% "…" findings=8 price=$20.00
nebu scans list [--repo <repo> | --project <project>] [--limit N]
nebu scans get <scan_id>                               # detail: price, failure_reason, pause_reason, what a pull request scan reviewed
```

A finished scan's findings: [findings.md](findings.md).

## Other forms

Each takes `--depth`, `--max-cost` and the patch settings; `scans estimate` takes `--pr` and `--base`/`--head` too.

```
nebu scans run --project-scan <project> --max-cost <approved_usd>   # the project's ready repositories together; no estimate, so read the quote
nebu scans run --repo <repo> --pr 128 --max-cost <approved_usd>     # one pull request (nebu repos prs <repo> lists them)
nebu scans run --repo <repo> --base main --head feature/login --max-cost <approved_usd>   # a diff
```

Patches during the scan: `--generate-patch --patch-min-severity <all|critical|high|medium|low>` (always both) patches findings from that severity up, `--no-generate-patch` none; without either the repository's setting applies.

## Control a scan

```
nebu scans pause|resume|cancel|retry <scan_id>         # prints "scan_… <new state>"; retry is for a failed scan
nebu scans delete <scan_id>                            # a finished scan, its findings and artifacts
```

Cancel ends the scan for good.
A scan paused for an insufficient balance is the user's to fix in the web app; a retry that charges again is refused with its amount: relay both.
