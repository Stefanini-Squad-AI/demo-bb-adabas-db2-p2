      ******************************************************************
      * BOOK ENTIDADE SOCIO - HOST VARIABLES DB2                        *
      ******************************************************************
       01  STFBKSOC-ENTIDADE.
           05  HSOC-NUMB-SOCIO-PRINCIPAL   PIC S9(09)V9(00) COMP-3.
           05  HSOC-NOME-SOCIO-PRINCIPAL   PIC X(40).
           05  HSOC-DATA-CADASTRO          PIC X(10).
           05  HSOC-CATG-SOCIO             PIC S9(04) COMP.
           05  HSOC-INDI-DIVIDA            PIC X(01).
           05  HSOC-DATA-BAIXA             PIC X(10).
           05  HSOC-HORA-BAIXA             PIC X(12).
           05  HSOC-OBSV-SOCIO             PIC X(500).
           05  HPER-SEQ-PERIODICO          PIC S9(04) COMP.
           05  HPER-DATA-VENCIMENTO        PIC X(10).
           05  HPER-VALR-MENSALIDADE       PIC S9(06)V9(02) COMP-3.
           05  HPER-PAGAMENTO-OK           PIC X(01).
           05  HPER-NUMB-SOCIO-PRINCIPAL   PIC S9(09)V9(00) COMP-3.
           05  IND-HSOC-NUMB               PIC S9(04) COMP.
           05  IND-HSOC-NOME               PIC S9(04) COMP.
           05  IND-HSOC-DATA-CAD           PIC S9(04) COMP.
           05  IND-HSOC-CATG               PIC S9(04) COMP.
           05  IND-HSOC-INDI-DIV           PIC S9(04) COMP.
           05  IND-HSOC-DATA-BAIXA         PIC S9(04) COMP.
           05  IND-HSOC-HORA-BAIXA         PIC S9(04) COMP.
           05  IND-HSOC-OBSV               PIC S9(04) COMP.
           05  IND-HPER-SEQ                PIC S9(04) COMP.
           05  IND-HPER-DATA-VENC          PIC S9(04) COMP.
           05  IND-HPER-VALR               PIC S9(04) COMP.
           05  IND-HPER-PAG-OK             PIC S9(04) COMP.
