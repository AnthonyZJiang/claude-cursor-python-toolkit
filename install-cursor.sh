#!/usr/bin/env bash
# Install claude-cursor-python-toolkit into a project's .cursor/ directory.
#
# Source: .cursor/{rules,agents,skills}/cpt/ in this repo.
# Existing cpt/ folders in the target are replaced.
#
# Usage:
#   ./install-cursor.sh [target-dir] [--copy]
#
# Examples:
#   ./install-cursor.sh                    # symlink into ./.cursor
#   ./install-cursor.sh /path/to/workspace
#   ./install-cursor.sh . --copy             # copy files (no symlink dependency)

set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="."
MODE="symlink"

for arg in "$@"; do
  case "$arg" in
    --copy) MODE="copy" ;;
    -h|--help)
      sed -n '2,13p' "$0"
      exit 0
      ;;
    *)
      if [[ "$arg" != --* ]]; then
        TARGET="$arg"
      fi
      ;;
  esac
done

TARGET="$(cd "$TARGET" && pwd)"
CURSOR_SRC="${TOOLKIT_DIR}/.cursor"
CURSOR_DEST="${TARGET}/.cursor"

install_cpt() {
  local category="$1"
  local src="${CURSOR_SRC}/${category}/cpt"
  local dest="${CURSOR_DEST}/${category}/cpt"

  [[ -d "$src" ]] || return 0

  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "  replacing ${dest}"
    rm -rf "$dest"
  fi

  mkdir -p "${CURSOR_DEST}/${category}"

  if [[ "$MODE" == "copy" ]]; then
    cp -a "$src" "$dest"
  else
    ln -sf "$src" "$dest"
  fi
}

echo "Installing claude-cursor-python-toolkit (Cursor)"
echo "  toolkit: ${TOOLKIT_DIR}"
echo "  target:  ${CURSOR_DEST}"
echo "  mode:    ${MODE}"

for category in rules agents skills; do
  install_cpt "$category"
done

echo "Done. Open ${TARGET} in Cursor to use the rules, skills, and agents."
