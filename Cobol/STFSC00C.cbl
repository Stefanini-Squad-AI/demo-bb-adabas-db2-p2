       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       01 WS-CONSTANTS.
           05 WS-SQLCODE-NOT-FOUND  PIC S9(4) VALUE 100.
           05 WS-SQLCODE-ERROR      PIC S9(4) VALUE -1.
           05 WS-RC-SUCCESS         PIC S9(4) VALUE 0.
           05 WS-RC-NOT-FOUND       PIC S9(4) VALUE 1.
           05 WS-RC-DB-ERROR        PIC S9(4) VALUE 2.
           05 WS-PAYMENT-INDEX      PIC 9(2).

       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.

       01 LS-HOST-VARIABLES.
           05 LS-NUMB-SOCIO         PIC 9(9).
           05 LS-NOME-SOCIO         PIC X(40).
           05 LS-DATA-CADASTRO      PIC X(10).
           05 LS-CATG-SOCIO         PIC S9(4) COMP.
           05 LS-DATA-BAIXA         PIC X(10).
           05 LS-HORA-BAIXA         PIC X(12).
           05 LS-OBSV-SOCIO         PIC X(500).
           05 LS-PAYMENT-ID         PIC 9(9).
           05 LS-PAYMENT-DATA       PIC X(10).
           05 LS-PAYMENT-VALUE      PIC S9(4)V9(2) COMP-3.
           05 LS-PAYMENT-OK         PIC S9(4) COMP.

       LINKAGE SECTION.
           COPY STFSC00-CPY.

       PROCEDURE DIVISION USING SOCIOS-COMM.

           PERFORM FIND-SOCIOS.

           IF SQLCODE = WS-SQLCODE-NOT-FOUND
               MOVE WS-RC-NOT-FOUND TO RETURN-CODE
           ELSE IF SQLCODE < 0
               MOVE WS-RC-DB-ERROR TO RETURN-CODE
           ELSE
               PERFORM FETCH-PAYMENTS
               MOVE WS-RC-SUCCESS TO RETURN-CODE
           END-IF.

           GOBACK.

       FIND-SOCIOS.
           MOVE NUMB-SOCIO-PRINCIPAL TO LS-NUMB-SOCIO.

           EXEC SQL
               SELECT NUMB_SOCIO_PRINCIPAL, NOME_SOCIO_PRINCIPAL,
                      DATA_CADASTRO, CATG_SOCIO, DATA_BAIXA,
                      HORA_BAIXA, OBSV_SOCIO
                 INTO :LS-NUMB-SOCIO, :LS-NOME-SOCIO,
                      :LS-DATA-CADASTRO, :LS-CATG-SOCIO,
                      :LS-DATA-BAIXA, :LS-HORA-BAIXA,
                      :LS-OBSV-SOCIO
                 FROM SOCIOS
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-NUMB-SOCIO
           END-EXEC.

           IF SQLCODE = 0
               MOVE LS-NUMB-SOCIO TO NUMB-SOCIO-PRINCIPAL
               MOVE LS-NOME-SOCIO TO NOME-SOCIO-PRINCIPAL
               MOVE LS-DATA-CADASTRO TO DATA-CADASTRO
               MOVE LS-CATG-SOCIO TO CATG-SOCIO
               MOVE LS-DATA-BAIXA TO DATA-BAIXA
               MOVE LS-HORA-BAIXA TO HORA-BAIXA
               MOVE LS-OBSV-SOCIO TO OBSV-SOCIO
           END-IF.

       FETCH-PAYMENTS.
           MOVE ZERO TO WS-PAYMENT-INDEX.

           EXEC SQL
               DECLARE PAYMENT-CURSOR CURSOR FOR
               SELECT DATA_VENCIMENTO, VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM SOCIOS_PAGAMENTO
                WHERE SOCIO_ID = :LS-NUMB-SOCIO
                ORDER BY SOCIOS_PAGAMENTO_ID
           END-EXEC.

           EXEC SQL
               OPEN PAYMENT-CURSOR
           END-EXEC.

           PERFORM UNTIL SQLCODE NOT = 0
               ADD 1 TO WS-PAYMENT-INDEX
               IF WS-PAYMENT-INDEX > 12
                   EXIT PERFORM
               END-IF

               EXEC SQL
                   FETCH PAYMENT-CURSOR
                     INTO :LS-PAYMENT-DATA, :LS-PAYMENT-VALUE,
                          :LS-PAYMENT-OK
               END-EXEC

               IF SQLCODE = 0
                   MOVE LS-PAYMENT-DATA
                       TO DATA-VENCIMENTO(WS-PAYMENT-INDEX)
                   MOVE LS-PAYMENT-VALUE
                       TO VALR-MENSALIDADE(WS-PAYMENT-INDEX)
                   MOVE LS-PAYMENT-OK
                       TO PAGAMENTO-OK(WS-PAYMENT-INDEX)
               END-IF
           END-PERFORM.

           EXEC SQL
               CLOSE PAYMENT-CURSOR
           END-EXEC.
