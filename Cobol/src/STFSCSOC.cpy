      ******************************************************************
      * STFSCSOC - Book de comunicacao Natural x COBOL (ADABAS-SOCIOS)
      * Operacoes: C=Consulta I=Inclusao A=Alteracao E=Exclusao
      * STFSCSOC-SQLCODE: +000 localizado/sucesso, +100 nao localizado,
      *                   +803 chave duplicada, demais tratamento generico
      * Datas: YYYY-MM-DD (10) | Hora: HH:MM (5)
      ******************************************************************
       01  STFSCSOC-AREA.
           05  STFSCSOC-ACAO                PIC  X(01).
           05  STFSCSOC-SQLCODE             PIC  S9(04) COMP-3.
           05  NUMB-SOCIO-PRINCIPAL         PIC  9(09).
           05  NOME-SOCIO-PRINCIPAL         PIC  X(40).
           05  DATA-CADASTRO                PIC  X(10).
           05  C-PERIODICO-PAGAMENTO        PIC  9(03).
           05  PERIODICO-PAGAMENTO OCCURS 12 TIMES
                                       INDEXED BY STFSCSOC-IDX-PE.
               10  DATA-VENCIMENTO          PIC  X(10).
               10  VALR-MENSALIDADE          PIC  S9(06)V9(02)
                                                   COMP-3.
               10  PAGAMENTO-OK              PIC  X(01).
           05  CATG-SOCIO                   PIC  9(02).
           05  INDI-DIVIDA                  PIC  X(01).
           05  DATA-BAIXA                   PIC  X(10).
           05  HORA-BAIXA                   PIC  X(05).
           05  OBSV-SOCIO                   PIC  X(500).
