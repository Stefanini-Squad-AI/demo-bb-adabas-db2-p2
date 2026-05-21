       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00A.
      ******************************************************************
      * STFSC00A - ALTERACAO SOCIO (DB2)                                *
      * DBATDP-18: Migracao ADABAS -> COBOL/DB2                       *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA             PIC X(08) VALUE 'STFSC00A'.
       01  WS-CONST-VERSAO               PIC X(05) VALUE '01.00'.
       01  WS-IDX-PER                    PIC 9(02) VALUE 0.
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
           .
       PROCESSA.
           PERFORM ATUALIZA-TB-SOCIO
           IF STFBKSC00-RETORNO = +0
               PERFORM ATUALIZA-TB-SOCIO-PERIODICO
           END-IF
           .
       ATUALIZA-TB-SOCIO.
           MOVE STFBKSC00-NUMB-SOCIO-PRINCIPAL TO HSOC-NUMB-SOCIO-PRINCIPAL
           MOVE STFBKSC00-NOME-SOCIO-PRINCIPAL TO HSOC-NOME-SOCIO-PRINCIPAL
           MOVE STFBKSC00-DATA-CADASTRO TO HSOC-DATA-CADASTRO
           MOVE STFBKSC00-CATG-SOCIO TO HSOC-CATG-SOCIO
           MOVE STFBKSC00-INDI-DIVIDA TO HSOC-INDI-DIVIDA
           MOVE STFBKSC00-DATA-BAIXA TO HSOC-DATA-BAIXA
           MOVE STFBKSC00-HORA-BAIXA TO HSOC-HORA-BAIXA
           MOVE STFBKSC00-OBSV-SOCIO TO HSOC-OBSV-SOCIO
           EXEC SQL
               UPDATE TB_SOCIO
                  SET NOME_SOCIO_PRINCIPAL = :HSOC-NOME-SOCIO-PRINCIPAL,
                      DATA_CADASTRO = DATE(:HSOC-DATA-CADASTRO),
                      CATG_SOCIO = :HSOC-CATG-SOCIO,
                      INDI_DIVIDA = :HSOC-INDI-DIVIDA,
                      DATA_BAIXA = DATE(:HSOC-DATA-BAIXA),
                      HORA_BAIXA = :HSOC-HORA-BAIXA,
                      OBSV_SOCIO = :HSOC-OBSV-SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HSOC-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE +0 TO STFBKSC00-RETORNO
               WHEN 100
                   MOVE +100 TO STFBKSC00-RETORNO
               WHEN OTHER
                   PERFORM TRATA-ERRO-GENERICO
           END-EVALUATE
           .
       ATUALIZA-TB-SOCIO-PERIODICO.
           PERFORM VARYING WS-IDX-PER FROM 1 BY 1
               UNTIL WS-IDX-PER > STFBKSC00-QTD-PERIODICO
               OR WS-IDX-PER > 12
               MOVE STFBKSC00-NUMB-SOCIO-PRINCIPAL
                   TO HPER-NUMB-SOCIO-PRINCIPAL
               MOVE STFBKSC00-SEQ-PERIODICO(WS-IDX-PER)
                   TO HPER-SEQ-PERIODICO
               MOVE STFBKSC00-DATA-VENCIMENTO(WS-IDX-PER)
                   TO HPER-DATA-VENCIMENTO
               MOVE STFBKSC00-VALR-MENSALIDADE(WS-IDX-PER)
                   TO HPER-VALR-MENSALIDADE
               MOVE STFBKSC00-PAGAMENTO-OK(WS-IDX-PER)
                   TO HPER-PAGAMENTO-OK
               EXEC SQL
                   UPDATE TB_SOCIO_PERIODICO_PAGAMENTO
                      SET DATA_VENCIMENTO = DATE(:HPER-DATA-VENCIMENTO),
                          VALR_MENSALIDADE = :HPER-VALR-MENSALIDADE,
                          PAGAMENTO_OK = :HPER-PAGAMENTO-OK
                    WHERE NUMB_SOCIO_PRINCIPAL = :HPER-NUMB-SOCIO-PRINCIPAL
                      AND SEQ_PERIODICO = :HPER-SEQ-PERIODICO
               END-EXEC
               IF SQLCODE = 100
                   EXEC SQL
                       INSERT INTO TB_SOCIO_PERIODICO_PAGAMENTO
                           (NUMB_SOCIO_PRINCIPAL,
                            SEQ_PERIODICO,
                            DATA_VENCIMENTO,
                            VALR_MENSALIDADE,
                            PAGAMENTO_OK)
                       VALUES
                           (:HPER-NUMB-SOCIO-PRINCIPAL,
                            :HPER-SEQ-PERIODICO,
                            DATE(:HPER-DATA-VENCIMENTO),
                            :HPER-VALR-MENSALIDADE,
                            :HPER-PAGAMENTO-OK)
                   END-EXEC
               END-IF
               IF SQLCODE NOT = 0 AND SQLCODE NOT = 100
                   PERFORM TRATA-ERRO-GENERICO
                   EXEC SQL ROLLBACK END-EXEC
                   GO TO ATUALIZA-TB-SOCIO-PERIODICO-FIM
               END-IF
           END-PERFORM
           EXEC SQL COMMIT END-EXEC
           .
       ATUALIZA-TB-SOCIO-PERIODICO-FIM.
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
