      ******************************************************************
      * STFSC00 - Book de comunicacao Natural x COBOL (DB2 SOCIOS)   *
      * Nivel 01 unico - operacoes C/I/A/E e return code DB2           *
      ******************************************************************
       01  STFSC00-AREA.
           05  STFSC00-ACAO              PIC X(01).
               88  STFSC00-ACAO-CONSULTA  VALUE 'C'.
               88  STFSC00-ACAO-INCLUSAO  VALUE 'I'.
               88  STFSC00-ACAO-ALTERACAO VALUE 'A'.
               88  STFSC00-ACAO-EXCLUSAO VALUE 'E'.
           05  STFSC00-RETURN-CODE       PIC S9(04)
                                       SIGN IS LEADING SEPARATE.
               88  STFSC00-RC-OK         VALUE +000.
               88  STFSC00-RC-NOTFOUND   VALUE +100.
               88  STFSC00-RC-DUPKEY     VALUE +803.
           05  STFSC00-NUMB-SOCIO-PRINCIPAL
                                       PIC S9(09)V9(00) COMP-3.
           05  STFSC00-NOME-SOCIO-PRINCIPAL
                                       PIC X(40).
           05  STFSC00-DATA-CADASTRO     PIC X(10).
           05  STFSC00-CATG-SOCIO       PIC S9(04) COMP.
           05  STFSC00-INDI-DIVIDA      PIC X(01).
               88  STFSC00-INDI-DIVIDA-SIM VALUE 'Y'.
               88  STFSC00-INDI-DIVIDA-NAO VALUE 'N'.
           05  STFSC00-DATA-BAIXA       PIC X(10).
           05  STFSC00-HORA-BAIXA       PIC X(05).
           05  STFSC00-OBSV-SOCIO       PIC X(500).
           05  STFSC00-C-PERIODICO-PAGAMENTO
                                       PIC S9(04) COMP.
           05  STFSC00-PERIODICO-PAGAMENTO
                                       OCCURS 12 TIMES
                                       INDEXED BY STFSC00-IX-PE.
               10  STFSC00-DATA-VENCIMENTO
                                       PIC X(10).
               10  STFSC00-VALR-MENSALIDADE
                                       PIC S9(06)V9(02) COMP-3.
               10  STFSC00-PAGAMENTO-OK PIC X(01).
                   88  STFSC00-PAG-OK   VALUE 'Y'.
                   88  STFSC00-PAG-NAO  VALUE 'N'.
