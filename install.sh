#!/bin/sh
# Canonical installer synced to NebuSec/nebu-skill by the release workflow.
set -eu

REPO="NebuSec/nebu-skill"
VERSION=${NEBU_VERSION:-latest}
INSTALL_DIR=${NEBU_INSTALL_DIR:-"$HOME/.local/bin"}
VEGA_CONFLICT=${NEBU_VEGA_CONFLICT:-}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

entry_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

case "$VEGA_CONFLICT" in
  ""|backup|uninstall|keep) ;;
  *)
    printf 'error: NEBU_VEGA_CONFLICT must be backup, uninstall, or keep\n' >&2
    exit 2
    ;;
esac

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
vega_path="$INSTALL_DIR/vega"

backup_path="$INSTALL_DIR/vega.legacy"
backup_number=0
while entry_exists "$backup_path"; do
  backup_number=$((backup_number + 1))
  backup_path="$INSTALL_DIR/vega.legacy.$backup_number"
done

# DEPRECATED: everything below that manages the `vega` entry belongs to the
# temporary legacy-command compatibility layer.
old_npm_package=false
if command -v npm >/dev/null 2>&1 &&
   npm list -g --depth=0 @nebusec/vega >/dev/null 2>&1; then
  old_npm_package=true
fi

if entry_exists "$vega_path"; then
  printf 'An existing Vega command was found at: %s\n' "$vega_path" >&2
  printf 'Choose how the installer should handle it:\n' >&2
  printf '  1) Back up %s to %s, then create %s -> nebu (default)\n' \
    "$vega_path" "$backup_path" "$vega_path" >&2
  printf '  2) Uninstall the old CLI. Only these detected items will be removed:\n' >&2
  printf '     - %s (only if it is a file or symbolic link)\n' "$vega_path" >&2
  if [ "$old_npm_package" = true ]; then
    printf '     - global npm package @nebusec/vega\n' >&2
  else
    printf '     - global npm package @nebusec/vega (not detected; no npm removal)\n' >&2
  fi
  printf '     Configuration, credentials, workspaces, and shell files are never removed.\n' >&2
  printf '  3) Keep %s; no compatibility alias will be created there.\n' "$vega_path" >&2

  if [ -z "$VEGA_CONFLICT" ]; then
    if [ -t 2 ] && [ -r /dev/tty ]; then
      printf 'Selection [1]: ' >/dev/tty
      selection=
      IFS= read -r selection </dev/tty || selection=
      case "$selection" in
        ""|1) VEGA_CONFLICT=backup ;;
        2) VEGA_CONFLICT=uninstall ;;
        3) VEGA_CONFLICT=keep ;;
        *)
          printf 'error: selection must be 1, 2, or 3\n' >&2
          exit 2
          ;;
      esac
    else
      VEGA_CONFLICT=backup
      printf 'No interactive terminal detected; using the default backup option.\n' >&2
    fi
  fi
else
  VEGA_CONFLICT=alias
fi

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

alias_installed=false
case "$VEGA_CONFLICT" in
  alias)
    if ln -s nebu "$vega_path"; then
      alias_installed=true
    else
      warn "could not create compatibility alias $vega_path -> nebu"
    fi
    ;;
  backup)
    if mv "$vega_path" "$backup_path"; then
      printf 'Backed up the existing Vega command to %s\n' "$backup_path" >&2
      if ln -s nebu "$vega_path"; then
        alias_installed=true
      else
        warn "could not create compatibility alias $vega_path -> nebu"
      fi
    else
      warn "could not back up $vega_path; the existing Vega command was left in place"
    fi
    ;;
  uninstall)
    if [ "$old_npm_package" = true ]; then
      printf 'Uninstalling detected global npm package @nebusec/vega\n' >&2
      npm uninstall -g @nebusec/vega >/dev/null 2>&1 ||
        warn "could not uninstall global npm package @nebusec/vega"
    fi
    if entry_exists "$vega_path"; then
      if [ -f "$vega_path" ] || [ -L "$vega_path" ]; then
        rm -f "$vega_path" || warn "could not remove old Vega entry $vega_path"
      else
        warn "refusing to remove non-file entry $vega_path"
      fi
    fi
    if ! entry_exists "$vega_path"; then
      if ln -s nebu "$vega_path"; then
        alias_installed=true
      else
        warn "could not create compatibility alias $vega_path -> nebu"
      fi
    else
      warn "the old Vega entry still blocks compatibility alias $vega_path"
    fi
    ;;
  keep)
    warn "kept the existing Vega command at $vega_path; use $nebu_path for Nebu"
    ;;
esac

if [ "$alias_installed" = true ]; then
  resolved_vega=$(command -v vega 2>/dev/null || true)
  if [ -z "$resolved_vega" ]; then
    warn "$vega_path was installed, but vega is not currently on PATH"
  elif [ "$resolved_vega" != "$vega_path" ]; then
    warn "vega currently resolves to $resolved_vega before the new alias $vega_path"
  else
    printf 'Installed compatibility alias %s -> nebu\n' "$vega_path"
  fi
fi

printf 'Run `nebu --help` to get started.\n'
