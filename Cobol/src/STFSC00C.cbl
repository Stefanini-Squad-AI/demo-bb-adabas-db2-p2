       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      *> Consulta socio por RG (NUMB_SOCIO_PRINCIPAL) em DB2.
      *> WORKING-STORAGE: somente dados imutaveis; SQL e variaveis em LOCAL-STORAGE.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGNAME              PIC X(08) VALUE 'STFSC00C'.

       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  H-NUMB-SOCIO                   PIC S9(9) COMP-3.
       01  H-NOME                         PIC X(40).
       01  H-DATA-CAD                     PIC X(10).
       01  H-CATG                         PIC S9(4) COMP.
       01  H-INDI-DIV                     PIC S9(4) COMP.
       01  H-DATA-BAIXA                   PIC X(10).
       01  H-DATA-BAIXA-IND               PIC S9(4) COMP.
       01  H-HORA-BAIXA                   PIC X(12).
       01  H-HORA-BAIXA-IND               PIC S9(4) COMP.
       01  H-OBSV                         PIC X(500).
       01  H-SEQ                          PIC S9(4) COMP.
       01  H-DATA-VENC                    PIC X(10).
       01  H-VALR                         PIC S9(6)V9(2) COMP-3.
       01  H-PAG-OK                       PIC X(01).
       01  WS-PAY-IX                      PIC S9(4) COMP.
       01  WS-FETCH-IX                    PIC S9(4) COMP.

       LINKAGE SECTION.
           COPY BKSTFSC.

       PROCEDURE DIVISION USING LK-STFSC-AREA.
       STFSC00C-MAIN.
           MOVE '99'                      TO LK-RETCODE

           EXEC SQL
             DECLARE STFSC00C-C1 CURSOR FOR
               SELECT SEQUENCIA,
                      CHAR(DATA_VENCIMENTO, ISO),
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM CLIENTE_PAGAMENTO
                WHERE NUMB_SOCIO_PRINCIPAL = :H-NUMB-SOCIO
                ORDER BY SEQUENCIA
           END-EXEC

           MOVE LK-NUMB-SOCIO-PRINCIPAL   TO H-NUMB-SOCIO
           MOVE ZERO                      TO H-DATA-BAIXA-IND
           MOVE ZERO                      TO H-HORA-BAIXA-IND

           EXEC SQL
             SELECT NOME_SOCIO_PRINCIPAL,
                    CHAR(DATA_CADASTRO, ISO),
                    CATG_SOCIO,
                    INDI_DIVIDA,
                    CHAR(DATA_BAIXA, ISO),
                    HORA_BAIXA,
                    OBSV_CLIENTE
               INTO :H-NOME,
                    :H-DATA-CAD,
                    :H-CATG,
                    :H-INDI-DIV,
                    :H-DATA-BAIXA:H-DATA-BAIXA-IND,
                    :H-HORA-BAIXA:H-HORA-BAIXA-IND,
                    :H-OBSV
               FROM CLIENTE
              WHERE NUMB_SOCIO_PRINCIPAL = :H-NUMB-SOCIO
           END-EXEC

           EVALUATE SQLCODE
             WHEN +100
               MOVE '01'                    TO LK-RETCODE
               GOBACK
             WHEN ZERO
               CONTINUE
             WHEN OTHER
               MOVE '99'                    TO LK-RETCODE
               GOBACK
           END-EVALUATE

           MOVE H-NOME                      TO LK-NOME-SOCIO-PRINCIPAL
           MOVE H-DATA-CAD                  TO LK-DATA-CADASTRO
           MOVE H-CATG                      TO LK-CATG-SOCIO
           MOVE H-INDI-DIV                  TO LK-INDI-DIVIDA
           MOVE H-OBSV                      TO LK-OBSV-CLIENTE

           IF H-DATA-BAIXA-IND LESS ZERO
             MOVE SPACES                    TO LK-DATA-BAIXA
             MOVE -1                        TO LK-DATA-BAIXA-IND
           ELSE
             MOVE H-DATA-BAIXA              TO LK-DATA-BAIXA
             MOVE ZERO                      TO LK-DATA-BAIXA-IND
           END-IF

           IF H-HORA-BAIXA-IND LESS ZERO
             MOVE SPACES                    TO LK-HORA-BAIXA
             MOVE -1                        TO LK-HORA-BAIXA-IND
           ELSE
             MOVE H-HORA-BAIXA              TO LK-HORA-BAIXA
             MOVE ZERO                      TO LK-HORA-BAIXA-IND
           END-IF

           PERFORM STFSC00C-INIT-PAGAMENTO
           EXEC SQL
             OPEN STFSC00C-C1
           END-EXEC
           IF SQLCODE NOT EQUAL ZERO
             MOVE '99'                      TO LK-RETCODE
             GOBACK
           END-IF

           MOVE 1                           TO WS-FETCH-IX
           PERFORM UNTIL WS-FETCH-IX GREATER 12
             EXEC SQL
               FETCH STFSC00C-C1
                INTO :H-SEQ,
                     :H-DATA-VENC,
                     :H-VALR,
                     :H-PAG-OK
             END-EXEC
             IF SQLCODE EQUAL +100
               EXIT PERFORM
             END-IF
             IF SQLCODE NOT EQUAL ZERO
               MOVE '99'                    TO LK-RETCODE
               EXEC SQL
                 CLOSE STFSC00C-C1
               END-EXEC
               GOBACK
             END-IF
             MOVE H-DATA-VENC TO LK-DATA-VENCIMENTO (WS-FETCH-IX)
             MOVE H-VALR      TO LK-VALR-MENSALIDADE (WS-FETCH-IX)
             MOVE H-PAG-OK    TO LK-PAGAMENTO-OK (WS-FETCH-IX)
             ADD 1            TO WS-FETCH-IX
           END-PERFORM

           EXEC SQL
             CLOSE STFSC00C-C1
           END-EXEC
           IF SQLCODE NOT EQUAL ZERO
             MOVE '99'                      TO LK-RETCODE
             GOBACK
           END-IF
           MOVE '00'                        TO LK-RETCODE
           GOBACK
           .

       STFSC00C-INIT-PAGAMENTO SECTION.
           MOVE 1                           TO WS-PAY-IX
           PERFORM UNTIL WS-PAY-IX GREATER 12
             MOVE SPACES                    TO LK-DATA-VENCIMENTO (WS-PAY-IX)
             MOVE ZERO                      TO LK-VALR-MENSALIDADE (WS-PAY-IX)
             MOVE '0'                       TO LK-PAGAMENTO-OK (WS-PAY-IX)
             ADD 1                          TO WS-PAY-IX
           END-PERFORM
           EXIT SECTION
           .
