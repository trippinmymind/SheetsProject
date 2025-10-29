#!/bin/bash

# -------------------------------------
# SheetsProject: Auto Push + Live Logger
# -------------------------------------

PROJECT_DIR="$HOME/SheetsProject"
LOG_FILE="$PROJECT_DIR/update.log"
HTML_FILE="$PROJECT_DIR/index.html"
FUNCTION_NAME="testFunction"
PORT=8000

cd "$PROJECT_DIR" || exit

# --- Function to push + run + log ---
run_and_log() {
  echo "📤 Pushing latest Apps Script code..."
  clasp push

  echo "▶️ Running function '$FUNCTION_NAME'..."
  clasp run "$FUNCTION_NAME"

  echo "🧠 Updating logs..."
  clasp logs > "$LOG_FILE"
}

# --- Start Python server ---
if command -v lsof &>/dev/null; then
  PID=$(sudo lsof -ti :$PORT)
  if [[ -n "$PID" ]]; then
    echo "⚠️ Port $PORT busy. Killing process $PID..."
    sudo kill -9 "$PID"
  fi
fi

echo "🚀 Starting local server on port $PORT..."
python3 -m http.server "$PORT" &
PY_PID=$!

# --- Watch for file changes ---
echo "👀 Watching for changes in Code.gs..."
while true; do
  inotifywait -q -e modify "$PROJECT_DIR/Code.gs"
  echo "💾 Detected change — syncing..."
  run_and_log
done &

# --- Initial run ---
run_and_log

echo "✅ Open browser at: http://localhost:$PORT"
echo "🟢 Press Ctrl+C to stop everything."

trap "echo '🛑 Stopping...'; kill $PY_PID; exit" INT
wait
