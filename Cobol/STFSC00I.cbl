       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Inclusao socio ADABAS-SOCIOS via DB2 (DBATDP-17)
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA            PIC X(08) VALUE 'STFSC00I'.
       01  WS-CONST-VERSAO              PIC X(04) VALUE '0001'.
      *
       LINKAGE SECTION.
           COPY STFSCB00.
      *
       LOCAL-STORAGE SECTION.
       01  LS-SQLCA.
           EXEC SQL INCLUDE SQLCA END-EXEC.
      *
       01  HV-NUMB-SOCIO                 PIC S9(09) COMP-3.
       01  HV-NOME                       PIC X(40).
       01  HV-DATA-CAD                   PIC X(10).
       01  HV-CATG                       PIC S9(04) COMP.
       01  HV-INDI-DIVIDA                PIC X(01).
       01  HV-DATA-BAIXA                 PIC X(10).
       01  HV-HORA-BAIXA                 PIC X(05).
       01  HV-OBSV                       PIC X(500).
       01  HV-SEQ-PE                     PIC S9(04) COMP.
       01  HV-DATA-VENC                  PIC X(10).
       01  HV-VALR-MENS                  PIC S9(06)V9(02) COMP-3.
       01  HV-PAG-OK                     PIC X(01).
       01  WS-IDX                        PIC 9(03) COMP.
       01  WS-SQLCODE-N                  PIC S9(09) COMP.
       01  WS-RC-EDIT                    PIC Z(04)9.
      *
       PROCEDURE DIVISION USING STFSCB00-COMUNICACAO.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           GOBACK.
      *
       INICIALIZA.
           MOVE SPACES TO STFSCB00-RETURN-CODE
           .
      *
       PROCESSA.
           IF NOT STFSCB00-OP-INCLUSAO
               MOVE '+0099' TO STFSCB00-RETURN-CODE
               GO TO PROCESSA-EXIT
           END-IF
           MOVE STFSCB00-NUMB-SOCIO-PRINC TO HV-NUMB-SOCIO
           MOVE STFSCB00-NOME-SOCIO-PRINC   TO HV-NOME
           MOVE STFSCB00-DATA-CADASTRO     TO HV-DATA-CAD
           MOVE STFSCB00-CATG-SOCIO        TO HV-CATG
           MOVE STFSCB00-INDI-DIVIDA       TO HV-INDI-DIVIDA
           MOVE STFSCB00-DATA-BAIXA        TO HV-DATA-BAIXA
           MOVE STFSCB00-HORA-BAIXA        TO HV-HORA-BAIXA
           MOVE STFSCB00-OBSV-SOCIO        TO HV-OBSV
           IF HV-INDI-DIVIDA = SPACES
               MOVE 'N' TO HV-INDI-DIVIDA
           END-IF
           EXEC SQL
               INSERT INTO ADABAS_SOCIOS
                   (NUMB_SOCIO_PRINCIPAL,
                    NOME_SOCIO_PRINCIPAL,
                    DATA_CADASTRO,
                    CATG_SOCIO,
                    INDI_DIVIDA,
                    DATA_BAIXA,
                    HORA_BAIXA,
                    OBSV_SOCIO)
               VALUES
                   (:HV-NUMB-SOCIO,
                    :HV-NOME,
                    DATE(:HV-DATA-CAD),
                    :HV-CATG,
                    :HV-INDI-DIVIDA,
                    CASE WHEN TRIM(:HV-DATA-BAIXA) = ' '
                         THEN NULL ELSE DATE(:HV-DATA-BAIXA) END,
                    CASE WHEN TRIM(:HV-HORA-BAIXA) = ' '
                         THEN NULL ELSE :HV-HORA-BAIXA END,
                    :HV-OBSV)
           END-EXEC
           PERFORM TRATA-SQLCODE-INCLUSAO
           IF STFSCB00-RETURN-CODE NOT = '+0000'
               GO TO PROCESSA-EXIT
           END-IF
           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 12
               MOVE WS-IDX TO HV-SEQ-PE
               MOVE STFSCB00-DATA-VENC(WS-IDX) TO HV-DATA-VENC
               MOVE STFSCB00-VALR-MENSAL(WS-IDX) TO HV-VALR-MENS
               MOVE STFSCB00-PAGAMENTO-OK(WS-IDX) TO HV-PAG-OK
               IF HV-PAG-OK = SPACES
                   MOVE 'N' TO HV-PAG-OK
               END-IF
               EXEC SQL
                   INSERT INTO ADABAS_SOCIOS_PERIODICO_PAGAMENTO
                       (NUMB_SOCIO_PRINCIPAL,
                        SEQ_PERIODICO,
                        DATA_VENCIMENTO,
                        VALR_MENSALIDADE,
                        PAGAMENTO_OK)
                   VALUES
                       (:HV-NUMB-SOCIO,
                        :HV-SEQ-PE,
                        DATE(:HV-DATA-VENC),
                        :HV-VALR-MENS,
                        :HV-PAG-OK)
               END-EXEC
               IF SQLCODE NOT = 0
                   PERFORM FORMATA-RETURN-CODE
                   GO TO PROCESSA-EXIT
               END-IF
           END-PERFORM
           MOVE '+0000' TO STFSCB00-RETURN-CODE
           .
       PROCESSA-EXIT.
           EXIT.
      *
       TRATA-SQLCODE-INCLUSAO.
           EVALUATE SQLCODE
               WHEN 0
                   MOVE '+0000' TO STFSCB00-RETURN-CODE
               WHEN -803
                   MOVE '+0803' TO STFSCB00-RETURN-CODE
               WHEN OTHER
                   PERFORM FORMATA-RETURN-CODE
           END-EVALUATE
           .
      *
       FORMATA-RETURN-CODE.
           MOVE SQLCODE TO WS-SQLCODE-N
           IF WS-SQLCODE-N >= 0
               MOVE WS-SQLCODE-N TO WS-RC-EDIT
               STRING '+' DELIMITED BY SIZE
                      WS-RC-EDIT DELIMITED BY SIZE
                 INTO STFSCB00-RETURN-CODE
           ELSE
               MOVE WS-SQLCODE-N TO WS-RC-EDIT
               STRING '-' DELIMITED BY SIZE
                      WS-RC-EDIT DELIMITED BY SIZE
                 INTO STFSCB00-RETURN-CODE
           END-IF
           .
      *
       FINALIZA.
           .
       END PROGRAM STFSC00I.
