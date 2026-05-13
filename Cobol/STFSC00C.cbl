       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      *> Consultation (query) for member and payment rows on DB2.
      *> COMM-RETURN-CODE: 00=found, 01=not found, 99=error.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-LITERAL-RC-OK               PIC X(02) VALUE '00'.
       01  WS-LITERAL-RC-NOTFOUND         PIC X(02) VALUE '01'.
       01  WS-LITERAL-RC-ERR              PIC X(02) VALUE '99'.
       01  WS-LITERAL-YES                 PIC X(01) VALUE 'Y'.
       01  WS-LITERAL-NO                  PIC X(01) VALUE 'N'.
       01  WS-IDX                        PIC 9(04) VALUE ZERO.
       01  WS-NUM-PAY                     PIC 9(04) VALUE ZERO.
       01  WS-NUMB-STR                    PIC X(09).
       01  WS-CATG-D                      PIC 99.
       01  WS-INDI-D                      PIC 9.
       01  WS-VALR-EDIT                   PIC ZZZZZ9.99.
       01  WS-N4-DISP                     PIC 9(04).
           EXEC SQL
               DECLARE C-PAG CURSOR FOR
                   SELECT SEQ_LINHA,
                          CHAR (DATA_VENCIMENTO, ISO),
                          VALR_MENSALIDADE,
                          PAGAMENTO_OK
                   FROM SOCIO_PAGAMENTO
                   WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB
                   ORDER BY SEQ_LINHA
           END-EXEC.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  HV-NUMB                        PIC S9(9)V9(0) COMP-3.
       01  HV-NOME                        PIC X(40).
       01  HV-DATA-CAD                    PIC X(10).
       01  HV-CATG                        PIC S9(4) COMP.
       01  HV-INDI                        PIC S9(4) COMP.
       01  HV-DATA-BAIXA                  PIC X(10).
       01  IND-DATA-BAIXA                 PIC S9(4) COMP.
       01  HV-HORA-BAIXA                  PIC X(12).
       01  IND-HORA-BAIXA                 PIC S9(4) COMP.
       01  HV-OBSV                        PIC X(500).
       01  HV-SEQ                         PIC S9(9) COMP.
       01  HV-DATA-VEN                    PIC X(10).
       01  HV-VALR                        PIC S9(5)V9(2) COMP-3.
       01  HV-PAG-OK                      PIC X(01).
       LINKAGE SECTION.
           COPY STFSCSOC.
       PROCEDURE DIVISION USING SOCIO-DB2-COMM.
       MAIN-P.
           MOVE WS-LITERAL-RC-ERR TO COMM-RETURN-CODE
           MOVE SPACES TO COMM-NOME-SOCIO-PRINCIPAL
           MOVE SPACES TO COMM-DATA-CADASTRO
           MOVE SPACES TO COMM-CATG-SOCIO
           MOVE SPACES TO COMM-INDI-DIVIDA
           MOVE SPACES TO COMM-DATA-BAIXA
           MOVE SPACES TO COMM-HORA-BAIXA
           MOVE SPACES TO COMM-OBSV-SOCIO
           MOVE '0000' TO COMM-NUM-PAGAMENTOS
           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 100
               MOVE SPACES TO COMM-DATA-VENCIMENTO (WS-IDX)
               MOVE SPACES TO COMM-VALR-MENSALIDADE (WS-IDX)
               MOVE SPACES TO COMM-PAGAMENTO-OK (WS-IDX)
           END-PERFORM
           MOVE COMM-NUMB-SOCIO-PRINCIPAL TO WS-NUMB-STR
           IF FUNCTION LENGTH (FUNCTION TRIM (WS-NUMB-STR)) = ZERO
               MOVE WS-LITERAL-RC-NOTFOUND TO COMM-RETURN-CODE
               GOBACK
           END-IF
           COMPUTE HV-NUMB = FUNCTION NUMVAL (FUNCTION TRIM (WS-NUMB-STR))
           EXEC SQL
               SELECT CHAR (DATA_CADASTRO, ISO),
                      NOME_SOCIO_PRINCIPAL,
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CHAR (DATA_BAIXA, ISO),
                      HORA_BAIXA,
                      OBSV_SOCIO
               INTO :HV-DATA-CAD,
                    :HV-NOME,
                    :HV-CATG,
                    :HV-INDI,
                    :HV-DATA-BAIXA INDICATOR :IND-DATA-BAIXA,
                    :HV-HORA-BAIXA INDICATOR :IND-HORA-BAIXA,
                    :HV-OBSV
               FROM SOCIO
               WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB
           END-EXEC
           EVALUATE SQLCODE
               WHEN 100
                   MOVE WS-LITERAL-RC-NOTFOUND TO COMM-RETURN-CODE
                   GOBACK
               WHEN ZERO
                   CONTINUE
               WHEN OTHER
                   GOBACK
           END-EVALUATE
           MOVE HV-DATA-CAD TO COMM-DATA-CADASTRO
           MOVE HV-NOME TO COMM-NOME-SOCIO-PRINCIPAL
           MOVE HV-CATG TO WS-CATG-D
           MOVE WS-CATG-D TO COMM-CATG-SOCIO
           MOVE HV-INDI TO WS-INDI-D
           MOVE WS-INDI-D TO COMM-INDI-DIVIDA
           IF IND-DATA-BAIXA < ZERO
               MOVE SPACES TO COMM-DATA-BAIXA
           ELSE
               MOVE HV-DATA-BAIXA TO COMM-DATA-BAIXA
           END-IF
           IF IND-HORA-BAIXA < ZERO
               MOVE SPACES TO COMM-HORA-BAIXA
           ELSE
               MOVE HV-HORA-BAIXA TO COMM-HORA-BAIXA
           END-IF
           MOVE HV-OBSV TO COMM-OBSV-SOCIO
           MOVE ZERO TO WS-NUM-PAY
           EXEC SQL OPEN C-PAG END-EXEC
           IF SQLCODE NOT = ZERO
               GOBACK
           END-IF
           PERFORM WITH TEST AFTER
               UNTIL SQLCODE = 100
               EXEC SQL
                   FETCH C-PAG
                   INTO :HV-SEQ,
                        :HV-DATA-VEN,
                        :HV-VALR,
                        :HV-PAG-OK
               END-EXEC
               IF SQLCODE = ZERO
                   ADD 1 TO WS-NUM-PAY
                   IF WS-NUM-PAY > 100
                       MOVE WS-LITERAL-RC-ERR TO COMM-RETURN-CODE
                       EXEC SQL CLOSE C-PAG END-EXEC
                       GOBACK
                   END-IF
                   MOVE HV-DATA-VEN TO COMM-DATA-VENCIMENTO (WS-NUM-PAY)
                   MOVE HV-VALR TO WS-VALR-EDIT
                   MOVE WS-VALR-EDIT TO COMM-VALR-MENSALIDADE (WS-NUM-PAY)
                   IF HV-PAG-OK = 'Y' OR HV-PAG-OK = 'T' OR HV-PAG-OK = '1'
                       MOVE WS-LITERAL-YES TO COMM-PAGAMENTO-OK (WS-NUM-PAY)
                   ELSE
                       MOVE WS-LITERAL-NO TO COMM-PAGAMENTO-OK (WS-NUM-PAY)
                   END-IF
               ELSE
                   IF SQLCODE NOT = 100
                       MOVE WS-LITERAL-RC-ERR TO COMM-RETURN-CODE
                       EXEC SQL CLOSE C-PAG END-EXEC
                       GOBACK
                   END-IF
               END-IF
           END-PERFORM
           EXEC SQL CLOSE C-PAG END-EXEC
           MOVE WS-NUM-PAY TO WS-N4-DISP
           MOVE WS-N4-DISP TO COMM-NUM-PAGAMENTOS
           MOVE WS-LITERAL-RC-OK TO COMM-RETURN-CODE
           GOBACK
           .
