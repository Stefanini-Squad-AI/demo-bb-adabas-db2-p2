      ******************************************************************
      * BOOK COMUNICACAO NATURAL x COBOL - ENTIDADE SOCIO (STFSC00)   *
      * RETURN CODES DB2:                                               *
      *   +000 = Registro localizado / operacao OK                      *
      *   +100 = Registro nao localizado                                *
      *   +803 = Erro insert: chave duplicada (SQLCODE -803)          *
      *   Outros = Tratamento generico de erro                          *
      ******************************************************************
       01  STFBKSC00-COMUNICACAO.
           05  STFBKSC00-ACAO              PIC X(01).
               88 STFBKSC00-CONSULTA       VALUE 'C'.
               88 STFBKSC00-INCLUSAO       VALUE 'I'.
               88 STFBKSC00-ALTERACAO      VALUE 'A'.
               88 STFBKSC00-EXCLUSAO       VALUE 'E'.
           05  STFBKSC00-RETORNO           PIC S9(09) COMP.
               88 STFBKSC00-OK             VALUE +0.
               88 STFBKSC00-NAO-LOCALIZADO VALUE +100.
               88 STFBKSC00-CHAVE-DUP      VALUE +803.
           05  STFBKSC00-NUMB-SOCIO-PRINCIPAL
                                       PIC 9(09).
           05  STFBKSC00-NOME-SOCIO-PRINCIPAL
                                       PIC X(40).
           05  STFBKSC00-DATA-CADASTRO     PIC X(10).
           05  STFBKSC00-CATG-SOCIO        PIC 9(02).
           05  STFBKSC00-INDI-DIVIDA       PIC X(01).
           05  STFBKSC00-DATA-BAIXA        PIC X(10).
           05  STFBKSC00-HORA-BAIXA        PIC X(12).
           05  STFBKSC00-OBSV-SOCIO        PIC X(500).
           05  STFBKSC00-QTD-PERIODICO     PIC 9(02).
           05  STFBKSC00-SEQ-PERIODICO     OCCURS 12 TIMES
                                       INDEXED BY STFBKSC00-IDX-PER
                                       PIC 9(02).
           05  STFBKSC00-DATA-VENCIMENTO   OCCURS 12 TIMES
                                       PIC X(10).
           05  STFBKSC00-VALR-MENSALIDADE   OCCURS 12 TIMES
                                       PIC S9(06)V9(02) COMP-3.
           05  STFBKSC00-PAGAMENTO-OK      OCCURS 12 TIMES
                                       PIC X(01).
