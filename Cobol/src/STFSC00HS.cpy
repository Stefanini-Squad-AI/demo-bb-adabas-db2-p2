      ******************************************************************
      * HOST VARIABLES DB2 - SOCIO / SOCIO_PAGAMENTO                    *
      ******************************************************************
       01  STFSC00-HOST-VARS.
           05  HV-NUMB-SOCIO-PRINCIPAL   PIC S9(09)V9(00) COMP-3.
           05  HV-NOME-SOCIO-PRINCIPAL   PIC X(40).
           05  HV-DATA-CADASTRO          PIC X(10).
           05  HV-CATG-SOCIO             PIC S9(04) COMP.
           05  HV-INDI-DIVIDA            PIC X(01).
           05  HV-DATA-BAIXA             PIC X(10).
           05  HV-HORA-BAIXA             PIC X(05).
           05  HV-OBSV-SOCIO             PIC X(500).
           05  HV-SEQ-PAGAMENTO          PIC S9(04) COMP.
           05  HV-DATA-VENCIMENTO        PIC X(10).
           05  HV-VALR-MENSALIDADE       PIC S9(06)V9(02) COMP-3.
           05  HV-PAGAMENTO-OK           PIC X(01).
           05  HV-NUL-DATA-BAIXA         PIC S9(04) COMP.
           05  HV-NUL-HORA-BAIXA         PIC S9(04) COMP.
           05  HV-NUL-OBSV-SOCIO         PIC S9(04) COMP.
