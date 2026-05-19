      ******************************************************************
      * BOOK COMUNICACAO NATURAL x COBOL - SOCIO / DB2                 *
      * Acoes: C=Consulta I=Inclusao A=Alteracao E=Exclusao            *
      * SQLCODE: +000 localizado +100 nao localizado +803 duplicado    *
      ******************************************************************
       01  STFSC00-AREA-COMUNICACAO.
           05  STFSC00-ACAO           PIC X(01).
               88  STFSC00-ACAO-CONSULTA   VALUE 'C'.
               88  STFSC00-ACAO-INCLUSAO   VALUE 'I'.
               88  STFSC00-ACAO-ALTERACAO  VALUE 'A'.
               88  STFSC00-ACAO-EXCLUSAO   VALUE 'E'.
           05  STFSC00-SQLCODE        PIC S9(09).
           05  STFSC00-DADOS          PIC X(8000).
           05  STFSC00-REGISTRO REDEFINES STFSC00-DADOS.
               10  STFSC00-NUMB-SOCIO-PRINCIPAL
                                       PIC 9(09).
               10  STFSC00-NOME-SOCIO-PRINCIPAL
                                       PIC X(40).
               10  STFSC00-DATA-CADASTRO
                                       PIC X(10).
               10  STFSC00-CATG-SOCIO PIC 9(02).
               10  STFSC00-INDI-DIVIDA PIC X(01).
               10  STFSC00-DATA-BAIXA PIC X(10).
               10  STFSC00-HORA-BAIXA PIC X(05).
               10  STFSC00-OBSV-SOCIO PIC X(500).
               10  STFSC00-QTD-PERIODICO
                                       PIC 9(03).
               10  STFSC00-PERIODICO
                                       OCCURS 999 TIMES
                                       INDEXED BY STFSC00-IDX-PER.
                   15  STFSC00-SEQ-OCORRENCIA
                                       PIC 9(03).
                   15  STFSC00-DATA-VENCIMENTO
                                       PIC X(10).
                   15  STFSC00-VALR-MENSALIDADE
                                       PIC S9(06)V9(02)
                                       COMP-3.
                   15  STFSC00-PAGAMENTO-OK
                                       PIC X(01).
