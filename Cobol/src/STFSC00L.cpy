      ******************************************************************
      * Book de comunicacao Natural x COBOL - entidade SOCIO (ADABAS)  *
      * Operacoes: C=Consulta I=Inclusao A=Alteracao E=Exclusao        *
      * Retorno: +000 localizado +100 nao localizado +803 duplicidade  *
      ******************************************************************
       01  STFSC00L-AREA.
           05  STFSC00L-OPERACAO              PIC X(01).
               88  STFSC00L-OP-CONSULTA         VALUE 'C'.
               88  STFSC00L-OP-INCLUSAO        VALUE 'I'.
               88  STFSC00L-OP-ALTERACAO       VALUE 'A'.
               88  STFSC00L-OP-EXCLUSAO       VALUE 'E'.
           05  STFSC00L-RETORNO               PIC S9(04) COMP.
           05  STFSC00L-NUMB-SOCIO-PRINCIPAL  PIC 9(09).
           05  STFSC00L-NOME-SOCIO-PRINCIPAL  PIC X(40).
           05  STFSC00L-DATA-CADASTRO         PIC X(10).
           05  STFSC00L-CATG-SOCIO            PIC 9(02).
           05  STFSC00L-INDI-DIVIDA           PIC X(01).
           05  STFSC00L-DATA-BAIXA            PIC X(10).
           05  STFSC00L-HORA-BAIXA            PIC X(05).
           05  STFSC00L-OBSV-SOCIO            PIC X(500).
           05  STFSC00L-C-PERIODICO-PAGAMENTO PIC 9(04).
           05  STFSC00L-PERIODICO-PAGAMENTO.
               10  STFSC00L-PER-ITEM OCCURS 12 TIMES
                                       INDEXED BY STFSC00L-IDX-PER.
                   15  STFSC00L-DATA-VENCIMENTO
                                       PIC X(10).
                   15  STFSC00L-VALR-MENSALIDADE
                                       PIC S9(06)V9(02) COMP-3.
                   15  STFSC00L-PAGAMENTO-OK  PIC X(01).
