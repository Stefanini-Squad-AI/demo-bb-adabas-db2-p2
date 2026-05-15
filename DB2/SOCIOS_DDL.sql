-- DB2 Table Creation Script for SOCIOS Module
-- Created: 2026-05-15
-- Purpose: Modernization of member management from Adabas to DB2

-- Main table: SOCIOS (Members)
CREATE TABLE SOCIOS (
    NUMB_SOCIO_PRINCIPAL    INTEGER NOT NULL,
    NOME_SOCIO_PRINCIPAL    VARCHAR(40) NOT NULL,
    DATA_CADASTRO           DATE NOT NULL,
    CATG_SOCIO              SMALLINT NOT NULL,
    DATA_BAIXA              DATE,
    HORA_BAIXA              TIME,
    OBSV_SOCIO              VARCHAR(500),
    PRIMARY KEY (NUMB_SOCIO_PRINCIPAL)
);

-- Child table: SOCIOS_PAGAMENTO (Monthly payment records)
-- Replaces the periodic group PERIODICO-PAGAMENTO from Adabas
-- Supports unlimited payment records per member (no hardcoded limit)
CREATE TABLE SOCIOS_PAGAMENTO (
    PAGTO_ID                INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
    NUMB_SOCIO_PRINCIPAL    INTEGER NOT NULL,
    DATA_VENCIMENTO         DATE NOT NULL,
    VALR_MENSALIDADE        DECIMAL(8,2) NOT NULL,
    PAGAMENTO_OK            SMALLINT NOT NULL DEFAULT 0,
    PRIMARY KEY (PAGTO_ID),
    FOREIGN KEY (NUMB_SOCIO_PRINCIPAL) REFERENCES SOCIOS(NUMB_SOCIO_PRINCIPAL)
);

-- Index for performance on foreign key lookups
CREATE INDEX IDX_SOCIOS_PAGAMENTO_FK ON SOCIOS_PAGAMENTO(NUMB_SOCIO_PRINCIPAL);
