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
  # Resolve the tag once, so the archive and its checksums come from the same
  # release even if a new one is published between the two downloads.
  latest_url=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest")
  tag=${latest_url##*/}
  case "$tag" in
    v*) ;;
    *)
      printf 'error: could not resolve the latest release (got %s)\n' "$latest_url" >&2
      exit 1
      ;;
  esac
else
  case "$VERSION" in
    v*) tag=$VERSION ;;
    *) tag="v$VERSION" ;;
  esac
fi
release_url="https://github.com/$REPO/releases/download/$tag"

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{ print $1 }'
  else
    printf 'error: neither sha256sum nor shasum is available to verify the download\n' >&2
    exit 1
  fi
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
curl -fsSL "$release_url/$asset" -o "$tmp/$asset"
if ! curl -fsSL "$release_url/SHA256SUMS" -o "$tmp/SHA256SUMS"; then
  printf 'error: could not download SHA256SUMS of %s; this script installs only releases that publish it\n' "$tag" >&2
  exit 1
fi
expected=$(awk -v asset="$asset" '$2 == asset { print $1 }' "$tmp/SHA256SUMS")
actual=$(sha256 "$tmp/$asset")
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  printf 'error: %s does not match the checksum published with %s; nothing was installed\n' "$asset" "$tag" >&2
  exit 1
fi
tar -xzf "$tmp/$asset" -C "$tmp"
install -m 755 "$tmp/nebu" "$nebu_path"
printf 'Installed nebu to %s\n' "$nebu_path"

printf 'Run `nebu --help` to get started.\n'
