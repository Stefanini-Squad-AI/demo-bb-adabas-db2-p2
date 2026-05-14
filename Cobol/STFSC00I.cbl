       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       01 WS-CONSTANTS.
           05 WS-RC-SUCCESS         PIC S9(4) VALUE 0.
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
           05 LS-PAYMENT-DATA       PIC X(10).
           05 LS-PAYMENT-VALUE      PIC S9(4)V9(2) COMP-3.
           05 LS-PAYMENT-OK         PIC S9(4) COMP.

       LINKAGE SECTION.
           COPY STFSC00-CPY.

       PROCEDURE DIVISION USING SOCIOS-COMM.

           PERFORM INSERT-SOCIOS.

           IF SQLCODE NOT = 0
               MOVE WS-RC-DB-ERROR TO RETURN-CODE
               GOBACK
           END-IF.

           PERFORM INSERT-PAYMENTS.

           IF SQLCODE NOT = 0
               MOVE WS-RC-DB-ERROR TO RETURN-CODE
               GOBACK
           END-IF.

           EXEC SQL
               COMMIT
           END-EXEC.

           MOVE WS-RC-SUCCESS TO RETURN-CODE.
           GOBACK.

       INSERT-SOCIOS.
           MOVE NUMB-SOCIO-PRINCIPAL TO LS-NUMB-SOCIO.
           MOVE NOME-SOCIO-PRINCIPAL TO LS-NOME-SOCIO.
           MOVE DATA-CADASTRO TO LS-DATA-CADASTRO.
           MOVE CATG-SOCIO TO LS-CATG-SOCIO.
           MOVE DATA-BAIXA TO LS-DATA-BAIXA.
           MOVE HORA-BAIXA TO LS-HORA-BAIXA.
           MOVE OBSV-SOCIO TO LS-OBSV-SOCIO.

           EXEC SQL
               INSERT INTO SOCIOS
                   (NUMB_SOCIO_PRINCIPAL, NOME_SOCIO_PRINCIPAL,
                    DATA_CADASTRO, CATG_SOCIO, DATA_BAIXA,
                    HORA_BAIXA, OBSV_SOCIO)
               VALUES
                   (:LS-NUMB-SOCIO, :LS-NOME-SOCIO,
                    :LS-DATA-CADASTRO, :LS-CATG-SOCIO,
                    :LS-DATA-BAIXA, :LS-HORA-BAIXA,
                    :LS-OBSV-SOCIO)
           END-EXEC.

       INSERT-PAYMENTS.
           PERFORM VARYING WS-PAYMENT-INDEX FROM 1 BY 1
               UNTIL WS-PAYMENT-INDEX > 12
               MOVE DATA-VENCIMENTO(WS-PAYMENT-INDEX)
                   TO LS-PAYMENT-DATA
               MOVE VALR-MENSALIDADE(WS-PAYMENT-INDEX)
                   TO LS-PAYMENT-VALUE
               MOVE PAGAMENTO-OK(WS-PAYMENT-INDEX)
                   TO LS-PAYMENT-OK

               EXEC SQL
                   INSERT INTO SOCIOS_PAGAMENTO
                       (SOCIO_ID, DATA_VENCIMENTO,
                        VALR_MENSALIDADE, PAGAMENTO_OK)
                   VALUES
                       (:LS-NUMB-SOCIO, :LS-PAYMENT-DATA,
                        :LS-PAYMENT-VALUE, :LS-PAYMENT-OK)
               END-EXEC

               IF SQLCODE NOT = 0
                   EXIT PERFORM
               END-IF
           END-PERFORM.
