       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consulta socio ADABAS-SOCIOS via DB2 (DBATDP-17)
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA            PIC X(08) VALUE 'STFSC00C'.
       01  WS-CONST-VERSAO              PIC X(04) VALUE '0001'.
      *
       01  WS-CURSOR-PERIODICO.
           EXEC SQL
               DECLARE CUR_PP CURSOR FOR
               SELECT SEQ_PERIODICO,
                      DATA_VENCIMENTO,
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM ADABAS_SOCIOS_PERIODICO_PAGAMENTO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO
                ORDER BY SEQ_PERIODICO
           END-EXEC.
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
           MOVE ZERO   TO STFSCB00-C-PERIODICO
           PERFORM VARYING STFSCB00-IDX-PE FROM 1 BY 1
               UNTIL STFSCB00-IDX-PE > 12
               MOVE SPACES TO STFSCB00-DATA-VENC(STFSCB00-IDX-PE)
               MOVE ZERO   TO STFSCB00-VALR-MENSAL(STFSCB00-IDX-PE)
               MOVE 'N'    TO STFSCB00-PAGAMENTO-OK(STFSCB00-IDX-PE)
           END-PERFORM
           .
      *
       PROCESSA.
           IF NOT STFSCB00-OP-CONSULTA
               MOVE '+0099' TO STFSCB00-RETURN-CODE
               GO TO PROCESSA-EXIT
           END-IF
           MOVE STFSCB00-NUMB-SOCIO-PRINC TO HV-NUMB-SOCIO
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CASE WHEN DATA_BAIXA IS NULL THEN ' '
                           ELSE CHAR(DATA_BAIXA, ISO) END,
                      COALESCE(HORA_BAIXA, ' '),
                      COALESCE(OBSV_SOCIO, ' ')
                 INTO :HV-NOME,
                      :HV-DATA-CAD,
                      :HV-CATG,
                      :HV-INDI-DIVIDA,
                      :HV-DATA-BAIXA,
                      :HV-HORA-BAIXA,
                      :HV-OBSV
                 FROM ADABAS_SOCIOS
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO
           END-EXEC
           PERFORM TRATA-SQLCODE-CONSULTA
           IF STFSCB00-RETURN-CODE NOT = '+0000'
               GO TO PROCESSA-EXIT
           END-IF
           MOVE HV-NOME         TO STFSCB00-NOME-SOCIO-PRINC
           MOVE HV-DATA-CAD     TO STFSCB00-DATA-CADASTRO
           MOVE HV-CATG         TO STFSCB00-CATG-SOCIO
           MOVE HV-INDI-DIVIDA  TO STFSCB00-INDI-DIVIDA
           MOVE HV-DATA-BAIXA   TO STFSCB00-DATA-BAIXA
           MOVE HV-HORA-BAIXA   TO STFSCB00-HORA-BAIXA
           MOVE HV-OBSV         TO STFSCB00-OBSV-SOCIO
           EXEC SQL OPEN CUR_PP END-EXEC
           IF SQLCODE NOT = 0
               PERFORM FORMATA-RETURN-CODE
               GO TO PROCESSA-EXIT
           END-IF
           MOVE ZERO TO WS-IDX
           PERFORM UNTIL SQLCODE = 100
               EXEC SQL
                   FETCH CUR_PP
                    INTO :HV-SEQ-PE,
                         :HV-DATA-VENC,
                         :HV-VALR-MENS,
                         :HV-PAG-OK
               END-EXEC
               IF SQLCODE = 0
                   ADD 1 TO WS-IDX
                   IF WS-IDX <= 12
                       MOVE HV-DATA-VENC TO
                           STFSCB00-DATA-VENC(WS-IDX)
                       MOVE HV-VALR-MENS TO
                           STFSCB00-VALR-MENSAL(WS-IDX)
                       MOVE HV-PAG-OK TO
                           STFSCB00-PAGAMENTO-OK(WS-IDX)
                   END-IF
               END-IF
           END-PERFORM
           MOVE WS-IDX TO STFSCB00-C-PERIODICO
           IF SQLCODE = 100
               EXEC SQL CLOSE CUR_PP END-EXEC
           END-IF
           .
       PROCESSA-EXIT.
           EXIT.
      *
       TRATA-SQLCODE-CONSULTA.
           EVALUATE SQLCODE
               WHEN 0
                   MOVE '+0000' TO STFSCB00-RETURN-CODE
               WHEN 100
                   MOVE '+0100' TO STFSCB00-RETURN-CODE
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
           IF SQLCODE = 0 OR SQLCODE = 100
               CONTINUE
           END-IF
           .
       END PROGRAM STFSC00C.
