       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consulta socio por NUMB-SOCIO-PRINCIPAL (RG)
      * SQLCODE +000 registro localizado / +100 nao localizado
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-OPER-CONSULTA        PIC X(01) VALUE 'C'.
       01  WS-IND-PER                    PIC 9(03) VALUE ZEROES.
       01  WS-FIM-CURSOR                 PIC X(01) VALUE 'N'.

           EXEC SQL INCLUDE SQLCA END-EXEC.

           EXEC SQL
                DECLARE CUR-PERIODICO CURSOR FOR
                 SELECT SEQ_PERIODICO,
                        CHAR(DATA_VENCIMENTO, ISO),
                        VALR_MENSALIDADE,
                        PAGAMENTO_OK
                   FROM SOCIO_PERIODICO_PAGAMENTO
                  WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRINCIPAL
                  ORDER BY SEQ_PERIODICO
           END-EXEC.

       LINKAGE SECTION.
           COPY STFSC00B.

       LOCAL-STORAGE SECTION.
       01  HV-NUMB-SOCIO-PRINCIPAL       PIC 9(09).
       01  HV-NOME-SOCIO-PRINCIPAL       PIC X(40).
       01  HV-DATA-CADASTRO              PIC X(10).
       01  HV-CATG-SOCIO                 PIC 9(02).
       01  HV-INDI-DIVIDA                PIC X(01).
       01  HV-DATA-BAIXA                 PIC X(10).
       01  HV-HORA-BAIXA                 PIC X(05).
       01  HV-OBSV-SOCIO                 PIC X(500).
       01  HV-SEQ-PERIODICO              PIC 9(09).
       01  HV-DATA-VENCIMENTO            PIC X(10).
       01  HV-VALR-MENSALIDADE           PIC S9(4)V99 COMP-3.
       01  HV-PAGAMENTO-OK               PIC X(01).

       PROCEDURE DIVISION USING STFSC00-AREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.

       INICIALIZA.
           MOVE WS-CONST-OPER-CONSULTA TO STFSC00-OPERACAO
           MOVE ZEROES TO STFSC00-SQLCODE
           MOVE ZEROES TO STFSC00-C-PERIODICO-PAGAMENTO
           .

       PROCESSA.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL
               TO HV-NUMB-SOCIO-PRINCIPAL

           EXEC SQL
                SELECT NOME_SOCIO_PRINCIPAL,
                       CHAR(DATA_CADASTRO, ISO),
                       CATG_SOCIO,
                       INDI_DIVIDA,
                       CHAR(DATA_BAIXA, ISO),
                       HORA_BAIXA,
                       OBSV_SOCIO
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
                   PERFORM CARREGA-SOCIO-ENCONTRADO
                   PERFORM CARREGA-PERIODICO
               WHEN 100
                   MOVE 100 TO STFSC00-SQLCODE
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-SQLCODE
           END-EVALUATE
           .

       CARREGA-SOCIO-ENCONTRADO.
           MOVE ZEROES TO STFSC00-SQLCODE
           MOVE HV-NOME-SOCIO-PRINCIPAL
               TO STFSC00-NOME-SOCIO-PRINCIPAL
           MOVE HV-DATA-CADASTRO TO STFSC00-DATA-CADASTRO
           MOVE HV-CATG-SOCIO TO STFSC00-CATG-SOCIO
           MOVE HV-INDI-DIVIDA TO STFSC00-INDI-DIVIDA
           MOVE HV-DATA-BAIXA TO STFSC00-DATA-BAIXA
           MOVE HV-HORA-BAIXA TO STFSC00-HORA-BAIXA
           MOVE HV-OBSV-SOCIO TO STFSC00-OBSV-CLIENTE
           .

       CARREGA-PERIODICO.
           EXEC SQL OPEN CUR-PERIODICO END-EXEC
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO STFSC00-SQLCODE
               GO TO CARREGA-PERIODICO-FIM
           END-IF

           MOVE ZEROES TO WS-IND-PER
           MOVE 'N' TO WS-FIM-CURSOR
           PERFORM UNTIL WS-FIM-CURSOR = 'Y'
               EXEC SQL FETCH CUR-PERIODICO
                    INTO :HV-SEQ-PERIODICO,
                         :HV-DATA-VENCIMENTO,
                         :HV-VALR-MENSALIDADE,
                         :HV-PAGAMENTO-OK
               END-EXEC
               EVALUATE SQLCODE
                   WHEN 0
                       ADD 1 TO WS-IND-PER
                       IF WS-IND-PER NOT > 12
                           MOVE HV-DATA-VENCIMENTO
                               TO STFSC00-DATA-VENCIMENTO(WS-IND-PER)
                           MOVE HV-VALR-MENSALIDADE
                               TO STFSC00-VALR-MENSALIDADE(WS-IND-PER)
                           MOVE HV-PAGAMENTO-OK
                               TO STFSC00-PAGAMENTO-OK(WS-IND-PER)
                       END-IF
                   WHEN 100
                       MOVE 'Y' TO WS-FIM-CURSOR
                   WHEN OTHER
                       MOVE SQLCODE TO STFSC00-SQLCODE
                       MOVE 'Y' TO WS-FIM-CURSOR
               END-EVALUATE
           END-PERFORM

           EXEC SQL CLOSE CUR-PERIODICO END-EXEC

       CARREGA-PERIODICO-FIM.
           MOVE WS-IND-PER TO STFSC00-C-PERIODICO-PAGAMENTO
           .

       FINALIZA.
           EXEC SQL COMMIT END-EXEC
           .
