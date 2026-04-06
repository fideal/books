#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
INDEX="$REPO_DIR/index.html"
BOOKPUSH="$REPO_DIR/bookpush.sh"

# ── Usage check ───────────────────────────────────────────────────
if [ -z "$1" ]; then
  echo "Usage: bookadd <filename.html> [\"Optional Title\"] [\"Optional Source\"]"
  echo "  e.g. bookadd NYT_Floating_analysis.html"
  echo "  e.g. bookadd NYT_Floating_analysis.html \"Floating\" \"The New Yorker\""
  exit 1
fi

FILENAME="$(basename "$1")"
FILEPATH="$REPO_DIR/$FILENAME"

# ── File existence check ───────────────────────────────────────────
if [ ! -f "$FILEPATH" ]; then
  echo "Error: '$FILENAME' not found in $REPO_DIR"
  exit 1
fi

# ── Check for duplicate entry ──────────────────────────────────────
if grep -q "href=\"$FILENAME\"" "$INDEX"; then
  echo "Warning: '$FILENAME' is already listed in index.html — skipping index update."
  "$BOOKPUSH"
  exit 0
fi

# ── Extract title: use arg if given, else parse <title> from file ──
if [ -n "$2" ]; then
  TITLE="$2"
else
  TITLE=$(grep -i "<title>" "$FILEPATH" | head -1 | sed 's/.*<title>\(.*\)<\/title>.*/\1/' | sed 's/^ *//;s/ *$//')
  # Strip common suffixes like " - Analysis", " | Reading Notes" etc.
  TITLE=$(echo "$TITLE" | sed 's/ *[|—–-].*$//')
  # Fallback to filename if title is empty
  if [ -z "$TITLE" ]; then
    TITLE=$(echo "$FILENAME" | sed 's/_analysis\.html$//' | sed 's/_/ /g' | sed 's/^[A-Z]*[_ ]*//')
  fi
fi

# ── Extract source: use arg if given, else default ─────────────────
if [ -n "$3" ]; then
  SOURCE="$3"
else
  SOURCE="The New Yorker"
fi

# ── Build the new <li> block ───────────────────────────────────────
NEW_ENTRY="      <li>\n        <a href=\"$FILENAME\">\n          <span class=\"book-title\">$TITLE<\/span>\n          <span class=\"book-meta\">$SOURCE<\/span>\n          <span class=\"arrow\">\u2192<\/span>\n        <\/a>\n      <\/li>"

# ── Insert after the ADD NEW ENTRIES comment line ─────────────────
sed -i '' "s/      <!-- ADD NEW ENTRIES AT THE TOP OF THIS LIST -->/      <!-- ADD NEW ENTRIES AT THE TOP OF THIS LIST -->\n\n$NEW_ENTRY/" "$INDEX"

echo "Added to index.html: \"$TITLE\" ($SOURCE) → $FILENAME"

# ── Push everything ────────────────────────────────────────────────
"$BOOKPUSH"
