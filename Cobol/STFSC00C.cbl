       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * STFSC00C - Consulta de sócio por RG (DBATDP-18)
      * Natural > COBOL > DB2
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA            PIC X(08) VALUE 'STFSC00C'.
       01  WS-CONST-VERSAO              PIC X(04) VALUE 'P2  '.
       01  WS-CONST-OPER-CONSULTA       PIC X(01) VALUE 'C'.
       01  WS-MSG-ERRO-GENERICO         PIC X(72)
           VALUE 'ERRO DB2 NA CONSULTA DE SOCIO.'.
      *
       LOCAL-STORAGE SECTION.
       01  LS-SQLCA                     SQLCA.
       01  LS-STFSC00-AREA.
           COPY STFSC00B.
       01  LS-HV-NUMB-SOCIO             PIC S9(09) COMP-3.
       01  LS-HV-NOME                   PIC X(40).
       01  LS-HV-DATA-CAD               PIC X(10).
       01  LS-HV-CATG                   PIC S9(04) COMP-3.
       01  LS-HV-INDI-DIVIDA            PIC X(01).
       01  LS-HV-DATA-BAIXA             PIC X(10).
       01  LS-HV-HORA-BAIXA             PIC X(12).
       01  LS-HV-OBSV                   PIC X(500).
       01  LS-HV-SEQ-PE                 PIC S9(09) COMP-3.
       01  LS-HV-DATA-VENC               PIC X(10).
       01  LS-HV-VALR-MENS               PIC S9(06)V9(02) COMP-3.
       01  LS-HV-PAGAMENTO-OK           PIC X(01).
       01  LS-IND-NUMB                  PIC S9(04) COMP.
       01  LS-IND-NOME                  PIC S9(04) COMP.
       01  LS-IND-DATA-CAD              PIC S9(04) COMP.
       01  LS-IND-CATG                  PIC S9(04) COMP.
       01  LS-IND-INDI                  PIC S9(04) COMP.
       01  LS-IND-DATA-BAIXA            PIC S9(04) COMP.
       01  LS-IND-HORA-BAIXA            PIC S9(04) COMP.
       01  LS-IND-OBSV                  PIC S9(04) COMP.
       01  LS-IND-SEQ                   PIC S9(04) COMP.
       01  LS-IND-DATA-VENC             PIC S9(04) COMP.
       01  LS-IND-VALR                  PIC S9(04) COMP.
       01  LS-IND-PGTO                  PIC S9(04) COMP.
       01  LS-IDX-PE                    PIC S9(04) COMP.
       01  LS-SQLCODE-AUX               PIC S9(09) COMP.
           EXEC SQL DECLARE CSR_SOCIO_PE CURSOR FOR
               SELECT SEQ_PERIODICO,
                      CHAR(DATA_VENCIMENTO, ISO),
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM TB_SOCIO_PERIODICO_PAGAMENTO
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-NUMB-SOCIO
                ORDER BY SEQ_PERIODICO
           END-EXEC
      *
       LINKAGE SECTION.
       01  LNK-STFSC00-AREA.
           COPY STFSC00B.
      *
       PROCEDURE DIVISION USING LNK-STFSC00-AREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
      *
       INICIALIZA.
           MOVE LNK-STFSC00-AREA TO LS-STFSC00-AREA
           MOVE WS-CONST-OPER-CONSULTA TO STFSC00-OPERACAO
           MOVE ZERO TO STFSC00-RETURN-CODE
           MOVE ZERO TO STFSC00-COUNT-PERIODICO
           PERFORM VARYING LS-IDX-PE FROM 1 BY 1
               UNTIL LS-IDX-PE > 12
               MOVE SPACES TO STFSC00-DATA-VENCIMENTO(LS-IDX-PE)
               MOVE ZERO TO STFSC00-VALR-MENSALIDADE(LS-IDX-PE)
               MOVE 'N' TO STFSC00-PAGAMENTO-OK(LS-IDX-PE)
           END-PERFORM
           .
      *
       PROCESSA.
           IF NOT STFSC00-OP-CONSULTA
               MOVE +9999 TO STFSC00-RETURN-CODE
               GO TO PROCESSA-EXIT
           END-IF
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL TO LS-HV-NUMB-SOCIO
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CASE WHEN DATA_BAIXA IS NULL
                           THEN '          '
                           ELSE CHAR(DATA_BAIXA, ISO)
                      END,
                      COALESCE(HORA_BAIXA, '            '),
                      COALESCE(OBSV_SOCIO, ' ')
                 INTO :LS-HV-NOME:LS-IND-NOME,
                      :LS-HV-DATA-CAD:LS-IND-DATA-CAD,
                      :LS-HV-CATG:LS-IND-CATG,
                      :LS-HV-INDI-DIVIDA:LS-IND-INDI,
                      :LS-HV-DATA-BAIXA:LS-IND-DATA-BAIXA,
                      :LS-HV-HORA-BAIXA:LS-IND-HORA-BAIXA,
                      :LS-HV-OBSV:LS-IND-OBSV
                 FROM TB_SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-NUMB-SOCIO
           END-EXEC
           MOVE SQLCODE TO LS-SQLCODE-AUX
           EVALUATE LS-SQLCODE-AUX
               WHEN 0
                   PERFORM CARREGA-PRINCIPAL
                   PERFORM CARREGA-PERIODICO-CURSOR
               WHEN 100
                   MOVE +100 TO STFSC00-RETURN-CODE
               WHEN OTHER
                   MOVE LS-SQLCODE-AUX TO STFSC00-RETURN-CODE
           END-EVALUATE
           .
       PROCESSA-EXIT.
           EXIT.
      *
       CARREGA-PRINCIPAL.
           MOVE +0 TO STFSC00-RETURN-CODE
           MOVE LS-HV-NOME TO STFSC00-NOME-SOCIO-PRINCIPAL
           MOVE LS-HV-DATA-CAD TO STFSC00-DATA-CADASTRO
           MOVE LS-HV-CATG TO STFSC00-CATG-SOCIO
           MOVE LS-HV-INDI-DIVIDA TO STFSC00-INDI-DIVIDA
           MOVE LS-HV-DATA-BAIXA TO STFSC00-DATA-BAIXA
           MOVE LS-HV-HORA-BAIXA TO STFSC00-HORA-BAIXA
           MOVE LS-HV-OBSV TO STFSC00-OBSV-SOCIO
           .
      *
       CARREGA-PERIODICO-CURSOR.
           MOVE ZERO TO STFSC00-COUNT-PERIODICO
           EXEC SQL OPEN CSR_SOCIO_PE END-EXEC
           IF SQLCODE NOT = 0
               GO TO CARREGA-PERIODICO-EXIT
           END-IF
           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL FETCH CSR_SOCIO_PE
                   INTO :LS-HV-SEQ-PE:LS-IND-SEQ,
                        :LS-HV-DATA-VENC:LS-IND-DATA-VENC,
                        :LS-HV-VALR-MENS:LS-IND-VALR,
                        :LS-HV-PAGAMENTO-OK:LS-IND-PGTO
               END-EXEC
               IF SQLCODE = 0
                   ADD 1 TO STFSC00-COUNT-PERIODICO
                   IF STFSC00-COUNT-PERIODICO <= 12
                       MOVE STFSC00-COUNT-PERIODICO TO LS-IDX-PE
                       MOVE LS-HV-DATA-VENC
                           TO STFSC00-DATA-VENCIMENTO(LS-IDX-PE)
                       MOVE LS-HV-VALR-MENS
                           TO STFSC00-VALR-MENSALIDADE(LS-IDX-PE)
                       MOVE LS-HV-PAGAMENTO-OK
                           TO STFSC00-PAGAMENTO-OK(LS-IDX-PE)
                   END-IF
               END-IF
           END-PERFORM
           EXEC SQL CLOSE CSR_SOCIO_PE END-EXEC
           .
       CARREGA-PERIODICO-EXIT.
           EXIT.
      *
       FINALIZA.
           MOVE LS-STFSC00-AREA TO LNK-STFSC00-AREA
           .
