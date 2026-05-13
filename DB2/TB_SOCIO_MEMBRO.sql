-- DB2 DDL: principal member (parent) — Phase 2 DBATDP-1
-- Dates stored as DATE (application uses YYYY-MM-DD).

CREATE TABLE TB_SOCIO_MEMBRO (
    NUMB_SOCIO_PRINCIPAL    DECIMAL(9, 0)    NOT NULL,
    NOME_SOCIO_PRINCIPAL    VARCHAR(40)    NOT NULL,
    DATA_CADASTRO           DATE           NOT NULL,
    CATG_SOCIO              SMALLINT       NOT NULL,
    INDI_DIVIDA             SMALLINT       NOT NULL DEFAULT 0,
    DATA_BAIXA              DATE,
    HORA_BAIXA              CHAR(12),
    OBSV_CLIENTE            VARCHAR(500)   NOT NULL,
    SUPER1                  CHAR(1),
    CONSTRAINT PK_SOCIO_MEMBRO PRIMARY KEY (NUMB_SOCIO_PRINCIPAL),
    CONSTRAINT CK_CATG_SOCIO CHECK (CATG_SOCIO IN (1, 2))
);

COMMENT ON TABLE TB_SOCIO_MEMBRO IS 'Sócio principal — migração fase 2 (ex-view ADABAS-SOCIOS)';
