-- DB2 DDL Script for SOCIO Module
-- Migration from Adabas ADABAS-SOCIOS (FNR 24) to COBOL/DB2
-- Date: 2026-05-26

-- ============================================================================
-- Table: SOCIO
-- Description: Main entity for member (sócio) registration
-- Adabas source: ADABAS-SOCIOS (FNR 24)
-- ============================================================================
CREATE TABLE SOCIO (
    NUMB_SOCIO_PRINCIPAL      DECIMAL(9,0)     NOT NULL PRIMARY KEY,
    NOME_SOCIO_PRINCIPAL      VARCHAR(40)      NOT NULL,
    DATA_CADASTRO             DATE             NOT NULL,
    CATG_SOCIO                SMALLINT         NOT NULL,
    INDI_DIVIDA               CHAR(1)          NOT NULL,
    DATA_BAIXA                DATE,
    HORA_BAIXA                CHAR(5),
    OBSV_SOCIO                VARCHAR(500)
);

-- ============================================================================
-- Table: SOCIO_PAGAMENTO
-- Description: Periodic payments (PE PERIODICO-PAGAMENTO normalized)
-- Represents the monthly payment schedule for each member
-- ============================================================================
CREATE TABLE SOCIO_PAGAMENTO (
    NUMB_SOCIO_PRINCIPAL      DECIMAL(9,0)     NOT NULL,
    SEQ_PAGAMENTO             SMALLINT         NOT NULL,
    DATA_VENCIMENTO           DATE             NOT NULL,
    VALR_MENSALIDADE          DECIMAL(8,2)     NOT NULL,
    PAGAMENTO_OK              CHAR(1)          NOT NULL,

    PRIMARY KEY (NUMB_SOCIO_PRINCIPAL, SEQ_PAGAMENTO),
    FOREIGN KEY (NUMB_SOCIO_PRINCIPAL) REFERENCES SOCIO(NUMB_SOCIO_PRINCIPAL) ON DELETE CASCADE
);

-- ============================================================================
-- Index: IX_SOCIO_SUPER1
-- Description: Composite index from Adabas SUPER1 (BA+BB)
-- Supports queries filtering by CATG_SOCIO and INDI_DIVIDA
-- ============================================================================
CREATE INDEX IX_SOCIO_SUPER1
    ON SOCIO(CATG_SOCIO, INDI_DIVIDA);

-- ============================================================================
-- Index: IX_SOCIO_PAG_VENC
-- Description: Support for queries by payment due date
-- ============================================================================
CREATE INDEX IX_SOCIO_PAG_VENC
    ON SOCIO_PAGAMENTO(DATA_VENCIMENTO);

-- ============================================================================
-- COMMIT statement
-- ============================================================================
COMMIT;
