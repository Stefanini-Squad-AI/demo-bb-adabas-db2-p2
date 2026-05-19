       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Inclusao socio (ADABAS STORE) via DB2                          *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA             PIC X(08) VALUE 'STFSC00I'.
       01  WS-CONST-OPERACAO             PIC X(01) VALUE 'I'.
       01  WS-CONST-RC-OK                PIC S9(09) COMP VALUE +0.
       01  WS-CONST-RC-DUPKEY            PIC S9(09) COMP VALUE +803.
       01  WS-CONST-MAX-PER              PIC 9(03) VALUE 12.
       01  WS-CONST-IND-SIM              PIC X(01) VALUE 'Y'.
       01  WS-CONST-IND-NAO              PIC X(01) VALUE 'N'.
       01  WS-MSG-INCLUSAO-OK            PIC X(50)
           VALUE 'INCLUSAO REALIZADA COM SUCESSO'.
      *
       LOCAL-STORAGE SECTION.
       01  LCL-SQLCA.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LCL-HV-NUMB-SOCIO-PRINCIPAL     PIC S9(09) COMP-3.
       01  LCL-HV-NOME-SOCIO-PRINCIPAL     PIC X(40).
       01  LCL-HV-DATA-CADASTRO            PIC X(10).
       01  LCL-HV-CATG-SOCIO               PIC S9(04) COMP.
       01  LCL-HV-INDI-DIVIDA              PIC X(01).
       01  LCL-HV-DATA-BAIXA               PIC X(10).
       01  LCL-HV-HORA-BAIXA               PIC X(08).
       01  LCL-HV-OBSV-SOCIO               PIC X(500).
       01  LCL-HV-SEQ-PERIODO              PIC S9(09) COMP.
       01  LCL-HV-DATA-VENCIMENTO          PIC X(10).
       01  LCL-HV-VALR-MENSALIDADE         PIC S9(06)V9(02) COMP-3.
       01  LCL-HV-PAGAMENTO-OK             PIC X(01).
       01  LCL-IDX-PER                     PIC 9(03).
       01  LCL-DT-WORK                     PIC X(10).
       01  LCL-HR-WORK                     PIC X(08).
      *
       LINKAGE SECTION.
       01  LNK-STFSC00-COMUNICACAO.
           COPY STFSC00B.
      *
       PROCEDURE DIVISION USING LNK-STFSC00-COMUNICACAO.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
      *
       INICIALIZA.
           MOVE WS-CONST-OPERACAO TO STFSC00-OPERACAO OF LNK-STFSC00-COMUNICACAO
           MOVE ZERO TO STFSC00-SQLCODE OF LNK-STFSC00-COMUNICACAO
           .
      *
       PROCESSA.
           PERFORM 1000-MONTA-HOST-PRINCIPAL
           EXEC SQL
               INSERT INTO STF_SOCIO
                   (NUMB_SOCIO_PRINCIPAL,
                    NOME_SOCIO_PRINCIPAL,
                    DATA_CADASTRO,
                    CATG_SOCIO,
                    INDI_DIVIDA,
                    DATA_BAIXA,
                    HORA_BAIXA,
                    OBSV_SOCIO)
               VALUES
                   (:LCL-HV-NUMB-SOCIO-PRINCIPAL,
                    :LCL-HV-NOME-SOCIO-PRINCIPAL,
                    DATE(:LCL-HV-DATA-CADASTRO),
                    :LCL-HV-CATG-SOCIO,
                    :LCL-HV-INDI-DIVIDA,
                    NULLIF(:LCL-HV-DATA-BAIXA, '          '),
                    NULLIF(:LCL-HV-HORA-BAIXA, '        '),
                    :LCL-HV-OBSV-SOCIO)
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   PERFORM 2000-INSERE-PERIODICOS
               WHEN -803
                   MOVE WS-CONST-RC-DUPKEY TO STFSC00-SQLCODE OF
                       LNK-STFSC00-COMUNICACAO
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-SQLCODE OF LNK-STFSC00-COMUNICACAO
           END-EVALUATE
           .
      *
       FINALIZA.
           CONTINUE
           .
      *
       1000-MONTA-HOST-PRINCIPAL.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL OF LNK-STFSC00-COMUNICACAO
               TO LCL-HV-NUMB-SOCIO-PRINCIPAL
           MOVE STFSC00-NOME-SOCIO-PRINCIPAL OF LNK-STFSC00-COMUNICACAO
               TO LCL-HV-NOME-SOCIO-PRINCIPAL
           MOVE STFSC00-DATA-CADASTRO OF LNK-STFSC00-COMUNICACAO
               TO LCL-HV-DATA-CADASTRO
           MOVE STFSC00-CATG-SOCIO OF LNK-STFSC00-COMUNICACAO
               TO LCL-HV-CATG-SOCIO
           IF STFSC00-INDI-DIVIDA OF LNK-STFSC00-COMUNICACAO = WS-CONST-IND-SIM
               MOVE WS-CONST-IND-SIM TO LCL-HV-INDI-DIVIDA
           ELSE
               MOVE WS-CONST-IND-NAO TO LCL-HV-INDI-DIVIDA
           END-IF
           MOVE STFSC00-DATA-BAIXA OF LNK-STFSC00-COMUNICACAO
               TO LCL-HV-DATA-BAIXA
           IF LCL-HV-DATA-BAIXA = SPACES
               MOVE '          ' TO LCL-HV-DATA-BAIXA
           END-IF
           MOVE STFSC00-HORA-BAIXA OF LNK-STFSC00-COMUNICACAO
               TO LCL-HV-HORA-BAIXA
           IF LCL-HV-HORA-BAIXA = SPACES
               MOVE '        ' TO LCL-HV-HORA-BAIXA
           END-IF
           MOVE STFSC00-OBSV-SOCIO OF LNK-STFSC00-COMUNICACAO
               TO LCL-HV-OBSV-SOCIO
           .
      *
       2000-INSERE-PERIODICOS.
           PERFORM VARYING LCL-IDX-PER FROM 1 BY 1
               UNTIL LCL-IDX-PER > WS-CONST-MAX-PER
               IF STFSC00-DATA-VENCIMENTO OF LNK-STFSC00-COMUNICACAO
                       (LCL-IDX-PER) NOT = SPACES
                   MOVE LCL-IDX-PER TO LCL-HV-SEQ-PERIODO
                   MOVE STFSC00-DATA-VENCIMENTO OF LNK-STFSC00-COMUNICACAO
                       (LCL-IDX-PER) TO LCL-HV-DATA-VENCIMENTO
                   MOVE STFSC00-VALR-MENSALIDADE OF LNK-STFSC00-COMUNICACAO
                       (LCL-IDX-PER) TO LCL-HV-VALR-MENSALIDADE
                   IF STFSC00-PAGAMENTO-OK OF LNK-STFSC00-COMUNICACAO
                           (LCL-IDX-PER) = WS-CONST-IND-SIM
                       MOVE WS-CONST-IND-SIM TO LCL-HV-PAGAMENTO-OK
                   ELSE
                       MOVE WS-CONST-IND-NAO TO LCL-HV-PAGAMENTO-OK
                   END-IF
                   EXEC SQL
                       INSERT INTO STF_SOCIO_PER_PAGTO
                           (NUMB_SOCIO_PRINCIPAL,
                            SEQ_PERIODO,
                            DATA_VENCIMENTO,
                            VALR_MENSALIDADE,
                            PAGAMENTO_OK)
                       VALUES
                           (:LCL-HV-NUMB-SOCIO-PRINCIPAL,
                            :LCL-HV-SEQ-PERIODO,
                            DATE(:LCL-HV-DATA-VENCIMENTO),
                            :LCL-HV-VALR-MENSALIDADE,
                            :LCL-HV-PAGAMENTO-OK)
                   END-EXEC
                   IF SQLCODE NOT = 0
                       MOVE SQLCODE TO STFSC00-SQLCODE OF
                           LNK-STFSC00-COMUNICACAO
                       GO TO 2000-EXIT
                   END-IF
               END-IF
           END-PERFORM
           IF STFSC00-SQLCODE OF LNK-STFSC00-COMUNICACAO = ZERO
               MOVE WS-CONST-RC-OK TO STFSC00-SQLCODE OF
                   LNK-STFSC00-COMUNICACAO
           END-IF
           .
       2000-EXIT.
           EXIT.
      *
       END PROGRAM STFSC00I.
