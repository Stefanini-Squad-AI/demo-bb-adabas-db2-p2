       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consulta socio por NUMB-SOCIO-PRINCIPAL (RG) - DB2            *
      * Return code: +000 localizado, +100 nao localizado, outros erro  *
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-PROGRAMA               PIC X(08) VALUE 'STFSC00C'.
       01  WS-VERSAO                 PIC X(05) VALUE '01.00'.
       01  WS-MAX-PERIODICO          PIC S9(04) COMP VALUE 12.
       01  WS-CONT-PE                PIC S9(04) COMP.
       01  WS-IND-PE                 PIC S9(04) COMP.
      *
       EXEC SQL DECLARE CSR_PERIODICO_PAG CURSOR FOR
           SELECT SEQ_PERIODICO,
                  CHAR(DATA_VENCIMENTO, ISO),
                  VALR_MENSALIDADE,
                  PAGAMENTO_OK
             FROM SOCIOS_PERIODICO_PAGAMENTO
            WHERE NUMB_SOCIO_PRINCIPAL = :WS-HV-NUMB-SOCIO
            ORDER BY SEQ_PERIODICO
       END-EXEC.
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
       01  LS-INICIALIZADO            PIC X(01) VALUE 'N'.
           EXEC SQL INCLUDE SQLCA END-EXEC.
      *
       PROCEDURE DIVISION USING STFSC00-AREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
      *
       INICIALIZA.
           MOVE 'C' TO STFSC00-ACAO
           MOVE ZERO TO STFSC00-RETURN-CODE
           MOVE ZERO TO STFSC00-C-PERIODICO-PAGAMENTO
           .
      *
       PROCESSA.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL TO WS-HV-NUMB-SOCIO
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      COALESCE(CHAR(DATA_BAIXA, ISO), ' '),
                      COALESCE(HORA_BAIXA, ' '),
                      COALESCE(OBSV_SOCIO, ' ')
                 INTO :WS-HV-NOME,
                      :WS-HV-DATA-CADASTRO,
                      :WS-HV-CATG,
                      :WS-HV-INDI-DIVIDA,
                      :WS-HV-DATA-BAIXA,
                      :WS-HV-HORA-BAIXA,
                      :WS-HV-OBSV
                 FROM SOCIOS
                WHERE NUMB_SOCIO_PRINCIPAL = :WS-HV-NUMB-SOCIO
           END-EXEC
           EVALUATE SQLCODE
               WHEN ZERO
                   PERFORM CARREGA-SOCIO-ENCONTRADO
               WHEN 100
                   MOVE +100 TO STFSC00-RETURN-CODE
               WHEN OTHER
                   PERFORM TRATA-ERRO-SQL
           END-EVALUATE
           .
      *
       CARREGA-SOCIO-ENCONTRADO.
           MOVE +000 TO STFSC00-RETURN-CODE
           MOVE WS-HV-NOME TO STFSC00-NOME-SOCIO-PRINCIPAL
           MOVE WS-HV-DATA-CADASTRO TO STFSC00-DATA-CADASTRO
           MOVE WS-HV-CATG TO STFSC00-CATG-SOCIO
           MOVE WS-HV-INDI-DIVIDA TO STFSC00-INDI-DIVIDA
           MOVE WS-HV-DATA-BAIXA TO STFSC00-DATA-BAIXA
           MOVE WS-HV-HORA-BAIXA TO STFSC00-HORA-BAIXA
           MOVE WS-HV-OBSV TO STFSC00-OBSV-SOCIO
           PERFORM LER-PERIODICO-PAGAMENTO
           .
      *
       LER-PERIODICO-PAGAMENTO.
           MOVE ZERO TO WS-CONT-PE
           EXEC SQL OPEN CSR_PERIODICO_PAG END-EXEC
           IF SQLCODE NOT = ZERO
               PERFORM TRATA-ERRO-SQL
               GO TO LER-PERIODICO-PAGAMENTO-EXIT
           END-IF
           PERFORM UNTIL SQLCODE = +100
               EXEC SQL FETCH CSR_PERIODICO_PAG
                   INTO :WS-HV-SEQ-PE,
                        :WS-HV-DATA-VENC,
                        :WS-HV-VALR-MENS,
                        :WS-HV-PAGAMENTO-OK
               END-EXEC
               EVALUATE SQLCODE
                   WHEN ZERO
                       ADD 1 TO WS-CONT-PE
                       IF WS-CONT-PE NOT > WS-MAX-PERIODICO
                           MOVE WS-HV-DATA-VENC
                             TO STFSC00-DATA-VENCIMENTO(WS-CONT-PE)
                           MOVE WS-HV-VALR-MENS
                             TO STFSC00-VALR-MENSALIDADE(WS-CONT-PE)
                           MOVE WS-HV-PAGAMENTO-OK
                             TO STFSC00-PAGAMENTO-OK(WS-CONT-PE)
                       END-IF
                   WHEN 100
                       CONTINUE
                   WHEN OTHER
                       PERFORM TRATA-ERRO-SQL
               END-EVALUATE
           END-PERFORM
           EXEC SQL CLOSE CSR_PERIODICO_PAG END-EXEC
           MOVE WS-CONT-PE TO STFSC00-C-PERIODICO-PAGAMENTO
           .
       LER-PERIODICO-PAGAMENTO-EXIT.
           EXIT.
      *
       TRATA-ERRO-SQL.
           MOVE SQLCODE TO STFSC00-RETURN-CODE
           .
      *
       FINALIZA.
           .
       END PROGRAM STFSC00C.
