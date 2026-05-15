# Guia técnico — migração Natural/ADABAS → COBOL/DB2 (SOCIOS)

## Mapeamento de operações

1. **Consulta (FIND)**  
   Substituída por `CALL 'STFSC00C' SOCIO-BOOK`. O COBOL executa `SELECT` na tabela `SOCIOS` e, em caso de sucesso, abre cursor em `SOCIOS_PERIODICO` preenchendo até 12 ocorrências no BOOK (alinhado ao laço Natural existente).

2. **Inclusão (STORE)**  
   Substituída por `CALL 'STFSC00I' SOCIO-BOOK`. O COBOL valida datas em **AAAAMMDD** antes de montar literais `YYYY-MM-DD` para `DATE(:host)` no SQL (requisito AC5 / conversão DB2).

## Conversão de datas (AC5)

Entrada (Natural, `A8` compacto):

1. Validar `SOCIO-DATA-CADASTRO` numérica e componentes mês/dia plausíveis.
2. Montar string `YYYY-MM-DD` (equivalente funcional ao uso de `MOVE EDITED` com máscara `9(4)-9(2)-9(2)` sobre grupos numéricos).
3. Utilizar `DATE(:host-char-10)` no `INSERT` / predicados.

Saída (consulta):

1. Receber `CHAR(DATA, ISO)` do DB2.
2. Remover hífens e popular `A8` AAAAMMDD no BOOK para o Natural.

## Tratamento de erros (SQLCA)

- Após cada `EXEC SQL`, os programas avaliam `SQLCODE`.
- Erros propagam `SOCIO-RETURN-CODE` ≠ `0` e copiam `SQLCODE` para `SOCIO-SQLCODE-DISP` (depuração no Natural).
- Duplicidade de PK na inclusão: `SQLCODE = -803` → `SOCIO-RETURN-CODE = 97` (ajustar se o seu dialecto DB2 usar outro código).

## Comentários `[MIGRADO]` no Natural

Os pontos exatos da troca ADABAS → COBOL estão marcados com:

`* [MIGRADO] Chamada para COBOL/DB2 (...)`  

no arquivo `prg-natural-p2/STFPCS00-P2.txt`.

## Testes automatizados

Ver scripts em `tests/` e o workflow `.github/workflows/ci-pipeline-card-demo.yml`. Ambientes sem `db2` / pré-compilador SQL podem executar apenas checagens estáticas (grep / existência de artefatos).
