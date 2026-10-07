#!/bin/sh
# Canonical installer synced to NebuSec/nebu-skill by the release workflow.
set -eu

REPO="NebuSec/nebu-skill"
VERSION=${NEBU_VERSION:-latest}
INSTALL_DIR=${NEBU_INSTALL_DIR:-"$HOME/.local/bin"}

case "$(uname -s)" in
  Linux) platform=linux ;;
  Darwin) platform=darwin ;;
  *)
    printf 'error: unsupported operating system: %s\n' "$(uname -s)" >&2
    exit 1
    ;;
esac

case "$(uname -m)" in
  x86_64|amd64) arch=x64 ;;
  aarch64|arm64) arch=arm64 ;;
  *)
    printf 'error: unsupported architecture: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac

mkdir -p "$INSTALL_DIR"
INSTALL_DIR=$(CDPATH= cd -- "$INSTALL_DIR" && pwd)
nebu_path="$INSTALL_DIR/nebu"

asset="nebu-$platform-$arch.tar.gz"
if [ "$VERSION" = latest ]; then
  download_url="https://github.com/$REPO/releases/latest/download/$asset"
else
  case "$VERSION" in
    v*) tag=$VERSION ;;
    *) tag="v$VERSION" ;;
  esac
  download_url="https://github.com/$REPO/releases/download/$tag/$asset"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
curl -fsSL "$download_url" -o "$tmp/$asset"
tar -xzf "$tmp/$asset" -C "$tmp"
install -m 755 "$tmp/nebu" "$nebu_path"
printf 'Installed nebu to %s\n' "$nebu_path"

printf 'Run `nebu --help` to get started.\n'
