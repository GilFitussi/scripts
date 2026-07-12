#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_DIRECTORY="${1:-$HOME/.copilot/pr-review}"
SOURCE_TOOLS="$PACKAGE_ROOT/.github/pr-review"

case "$TOOL_DIRECTORY" in
  ""|"/"|"$HOME")
    echo "Refusing unsafe tool directory: '$TOOL_DIRECTORY'" >&2
    exit 1
    ;;
esac

if [[ ! -f "$SOURCE_TOOLS/scripts/collect-review-context.sh" ]]; then
  echo "Could not find the bundled macOS review tools under: $SOURCE_TOOLS" >&2
  exit 1
fi

mkdir -p "$TOOL_DIRECTORY"
rm -rf "$TOOL_DIRECTORY/scripts" "$TOOL_DIRECTORY/schema"
cp -R "$SOURCE_TOOLS/scripts" "$TOOL_DIRECTORY/scripts"
cp -R "$SOURCE_TOOLS/schema" "$TOOL_DIRECTORY/schema"
chmod +x "$TOOL_DIRECTORY/scripts/collect-review-context.sh"

echo "Personal PR review tools installed at: $TOOL_DIRECTORY"
echo
echo "Add these entries to VS Code User settings.json:"
cat <<EOF
"chat.instructionsFilesLocations": {
  "$PACKAGE_ROOT/.github/instructions": true
},
"chat.promptFilesLocations": {
  "$PACKAGE_ROOT/.github/prompts": true
}
EOF
echo
echo "Reload VS Code, open any Git repository, and run /full-local-pr-review."
