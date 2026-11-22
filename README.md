<!-- Replaced with every release: an edit made here is overwritten. -->
# NebuSec Platform CLI — agent skill & binary distribution

NebuSec Platform CLI is a developer- and automation-friendly command-line tool that does most of the NebuSec Platform web app's work from the terminal, or through a coding agent.
It adds repositories, estimates and runs security scans at a price shown before anything is charged, lists and marks code and cloud findings, generates patches and fix pull requests, and sets up pull request triggers.

This repository distributes the **agent skill** and the **prebuilt binaries**.

## Install the skill

**Claude Code** (plugin):

```
/plugin marketplace add NebuSec/nebu-skill
/plugin install nebu-cli@nebusec
```

**Codex** (skill-installer):

```
$skill-installer install https://github.com/NebuSec/nebu-skill/tree/main/skills/nebu-cli
```

**Any agent** ([`npx skills`](https://github.com/vercel-labs/skills)):

```
npx skills add NebuSec/nebu-skill
```

## Install the binary

The skill instructs agents to bootstrap the binary automatically. To install it yourself:

```
curl -fsSL https://raw.githubusercontent.com/NebuSec/nebu-skill/main/install.sh | sh
```

Installs the latest release to `~/.local/bin`, after checking the download against the release's `SHA256SUMS`.
Options via environment: `NEBU_VERSION=vX.Y.Z` pins a release whose assets include `SHA256SUMS`, and `NEBU_INSTALL_DIR` changes the target directory.

Or via npm (requires Node.js ≥ 18):

```
npm install -g @nebusec/nebu
```

Release assets, if you prefer manual download (a release's `SHA256SUMS`, where its assets include one, is the SHA-256 digest of every archive):

| asset | platform |
|---|---|
| `nebu-linux-x64.tar.gz` | Linux x86_64 (static musl build) |
| `nebu-linux-arm64.tar.gz` | Linux aarch64 (static musl build) |
| `nebu-darwin-x64.tar.gz` | macOS Intel |
| `nebu-darwin-arm64.tar.gz` | macOS Apple Silicon |

## Update

```
nebu upgrade
```

replaces the installed binary with the latest release, verified against its `SHA256SUMS`; a global installation from npm, pnpm, yarn, bun or Volta is updated with that tool.
A release without `nebu upgrade` updates the way it was installed: rerun the installer, or `npm install -g @nebusec/nebu@latest`.
At a terminal, `nebu` mentions a newer release at most once a day; set `NEBU_NO_UPDATE_CHECK=1` to turn that off.
When the platform stops supporting an old release, its commands fail with `cli_upgrade_required` and the error says how to update.

## Getting started

```
nebu auth login                                           # or set NEBUSEC_PLATFORM_API_KEY, a key from the web app
nebu repos add --github example-org/acme-web --wait       # or --gitlab, --git-url; --path . uploads local code
nebu scans estimate --repo acme-web                       # free
nebu scans run --repo acme-web --max-cost <approved_usd>  # prints scan created: scan_…
nebu scans get scan_exampleScan0001 -s                    # its progress
nebu findings list --severity critical,high
```

`--max-cost` launches the scan only when its quoted price is at most that amount; the scan is charged exactly the quoted price.
`--max-cost` takes the amount the user approved; without it, `scans run` prints the price and then asks before charging at a terminal, or stops with exit 6 in a script or agent.
Every `scans run` that launches is a new scan: to see one, use `nebu scans get`, `nebu scans follow` or `nebu scans list`.
Every command's options are in its `--help`.
See [`skills/nebu-cli/SKILL.md`](skills/nebu-cli/SKILL.md) for the guide agents follow, task by task.
