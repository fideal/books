#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$REPO_DIR" || { echo "Error: could not change to repo directory $REPO_DIR"; exit 1; }

if [ -z "$(git status --porcelain)" ]; then
  echo "Nothing to push — no changes detected."
  exit 0
fi

CHANGED=$(git diff --name-only HEAD 2>/dev/null; git ls-files --others --exclude-standard)
COMMIT_MSG="add $(echo "$CHANGED" | head -1)"

git add -A
git commit -m "$COMMIT_MSG"
git push

echo "Done: $COMMIT_MSG"
