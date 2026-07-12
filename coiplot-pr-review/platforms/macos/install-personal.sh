#!/usr/bin/env bash
set -euo pipefail

PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$PLATFORM_ROOT/../.." && pwd)"
SOURCE_SKILL="$PACKAGE_ROOT/skill/local-pr-review"
SKILLS_ROOT="${1:-$HOME/.copilot/skills}"
TARGET_SKILL="$SKILLS_ROOT/local-pr-review"
STAGING_SKILL="$SKILLS_ROOT/.local-pr-review.installing"

case "$SKILLS_ROOT" in
  ""|"/"|"$HOME") echo "Refusing unsafe skills directory: '$SKILLS_ROOT'" >&2; exit 1 ;;
esac

[[ -f "$SOURCE_SKILL/SKILL.md" ]] || { echo "Missing skill source: $SOURCE_SKILL/SKILL.md" >&2; exit 1; }
[[ -f "$SOURCE_SKILL/scripts/macos/collect-review-context.sh" ]] || { echo "Incomplete macOS skill scripts." >&2; exit 1; }
[[ -f "$SOURCE_SKILL/references/findings.schema.json" ]] || { echo "Missing findings schema." >&2; exit 1; }

mkdir -p "$SKILLS_ROOT"
rm -rf "$STAGING_SKILL"
cp -R "$SOURCE_SKILL" "$STAGING_SKILL"
chmod +x "$STAGING_SKILL/scripts/macos/collect-review-context.sh"
rm -rf "$TARGET_SKILL"
mv "$STAGING_SKILL" "$TARGET_SKILL"

echo "Installed Copilot skill: $TARGET_SKILL"
echo "Reload VS Code, select Agent mode, and run: /local-pr-review against origin/main"
