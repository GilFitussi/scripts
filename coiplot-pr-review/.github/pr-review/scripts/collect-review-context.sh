#!/usr/bin/env bash
set -euo pipefail

BASE_REF=""
OUTPUT_DIRECTORY=".pr-review"
INCLUDE_WORKING_TREE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-ref) BASE_REF="${2:-}"; shift 2 ;;
    --output-directory) OUTPUT_DIRECTORY="${2:-}"; shift 2 ;;
    --include-working-tree) INCLUDE_WORKING_TREE=true; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$BASE_REF" ]]; then
  echo "Usage: $0 --base-ref <ref> [--output-directory <dir>] [--include-working-tree]" >&2
  exit 2
fi

git rev-parse --is-inside-work-tree >/dev/null
git rev-parse --verify "$BASE_REF" >/dev/null
MERGE_BASE="$(git merge-base HEAD "$BASE_REF")"
[[ -n "$MERGE_BASE" ]] || { echo "Could not compute merge base." >&2; exit 1; }

mkdir -p "$OUTPUT_DIRECTORY"
git diff --find-renames --binary "$MERGE_BASE...HEAD" > "$OUTPUT_DIRECTORY/pr.diff"
git diff --find-renames --name-status "$MERGE_BASE...HEAD" > "$OUTPUT_DIRECTORY/changed-files.txt"

if $INCLUDE_WORKING_TREE; then
  git diff --cached > "$OUTPUT_DIRECTORY/staged.diff"
  git diff > "$OUTPUT_DIRECTORY/unstaged.diff"
fi

export PR_REVIEW_BASE_REF="$BASE_REF"
export PR_REVIEW_MERGE_BASE="$MERGE_BASE"
export PR_REVIEW_OUTPUT="$OUTPUT_DIRECTORY"
export PR_REVIEW_INCLUDE_WORKING="$INCLUDE_WORKING_TREE"

python3 - <<'PY'
import json, os, subprocess
from datetime import datetime, timezone

def git(*args):
    return subprocess.check_output(["git", *args], text=True).strip()

files = []
raw = subprocess.check_output(
    ["git", "diff", "--numstat", f"{os.environ['PR_REVIEW_MERGE_BASE']}...HEAD"],
    text=True,
)
for line in raw.splitlines():
    parts = line.split("\t", 2)
    if len(parts) == 3:
        files.append({"additions": parts[0], "deletions": parts[1], "path": parts[2]})

def lines(*args):
    value = subprocess.check_output(["git", *args], text=True)
    return [line for line in value.splitlines() if line]

context = {
    "repositoryRoot": git("rev-parse", "--show-toplevel"),
    "baseRef": os.environ["PR_REVIEW_BASE_REF"],
    "mergeBase": os.environ["PR_REVIEW_MERGE_BASE"],
    "head": git("rev-parse", "HEAD"),
    "branch": git("branch", "--show-current"),
    "generatedAt": datetime.now(timezone.utc).astimezone().isoformat(),
    "files": files,
    "workingTree": {
        "included": os.environ["PR_REVIEW_INCLUDE_WORKING"] == "true",
        "staged": lines("diff", "--cached", "--name-only"),
        "unstaged": lines("diff", "--name-only"),
        "untracked": lines("ls-files", "--others", "--exclude-standard"),
    },
}
path = os.path.join(os.environ["PR_REVIEW_OUTPUT"], "context.json")
with open(path, "w", encoding="utf-8") as handle:
    json.dump(context, handle, indent=2, ensure_ascii=False)
PY

echo "Review context written to $OUTPUT_DIRECTORY"
echo "Range: $MERGE_BASE...HEAD ($BASE_REF)"
