#!/bin/bash
# -------------------------------------------------
# SheetsProject Auto Update Script
# -------------------------------------------------

LOGFILE="update.log"
README="README.md"

# 1️⃣ Git commit & push
git add .
git commit -m "Auto-update $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null
git push
echo "$(date '+%Y-%m-%d %H:%M:%S'): Git push completed" >> "$LOGFILE"

# 2️⃣ Push to Apps Script
clasp push
echo "$(date '+%Y-%m-%d %H:%M:%S'): Apps Script updated" >> "$LOGFILE"

# 3️⃣ Update README with last 10 log lines
echo "# SheetsProject Updates" > "$README"
echo "## Recent Activity" >> "$README"
tail -n 10 "$LOGFILE" >> "$README"
git add "$README"
git commit -m "Update README with recent activity" 2>/dev/null
git push

echo "✅ Update complete! Dashboard will reflect changes."
