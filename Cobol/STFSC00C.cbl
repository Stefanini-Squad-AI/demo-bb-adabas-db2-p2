      * STFSC00C - SOCIOS Consultation Program (Consulta)
      * Retrieves SOCIOS data from DB2 by member number
      * Called from Natural: CALLNAT 'STFSC00C' USING book-parameters
      *
       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATABASE SECTION.
           OBJECT SOCIOS TABLE FROM SOCIOS.
           OBJECT SOCIOS-PAGAMENTO TABLE FROM SOCIOS_PAGAMENTO.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      * No variables in WORKING-STORAGE per COBOL structure rules
      * (constants and literals only if needed)

       LOCAL-STORAGE SECTION.
      * Include copybook with entity, payment, and communication books
           COPY STFSCK00.

      * DB2 Control Area (SQLCA)
           EXEC SQL INCLUDE SQLCA END-EXEC.

      * Host variables and indicators for DB2
       01 LS-HOST-VARS.
          05 LS-NUMB-SOCIO           PIC 9(9) COMP.
          05 LS-NUMB-SOCIO-IND       PIC S9(4) COMP VALUE 0.

       01 LS-FETCH-VARS.
          05 LS-PAGO-DATA-VENC       PIC X(10).
          05 LS-PAGO-DATA-VENC-IND   PIC S9(4) COMP VALUE 0.
          05 LS-PAGO-VALR            PIC S9(4)V99 COMP-3.
          05 LS-PAGO-VALR-IND        PIC S9(4) COMP VALUE 0.
          05 LS-PAGO-OK              PIC X(1).
          05 LS-PAGO-OK-IND          PIC S9(4) COMP VALUE 0.

       01 LS-FETCH-IDX              PIC 9(4) COMP VALUE 0.

       LINKAGE SECTION.
           COPY STFSCK00.

       PROCEDURE DIVISION USING WS-SOCIOS-BOOK
                               WS-SOCIOS-PAGAMENTO-BOOK
                               WS-COMM-BOOK.

       MAIN-PROCEDURE.
           PERFORM INITIALIZE-FIELDS.

           IF OPER-CONSULTA
               PERFORM CONSULTA-SOCIO
           ELSE
               SET RC-DB-ERROR TO TRUE
               STRING 'Operação inválida: ' OPERATION-CODE
                   DELIMITED BY SIZE
                   INTO ERROR-MESSAGE
               END-STRING
           END-IF.

           GOBACK.

       INITIALIZE-FIELDS.
           SET RC-SUCCESS TO TRUE.
           MOVE 0 TO RECORD-COUNT.
           MOVE SPACES TO ERROR-MESSAGE.
           MOVE NUMB-SOCIO-PRINCIPAL TO LS-NUMB-SOCIO.

       CONSULTA-SOCIO.
      * Execute SELECT to retrieve SOCIOS record
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL, DATA_CADASTRO,
                      CATG_SOCIO, INDI_DIVIDA, DATA_BAIXA,
                      HORA_BAIXA, OBSV_SOCIO
                   INTO :NOME-SOCIO-PRINCIPAL :LS-NUMB-SOCIO-IND,
                        :DATA-CADASTRO :LS-NUMB-SOCIO-IND,
                        :CATG-SOCIO :LS-NUMB-SOCIO-IND,
                        :INDI-DIVIDA :LS-NUMB-SOCIO-IND,
                        :DATA-BAIXA :LS-NUMB-SOCIO-IND,
                        :HORA-BAIXA :LS-NUMB-SOCIO-IND,
                        :OBSV-SOCIO :LS-NUMB-SOCIO-IND
               FROM SOCIOS
               WHERE NUMB_SOCIO_PRINCIPAL = :LS-NUMB-SOCIO
           END-EXEC.

           EVALUATE SQLCODE
               WHEN 0
      * Success - now fetch payment records
                   PERFORM FETCH-PAGAMENTOS
               WHEN 100
      * No record found
                   SET RC-NOT-FOUND TO TRUE
                   MOVE 'Sócio não encontrado.' TO ERROR-MESSAGE
               WHEN OTHER
      * Database error
                   SET RC-DB-ERROR TO TRUE
                   STRING 'Erro na consulta: SQLCODE=' SQLCODE
                       DELIMITED BY SIZE
                       INTO ERROR-MESSAGE
                   END-STRING
           END-EVALUATE.

       FETCH-PAGAMENTOS.
      * Declare and open cursor for payment records
           EXEC SQL
               DECLARE PAGO-CURSOR CURSOR FOR
               SELECT DATA_VENCIMENTO, VALR_MENSALIDADE, PAGAMENTO_OK
                   FROM SOCIOS_PAGAMENTO
                   WHERE SOCIO_ID = :LS-NUMB-SOCIO
                   ORDER BY SOCIOS_PAGAMENTO_ID
           END-EXEC.

           EXEC SQL
               OPEN PAGO-CURSOR
           END-EXEC.

           IF SQLCODE NOT = 0
               SET RC-DB-ERROR TO TRUE
               STRING 'Erro ao abrir cursor: SQLCODE=' SQLCODE
                   DELIMITED BY SIZE
                   INTO ERROR-MESSAGE
               END-STRING
               EXEC SQL CLOSE PAGO-CURSOR END-EXEC
               EXIT PARAGRAPH
           END-IF.

      * Fetch up to 12 payment records
           PERFORM VARYING LS-FETCH-IDX FROM 1 BY 1
               UNTIL LS-FETCH-IDX > 12
               EXEC SQL
                   FETCH PAGO-CURSOR INTO
                       :LS-PAGO-DATA-VENC :LS-PAGO-DATA-VENC-IND,
                       :LS-PAGO-VALR :LS-PAGO-VALR-IND,
                       :LS-PAGO-OK :LS-PAGO-OK-IND
               END-EXEC

               IF SQLCODE = 100
      * End of cursor - no more records
                   EXIT PERFORM
               END-IF

               IF SQLCODE NOT = 0
                   SET RC-DB-ERROR TO TRUE
                   STRING 'Erro ao buscar pagamento: SQLCODE=' SQLCODE
                       DELIMITED BY SIZE
                       INTO ERROR-MESSAGE
                   END-STRING
                   EXIT PERFORM
               END-IF

               MOVE LS-FETCH-IDX TO RECORD-COUNT
               MOVE LS-PAGO-DATA-VENC TO
                   DATA-VENCIMENTO OF PAGAMENTO-REC(LS-FETCH-IDX)
               MOVE LS-PAGO-VALR TO
                   VALR-MENSALIDADE OF PAGAMENTO-REC(LS-FETCH-IDX)
               MOVE LS-PAGO-OK TO
                   PAGAMENTO-OK OF PAGAMENTO-REC(LS-FETCH-IDX)
           END-PERFORM.

           EXEC SQL
               CLOSE PAGO-CURSOR
           END-EXEC.
