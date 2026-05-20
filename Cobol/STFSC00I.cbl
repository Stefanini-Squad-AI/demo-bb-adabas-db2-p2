       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
       AUTHOR. STEFANINI-MIGRACAO-ADABAS-DB2.
       DATE-WRITTEN. 2026-05-20.
      ******************************************************************
      * Inclusao de socio e linhas periodicas de pagamento (1:N)
      * Substitui STORE no Adabas - retorno +000 / +803 / outros SQL
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA               PIC X(08) VALUE 'STFSC00I'.
       01  WS-CONST-ACAO-VALIDA            PIC X(01) VALUE 'I'.
       01  WS-CONST-MAX-PERIODICO          PIC 9(02) VALUE 12.
       01  WS-IDX                          PIC 9(02).
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-HOST-VARS.
           05  HV-NUMB-SOCIO-PRINCIPAL     PIC S9(09) COMP-3.
           05  HV-NOME-SOCIO-PRINCIPAL     PIC X(40).
           05  HV-DATA-CADASTRO            PIC X(10).
           05  HV-CATG-SOCIO               PIC S9(04) COMP.
           05  HV-INDI-DIVIDA              PIC X(01).
           05  HV-DATA-BAIXA               PIC X(10).
           05  HV-HORA-BAIXA               PIC X(08).
           05  HV-OBSV-SOCIO               PIC X(500).
           05  HV-SEQ-PERIODO              PIC S9(04) COMP.
           05  HV-DATA-VENCIMENTO          PIC X(10).
           05  HV-VALR-MENSALIDADE         PIC S9(06)V9(02) COMP-3.
           05  HV-PAGAMENTO-OK             PIC X(01).
           05  HV-IND-DATA-BAIXA           PIC S9(04) COMP.
           05  HV-IND-HORA-BAIXA          PIC S9(04) COMP.
       LINKAGE SECTION.
           COPY STFSOCIO.
       PROCEDURE DIVISION USING STFSOCIO-LINKAGE.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           GOBACK.
       INICIALIZA.
           MOVE ZEROES TO WS-RETORNO-CODIGO
           IF NOT WS-ACAO-INCLUSAO
               MOVE +100 TO WS-RETORNO-CODIGO
           END-IF
           .
       PROCESSA.
           IF WS-RETORNO-CODIGO NOT = ZERO
               GO TO PROCESSA-FIM
           END-IF
           PERFORM GRAVA-SOCIO
           IF WS-RETORNO-CODIGO NOT = ZERO
               GO TO PROCESSA-FIM
           END-IF
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > C-PERIODICO-PAGAMENTO
                  OR WS-IDX > WS-CONST-MAX-PERIODICO
              PERFORM GRAVA-PERIODICO
           END-PERFORM
           IF WS-RETORNO-CODIGO = ZERO
               EXEC SQL COMMIT END-EXEC
           ELSE
               EXEC SQL ROLLBACK END-EXEC
           END-IF
           .
       PROCESSA-FIM.
           EXIT.
       GRAVA-SOCIO.
           MOVE NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO-PRINCIPAL
           MOVE NOME-SOCIO-PRINCIPAL TO HV-NOME-SOCIO-PRINCIPAL
           MOVE DATA-CADASTRO TO HV-DATA-CADASTRO
           MOVE CATG-SOCIO TO HV-CATG-SOCIO
           MOVE INDI-DIVIDA TO HV-INDI-DIVIDA
           MOVE OBSV-SOCIO TO HV-OBSV-SOCIO
           IF DATA-BAIXA = SPACES OR LOW-VALUES
               MOVE -1 TO HV-IND-DATA-BAIXA
           ELSE
               MOVE ZERO TO HV-IND-DATA-BAIXA
               MOVE DATA-BAIXA TO HV-DATA-BAIXA
           END-IF
           IF HORA-BAIXA = SPACES OR LOW-VALUES
               MOVE -1 TO HV-IND-HORA-BAIXA
           ELSE
               MOVE ZERO TO HV-IND-HORA-BAIXA
               MOVE HORA-BAIXA TO HV-HORA-BAIXA
           END-IF
           EXEC SQL
               INSERT INTO TB_SOCIO
                 ( NUMB_SOCIO_PRINCIPAL
                 , NOME_SOCIO_PRINCIPAL
                 , DATA_CADASTRO
                 , CATG_SOCIO
                 , INDI_DIVIDA
                 , DATA_BAIXA
                 , HORA_BAIXA
                 , OBSV_SOCIO )
               VALUES
                 ( :HV-NUMB-SOCIO-PRINCIPAL
                 , :HV-NOME-SOCIO-PRINCIPAL
                 , DATE(:HV-DATA-CADASTRO)
                 , :HV-CATG-SOCIO
                 , :HV-INDI-DIVIDA
                 , :HV-DATA-BAIXA:HV-IND-DATA-BAIXA
                 , :HV-HORA-BAIXA:HV-IND-HORA-BAIXA
                 , :HV-OBSV-SOCIO )
           END-EXEC
           PERFORM TRATA-SQLCODE
           .
       GRAVA-PERIODICO.
           MOVE WS-IDX TO HV-SEQ-PERIODO
           MOVE DATA-VENCIMENTO (WS-IDX) TO HV-DATA-VENCIMENTO
           MOVE VALR-MENSALIDADE (WS-IDX) TO HV-VALR-MENSALIDADE
           MOVE PAGAMENTO-OK (WS-IDX) TO HV-PAGAMENTO-OK
           EXEC SQL
               INSERT INTO TB_SOCIO_PERIODICO_PAGAMENTO
                 ( NUMB_SOCIO_PRINCIPAL
                 , SEQ_PERIODO
                 , DATA_VENCIMENTO
                 , VALR_MENSALIDADE
                 , PAGAMENTO_OK )
               VALUES
                 ( :HV-NUMB-SOCIO-PRINCIPAL
                 , :HV-SEQ-PERIODO
                 , DATE(:HV-DATA-VENCIMENTO)
                 , :HV-VALR-MENSALIDADE
                 , :HV-PAGAMENTO-OK )
           END-EXEC
           PERFORM TRATA-SQLCODE
           .
       TRATA-SQLCODE.
           EVALUATE SQLCODE
               WHEN 0
                   MOVE ZERO TO WS-RETORNO-CODIGO
               WHEN -803
                   MOVE +803 TO WS-RETORNO-CODIGO
               WHEN +100
                   MOVE +100 TO WS-RETORNO-CODIGO
               WHEN OTHER
                   MOVE SQLCODE TO WS-RETORNO-CODIGO
           END-EVALUATE
           .
       FINALIZA.
           .
