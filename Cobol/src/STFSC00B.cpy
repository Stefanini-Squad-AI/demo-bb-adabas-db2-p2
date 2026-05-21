      ******************************************************************
      * STFSC00B - Book de comunicação Natural x COBOL (entidade SOCIO)
      * Compatível com WORKING-STORAGE, LINKAGE, FILE SECTION
      * Return codes DB2: +000 localizado, +100 não localizado, +803 duplicado
      ******************************************************************
       01  STFSC00B-COMMAREA.
           05  STFSC00B-RETURN-CODE        PIC X(5).
               88  STFSC00B-RC-OK          VALUE '+000'.
               88  STFSC00B-RC-NOT-FOUND   VALUE '+100'.
               88  STFSC00B-RC-DUP-KEY     VALUE '+803'.
           05  STFSC00B-NUMB-SOCIO-PRINCIPAL
                                       PIC 9(9).
           05  STFSC00B-NOME-SOCIO-PRINCIPAL
                                       PIC X(40).
           05  STFSC00B-DATA-CADASTRO    PIC X(10).
           05  STFSC00B-C-PERIODICO-PAGAMENTO
                                       PIC 9(3).
           05  STFSC00B-PERIODICO-PAGAMENTO
                                       OCCURS 12 TIMES
                                       INDEXED BY STFSC00B-IDX-PAG.
               10  STFSC00B-DATA-VENCIMENTO
                                       PIC X(10).
               10  STFSC00B-VALR-MENSALIDADE
                                       PIC S9(6)V9(2)
                                       USAGE COMP-3.
               10  STFSC00B-PAGAMENTO-OK PIC X(1).
           05  STFSC00B-CATG-SOCIO       PIC 9(2).
           05  STFSC00B-INDI-DIVIDA      PIC X(1).
           05  STFSC00B-DATA-BAIXA       PIC X(10).
           05  STFSC00B-HORA-BAIXA       PIC X(5).
           05  STFSC00B-OBSV-SOCIO       PIC X(500).
           05  STFSC00B-SUPER1           PIC X(5).
           05  REDEFINES STFSC00B-SUPER1.
               10  STFSC00B-SUPER-CATG   PIC 9(2).
               10  STFSC00B-SUPER-INDI   PIC X(1).
               10  FILLER                PIC X(2).
