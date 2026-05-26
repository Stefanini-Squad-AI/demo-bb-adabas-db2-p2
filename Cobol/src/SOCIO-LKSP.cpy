      *> COPYBOOK: SOCIO-LKSP
      *> Purpose: Communication book between Natural and COBOL
      *> Used for: I (Inclusion), C (Consultation) operations
      *> Equivalent to ADABAS-SOCIOS structure for DB2 access
      *> ================================================================
       01  SOCIO-LKSP.
           05  SO-NUMB-SOCIO-PRINCIPAL    PIC 9(9) COMP VALUE 0.
           05  SO-NOME-SOCIO-PRINCIPAL    PIC X(40) VALUE SPACES.
           05  SO-DATA-CADASTRO           PIC X(10) VALUE SPACES.
           05  SO-CATG-SOCIO              PIC S9(4) COMP VALUE 0.
           05  SO-INDI-DIVIDA             PIC X(1) VALUE '0'.
           05  SO-DATA-BAIXA              PIC X(10) VALUE SPACES.
           05  SO-HORA-BAIXA              PIC X(8) VALUE SPACES.
           05  SO-OBSV-SOCIO              PIC X(500) VALUE SPACES.
           05  SO-PERIODICO-PAGAMENTO OCCURS 12 TIMES.
               10  SO-DATA-VENCIMENTO     PIC X(10) VALUE SPACES.
               10  SO-VALR-MENSALIDADE    PIC S9(4)V9(2) COMP-3.
               10  SO-PAGAMENTO-OK        PIC X(1) VALUE '0'.
           05  SO-RETURN-CODE             PIC S9(4) COMP VALUE 0.
           05  SO-MSG-ERROR               PIC X(100) VALUE SPACES.
