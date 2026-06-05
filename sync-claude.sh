#!/usr/bin/env bash
# Regenerate .claude/ from .cursor/ (Cursor is the source of truth).
#
# - agents/cpt and skills/cpt: copied as-is (tool-neutral wording)
# - rules/cpt: .mdc converted to .md (globs -> paths, alwaysApply dropped)
#
# Usage:
#   ./sync-claude.sh

set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
CURSOR_DIR="${TOOLKIT_DIR}/.cursor"
CLAUDE_DIR="${TOOLKIT_DIR}/.claude"

convert_rule() {
  local src="$1"
  local dest="$2"
  awk '
    BEGIN { state = 0; globs = "" }
    { sub(/\r$/, "") }
    state == 0 && $0 == "---" { print; state = 1; next }
    state == 1 && $0 == "---" {
      if (globs != "") {
        print "paths:"
        printf "  - \"%s\"\n", globs
      }
      print "---"
      state = 2
      next
    }
    state == 1 && $0 ~ /^globs:[[:space:]]*/ {
      globs = $0
      sub(/^globs:[[:space:]]*/, "", globs)
      next
    }
    state == 1 && $0 ~ /^alwaysApply:/ { next }
    { print }
  ' "$src" > "$dest"
}

sync_category() {
  local category="$1"
  local src="${CURSOR_DIR}/${category}/cpt"
  local dest="${CLAUDE_DIR}/${category}/cpt"

  [[ -d "$src" ]] || return 0

  rm -rf "$dest"
  mkdir -p "${CLAUDE_DIR}/${category}"

  if [[ "$category" == "rules" ]]; then
    mkdir -p "$dest"
    while IFS= read -r -d '' mdc; do
      rel="${mdc#"${src}/"}"
      out="${dest}/${rel%.mdc}.md"
      mkdir -p "$(dirname "$out")"
      convert_rule "$mdc" "$out"
    done < <(find "$src" -type f -name '*.mdc' -print0)
    return 0
  fi

  cp -a "$src" "$dest"
}

echo "Syncing .claude/ from .cursor/"
echo "  source: ${CURSOR_DIR}"
echo "  target: ${CLAUDE_DIR}"

for category in rules agents skills; do
  sync_category "$category"
done

echo "Done."
