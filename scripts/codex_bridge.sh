#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${GRACE_AI_PROJECT_ROOT:-${TMPDIR:-/tmp}}"
CODEX_BIN="${GRACE_AI_CODEX_BIN:-/Applications/Codex.app/Contents/Resources/codex}"
CODEX_MODEL="${GRACE_AI_CODEX_MODEL:-gpt-5.4-mini}"
TRANSFORM_MODE="${GRACE_AI_TRANSFORM_MODE:-polish}"
INPUT_TEXT="$(cat)"
OUTPUT_FILE="$(mktemp "${TMPDIR:-/tmp}/grace-ai-codex.XXXXXX")"
LOG_FILE="$(mktemp "${TMPDIR:-/tmp}/grace-ai-codex-log.XXXXXX")"

cleanup() {
  rm -f "$OUTPUT_FILE" "$LOG_FILE"
}
trap cleanup EXIT

if [[ -z "${INPUT_TEXT//[[:space:]]/}" ]]; then
  echo ""
  exit 0
fi

if [[ ! -x "$CODEX_BIN" ]]; then
  echo "Не нашла Codex CLI по пути: $CODEX_BIN"
  exit 1
fi

if [[ "$TRANSFORM_MODE" == "translate" ]]; then
  TASK_PROMPT=$(cat <<EOF
Translate this Russian text into natural, correct English.
Return only the final English text.

${INPUT_TEXT}
EOF
)
else
  TASK_PROMPT=$(cat <<EOF
Fix spelling, punctuation, grammar, and phrasing in this English text so it sounds natural.
Keep the meaning. Return only the final English text.

${INPUT_TEXT}
EOF
)
fi

"$CODEX_BIN" exec \
  --skip-git-repo-check \
  --ephemeral \
  --ignore-rules \
  --ignore-user-config \
  --color never \
  --sandbox read-only \
  -m "$CODEX_MODEL" \
  -C "$PROJECT_ROOT" \
  -o "$OUTPUT_FILE" \
  "$TASK_PROMPT" >"$LOG_FILE" 2>&1 || {
    cat "$LOG_FILE" >&2
    exit 1
  }

cat "$OUTPUT_FILE"
