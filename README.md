<!-- Published as the NebuSec/nebu-skill README by the nebu-cli release workflow; edit it in nebu-cli (distribution/README.md). -->
# NebuSec Platform CLI — agent skill & binary distribution

NebuSec Platform CLI is a developer- and automation-friendly command-line tool for running NebuSec Platform security scans, tracking scan progress and cost, and inspecting projects, repositories, scans, and findings from the terminal.

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

Installs the latest release to `~/.local/bin`, after checking the download against the release's `SHA256SUMS`. Options via environment: `NEBU_VERSION=vX.Y.Z` pins a release whose assets include `SHA256SUMS`, `NEBU_INSTALL_DIR` changes the target directory, and `NEBU_VEGA_CONFLICT=backup|uninstall|keep` decides what happens to an existing `vega` command without asking.

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

replaces the installed binary with the latest release, verified against its `SHA256SUMS`; a global installation from npm, pnpm, yarn, bun or Volta is updated with that tool. A release without `nebu upgrade` updates the way it was installed: rerun the installer, or `npm install -g @nebusec/nebu@latest`. At a terminal, `nebu` mentions a newer release at most once a day; set `NEBU_NO_UPDATE_CHECK=1` to turn that off. When the platform stops supporting an old release, its commands fail with `cli_upgrade_required` and the error says how to update.

## Getting started

```
nebu auth login          # or export NEBUSEC_PLATFORM_API_KEY=vega_…
nebu scans run --path . --max-cost 20
```

See [`skills/nebu-cli/SKILL.md`](skills/nebu-cli/SKILL.md) for the full command reference.
