      ******************************************************************
      * STFSC00B - Book de comunicação Natural x COBOL (DBATDP-18)
      * Operações: I Inclusão | A Alteração | E Exclusão | C Consulta
      * Return codes: +000 localizado/sucesso | +100 não localizado
      *               +803 chave duplicada | demais erros genéricos
      ******************************************************************
       01  STFSC00-AREA.
           05  STFSC00-OPERACAO          PIC X(01).
               88  STFSC00-OP-INCLUSAO   VALUE 'I'.
               88  STFSC00-OP-ALTERACAO  VALUE 'A'.
               88  STFSC00-OP-EXCLUSAO   VALUE 'E'.
               88  STFSC00-OP-CONSULTA   VALUE 'C'.
           05  STFSC00-RETURN-CODE       PIC S9(04) COMP-3.
               88  STFSC00-RC-OK         VALUE +0.
               88  STFSC00-RC-NOTFOUND   VALUE +100.
               88  STFSC00-RC-DUPKEY     VALUE +803.
           05  STFSC00-NUMB-SOCIO-PRINCIPAL
                                       PIC S9(09) COMP-3.
           05  STFSC00-NOME-SOCIO-PRINCIPAL
                                       PIC X(40).
           05  STFSC00-DATA-CADASTRO     PIC X(10).
           05  STFSC00-COUNT-PERIODICO   PIC S9(04) COMP-3.
           05  STFSC00-PERIODICO-PAGAMENTO
                                       OCCURS 12 TIMES
                                       INDEXED BY STFSC00-IDX-PE.
               10  STFSC00-DATA-VENCIMENTO
                                       PIC X(10).
               10  STFSC00-VALR-MENSALIDADE
                                       PIC S9(06)V9(02) COMP-3.
               10  STFSC00-PAGAMENTO-OK  PIC X(01).
                   88  STFSC00-PGTO-SIM  VALUE 'Y' '1' 'S'.
                   88  STFSC00-PGTO-NAO  VALUE 'N' '0' ' '.
           05  STFSC00-CATG-SOCIO        PIC S9(04) COMP-3.
           05  STFSC00-INDI-DIVIDA       PIC X(01).
               88  STFSC00-DIVIDA-SIM    VALUE 'Y' '1' 'S'.
               88  STFSC00-DIVIDA-NAO    VALUE 'N' '0' ' '.
           05  STFSC00-DATA-BAIXA        PIC X(10).
           05  STFSC00-HORA-BAIXA        PIC X(12).
           05  STFSC00-OBSV-SOCIO        PIC X(500).
