       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      *
      * Program: STFSC00I - SOCIO Inclusão (Store/Insert)
      * Purpose: Insert new SOCIO member data into DB2
      * Author: Automated Migration
      * Date: 2026-05-19
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      * Constants and literals
       01  WS-CONSTANTS.
           05  WS-RETURN-SUCCESS     PIC S9(9) VALUE 0.
           05  WS-RETURN-DUP-KEY     PIC S9(9) VALUE 803.
           05  WS-RETURN-ERROR       PIC S9(9) VALUE 99.
           05  WS-DB2-OK             PIC S9(9) VALUE 0.
           05  WS-DB2-DUP-KEY        PIC S9(9) VALUE -803.

       LOCAL-STORAGE SECTION.
      * SQLCA for DB2 error handling
       01  SQLCA.
           05  SQLCAID              PIC X(8).
           05  SQLCABC              PIC S9(9) COMP.
           05  SQLCODE              PIC S9(9) COMP.
           05  SQLERRM.
               10  SQLERRML          PIC S9(9) COMP.
               10  SQLERRMSG          PIC X(70).
           05  SQLERRP               PIC X(8).
           05  SQLERRD               PIC S9(9) COMP OCCURS 6.
           05  SQLWARN.
               10  SQLWARN0           PIC X.
               10  SQLWARN1           PIC X.
               10  SQLWARN2           PIC X.
               10  SQLWARN3           PIC X.
               10  SQLWARN4           PIC X.
               10  SQLWARN5           PIC X.
               10  SQLWARN6           PIC X.
               10  SQLWARN7           PIC X.
               10  SQLWARN10          PIC X.
           05  SQLSTATE              PIC X(5).

      * Communication book from Natural
       COPY SOCIO.

      * DB2 Host variables
       01  DB2-HOST-VARS.
           05  DB2-NUMB-SOCIO        PIC 9(9).
           05  DB2-NOME-SOCIO        PIC X(40).
           05  DB2-DATA-CADASTRO     PIC X(10).
           05  DB2-CATG-SOCIO        PIC 9(4).
           05  DB2-INDI-DIVIDA       PIC X(1).
           05  DB2-DATA-BAIXA        PIC X(10).
           05  DB2-HORA-BAIXA        PIC X(8).
           05  DB2-OBSV-SOCIO        PIC X(500).

      * Payment insertion variables
       01  DB2-PAYMENT-VARS.
           05  DB2-DATA-VENCIMENTO   PIC X(10).
           05  DB2-VALR-MENSALIDADE  PIC 9(4)V99.
           05  DB2-PAGAMENTO-OK      PIC X(1).

      * Execution variables
       01  EXEC-VARS.
           05  WS-PAY-INDEX          PIC 9(2) VALUE 0.
           05  WS-TRANS-ACTIVE       PIC X(1) VALUE 'N'.

       PROCEDURE DIVISION.

           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA

           STOP RUN.

       INICIALIZA.

           MOVE 'N' TO WS-TRANS-ACTIVE
           MOVE 0 TO RETURN-CODE-SOCIO
           MOVE 0 TO WS-PAY-INDEX

           INITIALIZE DB2-HOST-VARS
           INITIALIZE DB2-PAYMENT-VARS

      * Prepare host variables from input record
           MOVE NUMB-SOCIO-PRINCIPAL TO DB2-NUMB-SOCIO
           MOVE NOME-SOCIO-PRINCIPAL TO DB2-NOME-SOCIO
           MOVE DATA-CADASTRO TO DB2-DATA-CADASTRO
           MOVE CATG-SOCIO TO DB2-CATG-SOCIO
           MOVE INDI-DIVIDA TO DB2-INDI-DIVIDA
           MOVE DATA-BAIXA TO DB2-DATA-BAIXA
           MOVE HORA-BAIXA TO DB2-HORA-BAIXA
           MOVE OBSV-SOCIO TO DB2-OBSV-SOCIO.

       PROCESSA.

      * Begin transaction
           EXEC SQL
               BEGIN WORK
           END-EXEC

           MOVE 'Y' TO WS-TRANS-ACTIVE

      * Insert parent record
           EXEC SQL
               INSERT INTO SOCIO
               (
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   INDI_DIVIDA,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_SOCIO
               )
               VALUES
               (
                   :DB2-NUMB-SOCIO,
                   :DB2-NOME-SOCIO,
                   :DB2-DATA-CADASTRO,
                   :DB2-CATG-SOCIO,
                   :DB2-INDI-DIVIDA,
                   :DB2-DATA-BAIXA,
                   :DB2-HORA-BAIXA,
                   :DB2-OBSV-SOCIO
               )
           END-EXEC

           IF SQLCODE NOT = 0
               EVALUATE SQLCODE
                   WHEN -803
                       MOVE 803 TO RETURN-CODE-SOCIO
                   WHEN OTHER
                       MOVE 99 TO RETURN-CODE-SOCIO
               END-EVALUATE
               PERFORM ROLLBACK-TRANS
               GOBACK
           END-IF

      * Insert payment records
           PERFORM VARYING WS-PAY-INDEX FROM 1 BY 1
               UNTIL WS-PAY-INDEX > 12

               IF DATA-VENCIMENTO(WS-PAY-INDEX) NOT = SPACES AND
                  VALR-MENSALIDADE(WS-PAY-INDEX) > 0

                   MOVE DATA-VENCIMENTO(WS-PAY-INDEX)
                       TO DB2-DATA-VENCIMENTO
                   MOVE VALR-MENSALIDADE(WS-PAY-INDEX)
                       TO DB2-VALR-MENSALIDADE
                   MOVE PAGAMENTO-OK(WS-PAY-INDEX)
                       TO DB2-PAGAMENTO-OK

                   EXEC SQL
                       INSERT INTO SOCIO_PAGAMENTO
                       (
                           NUMB_SOCIO_PRINCIPAL,
                           DATA_VENCIMENTO,
                           VALR_MENSALIDADE,
                           PAGAMENTO_OK
                       )
                       VALUES
                       (
                           :DB2-NUMB-SOCIO,
                           :DB2-DATA-VENCIMENTO,
                           :DB2-VALR-MENSALIDADE,
                           :DB2-PAGAMENTO-OK
                       )
                   END-EXEC

                   IF SQLCODE NOT = 0
                       MOVE 99 TO RETURN-CODE-SOCIO
                       PERFORM ROLLBACK-TRANS
                       GOBACK
                   END-IF
               END-IF
           END-PERFORM

      * Commit transaction
           EXEC SQL
               COMMIT WORK
           END-EXEC

           MOVE 'N' TO WS-TRANS-ACTIVE
           MOVE 0 TO RETURN-CODE-SOCIO.

       ROLLBACK-TRANS.

           IF WS-TRANS-ACTIVE = 'Y'
               EXEC SQL
                   ROLLBACK WORK
               END-EXEC
               MOVE 'N' TO WS-TRANS-ACTIVE
           END-IF.

       FINALIZA.

           IF WS-TRANS-ACTIVE = 'Y'
               PERFORM ROLLBACK-TRANS
           END-IF

           STOP RUN.
