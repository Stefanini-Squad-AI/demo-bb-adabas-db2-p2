       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * STFSC00I - Inclusão de sócio e pagamentos (SOCIO / SOCIO_PAGAMENTO)
      * Return codes: +000 ok, +803 chave duplicada, outros genérico
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-MAX-PAGAMENTOS        PIC 9(3) VALUE 12.
       01  WS-CONST-PROGRAMA              PIC X(8) VALUE 'STFSC00I'.
       01  WS-CONST-SQL-OK                PIC X(5) VALUE '+000'.
       01  WS-CONST-SQL-DUP-KEY           PIC X(5) VALUE '+803'.
       01  WS-CONST-SQL-OTHER             PIC X(5) VALUE '+999'.
       01  WS-IND-PAG                     PIC 9(3) VALUE ZERO.
       01  WS-QTD-PAG                     PIC 9(3) VALUE ZERO.
       01  WS-INDI-DB                     PIC X(1) VALUE 'N'.
       01  WS-PAG-OK-DB                   PIC X(1) VALUE 'N'.
      *
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-COMMAREA                    COPY STFSC00B.
       01  LS-HV-NUMB-SOCIO-PRINCIPAL     PIC S9(9)V9(0) USAGE COMP-3.
       01  LS-HV-NOME-SOCIO-PRINCIPAL     PIC X(40).
       01  LS-HV-DATA-CADASTRO            PIC X(10).
       01  LS-HV-CATG-SOCIO               PIC S9(4) USAGE COMP.
       01  LS-HV-INDI-DIVIDA              PIC X(1).
       01  LS-HV-DATA-BAIXA               PIC X(10).
       01  LS-HV-HORA-BAIXA               PIC X(5).
       01  LS-HV-OBSV-SOCIO               PIC X(500).
       01  LS-HV-SEQ-PAGAMENTO            PIC S9(4) USAGE COMP.
       01  LS-HV-DATA-VENCIMENTO          PIC X(10).
       01  LS-HV-VALR-MENSALIDADE         PIC S9(6)V9(2) USAGE COMP-3.
       01  LS-HV-PAGAMENTO-OK             PIC X(1).
      *
       LINKAGE SECTION.
       01  DFHCOMMAREA.
           05  LK-COMMAREA                PIC X(2000).
      *
       PROCEDURE DIVISION USING DFHCOMMAREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
      *
       INICIALIZA.
           MOVE LK-COMMAREA TO LS-COMMAREA
           MOVE WS-CONST-SQL-OTHER TO STFSC00B-RETURN-CODE
           MOVE ZERO TO WS-IND-PAG
           .
      *
       PROCESSA.
           PERFORM GRAVA-SOCIO
           IF STFSC00B-RC-OK
               PERFORM GRAVA-SOCIO-PAGAMENTO
           END-IF
           MOVE LS-COMMAREA TO LK-COMMAREA
           .
      *
       GRAVA-SOCIO.
           MOVE STFSC00B-NUMB-SOCIO-PRINCIPAL
               TO LS-HV-NUMB-SOCIO-PRINCIPAL
           MOVE STFSC00B-NOME-SOCIO-PRINCIPAL
               TO LS-HV-NOME-SOCIO-PRINCIPAL
           MOVE STFSC00B-DATA-CADASTRO TO LS-HV-DATA-CADASTRO
           MOVE STFSC00B-CATG-SOCIO TO LS-HV-CATG-SOCIO
           PERFORM CONVERTE-INDI-DIVIDA
           MOVE STFSC00B-DATA-BAIXA TO LS-HV-DATA-BAIXA
           MOVE STFSC00B-HORA-BAIXA TO LS-HV-HORA-BAIXA
           MOVE STFSC00B-OBSV-SOCIO TO LS-HV-OBSV-SOCIO
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
                   :LS-HV-NUMB-SOCIO-PRINCIPAL,
                   :LS-HV-NOME-SOCIO-PRINCIPAL,
                   DATE(:LS-HV-DATA-CADASTRO),
                   :LS-HV-CATG-SOCIO,
                   :WS-INDI-DB,
                   NULLIF(DATE(:LS-HV-DATA-BAIXA), DATE('0001-01-01')),
                   NULLIF(:LS-HV-HORA-BAIXA, '     '),
                   :LS-HV-OBSV-SOCIO)
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-CONST-SQL-OK TO STFSC00B-RETURN-CODE
               WHEN -803
                   MOVE WS-CONST-SQL-DUP-KEY TO STFSC00B-RETURN-CODE
               WHEN OTHER
                   MOVE WS-CONST-SQL-OTHER TO STFSC00B-RETURN-CODE
           END-EVALUATE
           .
      *
       GRAVA-SOCIO-PAGAMENTO.
           IF STFSC00B-C-PERIODICO-PAGAMENTO > ZERO
               MOVE STFSC00B-C-PERIODICO-PAGAMENTO TO WS-QTD-PAG
           ELSE
               MOVE WS-CONST-MAX-PAGAMENTOS TO WS-QTD-PAG
           END-IF
           PERFORM VARYING WS-IND-PAG FROM 1 BY 1
                      UNTIL WS-IND-PAG > WS-QTD-PAG
                      OR NOT STFSC00B-RC-OK
               MOVE WS-IND-PAG TO LS-HV-SEQ-PAGAMENTO
               MOVE STFSC00B-DATA-VENCIMENTO(WS-IND-PAG)
                   TO LS-HV-DATA-VENCIMENTO
               MOVE STFSC00B-VALR-MENSALIDADE(WS-IND-PAG)
                   TO LS-HV-VALR-MENSALIDADE
               PERFORM CONVERTE-PAGAMENTO-OK
               EXEC SQL
                   INSERT INTO SOCIO_PAGAMENTO (
                       NUMB_SOCIO_PRINCIPAL,
                       SEQ_PAGAMENTO,
                       DATA_VENCIMENTO,
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK)
                   VALUES (
                       :LS-HV-NUMB-SOCIO-PRINCIPAL,
                       :LS-HV-SEQ-PAGAMENTO,
                       DATE(:LS-HV-DATA-VENCIMENTO),
                       :LS-HV-VALR-MENSALIDADE,
                       :WS-PAG-OK-DB)
               END-EXEC
               IF SQLCODE NOT = 0
                   MOVE WS-CONST-SQL-OTHER TO STFSC00B-RETURN-CODE
               END-IF
           END-PERFORM
           .
      *
       CONVERTE-INDI-DIVIDA.
           IF STFSC00B-INDI-DIVIDA = 'Y' OR STFSC00B-INDI-DIVIDA = '1'
               MOVE 'Y' TO WS-INDI-DB
           ELSE
               MOVE 'N' TO WS-INDI-DB
           END-IF
           .
      *
       CONVERTE-PAGAMENTO-OK.
           IF STFSC00B-PAGAMENTO-OK(WS-IND-PAG) = 'Y'
              OR STFSC00B-PAGAMENTO-OK(WS-IND-PAG) = '1'
               MOVE 'Y' TO WS-PAG-OK-DB
           ELSE
               MOVE 'N' TO WS-PAG-OK-DB
           END-IF
           .
      *
       FINALIZA.
           .
