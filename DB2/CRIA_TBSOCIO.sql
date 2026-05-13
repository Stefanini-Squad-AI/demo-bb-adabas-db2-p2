-- =====================================================================
-- DB2 DDL - MIGRACAO ADABAS-SOCIOS -> DB2
-- Issue   : DBATDP-1 (Migracao adabas/db2 - V2)
-- Origem  : DDM ADABAS-SOCIOS (prg-natural-p2/ADABAS-SOCIOS-P2.txt)
-- Modelo  : Relacional 1:N. O grupo periodico ADABAS PERIODICO-PAGAMENTO
--           e modelado como tabela filha TBSOCIO_MENSALIDADE com FK para
--           a tabela principal TBSOCIO. NAO ha campos achatados do tipo
--           VALR_MENSALIDADE_1..12 / DATA_VENCIMENTO_1..12 etc.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Tabela principal: TBSOCIO
-- Chave primaria pelo RG do socio (NUMB_SOCIO_PRINCIPAL).
-- ---------------------------------------------------------------------
CREATE TABLE TBSOCIO (
    NUMB_SOCIO_PRINCIPAL  DECIMAL(9,0)   NOT NULL,
    NOME_SOCIO_PRINCIPAL  CHAR(40)       NOT NULL,
    DATA_CADASTRO         DATE                   ,
    CATG_SOCIO            SMALLINT               ,
    INDI_DIVIDA           CHAR(1)                ,
    DATA_BAIXA            DATE                   ,
    HORA_BAIXA            TIMESTAMP              ,
    OBSV_SOCIO            VARCHAR(500)           ,
    CONSTRAINT PK_TBSOCIO
        PRIMARY KEY (NUMB_SOCIO_PRINCIPAL),
    CONSTRAINT CK_TBSOCIO_CATEGORIA
        CHECK (CATG_SOCIO IN (1, 2))
)
;

-- ---------------------------------------------------------------------
-- Tabela filha: TBSOCIO_MENSALIDADE
-- Representa o grupo periodico PERIODICO-PAGAMENTO (DATA-VENCIMENTO,
-- VALR-MENSALIDADE, PAGAMENTO-OK) do DDM ADABAS, com FK para o socio.
-- Sem limite artificial de registros (PK composta inclui o numero da
-- parcela apenas para permitir a ordenacao 1..N das mensalidades).
-- ---------------------------------------------------------------------
CREATE TABLE TBSOCIO_MENSALIDADE (
    NUMB_SOCIO_PRINCIPAL  DECIMAL(9,0)   NOT NULL,
    NUMR_PARCELA          SMALLINT       NOT NULL,
    DATA_VENCIMENTO       DATE                   ,
    VALR_MENSALIDADE      DECIMAL(6,2)           ,
    PAGAMENTO_OK          CHAR(1)                ,
    CONSTRAINT PK_TBSOCIO_MENSALIDADE
        PRIMARY KEY (NUMB_SOCIO_PRINCIPAL, NUMR_PARCELA),
    CONSTRAINT FK_TBSOCIO_MENSALIDADE_SOCIO
        FOREIGN KEY (NUMB_SOCIO_PRINCIPAL)
        REFERENCES TBSOCIO (NUMB_SOCIO_PRINCIPAL)
        ON DELETE CASCADE,
    CONSTRAINT CK_TBSOCIO_MENSALIDADE_PAGTO
        CHECK (PAGAMENTO_OK IN ('T', 'F'))
)
;

-- ---------------------------------------------------------------------
-- Indices auxiliares
-- ---------------------------------------------------------------------
CREATE INDEX IX_TBSOCIO_MENSALIDADE_DTVENC
    ON TBSOCIO_MENSALIDADE (NUMB_SOCIO_PRINCIPAL, DATA_VENCIMENTO)
;
