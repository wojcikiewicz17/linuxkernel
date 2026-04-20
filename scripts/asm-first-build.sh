#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ARCH_NAME="${ARCH:-x86_64}"
JOBS="${JOBS:-$(nproc)}"
DRY_RUN="${DRY_RUN:-0}"
OUT_DIR="${OUT_DIR:-out/asm-first}"
MODE="${MODE:-build}" # build|prepare
KEEP_FRAGMENT="${KEEP_FRAGMENT:-0}"

FRAGMENT_PATH="${OUT_DIR}/asm-first.fragment"
CONFIG_PATH="${OUT_DIR}/.config"
LOG_PATH="${OUT_DIR}/build.log"
ARTIFACT_MANIFEST="${OUT_DIR}/artifacts.txt"

case "$ARCH_NAME" in
  x86_64) DEFCONFIG="x86_64_defconfig" ;;
  arm64|aarch64) ARCH_NAME="arm64"; DEFCONFIG="defconfig" ;;
  riscv|riscv64) ARCH_NAME="riscv"; DEFCONFIG="defconfig" ;;
  *)
    echo "[asm-first] ARCH '$ARCH_NAME' não suportada por este helper" >&2
    exit 2
    ;;
esac

mkdir -p "$OUT_DIR"

cleanup() {
  if [[ "$KEEP_FRAGMENT" != "1" ]]; then
    rm -f "$FRAGMENT_PATH"
  fi
}
trap cleanup EXIT

run() {
  echo "+ $*" | tee -a "$LOG_PATH"
  if [[ "$DRY_RUN" != "1" ]]; then
    "$@" 2>&1 | tee -a "$LOG_PATH"
  fi
}

write_fragment() {
  cat > "$FRAGMENT_PATH" <<'CFG'
CONFIG_MODULES=n
CONFIG_BPF_JIT=n
CONFIG_FTRACE=n
CONFIG_UPROBES=n
CFG
}

write_manifest() {
  : > "$ARTIFACT_MANIFEST"
  if [[ -f "$LOG_PATH" ]]; then echo "$LOG_PATH" >> "$ARTIFACT_MANIFEST"; fi
  if [[ -f "$CONFIG_PATH" ]]; then echo "$CONFIG_PATH" >> "$ARTIFACT_MANIFEST"; fi
  if [[ -f "${OUT_DIR}/vmlinux" ]]; then echo "${OUT_DIR}/vmlinux" >> "$ARTIFACT_MANIFEST"; fi
  if [[ -f "${OUT_DIR}/System.map" ]]; then echo "${OUT_DIR}/System.map" >> "$ARTIFACT_MANIFEST"; fi
}

required_tools=(make)
if [[ "$DRY_RUN" != "1" ]]; then
  required_tools+=(flex bison)
fi

for t in "${required_tools[@]}"; do
  if ! command -v "$t" >/dev/null 2>&1; then
    echo "[asm-first] dependência ausente: $t" >&2
    exit 3
  fi
done

write_fragment

echo "[asm-first] ARCH=$ARCH_NAME DEFCONFIG=$DEFCONFIG JOBS=$JOBS DRY_RUN=$DRY_RUN OUT_DIR=$OUT_DIR MODE=$MODE" | tee "$LOG_PATH"

run make O="$OUT_DIR" ARCH="$ARCH_NAME" "$DEFCONFIG"
run ./scripts/kconfig/merge_config.sh -O "$OUT_DIR" -m "$CONFIG_PATH" "$FRAGMENT_PATH"
run make O="$OUT_DIR" ARCH="$ARCH_NAME" olddefconfig

if [[ "$MODE" == "build" ]]; then
  run make -j"$JOBS" O="$OUT_DIR" ARCH="$ARCH_NAME" vmlinux
elif [[ "$MODE" != "prepare" ]]; then
  echo "[asm-first] MODE inválido: $MODE (use build|prepare)" >&2
  exit 4
fi

write_manifest

echo "[asm-first] build concluída; manifesto: $ARTIFACT_MANIFEST" | tee -a "$LOG_PATH"
