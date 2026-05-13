       IDENTIFICATION DIVISION.
       PROGRAM-ID. SOCIOCON.
      ******************************************************************
      * Consulta sócio por identificador principal + filhos pagamento.
      * Retornos: 00 ok, 01 não encontrado, 99 erro SQL.
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * Constantes fixas (sem SQLCA / hosts aqui).
           05 WS-FILLER                   PIC X VALUE SPACE.

       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.

           05 LS-IDX                      PIC 9(03).

           05 LS-HV-DATA-VENC            PIC X(10).
           05 LS-HV-VALR                 PIC S9(6)V9(2) DISPLAY.
           05 LS-HV-PAG-OK               PIC X(01).

       LINKAGE SECTION.
           COPY SOCIOLNK.

       PROCEDURE DIVISION USING SOCIO-LNK-AREA.

       MAIN-LOGIC.
           MOVE SPACES TO SOCIO-LNK-RETCODE
           MOVE ZEROES TO SOCIO-LNK-PAG-QTD

           EXEC SQL
               SELECT VARCHAR_FORMAT(DATA_CADASTRO, 'YYYY-MM-DD'),
                      NOME_SOCIO_PRINCIPAL,
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      COALESCE(VARCHAR_FORMAT(DATA_BAIXA, 'YYYY-MM-DD'),
                               ''),
                      COALESCE(HORA_BAIXA, ''),
                      OBSV_CLIENTE
                 INTO :SOCIO-LNK-DATA-CAD,
                      :SOCIO-LNK-NOME,
                      :SOCIO-LNK-CATG,
                      :SOCIO-LNK-INDI-DIVIDA,
                      :SOCIO-LNK-DATA-BAIXA,
                      :SOCIO-LNK-HORA-BAIXA,
                      :SOCIO-LNK-OBSV
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :SOCIO-LNK-NUMB
           END-EXEC

           EVALUATE SQLCODE
               WHEN +100
                   MOVE '01' TO SOCIO-LNK-RETCODE
                   GOBACK
               WHEN ZERO
                   CONTINUE
               WHEN OTHER
                   MOVE '99' TO SOCIO-LNK-RETCODE
                   GOBACK
           END-EVALUATE

           PERFORM LOAD-PAGAMENTOS THRU LOAD-PAGAMENTOS-EXIT

           IF SOCIO-LNK-PAG-QTD = ZERO
               MOVE '99' TO SOCIO-LNK-RETCODE
               GOBACK
           END-IF

           MOVE '00' TO SOCIO-LNK-RETCODE
           GOBACK
           .

       LOAD-PAGAMENTOS.
           PERFORM VARYING LS-IDX FROM 1 BY 1 UNTIL LS-IDX > 12
               EXEC SQL
                   SELECT VARCHAR_FORMAT(DATA_VENCIMENTO, 'YYYY-MM-DD'),
                          VALR_MENSALIDADE,
                          PAGAMENTO_OK
                     INTO :LS-HV-DATA-VENC,
                          :LS-HV-VALR,
                          :LS-HV-PAG-OK
                     FROM SOCIO_PAGAMENTO
                    WHERE NUMB_SOCIO_PRINCIPAL = :SOCIO-LNK-NUMB
                      AND SEQ_PAGAMENTO = :LS-IDX
               END-EXEC
               EVALUATE SQLCODE
                   WHEN ZERO
                       ADD 1 TO SOCIO-LNK-PAG-QTD
                       MOVE LS-HV-DATA-VENC
                         TO SOCIO-LNK-PAG-DATA-VENC (LS-IDX)
                       MOVE LS-HV-VALR
                         TO SOCIO-LNK-PAG-VALR (LS-IDX)
                       MOVE LS-HV-PAG-OK
                         TO SOCIO-LNK-PAG-OK (LS-IDX)
                   WHEN +100
                       CONTINUE
                   WHEN OTHER
                       MOVE '99' TO SOCIO-LNK-RETCODE
                       MOVE 12 TO LS-IDX
               END-EVALUATE
           END-PERFORM
           .
       LOAD-PAGAMENTOS-EXIT.
           EXIT
           .
