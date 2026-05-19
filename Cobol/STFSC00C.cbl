       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consulta SOCIO por NUMB-SOCIO-PRINCIPAL (operacao FIND Natural)
      * Return codes: 000=found, 100=not found, outros=erro generico
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA            PIC X(08) VALUE 'STFSC00C'.
       01  WS-CONST-RET-OK              PIC S9(04) COMP VALUE +0.
       01  WS-CONST-RET-NFND            PIC S9(04) COMP VALUE +100.
       01  WS-CONST-RET-ERR             PIC S9(04) COMP VALUE +999.
       01  WS-FLAG-EOF-PAG              PIC X(01) VALUE 'N'.
           88  WS-EOF-PAG               VALUE 'Y'.
       01  WS-IDX-LEITURA               PIC 9(04) VALUE ZEROES.

           EXEC SQL
               DECLARE CSR-SOCIO-PAG CURSOR FOR
                   SELECT DATA_VENCIMENTO,
                          VALR_MENSALIDADE,
                          PAGAMENTO_OK
                     FROM SOCIO_PAGAMENTO
                    WHERE NUMB_SOCIO_PRINCIPAL =
                          :HV-NUMB-SOCIO-PRINCIPAL
                    ORDER BY DATA_VENCIMENTO
           END-EXEC.

       LOCAL-STORAGE SECTION.
           COPY SQLCA.
       01  LS-HOST-VARS.
           05  HV-NUMB-SOCIO-PRINCIPAL    PIC 9(09).
           05  HV-NOME-SOCIO-PRINCIPAL    PIC X(40).
           05  HV-DATA-CADASTRO           PIC X(10).
           05  HV-CATG-SOCIO              PIC 9(02).
           05  HV-INDI-DIVIDA             PIC X(01).
           05  HV-DATA-BAIXA              PIC X(10).
           05  HV-HORA-BAIXA              PIC X(05).
           05  HV-OBSV-SOCIO              PIC X(500).
           05  HV-DATA-VENCIMENTO         PIC X(10).
           05  HV-VALR-MENSALIDADE        PIC S9(06)V9(02) COMP-3.
           05  HV-PAGAMENTO-OK            PIC X(01).
       01  LS-IND-VARS.
           05  IN-NOME-SOCIO-PRINCIPAL    PIC S9(04) COMP.
           05  IN-DATA-BAIXA              PIC S9(04) COMP.
           05  IN-HORA-BAIXA              PIC S9(04) COMP.
           05  IN-OBSV-SOCIO              PIC S9(04) COMP.

       LINKAGE SECTION.
           COPY STFSSOCIO.

       PROCEDURE DIVISION USING STFSSOCIO-LNK.

           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA

           STOP RUN.

       INICIALIZA SECTION.
       INICIALIZA-INICIO.
           MOVE WS-CONST-RET-OK TO WS-RETORNO
           MOVE ZEROES TO WS-QTD-PAGAMENTO
           MOVE ZEROES TO WS-IDX-LEITURA
           MOVE 'N' TO WS-FLAG-EOF-PAG
           .
       INICIALIZA-FIM.
           EXIT.

       PROCESSA SECTION.
       PROCESSA-INICIO.
           MOVE WS-NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO-PRINCIPAL

           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      COALESCE(CHAR(DATA_BAIXA, ISO), ' '),
                      COALESCE(HORA_BAIXA, ' '),
                      COALESCE(OBSV_SOCIO, ' ')
                 INTO :HV-NOME-SOCIO-PRINCIPAL
                      :IN-NOME-SOCIO-PRINCIPAL,
                      :HV-DATA-CADASTRO,
                      :HV-CATG-SOCIO,
                      :HV-INDI-DIVIDA,
                      :HV-DATA-BAIXA
                      :IN-DATA-BAIXA,
                      :HV-HORA-BAIXA
                      :IN-HORA-BAIXA,
                      :HV-OBSV-SOCIO
                      :IN-OBSV-SOCIO
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRINCIPAL
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   PERFORM PROCESSA-MONTA-SAIDA
                   PERFORM PROCESSA-LER-PAGAMENTOS
                   MOVE WS-CONST-RET-OK TO WS-RETORNO
               WHEN 100
                   MOVE WS-CONST-RET-NFND TO WS-RETORNO
               WHEN OTHER
                   MOVE WS-CONST-RET-ERR TO WS-RETORNO
           END-EVALUATE
           .
       PROCESSA-FIM.
           EXIT.

       PROCESSA-MONTA-SAIDA.
           MOVE HV-NOME-SOCIO-PRINCIPAL TO WS-NOME-SOCIO-PRINCIPAL
           MOVE HV-DATA-CADASTRO TO WS-DATA-CADASTRO
           MOVE HV-CATG-SOCIO TO WS-CATG-SOCIO
           MOVE HV-INDI-DIVIDA TO WS-INDI-DIVIDA
           IF IN-DATA-BAIXA < 0
               MOVE SPACES TO WS-DATA-BAIXA
           ELSE
               MOVE HV-DATA-BAIXA TO WS-DATA-BAIXA
           END-IF
           IF IN-HORA-BAIXA < 0
               MOVE SPACES TO WS-HORA-BAIXA
           ELSE
               MOVE HV-HORA-BAIXA TO WS-HORA-BAIXA
           END-IF
           IF IN-OBSV-SOCIO < 0
               MOVE SPACES TO WS-OBSV-SOCIO
           ELSE
               MOVE HV-OBSV-SOCIO TO WS-OBSV-SOCIO
           END-IF
           .

       PROCESSA-LER-PAGAMENTOS.
           EXEC SQL
               OPEN CSR-SOCIO-PAG
           END-EXEC
           IF SQLCODE NOT = 0
               MOVE WS-CONST-RET-ERR TO WS-RETORNO
               GO TO PROCESSA-LER-PAG-FIM
           END-IF

           PERFORM UNTIL WS-EOF-PAG OR WS-IDX-LEITURA >= 12
               EXEC SQL
                   FETCH CSR-SOCIO-PAG
                    INTO :HV-DATA-VENCIMENTO,
                         :HV-VALR-MENSALIDADE,
                         :HV-PAGAMENTO-OK
               END-EXEC
               EVALUATE SQLCODE
                   WHEN 0
                       ADD 1 TO WS-IDX-LEITURA
                       MOVE WS-IDX-LEITURA TO WS-IDX-PAG
                       MOVE HV-DATA-VENCIMENTO
                         TO WS-DATA-VENCIMENTO (WS-IDX-PAG)
                       MOVE HV-VALR-MENSALIDADE
                         TO WS-VALR-MENSALIDADE (WS-IDX-PAG)
                       MOVE HV-PAGAMENTO-OK
                         TO WS-PAGAMENTO-OK (WS-IDX-PAG)
                   WHEN 100
                       MOVE 'Y' TO WS-FLAG-EOF-PAG
                   WHEN OTHER
                       MOVE WS-CONST-RET-ERR TO WS-RETORNO
                       MOVE 'Y' TO WS-FLAG-EOF-PAG
               END-EVALUATE
           END-PERFORM

           MOVE WS-IDX-LEITURA TO WS-QTD-PAGAMENTO

           EXEC SQL
               CLOSE CSR-SOCIO-PAG
           END-EXEC
           .
       PROCESSA-LER-PAG-FIM.
           EXIT.

       FINALIZA SECTION.
       FINALIZA-INICIO.
           .
       FINALIZA-FIM.
           EXIT.
