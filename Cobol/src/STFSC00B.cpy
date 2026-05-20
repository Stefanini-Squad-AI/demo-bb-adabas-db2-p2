      ******************************************************************
      * COPYBOOK STFSC00B - Comunicacao Natural x Cobol / DB2
      * Entidade SOCIO (ADABAS-SOCIOS-P2)
      * Operacoes: C=Consulta I=Inclusao A=Alteracao E=Exclusao
      * Return codes DB2: +000 localizado +100 nao localizado
      *                     +803 chave duplicada (insert)
      ******************************************************************
       01  STFSC00-AREA.
           05  STFSC00-SQLCODE              PIC S9(9) COMP.
           05  STFSC00-OPERACAO             PIC X(01).
           05  STFSC00-NUMB-SOCIO-PRINCIPAL PIC 9(09).
           05  STFSC00-NOME-SOCIO-PRINCIPAL PIC X(40).
           05  STFSC00-DATA-CADASTRO        PIC X(10).
           05  STFSC00-C-PERIODICO-PAGAMENTO PIC 9(03).
           05  STFSC00-PERIODICO-PAGAMENTO OCCURS 12 TIMES
                                       INDEXED BY STFSC00-IDX-PER.
               10  STFSC00-DATA-VENCIMENTO PIC X(10).
               10  STFSC00-VALR-MENSALIDADE PIC S9(4)V99 COMP-3.
               10  STFSC00-PAGAMENTO-OK    PIC X(01).
           05  STFSC00-CATG-SOCIO          PIC 9(02).
           05  STFSC00-INDI-DIVIDA         PIC X(01).
           05  STFSC00-DATA-BAIXA          PIC X(10).
           05  STFSC00-HORA-BAIXA          PIC X(05).
           05  STFSC00-OBSV-CLIENTE        PIC X(500).
