#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

files=(
  Documentation/lowlevel/platform_ids.rst
  Documentation/lowlevel/ROADMAP.md
  Documentation/lowlevel/AI_CONTEXT.yaml
)

for file in "${files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "[lowlevel-docs] missing file: $file" >&2
    exit 1
  fi

done

if rg -n "\t" "${files[@]}"; then
  echo "[lowlevel-docs] tabs are not allowed in low-level docs" >&2
  exit 1
fi

if rg -n " +$" "${files[@]}"; then
  echo "[lowlevel-docs] trailing spaces are not allowed in low-level docs" >&2
  exit 1
fi

rg -n "PLATFORM_ID_SCHEMA" Documentation/lowlevel/platform_ids.rst >/dev/null
rg -n "PLATFORM_ID_SCHEMA" Documentation/lowlevel/AI_CONTEXT.yaml >/dev/null

echo "[lowlevel-docs] validation passed"
