#!/bin/sh
# Installs the nebu CLI from GitHub Releases.
#
#   curl -fsSL https://raw.githubusercontent.com/NebuSec/nebu-skill/main/install.sh | sh
#
# Environment:
#   NEBU_VERSION      release tag to install (default: latest)
#   NEBU_INSTALL_DIR  target directory (default: ~/.local/bin)
set -eu

REPO="NebuSec/nebu-skill"
INSTALL_DIR="${NEBU_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${NEBU_VERSION:-latest}"

os=$(uname -s)
arch=$(uname -m)
case "$os" in
  Linux) os=linux ;;
  Darwin) os=darwin ;;
  *) echo "error: unsupported OS: $os (see https://github.com/$REPO/releases)" >&2; exit 1 ;;
esac
case "$arch" in
  x86_64 | amd64) arch=x64 ;;
  aarch64 | arm64) arch=arm64 ;;
  *) echo "error: unsupported architecture: $arch" >&2; exit 1 ;;
esac

asset="nebu-$os-$arch.tar.gz"
if [ "$VERSION" = "latest" ]; then
  url="https://github.com/$REPO/releases/latest/download/$asset"
else
  url="https://github.com/$REPO/releases/download/$VERSION/$asset"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "downloading $url" >&2
curl -fsSL "$url" -o "$tmp/$asset"
tar -xzf "$tmp/$asset" -C "$tmp"

mkdir -p "$INSTALL_DIR"
install -m 755 "$tmp/nebu" "$INSTALL_DIR/nebu"
echo "installed $("$INSTALL_DIR/nebu" --version) to $INSTALL_DIR/nebu" >&2

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "warning: $INSTALL_DIR is not on PATH — add it to your shell profile" >&2 ;;
esac
