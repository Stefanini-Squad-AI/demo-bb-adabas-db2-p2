      * ================================================================
      * COPYBOOK: STFSC00B
      * Purpose: Communication area between Natural and COBOL programs
      * Description: Data structures for SOCIO entity operations
      * Migration: Adabas ADABAS-SOCIOS to DB2 (SOCIO, SOCIO_PAGAMENTO)
      * ================================================================

       01 STFSC00-COMM-AREA.
      * ================================================================
      * Control Fields
      * ================================================================
           05 STFSC00-OPERATION           PIC X(1).
              88 STFSC00-OP-CONSULT        VALUE 'C'.
              88 STFSC00-OP-INSERT         VALUE 'I'.
              88 STFSC00-OP-UPDATE         VALUE 'A'.
              88 STFSC00-OP-DELETE         VALUE 'E'.

           05 STFSC00-RETURN-CODE        PIC S9(3) COMP VALUE 000.
              88 STFSC00-RC-SUCCESS        VALUE 000.
              88 STFSC00-RC-NOT-FOUND      VALUE 100.
              88 STFSC00-RC-DUP-KEY        VALUE 803.
              88 STFSC00-RC-ERROR          VALUE 999.

      * ================================================================
      * SOCIO Main Record Fields
      * ================================================================
           05 STFSC00-SOCIO.
              10 STFSC00-NUMB-SOCIO-PRINCIPAL   PIC 9(9) COMP.
              10 STFSC00-NOME-SOCIO-PRINCIPAL   PIC X(40).
              10 STFSC00-DATA-CADASTRO          PIC 9(8).
              10 STFSC00-CATG-SOCIO             PIC S9(4) COMP.
              10 STFSC00-INDI-DIVIDA            PIC X(1).
              10 STFSC00-DATA-BAIXA             PIC 9(8).
              10 STFSC00-HORA-BAIXA             PIC X(5).
              10 STFSC00-OBSV-SOCIO             PIC X(500).

      * ================================================================
      * SOCIO_PAGAMENTO Array (Periodic Payments - PE normalization)
      * Max 12 occurrences per month in a year
      * ================================================================
           05 STFSC00-PAGAMENTOS.
              10 STFSC00-PAGAMENTO OCCURS 12 TIMES.
                 15 STFSC00-SEQ-PAGAMENTO       PIC S9(4) COMP.
                 15 STFSC00-DATA-VENCIMENTO     PIC 9(8).
                 15 STFSC00-VALR-MENSALIDADE    PIC 9(6)V99 COMP.
                 15 STFSC00-PAGAMENTO-OK        PIC X(1).

      * ================================================================
      * Additional Processing Fields
      * ================================================================
           05 STFSC00-NUM-REGISTROS      PIC S9(4) COMP VALUE 0.
