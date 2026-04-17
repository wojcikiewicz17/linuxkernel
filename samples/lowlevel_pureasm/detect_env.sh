#!/usr/bin/env sh
set -eu

out_file="${1:-generated/detected.inc}"

"$(dirname "$0")/../../scripts/detect_platform_ids.sh" "$out_file"
