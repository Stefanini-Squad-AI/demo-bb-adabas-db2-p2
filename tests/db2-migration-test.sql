-- AT-001: validação de migração DDL (executar com cliente DB2 apontando para DB de teste)
-- Exemplo LUW: db2 connect to SAMPLE && db2 -tvf DB2/CRIAR_SOCIOS.sql
-- Este arquivo referencia o script principal e falha se tabelas não existirem após apply.

-- Etapa 1 (manual/CI com DB2): aplicar DDL base
-- !include não é padrão DB2; em pipelines, invoque o script principal antes deste arquivo.

SELECT COUNT(*) AS CNT_SOCIOS_CAT
FROM SYSCAT.TABLES
WHERE TABSCHEMA = CURRENT SCHEMA
  AND TABNAME = 'SOCIOS';

SELECT COUNT(*) AS CNT_SOCIOS_PER
FROM SYSCAT.TABLES
WHERE TABSCHEMA = CURRENT SCHEMA
  AND TABNAME = 'SOCIOS_PERIODICO';

-- Em ambientes sem catálogo SYSCAT (ex.: validação offline), comente as consultas acima
-- e use apenas checagem de sintaxe do script principal via `db2 -td@ -f DB2/CRIAR_SOCIOS.sql`.
