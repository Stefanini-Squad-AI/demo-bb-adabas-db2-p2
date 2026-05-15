       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.

      *================================================================*
      * Program: STFSC00I
      * Purpose: Inclusion - Insert new member (SOCIOS) data into DB2
      * Date: 2026-05-15
      * Operation: I (Inclusion)
      * Function: Inserts a new member record and associated payment
      *           records in SOCIOS and SOCIOS_PAGAMENTO tables
      *================================================================*

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      *-- Constants
       01 WS-CONST-PROG         PIC X(8) VALUE 'STFSC00I'.
       01 WS-CONST-OK           PIC 9(4) VALUE 0.
       01 WS-CONST-INSERT-ERR   PIC 9(4) VALUE 300.
       01 WS-CONST-DB-ERROR     PIC 9(4) VALUE 500.
       01 WS-CONST-SPACES       PIC X(1) VALUE SPACE.

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

      *-- Working variables
       01 WS-PAYMENT-INDEX      PIC 9(2) VALUE 0.
       01 WS-PAYMENT-COUNT      PIC 9(2) VALUE 0.
       01 WS-NULL-VALUE         PIC X(10) VALUE SPACES.

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
           PERFORM INSERT-MEMBER-RECORD.
           IF RETURN-CODE-OPER = 0
               PERFORM INSERT-PAYMENT-RECORDS
           END-IF.
           PERFORM MOVE-DATA-TO-LINKAGE.
           PERFORM RETURN-TO-CALLER.
           STOP RUN.

       INITIALIZE-VARIABLES.
           MOVE SPACES TO SOCIOS-RECORD.
           MOVE 0 TO RETURN-CODE-OPER.
           MOVE 0 TO WS-PAYMENT-COUNT.
           MOVE 0 TO WS-PAYMENT-INDEX.
           MOVE LS-NUMB-SOCIO-PRINCIPAL
               TO HS-NUMB-SOCIO.
           MOVE LS-NOME-SOCIO-PRINCIPAL
               TO HS-NOME.
           MOVE LS-DATA-CADASTRO
               TO HS-DATA-CADASTRO.
           MOVE LS-CATG-SOCIO
               TO HS-CATG-SOCIO.
           MOVE LS-INDI-DIVIDA
               TO HS-INDI-DIVIDA.
           MOVE LS-DATA-BAIXA
               TO HS-DATA-BAIXA.
           MOVE LS-HORA-BAIXA
               TO HS-HORA-BAIXA.
           MOVE LS-OBSV-SOCIO
               TO HS-OBSV-SOCIO.

       INSERT-MEMBER-RECORD.
      *-- Insert main member record into SOCIOS
           EXEC SQL
               INSERT INTO SOCIOS (
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_SOCIO
               ) VALUES (
                   :HS-NUMB-SOCIO,
                   :HS-NOME,
                   :HS-DATA-CADASTRO,
                   :HS-CATG-SOCIO,
                   NULLIF(:HS-DATA-BAIXA, ''),
                   NULLIF(:HS-HORA-BAIXA, ''),
                   NULLIF(:HS-OBSV-SOCIO, '')
               )
           END-EXEC.

           EVALUATE TRUE
               WHEN SQLCODE = 0
                   MOVE 0 TO RETURN-CODE-OPER
               WHEN SQLCODE = -803
      *-- Duplicate key error
                   MOVE WS-CONST-INSERT-ERR
                       TO RETURN-CODE-OPER
               WHEN OTHER
                   MOVE WS-CONST-DB-ERROR
                       TO RETURN-CODE-OPER
           END-EVALUATE.

       INSERT-PAYMENT-RECORDS.
      *-- Insert all payment records from PERIODICO-PAGAMENTO
           MOVE 1 TO WS-PAYMENT-INDEX.
           PERFORM UNTIL WS-PAYMENT-INDEX > 12
               SET PAG-IDX TO WS-PAYMENT-INDEX
               MOVE DATA-VENCIMENTO(PAG-IDX)
                   TO HS-DATA-VENCIMENTO
               MOVE VALR-MENSALIDADE(PAG-IDX)
                   TO HS-VALR-MENSALIDADE
               MOVE PAGAMENTO-OK(PAG-IDX)
                   TO HS-PAGAMENTO-OK
      *-- Only insert if payment data is present
               IF HS-DATA-VENCIMENTO NOT = SPACES
                   PERFORM INSERT-SINGLE-PAYMENT
               END-IF
               ADD 1 TO WS-PAYMENT-INDEX
           END-PERFORM.

       INSERT-SINGLE-PAYMENT.
      *-- Insert individual payment record
           EXEC SQL
               INSERT INTO SOCIOS_PAGAMENTO (
                   NUMB_SOCIO_PRINCIPAL,
                   DATA_VENCIMENTO,
                   VALR_MENSALIDADE,
                   PAGAMENTO_OK
               ) VALUES (
                   :HS-NUMB-SOCIO,
                   :HS-DATA-VENCIMENTO,
                   :HS-VALR-MENSALIDADE,
                   :HS-PAGAMENTO-OK
               )
           END-EXEC.

           IF SQLCODE NOT = 0
               MOVE WS-CONST-DB-ERROR
                   TO RETURN-CODE-OPER
           END-IF.

       MOVE-DATA-TO-LINKAGE.
           MOVE RETURN-CODE-OPER
               TO LS-RETURN-CODE-OPER.

       RETURN-TO-CALLER.
           GOBACK.
