#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAT="$ROOT/prg-natural-p2/STFPCS00-P2.txt"
LDA="$ROOT/prg-natural-p2/LOCAL/SOCIOS-LOCAL.nlf"
grep -q "LOCAL USING SOCIOS-LOCAL" "$NAT" || { echo "Falta LOCAL USING"; exit 1; }
grep -q "\[MIGRADO\] Chamada para COBOL/DB2" "$NAT" || { echo "Falta comentário MIGRADO"; exit 1; }
grep -q "CALL 'STFSC00C'" "$NAT" && grep -q "CALL 'STFSC00I'" "$NAT"
test -f "$LDA"
echo "[natural-compile-test] OK"
