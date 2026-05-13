      ******************************************************************
      * STFSC00 - Sócio / DB2 commarea (Natural LDA paired layout).
      * RETURN-CODE: 00=found (consult) or insert OK; 01=not found;
      *              02=duplicate RG on insert; 99=technical error.
      ******************************************************************
       01  STFSC00-PARM.
           05 STFSC00-RETURN-CODE          PIC XX.
           05 STFSC00-NUMB-SOCIO-PRINCIPAL PIC 9(09).
           05 STFSC00-NOME-SOCIO-PRINCIPAL PIC X(40).
           05 STFSC00-DATA-CADASTRO        PIC X(10).
           05 STFSC00-CATG-SOCIO           PIC S9(4) COMP.
           05 STFSC00-INDI-DIVIDA         PIC S9(4) COMP.
           05 STFSC00-DATA-BAIXA          PIC X(10).
           05 STFSC00-HORA-BAIXA           PIC X(12).
           05 STFSC00-OBSV-CLIENTE         PIC X(500).
           05 STFSC00-SUPER1              PIC X(80).
           05 STFSC00-PERIODICO OCCURS 12.
              10 STFSC00-DATA-VENCIMENTO   PIC X(10).
              10 STFSC00-VALR-MENSALIDADE  PIC S9(5)V9(2) COMP-3.
              10 STFSC00-PAGAMENTO-OK     PIC X(01).
