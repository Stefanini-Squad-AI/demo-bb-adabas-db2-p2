-- DBATDP-18: Tabela principal de sócios (migração ADABAS-SOCIOS-P2)
-- Campos SUPER (SUPER1) não são colunas físicas; índice composto reproduz acesso Adabas.

CREATE TABLE TB_SOCIO (
    NUMB_SOCIO_PRINCIPAL   DECIMAL(9, 0)  NOT NULL,
    NOME_SOCIO_PRINCIPAL   VARCHAR(40)    NOT NULL,
    DATA_CADASTRO          DATE           NOT NULL,
    CATG_SOCIO             SMALLINT       NOT NULL,
    INDI_DIVIDA            CHAR(1)        NOT NULL DEFAULT 'N',
    DATA_BAIXA             DATE,
    HORA_BAIXA             CHAR(12),
    OBSV_SOCIO             VARCHAR(500),
    CONSTRAINT PK_TB_SOCIO PRIMARY KEY (NUMB_SOCIO_PRINCIPAL)
);

-- SUPER1: CATG-SOCIO(1-2) + INDI-DIVIDA(1-1) — mesma ordem e composição do Adabas
CREATE INDEX IX_TB_SOCIO_SUPER1 ON TB_SOCIO (CATG_SOCIO, INDI_DIVIDA);

COMMENT ON TABLE TB_SOCIO IS 'Sócio principal - migração ADABAS-SOCIOS-P2';
