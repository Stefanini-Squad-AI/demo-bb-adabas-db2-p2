      ******************************************************************
      * Copybook STFSSOCIO - Comunicacao Natural x COBOL (entidade SOCIO)
      * Compativel com WORKING-STORAGE, LINKAGE e FILE sections
      * Operacoes: I (inclusao), C (consulta)
      * WS-RETORNO: +000 encontrado, +100 nao encontrado, +803 duplicado
      ******************************************************************
       01  STFSSOCIO-LNK.
           05  WS-RETORNO                    PIC S9(4) COMP.
           05  WS-NUMB-SOCIO-PRINCIPAL       PIC 9(09).
           05  WS-NOME-SOCIO-PRINCIPAL       PIC X(40).
           05  WS-DATA-CADASTRO              PIC X(10).
           05  WS-CATG-SOCIO                 PIC 9(02).
           05  WS-INDI-DIVIDA                PIC X(01).
           05  WS-DATA-BAIXA                 PIC X(10).
           05  WS-HORA-BAIXA                 PIC X(05).
           05  WS-OBSV-SOCIO                 PIC X(500).
           05  WS-QTD-PAGAMENTO              PIC S9(4) COMP.
           05  WS-PERIODICO-PAGAMENTO OCCURS 12 TIMES
                                       INDEXED BY WS-IDX-PAG.
               10  WS-DATA-VENCIMENTO        PIC X(10).
               10  WS-VALR-MENSALIDADE       PIC S9(06)V9(02)
                                               COMP-3.
               10  WS-PAGAMENTO-OK           PIC X(01).
