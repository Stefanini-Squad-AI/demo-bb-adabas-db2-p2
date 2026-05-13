       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSSC00C.
      ******************************************************************
      * Consulta sócio por RG (NUMB_SOCIO_PRINCIPAL) + parcelas
      * DBATDP-1
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-C-MAX-PARCELAS              PIC S9(4) COMP VALUE 12.

       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-CURSOR-ABERTO              PIC X(01) VALUE 'N'.
               88  WS-CURSOR-SIM          VALUE 'S'.
       01  WS-IDX                         PIC S9(4) COMP.
       01  WS-PAG-DATA-VENC               PIC X(10).
       01  WS-PAG-VALR                    PIC S9(05)V9(02) COMP-3.
       01  WS-PAG-OK                      PIC X(01).

       LINKAGE SECTION.
           COPY STFSSCOM.

       PROCEDURE DIVISION USING SOCIO-COMMAREA.

           EXEC SQL
               DECLARE C_SOCIO_PAG CURSOR FOR
                   SELECT CHAR(DATE(DATA_VENCIMENTO)),
                          VALR_MENSALIDADE,
                          PAGAMENTO_OK
                     FROM SOCIO_PAGAMENTO
                    WHERE NUMB_SOCIO_PRINCIPAL = :SOCIO-RG
                    ORDER BY NR_PARCELA
           END-EXEC

           PERFORM P000-CONSULTA
           GOBACK
           .

       P000-CONSULTA.
           MOVE SPACES TO SOCIO-RETURN-CODE
           MOVE SPACES TO SOCIO-NOME SOCIO-DATA-CADASTRO
           MOVE ZERO TO SOCIO-CATG SOCIO-INDI-DIVIDA
           MOVE SPACES TO SOCIO-DATA-BAIXA SOCIO-HORA-BAIXA SOCIO-OBSV
           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > WS-C-MAX-PARCELAS
               MOVE SPACES TO SOCIO-DATA-VENC (WS-IDX)
               MOVE ZERO TO SOCIO-VALR-MENS (WS-IDX)
               MOVE SPACE TO SOCIO-PAG-OK (WS-IDX)
           END-PERFORM
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATE(DATA_CADASTRO)),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CASE WHEN DATA_BAIXA IS NULL
                           THEN '          '
                           ELSE CHAR(DATE(DATA_BAIXA))
                      END,
                      CASE WHEN HORA_BAIXA IS NULL
                           THEN '            '
                           ELSE HORA_BAIXA
                      END,
                      OBSV_SOCIO
                 INTO :SOCIO-NOME,
                      :SOCIO-DATA-CADASTRO,
                      :SOCIO-CATG,
                      :SOCIO-INDI-DIVIDA,
                      :SOCIO-DATA-BAIXA,
                      :SOCIO-HORA-BAIXA,
                      :SOCIO-OBSV
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :SOCIO-RG
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   PERFORM P010-CARREGA-PAGAMENTOS
                   IF SOCIO-RC-ERROR
                       CONTINUE
                   ELSE
                       SET SOCIO-RC-OK TO TRUE
                   END-IF
               WHEN +100
                   SET SOCIO-RC-NOT-FOUND TO TRUE
               WHEN OTHER
                   SET SOCIO-RC-ERROR TO TRUE
           END-EVALUATE
           .

       P010-CARREGA-PAGAMENTOS.
           MOVE 'N' TO WS-CURSOR-ABERTO
           EXEC SQL OPEN C_SOCIO_PAG END-EXEC
           IF SQLCODE NOT = ZERO
               SET SOCIO-RC-ERROR TO TRUE
               EXIT PARAGRAPH
           END-IF
           SET WS-CURSOR-SIM TO TRUE
           MOVE 1 TO WS-IDX
           PERFORM UNTIL WS-IDX > WS-C-MAX-PARCELAS
               EXEC SQL FETCH C_SOCIO_PAG
                   INTO :WS-PAG-DATA-VENC,
                        :WS-PAG-VALR,
                        :WS-PAG-OK
               END-EXEC
               EVALUATE SQLCODE
                   WHEN 0
                       MOVE WS-PAG-DATA-VENC TO SOCIO-DATA-VENC (WS-IDX)
                       MOVE WS-PAG-VALR TO SOCIO-VALR-MENS (WS-IDX)
                       MOVE WS-PAG-OK TO SOCIO-PAG-OK (WS-IDX)
                       ADD 1 TO WS-IDX
                   WHEN +100
                       MOVE WS-C-MAX-PARCELAS TO WS-IDX
                       ADD 1 TO WS-IDX
                   WHEN OTHER
                       SET SOCIO-RC-ERROR TO TRUE
                       MOVE WS-C-MAX-PARCELAS TO WS-IDX
                       ADD 1 TO WS-IDX
               END-EVALUATE
           END-PERFORM
           IF WS-CURSOR-SIM
               EXEC SQL CLOSE C_SOCIO_PAG END-EXEC
           END-IF
           .
