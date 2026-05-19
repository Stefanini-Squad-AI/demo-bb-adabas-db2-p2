       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      *
      * Program: STFSC00C - SOCIO Consulta (Find/Select)
      * Purpose: Query SOCIO member data from DB2
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
           05  WS-RETURN-NOT-FOUND   PIC S9(9) VALUE 100.
           05  WS-RETURN-ERROR       PIC S9(9) VALUE 99.
           05  WS-DB2-FETCH-SUCCESS  PIC S9(9) VALUE 0.
           05  WS-DB2-FETCH-EOF      PIC S9(9) VALUE 100.

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

      * Cursor for payment records
       01  DB2-CURSOR-VARS.
           05  DB2-ID-PAGAMENTO      PIC S9(18) COMP.
           05  DB2-DATA-VENCIMENTO   PIC X(10).
           05  DB2-VALR-MENSALIDADE  PIC 9(4)V99.
           05  DB2-PAGAMENTO-OK      PIC X(1).

      * Execution variables
       01  EXEC-VARS.
           05  WS-PAY-INDEX          PIC 9(2) VALUE 0.
           05  WS-PAY-COUNT          PIC 9(2) VALUE 0.

       PROCEDURE DIVISION.

           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA

           STOP RUN.

       INICIALIZA.

           MOVE 0 TO RETURN-CODE-SOCIO
           MOVE 0 TO WS-PAY-INDEX
           MOVE 0 TO WS-PAY-COUNT

           INITIALIZE DB2-HOST-VARS
           INITIALIZE DB2-CURSOR-VARS

           MOVE NUMB-SOCIO-PRINCIPAL TO DB2-NUMB-SOCIO.

       PROCESSA.

           EXEC SQL
               SELECT
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   INDI_DIVIDA,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_SOCIO
               INTO
                   :DB2-NUMB-SOCIO,
                   :DB2-NOME-SOCIO,
                   :DB2-DATA-CADASTRO,
                   :DB2-CATG-SOCIO,
                   :DB2-INDI-DIVIDA,
                   :DB2-DATA-BAIXA,
                   :DB2-HORA-BAIXA,
                   :DB2-OBSV-SOCIO
               FROM SOCIO
               WHERE NUMB_SOCIO_PRINCIPAL = :DB2-NUMB-SOCIO
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   PERFORM LOAD-SOCIO-RECORD
                   PERFORM LOAD-PAYMENT-RECORDS
                   MOVE 0 TO RETURN-CODE-SOCIO
               WHEN 100
                   MOVE 100 TO RETURN-CODE-SOCIO
               WHEN OTHER
                   MOVE 99 TO RETURN-CODE-SOCIO
           END-EVALUATE.

       LOAD-SOCIO-RECORD.

           MOVE DB2-NUMB-SOCIO TO NUMB-SOCIO-PRINCIPAL
           MOVE DB2-NOME-SOCIO TO NOME-SOCIO-PRINCIPAL
           MOVE DB2-DATA-CADASTRO TO DATA-CADASTRO
           MOVE DB2-CATG-SOCIO TO CATG-SOCIO
           MOVE DB2-INDI-DIVIDA TO INDI-DIVIDA
           MOVE DB2-DATA-BAIXA TO DATA-BAIXA
           MOVE DB2-HORA-BAIXA TO HORA-BAIXA
           MOVE DB2-OBSV-SOCIO TO OBSV-SOCIO.

       LOAD-PAYMENT-RECORDS.

      * Declare cursor for payments
           EXEC SQL
               DECLARE CURSOR-PAYMENTS CURSOR FOR
               SELECT
                   DATA_VENCIMENTO,
                   VALR_MENSALIDADE,
                   PAGAMENTO_OK
               FROM SOCIO_PAGAMENTO
               WHERE NUMB_SOCIO_PRINCIPAL = :DB2-NUMB-SOCIO
               ORDER BY DATA_VENCIMENTO
           END-EXEC

           EXEC SQL
               OPEN CURSOR-PAYMENTS
           END-EXEC

           IF SQLCODE NOT = 0
               MOVE 99 TO RETURN-CODE-SOCIO
               GOBACK
           END-IF

           MOVE 1 TO WS-PAY-INDEX
           PERFORM UNTIL WS-PAY-INDEX > 12
               EXEC SQL
                   FETCH FROM CURSOR-PAYMENTS
                   INTO
                       :DB2-DATA-VENCIMENTO,
                       :DB2-VALR-MENSALIDADE,
                       :DB2-PAGAMENTO-OK
               END-EXEC

               EVALUATE SQLCODE
                   WHEN 0
                       MOVE DB2-DATA-VENCIMENTO
                           TO DATA-VENCIMENTO(WS-PAY-INDEX)
                       MOVE DB2-VALR-MENSALIDADE
                           TO VALR-MENSALIDADE(WS-PAY-INDEX)
                       MOVE DB2-PAGAMENTO-OK
                           TO PAGAMENTO-OK(WS-PAY-INDEX)
                       ADD 1 TO WS-PAY-INDEX
                   WHEN 100
                       MOVE 12 TO WS-PAY-INDEX
                   WHEN OTHER
                       MOVE 99 TO RETURN-CODE-SOCIO
                       MOVE 13 TO WS-PAY-INDEX
               END-EVALUATE
           END-PERFORM

           EXEC SQL
               CLOSE CURSOR-PAYMENTS
           END-EXEC.

       FINALIZA.

           STOP RUN.
