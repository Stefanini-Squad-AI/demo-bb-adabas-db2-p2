       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      * Constants
           05 WS-CONST-MAX-PAGAMENTOS   PIC S9(4) COMP VALUE 12.
           05 WS-CONST-ZERO             PIC S9(4) COMP VALUE 0.
           05 WS-CONST-ONE              PIC S9(4) COMP VALUE 1.
           05 WS-CONST-800              PIC S9(4) COMP VALUE -803.
           05 WS-CONST-803              PIC S9(4) COMP VALUE 803.
           05 WS-CONST-999              PIC S9(4) COMP VALUE 999.

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
           05 WS-NUM-PAGAMENTOS          PIC S9(4) COMP VALUE 0.
           05 WS-INSERT-STATUS           PIC S9(4) COMP VALUE 0.
           05 WS-ROLLBACK-REQUIRED       PIC X(1) VALUE 'N'.

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
           MOVE 'N' TO WS-ROLLBACK-REQUIRED.

      * Get input parameters from communication area
           MOVE LS-NUMB-SOCIO-PRINCIPAL
               TO WS-NUMB-SOCIO.
           MOVE LS-NOME-SOCIO-PRINCIPAL
               TO WS-NOME-SOCIO.
           MOVE LS-DATA-CADASTRO
               TO WS-DATA-CAD.
           MOVE LS-CATG-SOCIO
               TO WS-CATG.
           MOVE LS-INDI-DIVIDA
               TO WS-INDI-DIV.
           MOVE LS-DATA-BAIXA
               TO WS-DATA-BAIXA.
           MOVE LS-HORA-BAIXA
               TO WS-HORA-BAIXA.
           MOVE LS-OBSV-SOCIO
               TO WS-OBSV.
           MOVE LS-NUM-REGISTROS
               TO WS-NUM-PAGAMENTOS.

       PROCESSA.
      * Insert SOCIO record
           EXEC SQL
               INSERT INTO SOCIO
                   (NUMB_SOCIO_PRINCIPAL,
                    NOME_SOCIO_PRINCIPAL,
                    DATA_CADASTRO,
                    CATG_SOCIO,
                    INDI_DIVIDA,
                    DATA_BAIXA,
                    HORA_BAIXA,
                    OBSV_SOCIO)
               VALUES
                   (:WS-NUMB-SOCIO,
                    :WS-NOME-SOCIO,
                    :WS-DATA-CAD,
                    :WS-CATG,
                    :WS-INDI-DIV,
                    :WS-DATA-BAIXA,
                    :WS-HORA-BAIXA,
                    :WS-OBSV)
           END-EXEC.

           EVALUATE SQLCODE
               WHEN 0
      * SOCIO inserted successfully, now insert PAGAMENTOS
                   PERFORM INSERE-SOCIO-PAGAMENTOS
               WHEN -803
      * Duplicate key error
                   MOVE 803 TO LS-RETURN-CODE
               WHEN OTHER
      * Database error
                   MOVE 999 TO LS-RETURN-CODE
           END-EVALUATE.

       INSERE-SOCIO-PAGAMENTOS.
           MOVE 1 TO WS-INDICE.

           PERFORM UNTIL WS-INDICE > WS-NUM-PAGAMENTOS
      * Get payment data from array
               MOVE LS-SEQ-PAGAMENTO(WS-INDICE)
                   TO WS-SEQ-PAG
               MOVE LS-DATA-VENCIMENTO(WS-INDICE)
                   TO WS-DATA-VENC
               MOVE LS-VALR-MENSALIDADE(WS-INDICE)
                   TO WS-VALR-MENS
               MOVE LS-PAGAMENTO-OK(WS-INDICE)
                   TO WS-PAG-OK

      * Insert payment record
               EXEC SQL
                   INSERT INTO SOCIO_PAGAMENTO
                       (NUMB_SOCIO_PRINCIPAL,
                        SEQ_PAGAMENTO,
                        DATA_VENCIMENTO,
                        VALR_MENSALIDADE,
                        PAGAMENTO_OK)
                   VALUES
                       (:WS-NUMB-SOCIO,
                        :WS-SEQ-PAG,
                        :WS-DATA-VENC,
                        :WS-VALR-MENS,
                        :WS-PAG-OK)
               END-EXEC

               EVALUATE SQLCODE
                   WHEN 0
      * Payment inserted successfully
                       ADD 1 TO WS-INDICE
                   WHEN OTHER
      * Error in payment insert
                       MOVE 999 TO LS-RETURN-CODE
                       MOVE 'Y' TO WS-ROLLBACK-REQUIRED
                       EXIT PERFORM
               END-EVALUATE
           END-PERFORM.

       FINALIZA.
           EVALUATE TRUE
               WHEN LS-RETURN-CODE = 0
      * Success - commit transaction
                   EXEC SQL COMMIT END-EXEC
               WHEN LS-RETURN-CODE NOT = 0
      * Error - rollback transaction
                   EXEC SQL ROLLBACK END-EXEC
           END-EVALUATE.
