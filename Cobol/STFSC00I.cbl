       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      *> Inclusion (insert) of member and payment rows on DB2.
      *> COMM-RETURN-CODE: 00=OK, 02=duplicate principal, 99=error.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-LITERAL-RC-OK               PIC X(02) VALUE '00'.
       01  WS-LITERAL-RC-DUP              PIC X(02) VALUE '02'.
       01  WS-LITERAL-RC-ERR              PIC X(02) VALUE '99'.
       01  WS-NUMB-STR                    PIC X(09).
       01  WS-NUM-PAY                     PIC 9(04) VALUE ZERO.
       01  WS-PAY-IDX                     PIC 9(04) VALUE ZERO.
       01  HV-CNT                        PIC S9(9) COMP.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  HV-NUMB                        PIC S9(9)V9(0) COMP-3.
       01  HV-NOME                        PIC X(40).
       01  HV-DATA-CAD                    PIC X(10).
       01  HV-CATG                        PIC S9(4) COMP.
       01  HV-INDI                        PIC S9(4) COMP.
       01  HV-DATA-BAIXA                  PIC X(10).
       01  IND-DATA-BAIXA                 PIC S9(4) COMP VALUE -1.
       01  HV-HORA-BAIXA                  PIC X(12).
       01  IND-HORA-BAIXA                 PIC S9(4) COMP VALUE -1.
       01  HV-OBSV                        PIC X(500).
       01  HV-SEQ                         PIC S9(9) COMP.
       01  HV-DATA-VEN                    PIC X(10).
       01  HV-VALR                        PIC S9(5)V9(2) COMP-3.
       01  HV-PAG-OK                      PIC X(01).
       01  WS-VALR-STR                    PIC X(12).
       LINKAGE SECTION.
           COPY STFSCSOC.
       PROCEDURE DIVISION USING SOCIO-DB2-COMM.
       MAIN-P.
           MOVE WS-LITERAL-RC-ERR TO COMM-RETURN-CODE
           MOVE COMM-NUMB-SOCIO-PRINCIPAL TO WS-NUMB-STR
           IF FUNCTION LENGTH (FUNCTION TRIM (WS-NUMB-STR)) = ZERO
               GOBACK
           END-IF
           COMPUTE HV-NUMB = FUNCTION NUMVAL (FUNCTION TRIM (WS-NUMB-STR))
           MOVE ZERO TO HV-CNT
           EXEC SQL
               SELECT COUNT (*)
               INTO :HV-CNT
               FROM SOCIO
               WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB
           END-EXEC
           IF SQLCODE NOT = ZERO
               GOBACK
           END-IF
           IF HV-CNT > ZERO
               MOVE WS-LITERAL-RC-DUP TO COMM-RETURN-CODE
               GOBACK
           END-IF
           MOVE COMM-NOME-SOCIO-PRINCIPAL TO HV-NOME
           MOVE COMM-DATA-CADASTRO TO HV-DATA-CAD
           COMPUTE HV-CATG = FUNCTION NUMVAL (FUNCTION TRIM (COMM-CATG-SOCIO))
           COMPUTE HV-INDI = FUNCTION NUMVAL (FUNCTION TRIM (COMM-INDI-DIVIDA))
           IF FUNCTION LENGTH (FUNCTION TRIM (COMM-DATA-BAIXA)) > ZERO
               MOVE COMM-DATA-BAIXA TO HV-DATA-BAIXA
               MOVE ZERO TO IND-DATA-BAIXA
           ELSE
               MOVE -1 TO IND-DATA-BAIXA
           END-IF
           IF FUNCTION LENGTH (FUNCTION TRIM (COMM-HORA-BAIXA)) > ZERO
               MOVE COMM-HORA-BAIXA TO HV-HORA-BAIXA
               MOVE ZERO TO IND-HORA-BAIXA
           ELSE
               MOVE -1 TO IND-HORA-BAIXA
           END-IF
           MOVE COMM-OBSV-SOCIO TO HV-OBSV
           EXEC SQL
               INSERT INTO SOCIO (
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   INDI_DIVIDA,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_SOCIO)
               VALUES (
                   :HV-NUMB,
                   :HV-NOME,
                   DATE (:HV-DATA-CAD),
                   :HV-CATG,
                   :HV-INDI,
                   :HV-DATA-BAIXA:IND-DATA-BAIXA,
                   :HV-HORA-BAIXA:IND-HORA-BAIXA,
                   :HV-OBSV)
           END-EXEC
           IF SQLCODE NOT = ZERO
               EXEC SQL ROLLBACK END-EXEC
               GOBACK
           END-IF
           COMPUTE WS-NUM-PAY = FUNCTION NUMVAL (FUNCTION TRIM (COMM-NUM-PAGAMENTOS))
           PERFORM VARYING WS-PAY-IDX FROM 1 BY 1 UNTIL WS-PAY-IDX > WS-NUM-PAY
               OR WS-PAY-IDX > 100
               MOVE WS-PAY-IDX TO HV-SEQ
               MOVE COMM-DATA-VENCIMENTO (WS-PAY-IDX) TO HV-DATA-VEN
               MOVE COMM-VALR-MENSALIDADE (WS-PAY-IDX) TO WS-VALR-STR
               COMPUTE HV-VALR = FUNCTION NUMVAL (FUNCTION TRIM (WS-VALR-STR))
               MOVE COMM-PAGAMENTO-OK (WS-PAY-IDX) TO HV-PAG-OK
               IF HV-PAG-OK = 'Y' OR HV-PAG-OK = 'T' OR HV-PAG-OK = '1'
                   MOVE 'Y' TO HV-PAG-OK
               ELSE
                   MOVE 'N' TO HV-PAG-OK
               END-IF
               EXEC SQL
                   INSERT INTO SOCIO_PAGAMENTO (
                       NUMB_SOCIO_PRINCIPAL,
                       SEQ_LINHA,
                       DATA_VENCIMENTO,
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK)
                   VALUES (
                       :HV-NUMB,
                       :HV-SEQ,
                       DATE (:HV-DATA-VEN),
                       :HV-VALR,
                       :HV-PAG-OK)
               END-EXEC
               IF SQLCODE NOT = ZERO
                   EXEC SQL ROLLBACK END-EXEC
                   GOBACK
               END-IF
           END-PERFORM
           EXEC SQL COMMIT END-EXEC
           MOVE WS-LITERAL-RC-OK TO COMM-RETURN-CODE
           GOBACK
           .
