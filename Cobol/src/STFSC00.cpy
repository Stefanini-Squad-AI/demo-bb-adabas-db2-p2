      ******************************************************************
      * Book de comunicação Natural x COBOL - ADABAS-SOCIOS / DB2
      * Operações: I Inclusão | A Alteração | E Exclusão | C Consulta
      * Return code: +000 localizado | +100 não localizado | +803 duplicado
      ******************************************************************
       01  STFSC00-AREA.
           05  STFSC00-OPERACAO           PIC X(01).
               88  STFSC00-OP-INCLUI      VALUE 'I'.
               88  STFSC00-OP-ALTERA      VALUE 'A'.
               88  STFSC00-OP-EXCLUI      VALUE 'E'.
               88  STFSC00-OP-CONSULTA   VALUE 'C'.
           05  STFSC00-RETURN-CODE       PIC S9(04) COMP.
               88  STFSC00-RC-OK          VALUE +000.
               88  STFSC00-RC-NAO-ACHOU   VALUE +100.
               88  STFSC00-RC-DUPKEY      VALUE +803.
           05  STFSC00-NUMB-SOCIO-PRINCIPAL
                                       PIC S9(09) COMP.
           05  STFSC00-NOME-SOCIO-PRINCIPAL
                                       PIC X(40).
           05  STFSC00-DATA-CADASTRO     PIC X(10).
           05  STFSC00-C-PERIODICO-PAGAMENTO
                                       PIC S9(04) COMP.
           05  STFSC00-PERIODICO-PAGAMENTO
                                       OCCURS 12 TIMES
                                       INDEXED BY STFSC00-IX-PE.
               10  STFSC00-DATA-VENCIMENTO
                                       PIC X(10).
               10  STFSC00-VALR-MENSALIDADE
                                       PIC S9(06)V9(02) COMP-3.
               10  STFSC00-PAGAMENTO-OK  PIC X(01).
                   88  STFSC00-PE-PAGO   VALUE 'Y' '1'.
                   88  STFSC00-PE-NAO-PAGO
                                       VALUE 'N' '0' ' '.
           05  STFSC00-CATG-SOCIO        PIC S9(04) COMP.
           05  STFSC00-INDI-DIVIDA       PIC X(01).
               88  STFSC00-DIVIDA-SIM   VALUE 'Y' '1'.
               88  STFSC00-DIVIDA-NAO   VALUE 'N' '0' ' '.
           05  STFSC00-DATA-BAIXA        PIC X(10).
           05  STFSC00-HORA-BAIXA        PIC X(05).
           05  STFSC00-OBSV-SOCIO        PIC X(500).
