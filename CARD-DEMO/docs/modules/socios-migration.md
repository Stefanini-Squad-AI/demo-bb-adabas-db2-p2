# Módulo SOCIOS — migração ADABAS → DB2

## Propósito

Substituir o DDM `ADABAS-SOCIOS` utilizado pelo programa Natural por tabelas DB2 acessadas exclusivamente via subprogramas COBOL (`STFSC00*`), mantendo equivalência funcional para consulta (ex-`FIND`) e inclusão (ex-`STORE`).

## Modelagem relacional

| ADABAS / Natural (legado) | DB2 | Observação |
|---------------------------|-----|------------|
| Registro principal SOCIOS | `SOCIOS` | PK `NUMB_SOCIO_PRINCIPAL` |
| Grupo periódico `PERIODICO-PAGAMENTO` | `SOCIOS_PERIODICO` | FK `NUMB_SOCIO_PRINCIPAL`; **sem limite** de linhas (1:N real) |
| `PAGAMENTO-OK` (L) | `PAGAMENTO_OK` SMALLINT | `0`/`1` (boolean lógico) |
| Datas `D` (6 interno) / AAAAMMDD na comunicação | `DATE` | Conversão no COBOL (ISO ↔ AAAAMMDD) |
| `HORA-BAIXA` | `TIME` | Tráfego como `CHAR(12)` no BOOK quando preenchido |
| `OBSV-CLIENTE` / `OBSV-SOCIO` | `OBSV_SOCIO` VARCHAR(500) | Nome unificado no modelo DB2 |
| `INDI-DIVIDA` | `INDI_DIVIDA` SMALLINT | Campo presente no programa Natural |

Índice auxiliar: `IX_SOCIOS_PERIODICO_SOCIO` na FK para suporte a joins por sócio.

## Contrato Natural ↔ COBOL

- Copybook: `Cobol/src/SOCIOS-BOOK.cpy` (nível `01 SOCIO-BOOK`, return code, contadores de periódicos, `OCCURS 12` para compatibilidade com o fluxo atual de 12 parcelas na tela).
- LDA Natural: `prg-natural-p2/LOCAL/SOCIOS-LOCAL.nlf`, incluída com `DEFINE DATA LOCAL USING SOCIOS-LOCAL`.

### Programas COBOL

| Programa | Operação | Origem Natural |
|----------|----------|----------------|
| `STFSC00C` | Consulta | Ex-`FIND` |
| `STFSC00I` | Inclusão | Ex-`STORE` |

**Não** foram gerados `STFSC00A` / `STFSC00E`: o fonte `STFPCS00-P2.txt` original não contém `UPDATE` nem `DELETE` em ADABAS.

### Return codes (campo `SOCIO-RETURN-CODE`)

| Valor | Significado |
|------|-------------|
| `0` | Sucesso |
| `1` | Não encontrado (consulta) |
| `2` | Data inválida (validação AAAAMMDD) |
| `9` | Erro SQL genérico (ver `SOCIO-SQLCODE-DISP`) |
| `97` | Violação de PK na inclusão (ex.: `-803` DB2) |

## Dependências

- Runtime Natural com suporte a `CALL` para módulos COBOL linkados.
- Pré-compilador SQL + bind DB2 para `STFSC00C` / `STFSC00I`.
- Tabelas criadas a partir de `DB2/CRIAR_SOCIOS.sql`.
