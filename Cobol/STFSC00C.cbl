       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consulta socio (ADABAS FIND) via DB2                           *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA             PIC X(08) VALUE 'STFSC00C'.
       01  WS-CONST-OPERACAO             PIC X(01) VALUE 'C'.
       01  WS-CONST-RC-OK                PIC S9(09) COMP VALUE +0.
       01  WS-CONST-RC-NOTFOUND          PIC S9(09) COMP VALUE +100.
       01  WS-CONST-MAX-PER              PIC 9(03) VALUE 12.
       01  WS-CONST-IND-SIM              PIC X(01) VALUE 'Y'.
       01  WS-CONST-IND-NAO              PIC X(01) VALUE 'N'.
       01  WS-MSG-CONSULTA-OK            PIC X(50)
           VALUE 'CONSULTA REALIZADA COM SUCESSO'.
       01  WS-MSG-NAO-LOCALIZADO         PIC X(50)
           VALUE 'SOCIO NAO LOCALIZADO'.
      *
       01  WS-CURSOR-PER-PAGTO.
           EXEC SQL
               DECLARE CSR_PER_PAGTO CURSOR FOR
               SELECT SEQ_PERIODO,
                      CHAR(DATA_VENCIMENTO, ISO),
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM STF_SOCIO_PER_PAGTO
                WHERE NUMB_SOCIO_PRINCIPAL = :LCL-HV-NUMB-SOCIO-PRINCIPAL
                ORDER BY SEQ_PERIODO
           END-EXEC.
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
       01  LCL-IND-NUMB                    PIC S9(04) COMP.
       01  LCL-IND-NOME                    PIC S9(04) COMP.
       01  LCL-IND-DT-CAD                  PIC S9(04) COMP.
       01  LCL-IND-CATG                    PIC S9(04) COMP.
       01  LCL-IND-INDI                    PIC S9(04) COMP.
       01  LCL-IND-DT-BAIXA                PIC S9(04) COMP.
       01  LCL-IND-HR-BAIXA                PIC S9(04) COMP.
       01  LCL-IND-OBSV                    PIC S9(04) COMP.
       01  LCL-IDX-PER                     PIC 9(03).
       01  LCL-CONT-PER                    PIC 9(03).
       01  LCL-FLAG-FIM-CURSOR             PIC X(01).
           88  LCL-FIM-CURSOR-SIM          VALUE 'Y'.
           88  LCL-FIM-CURSOR-NAO          VALUE 'N'.
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
           MOVE ZERO TO LCL-CONT-PER
           MOVE WS-CONST-IND-NAO TO LCL-FLAG-FIM-CURSOR
           PERFORM VARYING LCL-IDX-PER FROM 1 BY 1
               UNTIL LCL-IDX-PER > WS-CONST-MAX-PER
               MOVE SPACES TO STFSC00-DATA-VENCIMENTO OF LNK-STFSC00-COMUNICACAO
                   (LCL-IDX-PER)
               MOVE ZERO TO STFSC00-VALR-MENSALIDADE OF LNK-STFSC00-COMUNICACAO
                   (LCL-IDX-PER)
               MOVE WS-CONST-IND-NAO TO STFSC00-PAGAMENTO-OK OF
                   LNK-STFSC00-COMUNICACAO (LCL-IDX-PER)
           END-PERFORM
           .
      *
       PROCESSA.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL OF LNK-STFSC00-COMUNICACAO
               TO LCL-HV-NUMB-SOCIO-PRINCIPAL
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      COALESCE(CHAR(DATA_BAIXA, ISO), ' '),
                      COALESCE(CHAR(HORA_BAIXA, ISO), ' '),
                      COALESCE(OBSV_SOCIO, ' ')
                 INTO :LCL-HV-NOME-SOCIO-PRINCIPAL:LCL-IND-NOME,
                      :LCL-HV-DATA-CADASTRO:LCL-IND-DT-CAD,
                      :LCL-HV-CATG-SOCIO:LCL-IND-CATG,
                      :LCL-HV-INDI-DIVIDA:LCL-IND-INDI,
                      :LCL-HV-DATA-BAIXA:LCL-IND-DT-BAIXA,
                      :LCL-HV-HORA-BAIXA:LCL-IND-HR-BAIXA,
                      :LCL-HV-OBSV-SOCIO:LCL-IND-OBSV
                 FROM STF_SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :LCL-HV-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   PERFORM 1000-MONTA-SAIDA-PRINCIPAL
                   PERFORM 2000-CARREGA-PERIODICOS
               WHEN 100
                   MOVE WS-CONST-RC-NOTFOUND TO STFSC00-SQLCODE OF
                       LNK-STFSC00-COMUNICACAO
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-SQLCODE OF LNK-STFSC00-COMUNICACAO
           END-EVALUATE
           .
      *
       FINALIZA.
           IF LCL-FIM-CURSOR-NAO
               EXEC SQL CLOSE CSR_PER_PAGTO END-EXEC
           END-IF
           .
      *
       1000-MONTA-SAIDA-PRINCIPAL.
           MOVE WS-CONST-RC-OK TO STFSC00-SQLCODE OF LNK-STFSC00-COMUNICACAO
           MOVE LCL-HV-NOME-SOCIO-PRINCIPAL TO STFSC00-NOME-SOCIO-PRINCIPAL OF
               LNK-STFSC00-COMUNICACAO
           MOVE LCL-HV-DATA-CADASTRO TO STFSC00-DATA-CADASTRO OF
               LNK-STFSC00-COMUNICACAO
           MOVE LCL-HV-CATG-SOCIO TO STFSC00-CATG-SOCIO OF LNK-STFSC00-COMUNICACAO
           MOVE LCL-HV-INDI-DIVIDA TO STFSC00-INDI-DIVIDA OF
               LNK-STFSC00-COMUNICACAO
           MOVE LCL-HV-DATA-BAIXA TO STFSC00-DATA-BAIXA OF LNK-STFSC00-COMUNICACAO
           MOVE LCL-HV-HORA-BAIXA TO STFSC00-HORA-BAIXA OF LNK-STFSC00-COMUNICACAO
           MOVE LCL-HV-OBSV-SOCIO TO STFSC00-OBSV-SOCIO OF LNK-STFSC00-COMUNICACAO
           .
      *
       2000-CARREGA-PERIODICOS.
           EXEC SQL OPEN CSR_PER_PAGTO END-EXEC
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO STFSC00-SQLCODE OF LNK-STFSC00-COMUNICACAO
               GO TO 2000-EXIT
           END-IF
           MOVE WS-CONST-IND-SIM TO LCL-FLAG-FIM-CURSOR
           PERFORM UNTIL SQLCODE = 100
               EXEC SQL
                   FETCH CSR_PER_PAGTO
                    INTO :LCL-HV-SEQ-PERIODO,
                         :LCL-HV-DATA-VENCIMENTO,
                         :LCL-HV-VALR-MENSALIDADE,
                         :LCL-HV-PAGAMENTO-OK
               END-EXEC
               IF SQLCODE = 0
                   ADD 1 TO LCL-CONT-PER
                   IF LCL-CONT-PER <= WS-CONST-MAX-PER
                       MOVE LCL-HV-DATA-VENCIMENTO TO
                           STFSC00-DATA-VENCIMENTO OF LNK-STFSC00-COMUNICACAO
                           (LCL-CONT-PER)
                       MOVE LCL-HV-VALR-MENSALIDADE TO
                           STFSC00-VALR-MENSALIDADE OF LNK-STFSC00-COMUNICACAO
                           (LCL-CONT-PER)
                       MOVE LCL-HV-PAGAMENTO-OK TO STFSC00-PAGAMENTO-OK OF
                           LNK-STFSC00-COMUNICACAO (LCL-CONT-PER)
                   END-IF
               ELSE
                   IF SQLCODE NOT = 100
                       MOVE SQLCODE TO STFSC00-SQLCODE OF
                           LNK-STFSC00-COMUNICACAO
                   END-IF
               END-IF
           END-PERFORM
           MOVE LCL-CONT-PER TO STFSC00-C-PERIODICO-PAGAMENTO OF
               LNK-STFSC00-COMUNICACAO
           .
       2000-EXIT.
           EXIT.
      *
       END PROGRAM STFSC00C.
