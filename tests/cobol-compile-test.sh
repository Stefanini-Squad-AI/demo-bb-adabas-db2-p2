#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "[cobol-compile-test] Raiz: $ROOT"
missing=0
for f in "$ROOT/Cobol/STFSC00C.cbl" "$ROOT/Cobol/STFSC00I.cbl" "$ROOT/Cobol/src/SOCIOS-BOOK.cpy"; do
  if [[ ! -f "$f" ]]; then
    echo "ERRO: arquivo ausente: $f" >&2
    missing=1
  fi
done
if [[ "$missing" -ne 0 ]]; then
  exit 1
fi
if command -v cobc >/dev/null 2>&1; then
  echo "[cobol-compile-test] cobc encontrado; EXEC SQL requer pré-processador DB2 — não compilando STFSC00*.cbl aqui."
else
  echo "[cobol-compile-test] cobc não instalado — apenas validação de presença de artefatos."
fi
grep -q "EXEC SQL INCLUDE SQLCA" "$ROOT/Cobol/STFSC00C.cbl" "$ROOT/Cobol/STFSC00I.cbl"
grep -q "AAAAMMDD" "$ROOT/Cobol/STFSC00I.cbl"
echo "[cobol-compile-test] OK"
