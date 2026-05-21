       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * STFSC00C - CONSULTA SOCIO (DB2)                                 *
      * DBATDP-18: Migracao ADABAS -> COBOL/DB2                       *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA             PIC X(08) VALUE 'STFSC00C'.
       01  WS-CONST-VERSAO               PIC X(05) VALUE '01.00'.
       01  WS-CONT-PER                   PIC 9(02) VALUE 0.
           EXEC SQL
               DECLARE CSR_SOCIO_PERIODICO CURSOR FOR
                   SELECT SEQ_PERIODICO,
                          CHAR(DATA_VENCIMENTO, ISO),
                          VALR_MENSALIDADE,
                          PAGAMENTO_OK
                     FROM TB_SOCIO_PERIODICO_PAGAMENTO
                    WHERE NUMB_SOCIO_PRINCIPAL = :HPER-NUMB-SOCIO-PRINCIPAL
                    ORDER BY SEQ_PERIODICO
           END-EXEC.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-ENTIDADE.
           COPY STFBKSOC.
       LINKAGE SECTION.
       01  LNK-STFBKSC00-COMUNICACAO.
           COPY STFBKSC00.
       PROCEDURE DIVISION USING LNK-STFBKSC00-COMUNICACAO.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
       INICIALIZA.
           MOVE ZERO TO STFBKSC00-RETORNO
           MOVE ZERO TO STFBKSC00-QTD-PERIODICO
           MOVE ZERO TO WS-CONT-PER
           PERFORM VARYING STFBKSC00-IDX-PER FROM 1 BY 1
               UNTIL STFBKSC00-IDX-PER > 12
               MOVE ZERO TO STFBKSC00-SEQ-PERIODICO(STFBKSC00-IDX-PER)
               MOVE SPACES TO STFBKSC00-DATA-VENCIMENTO(STFBKSC00-IDX-PER)
               MOVE ZERO TO STFBKSC00-VALR-MENSALIDADE(STFBKSC00-IDX-PER)
               MOVE 'F' TO STFBKSC00-PAGAMENTO-OK(STFBKSC00-IDX-PER)
           END-PERFORM
           .
       PROCESSA.
           MOVE STFBKSC00-NUMB-SOCIO-PRINCIPAL TO HSOC-NUMB-SOCIO-PRINCIPAL
           MOVE HSOC-NUMB-SOCIO-PRINCIPAL TO HPER-NUMB-SOCIO-PRINCIPAL
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CHAR(DATA_BAIXA, ISO),
                      HORA_BAIXA,
                      OBSV_SOCIO
                 INTO :HSOC-NOME-SOCIO-PRINCIPAL:IND-HSOC-NOME,
                      :HSOC-DATA-CADASTRO:IND-HSOC-DATA-CAD,
                      :HSOC-CATG-SOCIO:IND-HSOC-CATG,
                      :HSOC-INDI-DIVIDA:IND-HSOC-INDI-DIV,
                      :HSOC-DATA-BAIXA:IND-HSOC-DATA-BAIXA,
                      :HSOC-HORA-BAIXA:IND-HSOC-HORA-BAIXA,
                      :HSOC-OBSV-SOCIO:IND-HSOC-OBSV
                 FROM TB_SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HSOC-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   PERFORM CARREGA-TB-SOCIO-PER-CURSOR
               WHEN 100
                   MOVE +100 TO STFBKSC00-RETORNO
               WHEN OTHER
                   PERFORM TRATA-ERRO-GENERICO
           END-EVALUATE
           .
       CARREGA-TB-SOCIO-PER-CURSOR.
           EXEC SQL OPEN CSR_SOCIO_PERIODICO END-EXEC
           IF SQLCODE NOT = 0
               PERFORM TRATA-ERRO-GENERICO
               GO TO CARREGA-TB-SOCIO-PER-FIM
           END-IF
           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL
                   FETCH CSR_SOCIO_PERIODICO
                    INTO :HPER-SEQ-PERIODICO:IND-HPER-SEQ,
                         :HPER-DATA-VENCIMENTO:IND-HPER-DATA-VENC,
                         :HPER-VALR-MENSALIDADE:IND-HPER-VALR,
                         :HPER-PAGAMENTO-OK:IND-HPER-PAG-OK
               END-EXEC
               IF SQLCODE = 0
                   ADD 1 TO WS-CONT-PER
                   IF WS-CONT-PER <= 12
                       MOVE WS-CONT-PER TO STFBKSC00-IDX-PER
                       MOVE HPER-SEQ-PERIODICO
                           TO STFBKSC00-SEQ-PERIODICO(STFBKSC00-IDX-PER)
                       MOVE HPER-DATA-VENCIMENTO
                           TO STFBKSC00-DATA-VENCIMENTO(STFBKSC00-IDX-PER)
                       MOVE HPER-VALR-MENSALIDADE
                           TO STFBKSC00-VALR-MENSALIDADE(STFBKSC00-IDX-PER)
                       MOVE HPER-PAGAMENTO-OK
                           TO STFBKSC00-PAGAMENTO-OK(STFBKSC00-IDX-PER)
                   END-IF
               END-IF
           END-PERFORM
           EXEC SQL CLOSE CSR_SOCIO_PERIODICO END-EXEC
           MOVE WS-CONT-PER TO STFBKSC00-QTD-PERIODICO
           MOVE HSOC-NOME-SOCIO-PRINCIPAL
               TO STFBKSC00-NOME-SOCIO-PRINCIPAL
           MOVE HSOC-DATA-CADASTRO TO STFBKSC00-DATA-CADASTRO
           MOVE HSOC-CATG-SOCIO TO STFBKSC00-CATG-SOCIO
           MOVE HSOC-INDI-DIVIDA TO STFBKSC00-INDI-DIVIDA
           MOVE HSOC-DATA-BAIXA TO STFBKSC00-DATA-BAIXA
           MOVE HSOC-HORA-BAIXA TO STFBKSC00-HORA-BAIXA
           MOVE HSOC-OBSV-SOCIO TO STFBKSC00-OBSV-SOCIO
           MOVE +0 TO STFBKSC00-RETORNO
           .
       CARREGA-TB-SOCIO-PER-FIM.
           EXIT.
       TRATA-ERRO-GENERICO.
           IF SQLCODE = -803
               MOVE +803 TO STFBKSC00-RETORNO
           ELSE
               MOVE SQLCODE TO STFBKSC00-RETORNO
           END-IF
           .
       FINALIZA.
           .
