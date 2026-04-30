#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

mkdir -p reports
OUT="reports/rafaelia_kernel_audit.txt"

branch="$(git rev-parse --abbrev-ref HEAD)"
remote_default="$(git remote 2>/dev/null | head -n1 || true)"

{
  echo "RAFAELIA KERNEL AUDIT"
  echo "Generated: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  echo "Branch: ${branch}"
  echo "Remote default: ${remote_default:-N/A}"
  echo

  echo "== git diff --stat =="
  git diff --stat || true
  echo

  echo "== commits próprios (últimos 100) =="
  git log --oneline -n 100
  echo

  echo "== subsistemas alterados (arquivos tocados últimos 100 commits) =="
  git log --name-only --pretty=format: -n 100 | sed '/^$/d' | awk -F/ '{print $1"/"$2}' | sort | uniq -c | sort -nr
  echo

  echo "== presença de mudanças em áreas críticas (últimos 100 commits) =="
  paths="$(git log --name-only --pretty=format: -n 100 | sed '/^$/d' | sort -u)"

  for scope in 'arch/.*/kvm/' '^kernel/sched/' '^mm/' '^kernel/trace/' '^security/' '^arch/arm/' '^arch/arm64/'; do
    if echo "$paths" | rg -q "$scope"; then
      echo "FOUND: $scope"
      echo "$paths" | rg "$scope" | sed 's/^/  - /'
    else
      echo "NOT FOUND: $scope"
    fi
    echo
  done

  echo "== classificação sugerida =="
  critical=0
  for scope in '^kernel/sched/' '^mm/' 'arch/.*/kvm/' '^kernel/trace/' '^security/'; do
    if echo "$paths" | rg -q "$scope"; then
      critical=1
    fi
  done

  if [[ "$critical" -eq 1 ]]; then
    echo "Possui indícios de alteração core (validar patch a patch)."
  else
    echo "Sem indício de alteração core relevante nos últimos 100 commits: classificar como fork de estudo/referência/não-core."
  fi
} > "$OUT"

echo "Relatório gerado em: $OUT"
