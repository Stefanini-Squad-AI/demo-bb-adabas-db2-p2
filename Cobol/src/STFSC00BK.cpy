      ******************************************************************
      * STFSC00BK - BOOK DE COMUNICACAO NATURAL x COBOL (SOCIO / DB2) *
      * Operacoes: C=CONSULTA I=INCLUSAO A=ALTERACAO E=EXCLUSAO        *
      ******************************************************************
       01  STFSC00-COMM-AREA.
           05 STFSC00-OPERACAO              PIC X(01).
           05 STFSC00-RETURN-CODE           PIC 9(02).
           05 STFSC00-SQLCODE-DSP           PIC S9(9) COMP.
           05 STFSC00-SQLSTATE              PIC X(05).
           05 STFSC00-NUMB-SOCIO-PRINCIPAL  PIC S9(09) DISPLAY.
           05 STFSC00-NOME-SOCIO-PRINCIPAL  PIC X(40).
           05 STFSC00-DATA-CADASTRO         PIC X(10).
           05 STFSC00-CATG-SOCIO            PIC S9(04) COMP.
           05 STFSC00-INDI-DIVIDA           PIC S9(04) COMP.
           05 STFSC00-DATA-BAIXA            PIC X(10).
           05 STFSC00-HORA-BAIXA            PIC X(05).
           05 STFSC00-OBSV-CLIENTE          PIC X(500).
           05 STFSC00-SUPER1                PIC X(20).
           05 STFSC00-PERIODICO             OCCURS 12 TIMES.
              10 STFSC00-DATA-VENCIMENTO    PIC X(10).
              10 STFSC00-VALR-MENSALIDADE   PIC S9(04)V9(02) COMP-3.
              10 STFSC00-PAGAMENTO-OK       PIC X(01).
