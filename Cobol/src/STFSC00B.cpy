      ******************************************************************
      * BOOK LOCAL - Comunicacao Natural x COBOL (STFPCS00 / STFSC00*) *
      * Layout compativel com tabelas DB2 STF_SOCIO / STF_SOCIO_PER_*  *
      * Operacoes: I=Inclusao A=Alteracao E=Exclusao C=Consulta        *
      ******************************************************************
       01  STFSC00-COMUNICACAO.
           05  STFSC00-SQLCODE              PIC S9(09) COMP.
           05  STFSC00-OPERACAO              PIC X(01).
           05  STFSC00-NUMB-SOCIO-PRINCIPAL  PIC 9(09).
           05  STFSC00-NOME-SOCIO-PRINCIPAL  PIC X(40).
           05  STFSC00-DATA-CADASTRO         PIC X(10).
           05  STFSC00-C-PERIODICO-PAGAMENTO PIC 9(03).
           05  STFSC00-PERIODICO-PAGAMENTO.
               10  STFSC00-PER-OCOR          OCCURS 12 TIMES
                                           INDEXED BY STFSC00-IDX-PER.
                   15  STFSC00-DATA-VENCIMENTO
                                               PIC X(10).
                   15  STFSC00-VALR-MENSALIDADE
                                               PIC S9(06)V9(02)
                                                   COMP-3.
                   15  STFSC00-PAGAMENTO-OK    PIC X(01).
           05  STFSC00-CATG-SOCIO            PIC 9(02).
           05  STFSC00-INDI-DIVIDA           PIC X(01).
           05  STFSC00-DATA-BAIXA            PIC X(10).
           05  STFSC00-HORA-BAIXA            PIC X(08).
           05  STFSC00-OBSV-SOCIO            PIC X(500).
