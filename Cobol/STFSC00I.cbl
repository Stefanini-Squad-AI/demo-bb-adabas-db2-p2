       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * STFSC00I - INCLUSAO SOCIO (DB2)                                 *
      * DBATDP-18: Migracao ADABAS -> COBOL/DB2                       *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA             PIC X(08) VALUE 'STFSC00I'.
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
           PERFORM GRAVA-TB-SOCIO
           IF STFBKSC00-RETORNO = +0
               PERFORM GRAVA-TB-SOCIO-PERIODICO
           END-IF
           .
       GRAVA-TB-SOCIO.
           MOVE STFBKSC00-NUMB-SOCIO-PRINCIPAL TO HSOC-NUMB-SOCIO-PRINCIPAL
           MOVE STFBKSC00-NOME-SOCIO-PRINCIPAL TO HSOC-NOME-SOCIO-PRINCIPAL
           MOVE STFBKSC00-DATA-CADASTRO TO HSOC-DATA-CADASTRO
           MOVE STFBKSC00-CATG-SOCIO TO HSOC-CATG-SOCIO
           MOVE STFBKSC00-INDI-DIVIDA TO HSOC-INDI-DIVIDA
           MOVE STFBKSC00-DATA-BAIXA TO HSOC-DATA-BAIXA
           MOVE STFBKSC00-HORA-BAIXA TO HSOC-HORA-BAIXA
           MOVE STFBKSC00-OBSV-SOCIO TO HSOC-OBSV-SOCIO
           EXEC SQL
               INSERT INTO TB_SOCIO
                   (NUMB_SOCIO_PRINCIPAL,
                    NOME_SOCIO_PRINCIPAL,
                    DATA_CADASTRO,
                    CATG_SOCIO,
                    INDI_DIVIDA,
                    DATA_BAIXA,
                    HORA_BAIXA,
                    OBSV_SOCIO)
               VALUES
                   (:HSOC-NUMB-SOCIO-PRINCIPAL,
                    :HSOC-NOME-SOCIO-PRINCIPAL,
                    DATE(:HSOC-DATA-CADASTRO),
                    :HSOC-CATG-SOCIO,
                    :HSOC-INDI-DIVIDA,
                    DATE(:HSOC-DATA-BAIXA),
                    :HSOC-HORA-BAIXA,
                    :HSOC-OBSV-SOCIO)
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE +0 TO STFBKSC00-RETORNO
               WHEN -803
                   MOVE +803 TO STFBKSC00-RETORNO
               WHEN OTHER
                   PERFORM TRATA-ERRO-GENERICO
           END-EVALUATE
           .
       GRAVA-TB-SOCIO-PERIODICO.
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
               IF SQLCODE NOT = 0
                   PERFORM TRATA-ERRO-GENERICO
                   EXEC SQL ROLLBACK END-EXEC
                   GO TO GRAVA-TB-SOCIO-PERIODICO-FIM
               END-IF
           END-PERFORM
           EXEC SQL COMMIT END-EXEC
           .
       GRAVA-TB-SOCIO-PERIODICO-FIM.
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
