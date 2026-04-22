#!/usr/bin/env bash
set -euo pipefail

required_signed='^Signed-off-by:[[:space:]]+.+<.+>$'
required_assisted='^Assisted-by:[[:space:]]+.+'

msg_file=""
if [[ "${1:-}" == "--commit-msg-file" && -n "${2:-}" ]]; then
  msg_file="$2"
else
  msg_file="$(git rev-parse --git-path COMMIT_EDITMSG)"
fi

if ! git diff --cached --quiet --exit-code; then
  :
else
  # Nothing staged; allow.
  exit 0
fi

if [[ ! -f "$msg_file" ]]; then
  echo "ERROR: Commit message file not found: $msg_file" >&2
  echo "Use the template: Documentation/process/ai-attribution-commit-template.txt" >&2
  exit 1
fi

if ! grep -Eiq "$required_signed" "$msg_file"; then
  echo "ERROR: Missing required trailer: Signed-off-by:" >&2
  exit 1
fi

if ! grep -Eiq "$required_assisted" "$msg_file"; then
  echo "ERROR: Missing required trailer: Assisted-by:" >&2
  exit 1
fi

exit 0
