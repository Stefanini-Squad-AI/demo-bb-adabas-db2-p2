      * STFSCK00.CPY - COBOL Copybook for SOCIOS Entity
      * Migration: ADABAS to DB2 via COBOL intermediary
      * Contains entity book and communication book structures
      *
      * Entity Book: Main SOCIOS table fields
       01 WS-SOCIOS-BOOK.
          05 NUMB-SOCIO-PRINCIPAL    PIC 9(9) COMP.
          05 NOME-SOCIO-PRINCIPAL    PIC X(40).
          05 DATA-CADASTRO           PIC X(10).
          05 CATG-SOCIO              PIC S9(4) COMP.
          05 INDI-DIVIDA             PIC S9(4) COMP VALUE 0.
          05 DATA-BAIXA              PIC X(10).
          05 HORA-BAIXA              PIC X(12).
          05 OBSV-SOCIO              PIC X(500).
      *
      * Payment Book: Array of 12 payment records (PERIODICO-PAGAMENTO)
       01 WS-SOCIOS-PAGAMENTO-BOOK.
          05 PAGAMENTO-REC OCCURS 12 TIMES.
             10 DATA-VENCIMENTO      PIC X(10).
             10 VALR-MENSALIDADE     PIC S9(4)V99 COMP-3.
             10 PAGAMENTO-OK         PIC X(1).
      *
      * Communication Book: Operation and control fields
       01 WS-COMM-BOOK.
          05 OPERATION-CODE          PIC X VALUE SPACE.
             88 OPER-CONSULTA        VALUE 'C'.
             88 OPER-INCLUSAO        VALUE 'I'.
             88 OPER-ALTERACAO       VALUE 'A'.
             88 OPER-EXCLUSAO        VALUE 'E'.
          05 RETURN-CODE             PIC 9(2) COMP VALUE 0.
             88 RC-SUCCESS           VALUE 0.
             88 RC-NOT-FOUND         VALUE 1.
             88 RC-DB-ERROR          VALUE 2.
          05 ERROR-MESSAGE           PIC X(255).
          05 RECORD-COUNT            PIC 9(4) COMP VALUE 0.
