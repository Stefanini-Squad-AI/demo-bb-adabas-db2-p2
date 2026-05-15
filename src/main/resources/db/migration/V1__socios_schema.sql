-- MySQL equivalent of ADABAS-SOCIOS / periodic PERIODICO-PAGAMENTO (12 occurrences normalized).
CREATE TABLE socio (
    numb_socio_principal BIGINT NOT NULL COMMENT 'RG / número do sócio (NUMB-SOCIO-PRINCIPAL N 9,0)',
    nome_socio_principal VARCHAR(40) NOT NULL,
    data_cadastro DATE NOT NULL COMMENT 'ADABAS D 6 YYMMDD',
    catg_socio SMALLINT NOT NULL COMMENT '1 Principal 2 Dependente',
    indi_divida SMALLINT NULL,
    data_baixa DATE NULL,
    hora_baixa VARCHAR(12) NULL,
    obsv_socio VARCHAR(500) NOT NULL,
    PRIMARY KEY (numb_socio_principal)
) COMMENT 'Migrated from ADABAS-SOCIOS (DDM prg-natural-p2/ADABAS-SOCIOS-P2.txt)';

CREATE TABLE socio_periodo_pagamento (
    numb_socio_principal BIGINT NOT NULL,
    periodo_index TINYINT NOT NULL COMMENT '1..12 maps Natural array index',
    data_vencimento DATE NOT NULL,
    valr_mensalidade DECIMAL(8, 2) NOT NULL COMMENT 'Packed P 6,2 in ADABAS',
    pagamento_ok TINYINT(1) NOT NULL COMMENT 'Boolean L 1',
    PRIMARY KEY (numb_socio_principal, periodo_index),
    CONSTRAINT fk_periodo_socio FOREIGN KEY (numb_socio_principal) REFERENCES socio (numb_socio_principal)
        ON DELETE CASCADE
) COMMENT 'Normalized PERIODICO-PAGAMENTO group (12 rows per sócio)';

CREATE INDEX idx_socio_nome ON socio (nome_socio_principal);
