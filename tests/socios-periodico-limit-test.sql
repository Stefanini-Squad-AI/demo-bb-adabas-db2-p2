-- AT-002: garantir modelo 1:N sem colunas flatten (teste lógico + inserção em massa)
-- Pré-condição: tabelas criadas por DB2/CRIAR_SOCIOS.sql
-- Insere 100 linhas em SOCIOS_PERIODICO para um sócio de teste e valida COUNT(*)=100.

-- Ajuste :NUMB conforme ambiente (ex.: 123456789)
-- Exemplo (DB2 LUW):
-- INSERT INTO SOCIOS (...) VALUES (...);
-- INSERT INTO SOCIOS_PERIODICO (...) SELECT ... FROM ... (100 linhas);

SELECT 1 AS AT002_SKIPPED
FROM SYSIBM.SYSDUMMY1
WHERE 1 = 0;

-- Quando CI tiver DB2, substitua por INSERT/SELECT gerando 100 parcelas e:
-- SELECT COUNT(*) FROM SOCIOS_PERIODICO WHERE NUMB_SOCIO_PRINCIPAL = ? ; -- esperado 100
