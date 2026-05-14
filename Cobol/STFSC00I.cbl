      * STFSC00I - SOCIOS Inclusion Program (Inclusão)
      * Inserts new SOCIOS record and payment records into DB2
      * Called from Natural: CALLNAT 'STFSC00I' USING book-parameters
      *
       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATABASE SECTION.
           OBJECT SOCIOS TABLE FROM SOCIOS.
           OBJECT SOCIOS-PAGAMENTO TABLE FROM SOCIOS_PAGAMENTO.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      * No variables in WORKING-STORAGE per COBOL structure rules

       LOCAL-STORAGE SECTION.
      * Include copybook with entity, payment, and communication books
           COPY STFSCK00.

      * DB2 Control Area (SQLCA)
           EXEC SQL INCLUDE SQLCA END-EXEC.

      * Host variables and indicators for DB2
       01 LS-INSERT-VARS.
          05 LS-PAGO-IDX             PIC 9(4) COMP VALUE 0.

       01 LS-PAGO-INDICATORS.
          05 LS-DATA-VENC-IND        PIC S9(4) COMP VALUE 0.
          05 LS-VALR-IND             PIC S9(4) COMP VALUE 0.
          05 LS-PAGO-OK-IND          PIC S9(4) COMP VALUE 0.

       LINKAGE SECTION.
           COPY STFSCK00.

       PROCEDURE DIVISION USING WS-SOCIOS-BOOK
                               WS-SOCIOS-PAGAMENTO-BOOK
                               WS-COMM-BOOK.

       MAIN-PROCEDURE.
           PERFORM INITIALIZE-FIELDS.

           IF OPER-INCLUSAO
               PERFORM INCLUI-SOCIO
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

       INCLUI-SOCIO.
      * Insert main SOCIOS record
           EXEC SQL
               INSERT INTO SOCIOS
               (NUMB_SOCIO_PRINCIPAL, NOME_SOCIO_PRINCIPAL,
                DATA_CADASTRO, CATG_SOCIO, INDI_DIVIDA,
                DATA_BAIXA, HORA_BAIXA, OBSV_SOCIO)
               VALUES
               (:NUMB-SOCIO-PRINCIPAL,
                :NOME-SOCIO-PRINCIPAL,
                :DATA-CADASTRO,
                :CATG-SOCIO,
                :INDI-DIVIDA,
                :DATA-BAIXA,
                :HORA-BAIXA,
                :OBSV-SOCIO)
           END-EXEC.

           IF SQLCODE NOT = 0
               SET RC-DB-ERROR TO TRUE
               STRING 'Erro ao inserir sócio: SQLCODE=' SQLCODE
                   DELIMITED BY SIZE
                   INTO ERROR-MESSAGE
               END-STRING
               EXEC SQL ROLLBACK END-EXEC
               EXIT PARAGRAPH
           END-IF.

      * Insert payment records (up to 12)
           PERFORM INCLUI-PAGAMENTOS.

           IF RC-SUCCESS
               EXEC SQL COMMIT END-EXEC
           ELSE
               EXEC SQL ROLLBACK END-EXEC
           END-IF.

       INCLUI-PAGAMENTOS.
      * Insert each payment record where data is provided
           PERFORM VARYING LS-PAGO-IDX FROM 1 BY 1
               UNTIL LS-PAGO-IDX > 12 OR NOT RC-SUCCESS
      * Skip empty payment records (PAGAMENTO-OK = space means unused)
               IF DATA-VENCIMENTO OF PAGAMENTO-REC(LS-PAGO-IDX)
                   NOT = SPACES
                   EXEC SQL
                       INSERT INTO SOCIOS_PAGAMENTO
                       (SOCIO_ID, DATA_VENCIMENTO,
                        VALR_MENSALIDADE, PAGAMENTO_OK)
                       VALUES
                       (:NUMB-SOCIO-PRINCIPAL,
                        :DATA-VENCIMENTO OF
                             PAGAMENTO-REC(LS-PAGO-IDX),
                        :VALR-MENSALIDADE OF
                             PAGAMENTO-REC(LS-PAGO-IDX),
                        :PAGAMENTO-OK OF
                             PAGAMENTO-REC(LS-PAGO-IDX))
                   END-EXEC

                   IF SQLCODE NOT = 0
                       SET RC-DB-ERROR TO TRUE
                       STRING 'Erro ao inserir pagamento ' LS-PAGO-IDX
                           ': SQLCODE=' SQLCODE
                           DELIMITED BY SIZE
                           INTO ERROR-MESSAGE
                       END-STRING
                       EXIT PERFORM
                   ELSE
                       ADD 1 TO RECORD-COUNT
                   END-IF
               END-IF
           END-PERFORM.
