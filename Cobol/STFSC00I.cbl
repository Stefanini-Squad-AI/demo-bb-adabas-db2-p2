       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Inclusao de socio e vencimentos periodicos em DB2             *
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-PROGRAMA                   PIC X(08) VALUE 'STFSC00I'.
       01  WS-VERSAO                     PIC X(05) VALUE '01.00'.
       01  WS-SQL-OK                     PIC S9(04) COMP VALUE 0.
       01  WS-SQL-DUPLICADO              PIC S9(04) COMP VALUE 803.
       01  WS-IDX                        PIC 9(04) COMP.
       01  WS-INSERIR-BAIXA              PIC X(01) VALUE 'N'.
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
           MOVE 'I' TO STFSC00L-OPERACAO
           .
      *
       PROCESSA.
           PERFORM GRAVA-SOCIO
           IF STFSC00L-RETORNO = WS-SQL-OK
               PERFORM GRAVA-SOCIO-PER-ITENS
           END-IF
           .
      *
       GRAVA-SOCIO.
           MOVE STFSC00L-NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO-PRINCIPAL
           MOVE STFSC00L-NOME-SOCIO-PRINCIPAL TO HV-NOME-SOCIO-PRINCIPAL
           MOVE STFSC00L-DATA-CADASTRO TO HV-DATA-CADASTRO
           MOVE STFSC00L-CATG-SOCIO TO HV-CATG-SOCIO
           MOVE STFSC00L-INDI-DIVIDA TO HV-INDI-DIVIDA
           MOVE STFSC00L-OBSV-SOCIO TO HV-OBSV-SOCIO
           MOVE 'N' TO WS-INSERIR-BAIXA
           IF STFSC00L-DATA-BAIXA NOT = SPACES
               MOVE STFSC00L-DATA-BAIXA TO HV-DATA-BAIXA
               MOVE 'Y' TO WS-INSERIR-BAIXA
           END-IF
           IF STFSC00L-HORA-BAIXA NOT = SPACES
               MOVE STFSC00L-HORA-BAIXA TO HV-HORA-BAIXA
           ELSE
               MOVE SPACES TO HV-HORA-BAIXA
           END-IF
           IF WS-INSERIR-BAIXA = 'Y'
               EXEC SQL
                   INSERT INTO SOCIO (
                       NUMB_SOCIO_PRINCIPAL,
                       NOME_SOCIO_PRINCIPAL,
                       DATA_CADASTRO,
                       CATG_SOCIO,
                       INDI_DIVIDA,
                       DATA_BAIXA,
                       HORA_BAIXA,
                       OBSV_SOCIO)
                   VALUES (
                       :HV-NUMB-SOCIO-PRINCIPAL,
                       :HV-NOME-SOCIO-PRINCIPAL,
                       DATE(:HV-DATA-CADASTRO),
                       :HV-CATG-SOCIO,
                       :HV-INDI-DIVIDA,
                       DATE(:HV-DATA-BAIXA),
                       :HV-HORA-BAIXA,
                       :HV-OBSV-SOCIO)
               END-EXEC
           ELSE
               EXEC SQL
                   INSERT INTO SOCIO (
                       NUMB_SOCIO_PRINCIPAL,
                       NOME_SOCIO_PRINCIPAL,
                       DATA_CADASTRO,
                       CATG_SOCIO,
                       INDI_DIVIDA,
                       HORA_BAIXA,
                       OBSV_SOCIO)
                   VALUES (
                       :HV-NUMB-SOCIO-PRINCIPAL,
                       :HV-NOME-SOCIO-PRINCIPAL,
                       DATE(:HV-DATA-CADASTRO),
                       :HV-CATG-SOCIO,
                       :HV-INDI-DIVIDA,
                       :HV-HORA-BAIXA,
                       :HV-OBSV-SOCIO)
               END-EXEC
           END-IF
           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-SQL-OK TO STFSC00L-RETORNO
               WHEN -803
                   MOVE WS-SQL-DUPLICADO TO STFSC00L-RETORNO
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00L-RETORNO
           END-EVALUATE
           .
      *
       GRAVA-SOCIO-PER-ITENS.
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > STFSC00L-C-PERIODICO-PAGAMENTO
                  OR STFSC00L-RETORNO NOT = WS-SQL-OK
               IF STFSC00L-DATA-VENCIMENTO(WS-IDX) NOT = SPACES
                   MOVE STFSC00L-NUMB-SOCIO-PRINCIPAL
                     TO HV-NUMB-SOCIO-PRINCIPAL
                   MOVE WS-IDX TO HV-SEQ-PERIODICO
                   MOVE STFSC00L-DATA-VENCIMENTO(WS-IDX)
                     TO HV-DATA-VENCIMENTO
                   MOVE STFSC00L-VALR-MENSALIDADE(WS-IDX)
                     TO HV-VALR-MENSALIDADE
                   MOVE STFSC00L-PAGAMENTO-OK(WS-IDX)
                     TO HV-PAGAMENTO-OK
                   EXEC SQL
                       INSERT INTO SOCIO_PERIODICO_PAGAMENTO (
                           NUMB_SOCIO_PRINCIPAL,
                           SEQ_PERIODICO,
                           DATA_VENCIMENTO,
                           VALR_MENSALIDADE,
                           PAGAMENTO_OK)
                       VALUES (
                           :HV-NUMB-SOCIO-PRINCIPAL,
                           :HV-SEQ-PERIODICO,
                           DATE(:HV-DATA-VENCIMENTO),
                           :HV-VALR-MENSALIDADE,
                           :HV-PAGAMENTO-OK)
                   END-EXEC
                   IF SQLCODE NOT = 0
                       MOVE SQLCODE TO STFSC00L-RETORNO
                   END-IF
               END-IF
           END-PERFORM
           .
      *
       FINALIZA.
           IF STFSC00L-RETORNO = WS-SQL-OK
               EXEC SQL COMMIT END-EXEC
           ELSE
               EXEC SQL ROLLBACK END-EXEC
           END-IF
           .
       END PROGRAM STFSC00I.
