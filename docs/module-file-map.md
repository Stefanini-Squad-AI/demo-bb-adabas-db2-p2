# Mapa de Arquivos — Modernização Natural/Adabas → COBOL/DB2

**Versão:** 2026-05-21  
**Repositório:** P2 — Gestão de Sócios  
**Pasta fonte Natural:** `prg-natural-p2/`

---

## Módulos de Negócio

| Módulo | Descrição | Pasta documentação |
|--------|-----------|-------------------|
| `socio` | Cadastro e inclusão de sócios com pagamentos periódicos | `docs/site/modules/socio/` |

---

## Inventário de Programas Natural

| Programa | Tipo | Módulo | Arquivo | CALLNAT / Serviços | Status migração |
|----------|------|--------|---------|-------------------|-----------------|
| STFPCS00 | Online (mapa MAPSOCIO) | socio | `prg-natural-p2/STFPCS00-P2.txt` | STFSC00C, STFSC00I, VERVALOR | Parcial — Adabas substituído por COBOL |

---

## Áreas de Dados e Copycode

| Artefato | Tipo | Arquivo | Uso |
|----------|------|---------|-----|
| STFSC00L | LDA (Local Data Area) | `prg-natural-p2/LOCAL/STFSC00L.txt` | Comunicação Natural ↔ COBOL (equivalente ao copybook STFSC00B) |
| ADABAS-SOCIOS | DDM Adabas (referência legado) | `prg-natural-p2/ADABAS-SOCIOS-P2.txt` | Definição original do arquivo FNR 24 |

---

## Mapeamento Adabas → DB2

| Arquivo/View Adabas | FNR | Operações legado | Tabela(s) DB2 | Observação |
|---------------------|-----|------------------|---------------|------------|
| ADABAS-SOCIOS | 24 | FIND, STORE | `SOCIO`, `SOCIO_PAGAMENTO` | PE `PERIODICO-PAGAMENTO` normalizado em tabela filha 1:N |
| SUPER1 (BA+BB) | — | Índice lógico | `IX_SOCIO_SUPER1` | CATG_SOCIO + INDI_DIVIDA — sem coluna física SUPER |

### Campos principais — entidade SOCIO

| Campo Adabas | Campo DB2 | Tipo DB2 |
|--------------|-------------|----------|
| NUMB-SOCIO-PRINCIPAL | NUMB_SOCIO_PRINCIPAL | DECIMAL(9,0) PK |
| NOME-SOCIO-PRINCIPAL | NOME_SOCIO_PRINCIPAL | VARCHAR(40) |
| DATA-CADASTRO | DATA_CADASTRO | DATE |
| CATG-SOCIO | CATG_SOCIO | SMALLINT |
| INDI-DIVIDA | INDI_DIVIDA | CHAR(1) |
| DATA-BAIXA | DATA_BAIXA | DATE (nullable) |
| HORA-BAIXA | HORA_BAIXA | CHAR(5) |
| OBSV-SOCIO | OBSV_SOCIO | VARCHAR(500) |

### Campos — PE PERIODICO-PAGAMENTO → SOCIO_PAGAMENTO

| Campo Adabas (PE) | Campo DB2 | Tipo DB2 |
|-------------------|-------------|----------|
| DATA-VENCIMENTO | DATA_VENCIMENTO | DATE |
| VALR-MENSALIDADE | VALR_MENSALIDADE | DECIMAL(8,2) |
| PAGAMENTO-OK | PAGAMENTO_OK | CHAR(1) |
| (sequencial implícito) | SEQ_PAGAMENTO | SMALLINT (PK composta) |

---

## Mapeamento Natural → Serviços COBOL

| Programa Natural | Operação legado Adabas | Serviço COBOL | Ação | Return codes |
|------------------|------------------------|---------------|------|--------------|
| STFPCS00 | FIND SOCIO BY NUMB-SOCIO-PRINCIPAL | STFSC00C | Consulta (C) | +000 encontrado, +100 não encontrado, +999 erro |
| STFPCS00 | STORE SOCIO | STFSC00I | Inclusão (I) | +000 ok, +803 duplicado, +999 erro |
| STFPCS00 | (tarifa por categoria) | VERVALOR | Externo | Não presente no repositório |

### Serviços COBOL candidatos / pendentes

| Serviço | Ação | Necessidade | Motivo |
|---------|------|-------------|--------|
| STFSC00A | Alteração (A) | Não gerado | Operação UPDATE não encontrada no fonte Natural |
| STFSC00E | Exclusão (E) | Não gerado | Operação DELETE não encontrada no fonte Natural |

---

## Artefatos de Suporte

| Artefato | Caminho | Função |
|----------|---------|--------|
| STFSC00B | `Cobol/src/STFSC00B.cpy` | Copybook de comunicação Natural/COBOL |
| STFSC00C | `Cobol/STFSC00C.cbl` | Consulta sócio + pagamentos (cursor DB2) |
| STFSC00I | `Cobol/STFSC00I.cbl` | Inclusão sócio + pagamentos |
| DDL_SOCIO | `DB2/DDL_SOCIO.sql` | Script de criação de tabelas DB2 |

---

## Dependências Externas

| Dependência | Tipo | Impacto na migração |
|-------------|------|---------------------|
| VERVALOR | Subprograma Natural | Obtém valor de mensalidade por categoria; deve ser documentado/migrado separadamente |
| MAPSOCIO | Mapa de tela | Interface de entrada (RG, nome, categoria, dia vencimento) |

---

*Última atualização: 2026-05-21*
