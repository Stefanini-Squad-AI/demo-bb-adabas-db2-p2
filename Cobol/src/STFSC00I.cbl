       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      *> Inclusao de socio e linhas de pagamento em DB2.
      *> WORKING-STORAGE: somente dados imutaveis; SQL e variaveis em LOCAL-STORAGE.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGNAME              PIC X(08) VALUE 'STFSC00I'.

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

       LINKAGE SECTION.
           COPY BKSTFSC.

       PROCEDURE DIVISION USING LK-STFSC-AREA.
       STFSC00I-MAIN.
           MOVE '99'                      TO LK-RETCODE
           MOVE LK-NUMB-SOCIO-PRINCIPAL   TO H-NUMB-SOCIO
           MOVE LK-NOME-SOCIO-PRINCIPAL   TO H-NOME
           MOVE LK-DATA-CADASTRO          TO H-DATA-CAD
           MOVE LK-CATG-SOCIO             TO H-CATG
           MOVE LK-INDI-DIVIDA            TO H-INDI-DIV

           IF LK-DATA-BAIXA-IND LESS ZERO
             MOVE -1                      TO H-DATA-BAIXA-IND
           ELSE
             MOVE ZERO                    TO H-DATA-BAIXA-IND
             MOVE LK-DATA-BAIXA           TO H-DATA-BAIXA
           END-IF

           IF LK-HORA-BAIXA-IND LESS ZERO
             MOVE -1                      TO H-HORA-BAIXA-IND
           ELSE
             MOVE ZERO                    TO H-HORA-BAIXA-IND
             MOVE LK-HORA-BAIXA           TO H-HORA-BAIXA
           END-IF

           MOVE LK-OBSV-CLIENTE           TO H-OBSV

           EXEC SQL
             INSERT INTO CLIENTE (
                 NUMB_SOCIO_PRINCIPAL,
                 NOME_SOCIO_PRINCIPAL,
                 DATA_CADASTRO,
                 CATG_SOCIO,
                 INDI_DIVIDA,
                 DATA_BAIXA,
                 HORA_BAIXA,
                 OBSV_CLIENTE
             ) VALUES (
                 :H-NUMB-SOCIO,
                 :H-NOME,
                 DATE(:H-DATA-CAD),
                 :H-CATG,
                 :H-INDI-DIV,
                 :H-DATA-BAIXA:H-DATA-BAIXA-IND,
                 :H-HORA-BAIXA:H-HORA-BAIXA-IND,
                 :H-OBSV
             )
           END-EXEC

           EVALUATE SQLCODE
             WHEN ZERO
               CONTINUE
             WHEN -803
               MOVE '98'                    TO LK-RETCODE
               GOBACK
             WHEN OTHER
               MOVE '99'                    TO LK-RETCODE
               GOBACK
           END-EVALUATE

           MOVE 1                           TO WS-PAY-IX
           PERFORM UNTIL WS-PAY-IX GREATER 12
             MOVE WS-PAY-IX                 TO H-SEQ
             MOVE LK-DATA-VENCIMENTO (WS-PAY-IX) TO H-DATA-VENC
             MOVE LK-VALR-MENSALIDADE (WS-PAY-IX) TO H-VALR
             MOVE LK-PAGAMENTO-OK (WS-PAY-IX) TO H-PAG-OK
             EXEC SQL
               INSERT INTO CLIENTE_PAGAMENTO (
                   NUMB_SOCIO_PRINCIPAL,
                   SEQUENCIA,
                   DATA_VENCIMENTO,
                   VALR_MENSALIDADE,
                   PAGAMENTO_OK
               ) VALUES (
                   :H-NUMB-SOCIO,
                   :H-SEQ,
                   DATE(:H-DATA-VENC),
                   :H-VALR,
                   :H-PAG-OK
               )
             END-EXEC
             IF SQLCODE NOT EQUAL ZERO
               MOVE '99'                    TO LK-RETCODE
               EXEC SQL ROLLBACK END-EXEC
               GOBACK
             END-IF
             ADD 1                          TO WS-PAY-IX
           END-PERFORM

           EXEC SQL COMMIT END-EXEC
           IF SQLCODE NOT EQUAL ZERO
             MOVE '99'                      TO LK-RETCODE
             GOBACK
           END-IF
           MOVE '00'                        TO LK-RETCODE
           GOBACK
           .
