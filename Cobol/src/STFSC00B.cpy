      ******************************************************************
      * STFSC00B - Book de comunicacao Natural x COBOL (ADABAS-SOCIOS)
      * Suporta operacoes I/A/E/C com return code DB2
      ******************************************************************
       01  STFSC00-AREA.
           05  STFSC00-DADOS.
               10  NUMB-SOCIO-PRINCIPAL     PIC 9(09).
               10  NOME-SOCIO-PRINCIPAL     PIC X(40).
               10  DATA-CADASTRO            PIC X(10).
               10  C-PERIODICO-PAGAMENTO    PIC 9(03).
               10  VALR-MENSALIDADE
                   OCCURS 12 TIMES
                   PIC S9(04)V99 COMP-3.
               10  DATA-VENCIMENTO
                   OCCURS 12 TIMES
                   PIC X(10).
               10  PAGAMENTO-OK
                   OCCURS 12 TIMES
                   PIC X(01).
               10  CATG-SOCIO               PIC 9(02).
               10  INDI-DIVIDA              PIC X(01).
               10  DATA-BAIXA               PIC X(10).
               10  HORA-BAIXA               PIC X(05).
               10  OBSV-CLIENTE             PIC X(500).
           05  STFSC00-RETORNO.
               10  STFSC00-SQLCODE          PIC S9(09) COMP.
               10  STFSC00-SQLSTATE         PIC X(05).
               10  STFSC00-MSG              PIC X(72).
