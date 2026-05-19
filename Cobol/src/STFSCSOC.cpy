      ******************************************************************
      * COPYBOOK ENTIDADE SOCIO - compativel WORKING/LINKAGE/FILE      *
      * Migrado de ADABAS-SOCIOS-P2                                    *
      ******************************************************************
       01  STFSCSOC-REGISTRO.
           05  STFSCSOC-NUMB-SOCIO-PRINCIPAL
                                       PIC 9(09).
           05  STFSCSOC-NOME-SOCIO-PRINCIPAL
                                       PIC X(40).
           05  STFSCSOC-DATA-CADASTRO  PIC X(10).
           05  STFSCSOC-CATG-SOCIO     PIC 9(02).
           05  STFSCSOC-INDI-DIVIDA    PIC X(01).
           05  STFSCSOC-DATA-BAIXA     PIC X(10).
           05  STFSCSOC-HORA-BAIXA     PIC X(05).
           05  STFSCSOC-OBSV-SOCIO     PIC X(500).
           05  STFSCSOC-QTD-PERIODICO  PIC 9(03).
           05  STFSCSOC-PERIODICO
                                       OCCURS 999 TIMES
                                       INDEXED BY STFSCSOC-IDX-PER.
               10  STFSCSOC-SEQ-OCORRENCIA
                                       PIC 9(03).
               10  STFSCSOC-DATA-VENCIMENTO
                                       PIC X(10).
               10  STFSCSOC-VALR-MENSALIDADE
                                       PIC S9(06)V9(02)
                                       COMP-3.
               10  STFSCSOC-PAGAMENTO-OK
                                       PIC X(01).
