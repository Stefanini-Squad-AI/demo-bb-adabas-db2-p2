       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Inclusao de socio e 12 periodicos de pagamento - DB2            *
      * Return code: +000 ok, +803 chave duplicada, outros erro         *
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-PROGRAMA               PIC X(08) VALUE 'STFSC00I'.
       01  WS-VERSAO                 PIC X(05) VALUE '01.00'.
       01  WS-MAX-PERIODICO          PIC S9(04) COMP VALUE 12.
       01  WS-SEQ-PE                 PIC S9(04) COMP.
       01  WS-IND-PE                 PIC S9(04) COMP.
      *
       01  WS-HV-NUMB-SOCIO          PIC S9(09)V9(00) COMP-3.
       01  WS-HV-NOME                PIC X(40).
       01  WS-HV-DATA-CADASTRO       PIC X(10).
       01  WS-HV-CATG                PIC S9(04) COMP.
       01  WS-HV-INDI-DIVIDA         PIC X(01).
       01  WS-HV-DATA-BAIXA          PIC X(10).
       01  WS-HV-HORA-BAIXA          PIC X(05).
       01  WS-HV-OBSV                PIC X(500).
       01  WS-HV-SEQ-PE              PIC S9(04) COMP.
       01  WS-HV-DATA-VENC           PIC X(10).
       01  WS-HV-VALR-MENS           PIC S9(06)V9(02) COMP-3.
       01  WS-HV-PAGAMENTO-OK        PIC X(01).
      *
       LINKAGE SECTION.
           COPY STFSC00.
      *
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-INICIALIZADO            PIC X(01) VALUE 'N'.
      *
       PROCEDURE DIVISION USING STFSC00-AREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
      *
       INICIALIZA.
           MOVE 'I' TO STFSC00-ACAO
           MOVE ZERO TO STFSC00-RETURN-CODE
           .
      *
       PROCESSA.
           PERFORM GRAVA-SOCIO
           IF STFSC00-RC-OK
               PERFORM GRAVA-PERIODICO-PAGAMENTO
           END-IF
           .
      *
       GRAVA-SOCIO.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL TO WS-HV-NUMB-SOCIO
           MOVE STFSC00-NOME-SOCIO-PRINCIPAL TO WS-HV-NOME
           MOVE STFSC00-DATA-CADASTRO TO WS-HV-DATA-CADASTRO
           MOVE STFSC00-CATG-SOCIO TO WS-HV-CATG
           MOVE STFSC00-INDI-DIVIDA TO WS-HV-INDI-DIVIDA
           IF STFSC00-DATA-BAIXA = SPACES
               MOVE ' ' TO WS-HV-DATA-BAIXA
           ELSE
               MOVE STFSC00-DATA-BAIXA TO WS-HV-DATA-BAIXA
           END-IF
           IF STFSC00-HORA-BAIXA = SPACES
               MOVE ' ' TO WS-HV-HORA-BAIXA
           ELSE
               MOVE STFSC00-HORA-BAIXA TO WS-HV-HORA-BAIXA
           END-IF
           MOVE STFSC00-OBSV-SOCIO TO WS-HV-OBSV
           EXEC SQL
               INSERT INTO SOCIOS
                   (NUMB_SOCIO_PRINCIPAL,
                    NOME_SOCIO_PRINCIPAL,
                    DATA_CADASTRO,
                    CATG_SOCIO,
                    INDI_DIVIDA,
                    DATA_BAIXA,
                    HORA_BAIXA,
                    OBSV_SOCIO)
               VALUES
                   (:WS-HV-NUMB-SOCIO,
                    :WS-HV-NOME,
                    DATE(:WS-HV-DATA-CADASTRO),
                    :WS-HV-CATG,
                    :WS-HV-INDI-DIVIDA,
                    NULLIF(:WS-HV-DATA-BAIXA, ' '),
                    NULLIF(:WS-HV-HORA-BAIXA, ' '),
                    :WS-HV-OBSV)
           END-EXEC
           EVALUATE SQLCODE
               WHEN ZERO
                   MOVE +000 TO STFSC00-RETURN-CODE
               WHEN -803
                   MOVE +803 TO STFSC00-RETURN-CODE
               WHEN OTHER
                   PERFORM TRATA-ERRO-SQL
           END-EVALUATE
           .
      *
       GRAVA-PERIODICO-PAGAMENTO.
           IF STFSC00-C-PERIODICO-PAGAMENTO = ZERO
               MOVE WS-MAX-PERIODICO TO STFSC00-C-PERIODICO-PAGAMENTO
           END-IF
           PERFORM VARYING WS-IND-PE FROM 1 BY 1
               UNTIL WS-IND-PE > STFSC00-C-PERIODICO-PAGAMENTO
                  OR WS-IND-PE > WS-MAX-PERIODICO
               IF STFSC00-DATA-VENCIMENTO(WS-IND-PE) > SPACES
                   MOVE WS-IND-PE TO WS-HV-SEQ-PE
                   MOVE STFSC00-DATA-VENCIMENTO(WS-IND-PE)
                     TO WS-HV-DATA-VENC
                   MOVE STFSC00-VALR-MENSALIDADE(WS-IND-PE)
                     TO WS-HV-VALR-MENS
                   MOVE STFSC00-PAGAMENTO-OK(WS-IND-PE)
                     TO WS-HV-PAGAMENTO-OK
                   EXEC SQL
                       INSERT INTO SOCIOS_PERIODICO_PAGAMENTO
                           (NUMB_SOCIO_PRINCIPAL,
                            SEQ_PERIODICO,
                            DATA_VENCIMENTO,
                            VALR_MENSALIDADE,
                            PAGAMENTO_OK)
                       VALUES
                           (:WS-HV-NUMB-SOCIO,
                            :WS-HV-SEQ-PE,
                            DATE(:WS-HV-DATA-VENC),
                            :WS-HV-VALR-MENS,
                            :WS-HV-PAGAMENTO-OK)
                   END-EXEC
                   IF SQLCODE NOT = ZERO
                       PERFORM TRATA-ERRO-SQL
                       MOVE WS-MAX-PERIODICO TO WS-IND-PE
                   END-IF
               END-IF
           END-PERFORM
           .
      *
       TRATA-ERRO-SQL.
           MOVE SQLCODE TO STFSC00-RETURN-CODE
           .
      *
       FINALIZA.
           .
       END PROGRAM STFSC00I.
