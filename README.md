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

Installs the latest release to `~/.local/bin`. Options via environment:`NEBU_VERSION=vX.Y.Z` pins a release, `NEBU_INSTALL_DIR` changes the target directory.

Or via npm (requires Node.js ≥ 18):

```
npm install -g @nebusec/nebu
```

Release assets, if you prefer manual download:

| asset | platform |
|---|---|
| `nebu-linux-x64.tar.gz` | Linux x86_64 (static musl build) |
| `nebu-linux-arm64.tar.gz` | Linux aarch64 (static musl build) |
| `nebu-darwin-x64.tar.gz` | macOS Intel |
| `nebu-darwin-arm64.tar.gz` | macOS Apple Silicon |

## Getting started

```
nebu auth login          # or export NEBU_API_KEY=…
nebu scans run --path . --max-cost 20
```

See [`skills/nebu-cli/SKILL.md`](skills/nebu-cli/SKILL.md) for the full command reference.
