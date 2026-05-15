       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.

      *================================================================*
      * Program: STFSC00C
      * Purpose: Consultation - Retrieve member (SOCIOS) data from DB2
      * Date: 2026-05-15
      * Operation: C (Consultation)
      * Function: Retrieves member record by NUMB-SOCIO-PRINCIPAL and
      *           all associated payment records from SOCIOS_PAGAMENTO
      *================================================================*

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      *-- Constants
       01 WS-CONST-PROG         PIC X(8) VALUE 'STFSC00C'.
       01 WS-CONST-OK           PIC 9(4) VALUE 0.
       01 WS-CONST-NOT-FOUND    PIC 9(4) VALUE 100.
       01 WS-CONST-DB-ERROR     PIC 9(4) VALUE 500.

       LOCAL-STORAGE SECTION.
      *-- SQLCA for DB2
           EXEC SQL INCLUDE SQLCA END-EXEC.

      *-- Communication book
       01 SOCIOS-RECORD.
           05 RETURN-CODE-OPER          PIC 9(4) VALUE 0.
           05 NUMB-SOCIO-PRINCIPAL      PIC 9(9).
           05 NOME-SOCIO-PRINCIPAL      PIC X(40).
           05 DATA-CADASTRO             PIC X(10).
           05 CATG-SOCIO                PIC 9(2).
           05 INDI-DIVIDA               PIC X(1).
           05 DATA-BAIXA                PIC X(10).
           05 HORA-BAIXA                PIC X(12).
           05 OBSV-SOCIO                PIC X(500).
           05 FILLER                    PIC X(13) VALUE SPACES.
           05 PERIODICO-PAGAMENTO.
               10 PAGAMENTO-ITEM        OCCURS 12 TIMES
                   INDEXED BY PAG-IDX.
                   15 DATA-VENCIMENTO   PIC X(10).
                   15 VALR-MENSALIDADE  PIC S9(6)V99.
                   15 PAGAMENTO-OK      PIC 9(1).

      *-- Host variables for DB2
       01 HS-NUMB-SOCIO         PIC 9(9).
       01 HS-NOME               PIC X(40).
       01 HS-DATA-CADASTRO      PIC X(10).
       01 HS-CATG-SOCIO         PIC 9(2).
       01 HS-INDI-DIVIDA        PIC X(1).
       01 HS-DATA-BAIXA         PIC X(10).
       01 HS-HORA-BAIXA         PIC X(12).
       01 HS-OBSV-SOCIO         PIC X(500).
       01 HS-DATA-VENCIMENTO    PIC X(10).
       01 HS-VALR-MENSALIDADE   PIC S9(6)V99.
       01 HS-PAGAMENTO-OK       PIC 9(1).

      *-- DB2 Indicators
       01 IND-NUMB-SOCIO        PIC S9(4) COMP.
       01 IND-NOME              PIC S9(4) COMP.
       01 IND-DATA-CADASTRO     PIC S9(4) COMP.
       01 IND-CATG-SOCIO        PIC S9(4) COMP.
       01 IND-INDI-DIVIDA       PIC S9(4) COMP.
       01 IND-DATA-BAIXA        PIC S9(4) COMP.
       01 IND-HORA-BAIXA        PIC S9(4) COMP.
       01 IND-OBSV-SOCIO        PIC S9(4) COMP.
       01 IND-DATA-VENCIMENTO   PIC S9(4) COMP.
       01 IND-VALR-MENSALIDADE  PIC S9(4) COMP.
       01 IND-PAGAMENTO-OK      PIC S9(4) COMP.

      *-- Working variables
       01 WS-PAYMENT-COUNT      PIC 9(2) VALUE 0.
       01 WS-CURSOR-EOF         PIC X(1) VALUE 'N'.

       LINKAGE SECTION.
       01 LS-SOCIOS-RECORD.
           05 RETURN-CODE-OPER          PIC 9(4).
           05 NUMB-SOCIO-PRINCIPAL      PIC 9(9).
           05 NOME-SOCIO-PRINCIPAL      PIC X(40).
           05 DATA-CADASTRO             PIC X(10).
           05 CATG-SOCIO                PIC 9(2).
           05 INDI-DIVIDA               PIC X(1).
           05 DATA-BAIXA                PIC X(10).
           05 HORA-BAIXA                PIC X(12).
           05 OBSV-SOCIO                PIC X(500).
           05 FILLER                    PIC X(13).
           05 PERIODICO-PAGAMENTO.
               10 PAGAMENTO-ITEM        OCCURS 12 TIMES
                   INDEXED BY PAG-IDX.
                   15 DATA-VENCIMENTO   PIC X(10).
                   15 VALR-MENSALIDADE  PIC S9(6)V99.
                   15 PAGAMENTO-OK      PIC 9(1).

       PROCEDURE DIVISION USING LS-SOCIOS-RECORD.

       MAIN-PROCEDURE.
           PERFORM INITIALIZE-VARIABLES.
           PERFORM RETRIEVE-MEMBER-DATA.
           PERFORM MOVE-DATA-TO-LINKAGE.
           PERFORM RETURN-TO-CALLER.
           STOP RUN.

       INITIALIZE-VARIABLES.
           MOVE SPACES TO SOCIOS-RECORD.
           MOVE 0 TO RETURN-CODE-OPER.
           MOVE 0 TO WS-PAYMENT-COUNT.
           MOVE 'N' TO WS-CURSOR-EOF.
           MOVE LS-NUMB-SOCIO-PRINCIPAL
               TO HS-NUMB-SOCIO.

       RETRIEVE-MEMBER-DATA.
      *-- Query main member record from SOCIOS
           EXEC SQL
               SELECT
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   COALESCE(DATA_BAIXA, ''),
                   COALESCE(HORA_BAIXA, ''),
                   COALESCE(OBSV_SOCIO, '')
               INTO
                   :HS-NUMB-SOCIO :IND-NUMB-SOCIO,
                   :HS-NOME :IND-NOME,
                   :HS-DATA-CADASTRO :IND-DATA-CADASTRO,
                   :HS-CATG-SOCIO :IND-CATG-SOCIO,
                   :HS-DATA-BAIXA :IND-DATA-BAIXA,
                   :HS-HORA-BAIXA :IND-HORA-BAIXA,
                   :HS-OBSV-SOCIO :IND-OBSV-SOCIO
               FROM SOCIOS
               WHERE NUMB_SOCIO_PRINCIPAL = :HS-NUMB-SOCIO
           END-EXEC.

           EVALUATE TRUE
               WHEN SQLCODE = 0
                   MOVE 0 TO RETURN-CODE-OPER
                   PERFORM RETRIEVE-PAYMENT-RECORDS
               WHEN SQLCODE = 100
                   MOVE WS-CONST-NOT-FOUND
                       TO RETURN-CODE-OPER
               WHEN OTHER
                   MOVE WS-CONST-DB-ERROR
                       TO RETURN-CODE-OPER
           END-EVALUATE.

       RETRIEVE-PAYMENT-RECORDS.
      *-- Declare cursor for payment records
           EXEC SQL
               DECLARE CURSOR-PAYMENTS CURSOR FOR
               SELECT
                   DATA_VENCIMENTO,
                   VALR_MENSALIDADE,
                   PAGAMENTO_OK
               FROM SOCIOS_PAGAMENTO
               WHERE NUMB_SOCIO_PRINCIPAL = :HS-NUMB-SOCIO
               ORDER BY PAGTO_ID
           END-EXEC.

      *-- Open and fetch payment records
           EXEC SQL
               OPEN CURSOR-PAYMENTS
           END-EXEC.

           MOVE 1 TO WS-PAYMENT-COUNT.
           PERFORM UNTIL WS-CURSOR-EOF = 'Y'
               OR WS-PAYMENT-COUNT > 12
               EXEC SQL
                   FETCH CURSOR-PAYMENTS INTO
                       :HS-DATA-VENCIMENTO :IND-DATA-VENCIMENTO,
                       :HS-VALR-MENSALIDADE :IND-VALR-MENSALIDADE,
                       :HS-PAGAMENTO-OK :IND-PAGAMENTO-OK
               END-EXEC
               IF SQLCODE = 0
                   PERFORM STORE-PAYMENT-ITEM
                   ADD 1 TO WS-PAYMENT-COUNT
               ELSE
                   IF SQLCODE = 100
                       MOVE 'Y' TO WS-CURSOR-EOF
                   ELSE
                       MOVE WS-CONST-DB-ERROR
                           TO RETURN-CODE-OPER
                       MOVE 'Y' TO WS-CURSOR-EOF
                   END-IF
               END-IF
           END-PERFORM.

           EXEC SQL
               CLOSE CURSOR-PAYMENTS
           END-EXEC.

       STORE-PAYMENT-ITEM.
           SET PAG-IDX TO WS-PAYMENT-COUNT.
           MOVE HS-DATA-VENCIMENTO
               TO DATA-VENCIMENTO(PAG-IDX).
           MOVE HS-VALR-MENSALIDADE
               TO VALR-MENSALIDADE(PAG-IDX).
           MOVE HS-PAGAMENTO-OK
               TO PAGAMENTO-OK(PAG-IDX).

       MOVE-DATA-TO-LINKAGE.
           MOVE RETURN-CODE-OPER
               TO LS-RETURN-CODE-OPER.
           MOVE NUMB-SOCIO-PRINCIPAL
               TO LS-NUMB-SOCIO-PRINCIPAL.
           MOVE NOME-SOCIO-PRINCIPAL
               TO LS-NOME-SOCIO-PRINCIPAL.
           MOVE DATA-CADASTRO
               TO LS-DATA-CADASTRO.
           MOVE CATG-SOCIO
               TO LS-CATG-SOCIO.
           MOVE INDI-DIVIDA
               TO LS-INDI-DIVIDA.
           MOVE DATA-BAIXA
               TO LS-DATA-BAIXA.
           MOVE HORA-BAIXA
               TO LS-HORA-BAIXA.
           MOVE OBSV-SOCIO
               TO LS-OBSV-SOCIO.
           MOVE PERIODICO-PAGAMENTO
               TO LS-PERIODICO-PAGAMENTO.

       RETURN-TO-CALLER.
           GOBACK.
