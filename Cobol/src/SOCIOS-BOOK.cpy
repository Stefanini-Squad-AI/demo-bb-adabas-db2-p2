      ******************************************************************
      * SOCIOS-BOOK — área de comunicação Natural ↔ COBOL (DB2)
      * Um único nível 01; hierarquia principal + ocorrências periódicas
      * Datas trafegam como AAAAMMDD (A8) no lado Natural/BOOK.
      ******************************************************************
       01  SOCIO-BOOK.
           05  SOCIO-RETURN-CODE           PIC S9(09) COMP-5.
           05  SOCIO-SQLCODE-DISP          PIC S9(09) COMP-5.
           05  SOCIO-NUMB-PRINCIPAL        PIC S9(09) COMP-5.
           05  SOCIO-NOME-PRINCIPAL        PIC X(40).
           05  SOCIO-DATA-CADASTRO         PIC X(08).
           05  SOCIO-CATG                  PIC S9(04) COMP-5.
           05  SOCIO-INDI-DIVIDA           PIC S9(04) COMP-5.
           05  SOCIO-DATA-BAIXA            PIC X(08).
           05  SOCIO-HORA-BAIXA            PIC X(12).
           05  SOCIO-OBSV                  PIC X(500).
           05  SOCIO-PERIODICO-CNT-IN      PIC S9(04) COMP-5.
           05  SOCIO-PERIODICO-CNT-OUT     PIC S9(04) COMP-5.
           05  SOCIO-PERIODICO             OCCURS 12 TIMES.
               10  SOCIO-PER-DATA-VENC     PIC X(08).
               10  SOCIO-PER-VALR          PIC S9(09)V9(02) COMP-3.
               10  SOCIO-PER-PAGO-OK       PIC X(01).
