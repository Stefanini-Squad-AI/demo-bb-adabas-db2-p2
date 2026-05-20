# Module File Map

**Version:** 2026-05-20

Machine-readable inventory mapping Natural programs, Adabas artifacts, target COBOL services, and DB2 entities for the Stefanini P2 modernization sample.

---

## Source Root

| Path | Description |
|------|-------------|
| `prg-natural-p2/` | Natural programs and Adabas DDM definitions (repository uses this folder; template alias `natural-prg/` not present) |

---

## Module: socio

| Attribute | Value |
|-----------|-------|
| Business domain | Gym/club member (sócio) registration and payment schedule |
| Adabas file | `ADABAS-SOCIOS` (DDM FNR 24, VSAM `ADABAS-SOCIOS 2`) |
| Natural view | `SOCIO VIEW OF ADABAS-SOCIOS` |

### Natural Programs

| Program | File | Type | Description |
|---------|------|------|-------------|
| STFPCS00 | `prg-natural-p2/STFPCS00-P2.txt` | Online dialog | New member inclusion; RG lookup, validation, 12-month payment schedule |
| VERVALOR | *(external)* | Subprogram | Called via `CALLNAT`; loads `VALR-MENSALIDADE(*)` by `CATG-SOCIO` — not in repository |

### Adabas / DDM Artifacts

| Artifact | File | Role |
|----------|------|------|
| ADABAS-SOCIOS | `prg-natural-p2/ADABAS-SOCIOS-P2.txt` | DDM: member master + periodic payment group |

### Maps and UI

| Map | Referenced by | Notes |
|-----|---------------|-------|
| MAPSOCIO | `STFPCS00` (`INPUT ... MAP 'MAPSOCIO'`) | Screen for RG, name, category, due day — map source not in repo |

### Adabas Operations by Program

| Natural Program | Operation | Adabas / View | Key / Condition | Line ref |
|---------------|-----------|---------------|-----------------|----------|
| STFPCS00 | FIND | SOCIO | `NUMB-SOCIO-PRINCIPAL EQ #RG-CONSULTA` | 49–55 |
| STFPCS00 | STORE | SOCIO | After `INCLUI-SOCIO` validation | 107 |
| STFPCS00 | — | — | `CALLNAT 'VERVALOR'` (no Adabas) | 83 |

### CALLNAT Dependencies

| Caller | Called | Parameters |
|--------|--------|------------|
| STFPCS00 | VERVALOR | `CATG-SOCIO`, `VALR-MENSALIDADE(*)` |

### Target COBOL Services

Naming per project standard: `STF` + `S` + `C` + `00` + action (`I`/`A`/`E`/`C`).

| Natural operation | Candidate COBOL | Action | Scope |
|-------------------|-----------------|--------|-------|
| FIND SOCIO | STFSC00C | C (Consult) | Lookup by RG (`NUMB-SOCIO-PRINCIPAL`) |
| STORE | STFSC00I | I (Inclusion) | Insert member + payment periodic rows |
| UPDATE | — | — | Not present in source — do not generate |
| DELETE | — | — | Not present in source — do not generate |

### Target DB2 Entities

| DB2 Table | Source Adabas | Notes |
|-----------|---------------|-------|
| TB_SOCIO | ADABAS-SOCIOS (non-PE fields) | PK: `NUMB_SOCIO_PRINCIPAL`; dates as `DATE` (YYYY-MM-DD) |
| TB_SOCIO_PERIODICO_PAGAMENTO | PE `PERIODICO-PAGAMENTO` | 1:N child; no flatten of 12 slots; unlimited rows per member |
| — | SUPER1 (`BA+BB`) | Not a physical column; composite access via `CATG_SOCIO` + `INDI_DIVIDA` indexes |

### Copybooks / LDA (planned)

| Artifact | Location (per migration script) |
|----------|----------------------------------|
| COBOL communication copybook | `Cobol/src` |
| Natural LOCAL book | `prg-natural-p2/LOCAL` (or `prg-natural/LOCAL` per script) |

---

## Cross-Module Dependencies

| From | To | Type |
|------|-----|------|
| STFPCS00 | VERVALOR | CALLNAT (fee lookup) |
| STFPCS00 | MAPSOCIO | Map |
| STFPCS00 | ADABAS-SOCIOS | View / persistence |

---

## Repository Files Excluded from Migration Scope

| File | Reason |
|------|--------|
| `script-adabas-db2 - P2.txt` | Migration generation prompt / rules — not executable Natural |

---

## Module Index (HTML)

| Module | Documentation page |
|--------|-------------------|
| socio | `docs/site/modules/socio/index.html` |
