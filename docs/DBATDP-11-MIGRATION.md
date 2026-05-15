# DBATDP-11 — Natural (prg-natural-p2) → Java / MySQL

## Scope

- **In scope:** `prg-natural-p2/STFPCS00-P2.txt`, `prg-natural-p2/ADABAS-SOCIOS-P2.txt`, ADABAS view `ADABAS-SOCIOS` and periodic group `PERIODICO-PAGAMENTO` (12 occurrences).
- **Out of scope:** Other Natural folders/tables, live ADABAS connectivity, and the alternate migration path described in `script-adabas-db2 - P2.txt` (Natural → COBOL → DB2), unless the program later converges those streams.

## Java architecture

- **Runtime:** Spring Boot 3.2, Java 17, JDBC + Flyway (no JPA), MySQL 8+ as target.
- **API:** REST resources under `/api/socios` replace the interactive map + PF-key flow:
  - `GET /api/socios/{rg}` — read member + 12 payment periods (equivalent to successful `FIND`).
  - `GET /api/socios/{rg}/status` — lightweight “already registered?” check (equivalent to post-`FIND` message path).
  - `POST /api/socios` — new member + `STORE` (equivalent to `PERFORM INCLUI-SOCIO`).
- **Configuration:** `socios.mensalidade-por-categoria` in `application.yml` replaces `CALLNAT 'VERVALOR'` until the real fee table or service is wired in.

## MySQL schema design

| ADABAS / Natural | MySQL |
|------------------|--------|
| `SOCIO` record (non-periodic fields) | Table `socio` |
| `PERIODICO-PAGAMENTO` (12 × `DATA-VENCIMENTO`, `VALR-MENSALIDADE`, `PAGAMENTO-OK`) | Table `socio_periodo_pagamento` with `periodo_index` 1–12 |

**Type mapping (high level):**

- `N 9,0` → `BIGINT`
- `C 40` / `A 500` → `VARCHAR` with same lengths
- `D 6` (YYMMDD) → `DATE` (application uses ISO local dates; loaders must convert from ADABAS)
- `P 6,2` → `DECIMAL(8,2)`
- `L 1` → `TINYINT(1)` / boolean
- `I 2` → `SMALLINT`
- `T 12` → `VARCHAR(12)`

**Natural vs DDM naming:** the program uses `OBSV-CLIENTE` while the DDM excerpt shows `OBSV-SOCIO`; both map to column `obsv_socio`. Field `INDI-DIVIDA` appears in the program but not in the truncated DDM snippet; it is modeled as nullable `indi_divida` for forward compatibility. `SUPER1` from the Natural data area is not in the supplied DDM and is not persisted until the physical file layout confirms it.

## Functional mapping (STFPCS00-P2)

| Natural | Java |
|---------|------|
| `FIND` + `NO RECORD` → `INCLUI-SOCIO` | Client calls `GET .../status` or `GET` then `POST` if not found |
| `REINPUT` validations (name, category, due day) | Bean Validation on `NovoSocioRequest` + service rules for allowed due days `{1,5,15,20,25}` |
| `DATA-CADASTRO := *DATX` | `LocalDate.now()` on insert |
| Due date loop (`DATX` + `#DIA-VENCIAMENTO` + `ADD 1 TO #MES`) | `PeriodoVencimentoCalculator.dozeVencimentos` |
| `PAGAMENTO-OK(1) := TRUE`, `PAGAMENTO-OK(2:11) := FALSE` | First period `pagamento_ok = true`, others `false` |
| `STORE` | `SocioRepository.insertSocioComPeriodos` in a `@Transactional` service method |

## Data migration (ADABAS → MySQL)

**Not automated in this repository** (requires export tooling and credentials). Recommended validation (AC3):

1. Row count parity: count ADABAS `SOCIO` vs `SELECT COUNT(*) FROM socio`.
2. For each member, compare `NUMB-SOCIO-PRINCIPAL` and expanded 12-period vectors vs `socio` + `socio_periodo_pagamento` ordered by `periodo_index`.
3. Spot-check packed decimals and YYMMDD boundaries; verify NULLs for `DATA-BAIXA` / `HORA-BAIXA` when not set.

## Build & run

Requires **JDK 17+** and **Maven 3.9+** on the host (not bundled as `mvnw` in this repo).

```bash
export MYSQL_URL='jdbc:mysql://localhost:3306/socios?createDatabaseIfNotExist=true'
export MYSQL_USER=...
export MYSQL_PASSWORD=...
mvn spring-boot:run
```

Flyway applies `src/main/resources/db/migration/V1__socios_schema.sql` on startup.

## Known gaps vs full acceptance criteria

- **AC3 / AC4:** Historical load and end-to-end parity tests depend on real ADABAS export + UAT data; stubs are not in repo.
- **AC5 (this document):** Covers architecture, schema, and mapping; extend with runbooks once ETL and environments are fixed.
- **PF-key UX:** Replaced by HTTP verbs and status codes (`F3` exit → client closes session; validation errors → `400` with default Spring error body unless a custom `@ControllerAdvice` is added later).
