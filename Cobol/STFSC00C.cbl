       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      * Constants
           05 WS-CONST-MAX-PAGAMENTOS   PIC S9(4) COMP VALUE 12.
           05 WS-CONST-ZERO             PIC S9(4) COMP VALUE 0.
           05 WS-CONST-ONE              PIC S9(4) COMP VALUE 1.

      * Cursor declaration for SOCIO_PAGAMENTO
           EXEC SQL
               DECLARE CSR-SOCIO-PAG CURSOR FOR
                   SELECT SEQ_PAGAMENTO,
                          DATA_VENCIMENTO,
                          VALR_MENSALIDADE,
                          PAGAMENTO_OK
                     FROM SOCIO_PAGAMENTO
                    WHERE NUMB_SOCIO_PRINCIPAL = :WS-NUMB-SOCIO
                    ORDER BY SEQ_PAGAMENTO
           END-EXEC.

       LINKAGE SECTION.
      * Communication parameters from Natural/CALLNAT
           05 LS-OPERATION               PIC X(1).
           05 LS-RETURN-CODE             PIC S9(3) COMP.
           05 LS-SOCIO.
              10 LS-NUMB-SOCIO-PRINCIPAL   PIC 9(9) COMP.
              10 LS-NOME-SOCIO-PRINCIPAL   PIC X(40).
              10 LS-DATA-CADASTRO          PIC 9(8).
              10 LS-CATG-SOCIO             PIC S9(4) COMP.
              10 LS-INDI-DIVIDA            PIC X(1).
              10 LS-DATA-BAIXA             PIC 9(8).
              10 LS-HORA-BAIXA             PIC X(5).
              10 LS-OBSV-SOCIO             PIC X(500).
           05 LS-PAGAMENTOS.
              10 LS-PAGAMENTO OCCURS 12 TIMES.
                 15 LS-SEQ-PAGAMENTO       PIC S9(4) COMP.
                 15 LS-DATA-VENCIMENTO     PIC 9(8).
                 15 LS-VALR-MENSALIDADE    PIC 9(6)V99 COMP.
                 15 LS-PAGAMENTO-OK        PIC X(1).
           05 LS-NUM-REGISTROS            PIC S9(4) COMP.

       LOCAL-STORAGE SECTION.
       * SQLCA for DB2 error handling
           EXEC SQL INCLUDE SQLCA END-EXEC.

      * Host variables for SOCIO table
           05 WS-NUMB-SOCIO              PIC 9(9) COMP.
           05 WS-NOME-SOCIO              PIC X(40).
           05 WS-DATA-CAD                PIC X(10).
           05 WS-CATG                    PIC S9(4) COMP.
           05 WS-INDI-DIV                PIC X(1).
           05 WS-DATA-BAIXA              PIC X(10).
           05 WS-HORA-BAIXA              PIC X(5).
           05 WS-OBSV                    PIC X(500).

      * Host variables for SOCIO_PAGAMENTO
           05 WS-SEQ-PAG                 PIC S9(4) COMP.
           05 WS-DATA-VENC               PIC X(10).
           05 WS-VALR-MENS               PIC S9(6)V99 COMP.
           05 WS-PAG-OK                  PIC X(1).

      * Processing variables
           05 WS-INDICE                  PIC S9(4) COMP VALUE 0.
           05 WS-FETCH-STATUS            PIC S9(4) COMP VALUE 0.

       PROCEDURE DIVISION USING LS-OPERATION LS-RETURN-CODE
                                 LS-SOCIO LS-PAGAMENTOS
                                 LS-NUM-REGISTROS.

           PERFORM INICIALIZA.
           PERFORM PROCESSA.
           PERFORM FINALIZA.

           GOBACK.

       INICIALIZA.
      * Initialize return code to success
           MOVE 000 TO LS-RETURN-CODE.
           MOVE 0 TO LS-NUM-REGISTROS.
           MOVE 0 TO WS-INDICE.

      * Clear SOCIO data fields in communication area
           INITIALIZE LS-SOCIO.
           INITIALIZE LS-PAGAMENTOS.

      * Get input parameter
           MOVE LS-NUMB-SOCIO-PRINCIPAL
               TO WS-NUMB-SOCIO.

       PROCESSA.
      * Query SOCIO table
           EXEC SQL
               SELECT NUMB_SOCIO_PRINCIPAL,
                      NOME_SOCIO_PRINCIPAL,
                      DATA_CADASTRO,
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      DATA_BAIXA,
                      HORA_BAIXA,
                      OBSV_SOCIO
                 INTO :WS-NUMB-SOCIO,
                      :WS-NOME-SOCIO,
                      :WS-DATA-CAD,
                      :WS-CATG,
                      :WS-INDI-DIV,
                      :WS-DATA-BAIXA,
                      :WS-HORA-BAIXA,
                      :WS-OBSV
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :WS-NUMB-SOCIO
           END-EXEC.

           EVALUATE SQLCODE
               WHEN 0
      * Record found - populate output and fetch payments
                   MOVE WS-NUMB-SOCIO
                       TO LS-NUMB-SOCIO-PRINCIPAL.
                   MOVE WS-NOME-SOCIO
                       TO LS-NOME-SOCIO-PRINCIPAL.
                   MOVE WS-DATA-CAD
                       TO LS-DATA-CADASTRO.
                   MOVE WS-CATG
                       TO LS-CATG-SOCIO.
                   MOVE WS-INDI-DIV
                       TO LS-INDI-DIVIDA.
                   MOVE WS-DATA-BAIXA
                       TO LS-DATA-BAIXA.
                   MOVE WS-HORA-BAIXA
                       TO LS-HORA-BAIXA.
                   MOVE WS-OBSV
                       TO LS-OBSV-SOCIO.

                   PERFORM CARREGA-SOCIO-PAG-CURSOR
               WHEN 100
      * Record not found
                   MOVE 100 TO LS-RETURN-CODE
               WHEN OTHER
      * Database error
                   MOVE 999 TO LS-RETURN-CODE
           END-EVALUATE.

       CARREGA-SOCIO-PAG-CURSOR.
           MOVE 0 TO WS-INDICE.

           EXEC SQL OPEN CSR-SOCIO-PAG END-EXEC.

           PERFORM UNTIL WS-INDICE >= WS-CONST-MAX-PAGAMENTOS
               EXEC SQL
                   FETCH CSR-SOCIO-PAG
                       INTO :WS-SEQ-PAG,
                            :WS-DATA-VENC,
                            :WS-VALR-MENS,
                            :WS-PAG-OK
               END-EXEC

               EVALUATE SQLCODE
                   WHEN 0
                       ADD 1 TO WS-INDICE
                       MOVE WS-SEQ-PAG
                           TO LS-SEQ-PAGAMENTO(WS-INDICE)
                       MOVE WS-DATA-VENC
                           TO LS-DATA-VENCIMENTO(WS-INDICE)
                       MOVE WS-VALR-MENS
                           TO LS-VALR-MENSALIDADE(WS-INDICE)
                       MOVE WS-PAG-OK
                           TO LS-PAGAMENTO-OK(WS-INDICE)
                   WHEN 100
      * End of cursor
                       EXIT PERFORM
                   WHEN OTHER
      * Error in fetch
                       MOVE 999 TO LS-RETURN-CODE
                       EXIT PERFORM
               END-EVALUATE
           END-PERFORM.

           EXEC SQL CLOSE CSR-SOCIO-PAG END-EXEC.

           MOVE WS-INDICE TO LS-NUM-REGISTROS.

       FINALIZA.
      * No additional cleanup needed for query operation
           CONTINUE.
