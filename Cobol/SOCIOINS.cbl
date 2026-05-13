       IDENTIFICATION DIVISION.
       PROGRAM-ID. SOCIOINS.
      ******************************************************************
      * Inclusão de sócio + linhas de pagamento (1..12 via ligação).
      * Retornos: 00 ok, 02 duplicidade, 03 validação, 99 erro SQL.
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           05 WS-SQLSTATE-DUP             PIC X(5) VALUE '23505'.
           05 WS-SQLCODE-DUP              PIC S9(9) DISPLAY VALUE -803.

       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.

           05 LS-CNT                      PIC S9(9) DISPLAY.
           05 LS-IDX                      PIC 9(03).

       LINKAGE SECTION.
           COPY SOCIOLNK.

       PROCEDURE DIVISION USING SOCIO-LNK-AREA.

       MAIN-LOGIC.
           MOVE SPACES TO SOCIO-LNK-RETCODE

           IF SOCIO-LNK-NOME = SPACES
               MOVE '03' TO SOCIO-LNK-RETCODE
               GOBACK
           END-IF

           IF SOCIO-LNK-CATG NOT = 1 AND SOCIO-LNK-CATG NOT = 2
               MOVE '03' TO SOCIO-LNK-RETCODE
               GOBACK
           END-IF

           IF SOCIO-LNK-PAG-QTD = ZERO
               MOVE '03' TO SOCIO-LNK-RETCODE
               GOBACK
           END-IF

           MOVE ZERO TO LS-CNT
           EXEC SQL
               SELECT COUNT(*)
                 INTO :LS-CNT
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :SOCIO-LNK-NUMB
           END-EXEC

           IF SQLCODE NOT = ZERO
               MOVE '99' TO SOCIO-LNK-RETCODE
               EXEC SQL ROLLBACK END-EXEC
               GOBACK
           END-IF

           IF LS-CNT > ZERO
               MOVE '02' TO SOCIO-LNK-RETCODE
               GOBACK
           END-IF

           EXEC SQL
               INSERT INTO SOCIO (
                       NUMB_SOCIO_PRINCIPAL,
                       NOME_SOCIO_PRINCIPAL,
                       DATA_CADASTRO,
                       CATG_SOCIO,
                       INDI_DIVIDA,
                       DATA_BAIXA,
                       HORA_BAIXA,
                       OBSV_CLIENTE)
               VALUES (
                       :SOCIO-LNK-NUMB,
                       :SOCIO-LNK-NOME,
                       DATE(:SOCIO-LNK-DATA-CAD),
                       :SOCIO-LNK-CATG,
                       :SOCIO-LNK-INDI-DIVIDA,
                       NULL,
                       NULL,
                       :SOCIO-LNK-OBSV)
           END-EXEC

           IF SQLCODE NOT = ZERO
               IF SQLSTATE = WS-SQLSTATE-DUP
               OR SQLCODE = WS-SQLCODE-DUP
                   MOVE '02' TO SOCIO-LNK-RETCODE
               ELSE
                   MOVE '99' TO SOCIO-LNK-RETCODE
               END-IF
               EXEC SQL ROLLBACK END-EXEC
               GOBACK
           END-IF

           PERFORM INSERT-PAGAMENTOS THRU INSERT-PAGAMENTOS-EXIT

           IF SOCIO-LNK-RETCODE NOT = SPACES
               EXEC SQL ROLLBACK END-EXEC
               GOBACK
           END-IF

           MOVE '00' TO SOCIO-LNK-RETCODE
           EXEC SQL COMMIT END-EXEC
           GOBACK
           .

       INSERT-PAGAMENTOS.
           PERFORM VARYING LS-IDX FROM 1 BY 1
                   UNTIL LS-IDX > SOCIO-LNK-PAG-QTD
               EXEC SQL
                   INSERT INTO SOCIO_PAGAMENTO (
                           NUMB_SOCIO_PRINCIPAL,
                           SEQ_PAGAMENTO,
                           DATA_VENCIMENTO,
                           VALR_MENSALIDADE,
                           PAGAMENTO_OK)
                   VALUES (
                           :SOCIO-LNK-NUMB,
                           :LS-IDX,
                           DATE(:SOCIO-LNK-PAG-DATA-VENC (LS-IDX)),
                           :SOCIO-LNK-PAG-VALR (LS-IDX),
                           :SOCIO-LNK-PAG-OK (LS-IDX))
               END-EXEC
               IF SQLCODE NOT = ZERO
                   IF SQLSTATE = WS-SQLSTATE-DUP
                   OR SQLCODE = WS-SQLCODE-DUP
                       MOVE '02' TO SOCIO-LNK-RETCODE
                   ELSE
                       MOVE '99' TO SOCIO-LNK-RETCODE
                   END-IF
                   MOVE SOCIO-LNK-PAG-QTD TO LS-IDX
               END-IF
           END-PERFORM
           .
       INSERT-PAGAMENTOS-EXIT.
           EXIT
           .
