-- =====================================================================
-- DB2 Schema for SOCIO Member Data Migration
-- =====================================================================
-- This script creates the relational tables for the SOCIO (member)
-- data migration from Adabas to DB2. It includes a parent table SOCIO
-- and a child table SOCIO_PAGAMENTO for the periodic payments.
-- =====================================================================

-- Create SOCIO parent table
CREATE TABLE SOCIO (
    NUMB_SOCIO_PRINCIPAL NUMERIC(9) NOT NULL PRIMARY KEY,
    NOME_SOCIO_PRINCIPAL VARCHAR(40) NOT NULL,
    DATA_CADASTRO DATE NOT NULL,
    CATG_SOCIO SMALLINT NOT NULL,
    INDI_DIVIDA CHAR(1) NOT NULL DEFAULT '0',
    DATA_BAIXA DATE NULL,
    HORA_BAIXA TIME NULL,
    OBSV_SOCIO VARCHAR(500) NULL
);

-- Create SOCIO_PAGAMENTO child table for periodic payments
CREATE TABLE SOCIO_PAGAMENTO (
    ID_PAGAMENTO BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NUMB_SOCIO_PRINCIPAL NUMERIC(9) NOT NULL,
    DATA_VENCIMENTO DATE NOT NULL,
    VALR_MENSALIDADE DECIMAL(6, 2) NOT NULL,
    PAGAMENTO_OK CHAR(1) NOT NULL DEFAULT '0',
    FOREIGN KEY (NUMB_SOCIO_PRINCIPAL)
        REFERENCES SOCIO(NUMB_SOCIO_PRINCIPAL)
        ON DELETE CASCADE
);

-- Create composite index for SUPER1 field (CATG_SOCIO + INDI_DIVIDA)
CREATE INDEX IDX_SOCIO_CATG_DIVIDA
    ON SOCIO(CATG_SOCIO, INDI_DIVIDA);

-- Create index on SOCIO_PAGAMENTO for lookups by member
CREATE INDEX IDX_PAGAMENTO_SOCIO
    ON SOCIO_PAGAMENTO(NUMB_SOCIO_PRINCIPAL, DATA_VENCIMENTO);

COMMIT;
