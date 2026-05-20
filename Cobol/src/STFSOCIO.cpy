      ******************************************************************
      * STFSOCIO - Book de comunicacao Natural x COBOL (socio)
      * Operacoes: C=Consulta  I=Inclusao  A=Alteracao  E=Exclusao
      * Retorno alinhado a SQLCODE DB2 (+000, +100, +803)
      ******************************************************************
       01  STFSOCIO-LINKAGE.
           05  WS-ACAO                         PIC X(01).
               88  WS-ACAO-CONSULTA            VALUE 'C'.
               88  WS-ACAO-INCLUSAO            VALUE 'I'.
               88  WS-ACAO-ALTERACAO           VALUE 'A'.
               88  WS-ACAO-EXCLUSAO            VALUE 'E'.
           05  WS-RETORNO-CODIGO               PIC S9(04) COMP.
               88  WS-RET-OK                   VALUE +0.
               88  WS-RET-NAO-LOCALIZADO       VALUE +100.
               88  WS-RET-CHAVE-DUPLICADA      VALUE +803.
           05  NUMB-SOCIO-PRINCIPAL            PIC 9(09).
           05  NOME-SOCIO-PRINCIPAL            PIC X(40).
           05  DATA-CADASTRO                   PIC X(10).
           05  C-PERIODICO-PAGAMENTO           PIC 9(02).
           05  PERIODICO-PAGAMENTO.
               10  DATA-VENCIMENTO             OCCURS 12
                                               PIC X(10).
               10  VALR-MENSALIDADE            OCCURS 12
                                               PIC S9(06)V9(02)
                                               COMP-3.
               10  PAGAMENTO-OK                OCCURS 12
                                               PIC X(01).
           05  CATG-SOCIO                      PIC 9(02).
           05  INDI-DIVIDA                     PIC X(01).
           05  DATA-BAIXA                      PIC X(10).
           05  HORA-BAIXA                      PIC X(08).
           05  OBSV-SOCIO                      PIC X(500).
