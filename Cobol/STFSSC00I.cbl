       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSSC00I.
      ******************************************************************
      * Inclusão de sócio (pai + 12 parcelas) com checagem de duplicidade
      * DBATDP-1
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-C-MAX-PARCELAS              PIC S9(4) COMP VALUE 12.
       01  WS-COUNT-DUP                   PIC S9(9) COMP.

       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-IDX                         PIC S9(4) COMP.
       01  WS-HV-DATA-VENC                PIC X(10).
       01  WS-HV-VALR                     PIC S9(05)V9(02) COMP-3.
       01  WS-HV-PAG-OK                   PIC X(01).

       LINKAGE SECTION.
           COPY STFSSCOM.

       PROCEDURE DIVISION USING SOCIO-COMMAREA.

           PERFORM P000-INCLUI
           GOBACK
           .

       P000-INCLUI.
           MOVE SPACES TO SOCIO-RETURN-CODE
           MOVE ZERO TO WS-COUNT-DUP
           EXEC SQL
               SELECT COUNT(*)
                 INTO :WS-COUNT-DUP
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :SOCIO-RG
           END-EXEC
           IF SQLCODE NOT = ZERO
               SET SOCIO-RC-ERROR TO TRUE
               EXIT PARAGRAPH
           END-IF
           IF WS-COUNT-DUP > ZERO
               SET SOCIO-RC-DUPLICATE TO TRUE
               EXIT PARAGRAPH
           END-IF
           EXEC SQL
               INSERT INTO SOCIO (
                       NUMB_SOCIO_PRINCIPAL,
                       NOME_SOCIO_PRINCIPAL,
                       DATA_CADASTRO,
                       CATG_SOCIO,
                       INDI_DIVIDA,
                       OBSV_SOCIO)
               VALUES (
                       :SOCIO-RG,
                       :SOCIO-NOME,
                       CAST(:SOCIO-DATA-CADASTRO AS DATE),
                       :SOCIO-CATG,
                       :SOCIO-INDI-DIVIDA,
                       :SOCIO-OBSV)
           END-EXEC
           IF SQLCODE NOT = ZERO
               EXEC SQL ROLLBACK END-EXEC
               SET SOCIO-RC-ERROR TO TRUE
               EXIT PARAGRAPH
           END-IF
           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > WS-C-MAX-PARCELAS
               MOVE SOCIO-DATA-VENC (WS-IDX) TO WS-HV-DATA-VENC
               MOVE SOCIO-VALR-MENS (WS-IDX) TO WS-HV-VALR
               MOVE SOCIO-PAG-OK (WS-IDX) TO WS-HV-PAG-OK
               EXEC SQL
                   INSERT INTO SOCIO_PAGAMENTO (
                           NUMB_SOCIO_PRINCIPAL,
                           NR_PARCELA,
                           DATA_VENCIMENTO,
                           VALR_MENSALIDADE,
                           PAGAMENTO_OK)
                   VALUES (
                           :SOCIO-RG,
                           :WS-IDX,
                           CAST(:WS-HV-DATA-VENC AS DATE),
                           :WS-HV-VALR,
                           :WS-HV-PAG-OK)
               END-EXEC
               IF SQLCODE NOT = ZERO
                   EXEC SQL ROLLBACK END-EXEC
                   SET SOCIO-RC-ERROR TO TRUE
                   EXIT PARAGRAPH
               END-IF
           END-PERFORM
           EXEC SQL COMMIT END-EXEC
           IF SQLCODE NOT = ZERO
               SET SOCIO-RC-ERROR TO TRUE
               EXIT PARAGRAPH
           END-IF
           SET SOCIO-RC-OK TO TRUE
           .
