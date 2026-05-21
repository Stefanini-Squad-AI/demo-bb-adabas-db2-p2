       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consulta de socio por NUMB-SOCIO-PRINCIPAL (RG) em DB2        *
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-PROGRAMA                   PIC X(08) VALUE 'STFSC00C'.
       01  WS-VERSAO                     PIC X(05) VALUE '01.00'.
       01  WS-SQL-OK                     PIC S9(04) COMP VALUE 0.
       01  WS-SQL-NAO-ENCONTRADO         PIC S9(04) COMP VALUE 100.
       01  WS-CONT-PERIODICO             PIC 9(04) COMP VALUE 0.
       01  WS-FIM-CURSOR                 PIC X(01) VALUE 'N'.
      *
       EXEC SQL DECLARE CSR_SOCIO_PER CURSOR FOR
           SELECT SEQ_PERIODICO,
                  CHAR(DATA_VENCIMENTO, ISO),
                  VALR_MENSALIDADE,
                  PAGAMENTO_OK
             FROM SOCIO_PERIODICO_PAGAMENTO
            WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRINCIPAL
            ORDER BY SEQ_PERIODICO
       END-EXEC.
      *
       LOCAL-STORAGE SECTION.
       EXEC SQL INCLUDE SQLCA END-EXEC.
      *
       01  HV-NUMB-SOCIO-PRINCIPAL       PIC S9(09) COMP-3.
       01  HV-NOME-SOCIO-PRINCIPAL       PIC X(40).
       01  HV-DATA-CADASTRO              PIC X(10).
       01  HV-CATG-SOCIO                 PIC S9(04) COMP.
       01  HV-INDI-DIVIDA                PIC X(01).
       01  HV-DATA-BAIXA                 PIC X(10).
       01  HV-HORA-BAIXA                 PIC X(05).
       01  HV-OBSV-SOCIO                 PIC X(500).
       01  HV-SEQ-PERIODICO              PIC S9(09) COMP.
       01  HV-DATA-VENCIMENTO            PIC X(10).
       01  HV-VALR-MENSALIDADE           PIC S9(06)V9(02) COMP-3.
       01  HV-PAGAMENTO-OK               PIC X(01).
      *
       LINKAGE SECTION.
           COPY STFSC00L.
      *
       PROCEDURE DIVISION USING STFSC00L-AREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
      *
       INICIALIZA.
           MOVE ZERO TO STFSC00L-RETORNO
           MOVE 'C' TO STFSC00L-OPERACAO
           .
      *
       PROCESSA.
           MOVE STFSC00L-NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO-PRINCIPAL
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      COALESCE(CHAR(DATA_BAIXA, ISO), '          '),
                      COALESCE(HORA_BAIXA, '     '),
                      COALESCE(OBSV_SOCIO, ' ')
                 INTO :HV-NOME-SOCIO-PRINCIPAL,
                      :HV-DATA-CADASTRO,
                      :HV-CATG-SOCIO,
                      :HV-INDI-DIVIDA,
                      :HV-DATA-BAIXA,
                      :HV-HORA-BAIXA,
                      :HV-OBSV-SOCIO
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   PERFORM CARREGA-DADOS-SOCIO
                   PERFORM CARREGA-SOCIO-PER-CURSOR
               WHEN 100
                   MOVE WS-SQL-NAO-ENCONTRADO TO STFSC00L-RETORNO
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00L-RETORNO
           END-EVALUATE
           .
      *
       CARREGA-DADOS-SOCIO.
           MOVE HV-NUMB-SOCIO-PRINCIPAL TO STFSC00L-NUMB-SOCIO-PRINCIPAL
           MOVE HV-NOME-SOCIO-PRINCIPAL TO STFSC00L-NOME-SOCIO-PRINCIPAL
           MOVE HV-DATA-CADASTRO TO STFSC00L-DATA-CADASTRO
           MOVE HV-CATG-SOCIO TO STFSC00L-CATG-SOCIO
           MOVE HV-INDI-DIVIDA TO STFSC00L-INDI-DIVIDA
           MOVE HV-DATA-BAIXA TO STFSC00L-DATA-BAIXA
           MOVE HV-HORA-BAIXA TO STFSC00L-HORA-BAIXA
           MOVE HV-OBSV-SOCIO TO STFSC00L-OBSV-SOCIO
           MOVE WS-SQL-OK TO STFSC00L-RETORNO
           .
      *
       CARREGA-SOCIO-PER-CURSOR.
           MOVE ZERO TO WS-CONT-PERIODICO
           MOVE 'N' TO WS-FIM-CURSOR
           INITIALIZE STFSC00L-PERIODICO-PAGAMENTO
           EXEC SQL OPEN CSR_SOCIO_PER END-EXEC
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO STFSC00L-RETORNO
               GO TO CARREGA-SOCIO-PER-FIM
           END-IF
           PERFORM UNTIL WS-FIM-CURSOR = 'Y'
               EXEC SQL FETCH CSR_SOCIO_PER
                 INTO :HV-SEQ-PERIODICO,
                      :HV-DATA-VENCIMENTO,
                      :HV-VALR-MENSALIDADE,
                      :HV-PAGAMENTO-OK
               END-EXEC
               EVALUATE SQLCODE
                   WHEN 0
                       ADD 1 TO WS-CONT-PERIODICO
                       IF WS-CONT-PERIODICO NOT > 12
                           MOVE WS-CONT-PERIODICO TO STFSC00L-IDX-PER
                           MOVE HV-DATA-VENCIMENTO
                             TO STFSC00L-DATA-VENCIMENTO(STFSC00L-IDX-PER)
                           MOVE HV-VALR-MENSALIDADE
                             TO STFSC00L-VALR-MENSALIDADE(STFSC00L-IDX-PER)
                           MOVE HV-PAGAMENTO-OK
                             TO STFSC00L-PAGAMENTO-OK(STFSC00L-IDX-PER)
                       END-IF
                   WHEN 100
                       MOVE WS-CONT-PERIODICO
                         TO STFSC00L-C-PERIODICO-PAGAMENTO
                       MOVE 'Y' TO WS-FIM-CURSOR
                   WHEN OTHER
                       MOVE SQLCODE TO STFSC00L-RETORNO
                       MOVE 'Y' TO WS-FIM-CURSOR
               END-EVALUATE
           END-PERFORM
           .
       CARREGA-SOCIO-PER-FIM.
           EXEC SQL CLOSE CSR_SOCIO_PER END-EXEC
           .
      *
       FINALIZA.
           CONTINUE
           .
       END PROGRAM STFSC00C.
