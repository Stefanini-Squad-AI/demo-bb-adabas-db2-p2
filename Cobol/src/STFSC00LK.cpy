      ******************************************************************
      * BOOK DE COMUNICACAO NATURAL x COBOL - ENTIDADE SOCIO (DB2)    *
      * DBATDP-14 - Layout equivalente a LDA Natural STFSC00LDA         *
      ******************************************************************
       01  STFSC00-LINKAGE.
           05  STFSC00-NUMB-SOCIO-PRINCIPAL   PIC 9(09).
           05  STFSC00-NOME-SOCIO-PRINCIPAL    PIC X(40).
           05  STFSC00-DATA-CADASTRO           PIC X(10).
           05  STFSC00-C-PERIODICO-PAGAMENTO   PIC 9(02).
           05  STFSC00-PERIODICO-PAGAMENTO OCCURS 12 TIMES
                                       INDEXED BY STFSC00-IDX-PAG.
               10  STFSC00-DATA-VENCIMENTO   PIC X(10).
               10  STFSC00-VALR-MENSALIDADE  PIC S9(06)V9(02)
                                                   COMP-3.
               10  STFSC00-PAGAMENTO-OK      PIC X(01).
           05  STFSC00-CATG-SOCIO            PIC 9(02).
           05  STFSC00-INDI-DIVIDA           PIC X(01).
           05  STFSC00-DATA-BAIXA            PIC X(10).
           05  STFSC00-HORA-BAIXA            PIC X(05).
           05  STFSC00-OBSV-SOCIO            PIC X(500).
           05  STFSC00-RETURN-CODE           PIC S9(04).
