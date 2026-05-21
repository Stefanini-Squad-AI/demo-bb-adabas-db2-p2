       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00E.
      ******************************************************************
      * STFSC00E - EXCLUSAO SOCIO (DB2)                                 *
      * DBATDP-18: Migracao ADABAS -> COBOL/DB2                       *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA             PIC X(08) VALUE 'STFSC00E'.
       01  WS-CONST-VERSAO               PIC X(05) VALUE '01.00'.
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
           MOVE STFBKSC00-NUMB-SOCIO-PRINCIPAL TO HSOC-NUMB-SOCIO-PRINCIPAL
           MOVE HSOC-NUMB-SOCIO-PRINCIPAL TO HPER-NUMB-SOCIO-PRINCIPAL
           EXEC SQL
               DELETE FROM TB_SOCIO_PERIODICO_PAGAMENTO
                WHERE NUMB_SOCIO_PRINCIPAL = :HPER-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           IF SQLCODE NOT = 0 AND SQLCODE NOT = 100
               PERFORM TRATA-ERRO-GENERICO
               GO TO PROCESSA-FIM
           END-IF
           EXEC SQL
               DELETE FROM TB_SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HSOC-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE +0 TO STFBKSC00-RETORNO
                   EXEC SQL COMMIT END-EXEC
               WHEN 100
                   MOVE +100 TO STFBKSC00-RETORNO
               WHEN OTHER
                   PERFORM TRATA-ERRO-GENERICO
           END-EVALUATE
           .
       PROCESSA-FIM.
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
