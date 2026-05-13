      ******************************************************************
      * STFSSCOM - Comunicação sócio (Natural ↔ COBOL) + código retorno
      * DBATDP-1 - espelha hierarquia usada no programa Natural
      ******************************************************************
       01  SOCIO-COMMAREA.
           05  SOCIO-RETURN-CODE          PIC X(02).
               88  SOCIO-RC-OK            VALUE '00'.
               88  SOCIO-RC-NOT-FOUND     VALUE '01'.
               88  SOCIO-RC-DUPLICATE     VALUE '02'.
               88  SOCIO-RC-ERROR         VALUE '99'.
           05  SOCIO-RG                   PIC 9(09).
           05  SOCIO-NOME                 PIC X(40).
           05  SOCIO-DATA-CADASTRO        PIC X(10).
           05  SOCIO-CATG                 PIC 9(02).
           05  SOCIO-INDI-DIVIDA          PIC S9(04) COMP.
           05  SOCIO-DATA-BAIXA           PIC X(10).
           05  SOCIO-HORA-BAIXA           PIC X(12).
           05  SOCIO-OBSV                 PIC X(500).
           05  SOCIO-PAG-TABELA OCCURS 12.
               10  SOCIO-DATA-VENC        PIC X(10).
               10  SOCIO-VALR-MENS        PIC S9(05)V9(02) COMP-3.
               10  SOCIO-PAG-OK           PIC X(01).
