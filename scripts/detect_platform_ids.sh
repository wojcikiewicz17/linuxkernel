#!/usr/bin/env sh
set -eu

out_file="${1:-generated/detected.inc}"
out_dir=$(dirname "$out_file")
mkdir -p "$out_dir"

arch_raw=$(uname -m 2>/dev/null || echo unknown)
os_raw=$(uname -s 2>/dev/null || echo unknown)

arch_id=0
case "$arch_raw" in
  x86_64|amd64) arch_id=1 ;;
  i?86) arch_id=2 ;;
  aarch64|arm64) arch_id=3 ;;
  armv7*|armv6*|arm) arch_id=4 ;;
  riscv64) arch_id=5 ;;
  *) arch_id=0 ;;
esac

os_id=0
case "$os_raw" in
  Linux) os_id=1 ;;
  Darwin) os_id=2 ;;
  FreeBSD) os_id=3 ;;
  *) os_id=0 ;;
esac

hw_id=0
if [ -r /proc/device-tree/model ]; then
  if tr -d '\000' </proc/device-tree/model | grep -qi 'raspberry'; then
    hw_id=1
  elif tr -d '\000' </proc/device-tree/model | grep -qi 'jetson'; then
    hw_id=2
  else
    hw_id=3
  fi
elif [ -r /sys/class/dmi/id/product_name ]; then
  if grep -qi 'virtual' /sys/class/dmi/id/product_name; then
    hw_id=10
  else
    hw_id=11
  fi
fi

cat >"$out_file" <<INC
/* auto-generated: do not edit */
    .equ D0, ${arch_id}
    .equ D1, ${os_id}
    .equ D2, ${hw_id}
INC
