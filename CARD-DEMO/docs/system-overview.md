# CARD-DEMO — visão geral do sistema

## Arquitetura atual (migração SOCIOS)

O fluxo de cadastro/consulta de sócios foi migrado de acesso direto **Natural → ADABAS** para **Natural → COBOL → DB2**, preservando o comportamento funcional do programa `STFPCS00` enquanto a persistência passa a ser relacional.

```
┌─────────────┐     CALL / LINKAGE      ┌──────────────┐     SQL embutido    ┌──────┐
│   Natural   │ ───────────────────────►│ COBOL STFSC │────────────────────►│ DB2  │
│ STFPCS00-P2 │◄───────────────────────│   00C/00I    │◄────────────────────│ SOCIOS│
└─────────────┘   área SOCIO-BOOK       └──────────────┘                     └──────┘
```

### Módulos relevantes

| Camada | Artefato | Função |
|--------|----------|--------|
| Natural | `prg-natural-p2/STFPCS00-P2.txt` | Orquestração de tela, validações de negócio, chamadas COBOL |
| Natural LDA | `prg-natural-p2/LOCAL/SOCIOS-LOCAL.nlf` | Área local espelhando o copybook COBOL |
| COBOL | `Cobol/STFSC00C.cbl` | Consulta (`SELECT` + cursor em `SOCIOS_PERIODICO`) |
| COBOL | `Cobol/STFSC00I.cbl` | Inclusão (`INSERT` principal + filhos) |
| DB2 | `DB2/CRIAR_SOCIOS.sql` | DDL `SOCIOS` + `SOCIOS_PERIODICO` (1:N, sem flatten) |
| Comunicação | `Cobol/src/SOCIOS-BOOK.cpy` | Contrato de dados e return code |

Detalhes de mapeamento e códigos de retorno: `modules/socios-migration.md` e `migration-guide.md`.
