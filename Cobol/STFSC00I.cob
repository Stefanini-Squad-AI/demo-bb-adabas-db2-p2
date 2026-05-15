       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.

       AUTHOR. STEFANINI SAI-APP.
       INSTALLATION. STEFANINI.
       DATE-WRITTEN. 2026-05-15.
      * PURPOSE: COBOL Inclusão program - insert new SOCIOS record
      *          and related SOCIOS_PAGAMENTO records into DB2
      *          Called from Natural program STFPCS00

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      * Constants and fixed values only
       01 WS-CONSTANTS.
           05 WS-PROG-NAME        PIC X(8) VALUE 'STFSC00I'.
           05 WS-MAX-PAGOS        PIC 9(2) VALUE 12.
           05 WS-SQL-OK           PIC S9(4) COMP VALUE 0.

       LOCAL-STORAGE SECTION.
      * SQL Communication Area
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01 SQLCA.
           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL END DECLARE SECTION END-EXEC.

      * Natural-COBOL Communication Area
       01 LS-STFSC00-AREA.
           COPY STFSC00 IN 'Cobol/src'.

      * Host variables for main SOCIOS record
       01 LS-SOCIOS-VARS.
           05 LS-NUMB-SOCIO       PIC 9(9).
           05 LS-NOME-SOCIO       PIC X(40).
           05 LS-DATA-CADAS-DB2   PIC X(10).
           05 LS-CATG-SOCIO       PIC S9(4) COMP.
           05 LS-DATA-BAIXA-DB2   PIC X(10).
           05 LS-HORA-BAIXA       PIC X(12).
           05 LS-OBSV-SOCIO       PIC X(500).

      * Host variables for SOCIOS_PAGAMENTO insert
       01 LS-PAGTO-VARS.
           05 LS-PAGTO-DATA-VENC  PIC X(10).
           05 LS-PAGTO-VALOR      PIC S9(4)V99 COMP-3.
           05 LS-PAGTO-OK         PIC X(1).

      * Working variables
       01 LS-WORK-VARS.
           05 LS-INDICE           PIC 9(2) VALUE 0.
           05 LS-NULLIND          PIC S9(4) COMP VALUE 0.

       LINKAGE SECTION.
       01 LS-PARM-STFSC00.
           COPY STFSC00 IN 'Cobol/src'.

       PROCEDURE DIVISION USING LS-PARM-STFSC00.
       MAIN-PROCEDURE.
           MOVE 0 TO WS-RETURN-CODE.

      * Validate input: operation code must be 'I' (Inclusão)
           IF WS-OPERACAO NOT = 'I'
               MOVE 1 TO WS-RETURN-CODE
               PERFORM FINALIZE-PROGRAM
               STOP RUN
           END-IF.

      * Check if member number and name are provided
           IF WS-NUMB-SOCIO-PRINCIPAL = 0
               OR WS-NOME-SOCIO-PRINCIPAL = SPACES
               MOVE 2 TO WS-RETURN-CODE
               PERFORM FINALIZE-PROGRAM
               STOP RUN
           END-IF.

      * Prepare variables from linkage area
           PERFORM PREPARE-INSERT-VARS.

      * Insert main SOCIOS record
           PERFORM INSERT-SOCIOS.

           IF WS-RETURN-CODE NOT = WS-SQL-OK
               PERFORM FINALIZE-PROGRAM
               STOP RUN
           END-IF.

      * Insert payment records
           PERFORM INSERT-PAGAMENTOS.

           PERFORM FINALIZE-PROGRAM.
           STOP RUN.

       PREPARE-INSERT-VARS.
           MOVE WS-NUMB-SOCIO-PRINCIPAL TO LS-NUMB-SOCIO.
           MOVE WS-NOME-SOCIO-PRINCIPAL TO LS-NOME-SOCIO.
           MOVE WS-DATA-CADASTRO TO LS-DATA-CADAS-DB2.
           MOVE WS-CATG-SOCIO TO LS-CATG-SOCIO.
           MOVE WS-DATA-BAIXA TO LS-DATA-BAIXA-DB2.
           MOVE WS-HORA-BAIXA TO LS-HORA-BAIXA.
           MOVE WS-OBSV-SOCIO TO LS-OBSV-SOCIO.

       INSERT-SOCIOS.
      * Insert into main SOCIOS table
           EXEC SQL
               INSERT INTO SOCIOS
               (NUMB_SOCIO_PRINCIPAL,
                NOME_SOCIO_PRINCIPAL,
                DATA_CADASTRO,
                CATG_SOCIO,
                DATA_BAIXA,
                HORA_BAIXA,
                OBSV_SOCIO)
               VALUES
               (:LS-NUMB-SOCIO,
                :LS-NOME-SOCIO,
                :LS-DATA-CADAS-DB2,
                :LS-CATG-SOCIO,
                :LS-DATA-BAIXA-DB2,
                :LS-HORA-BAIXA,
                :LS-OBSV-SOCIO)
           END-EXEC.

           MOVE SQLCODE TO WS-RETURN-CODE.

           IF SQLCODE NOT = WS-SQL-OK
               MOVE SQLCODE TO WS-RETURN-CODE
           END-IF.

       INSERT-PAGAMENTOS.
      * Loop through payment records and insert each one
           PERFORM VARYING LS-INDICE FROM 1 BY 1
               UNTIL LS-INDICE > WS-QTD-PAGAMENTOS
                   OR LS-INDICE > WS-MAX-PAGOS

               MOVE WS-DATA-VENCIMENTO(LS-INDICE)
                   TO LS-PAGTO-DATA-VENC
               MOVE WS-VALR-MENSALIDADE(LS-INDICE)
                   TO LS-PAGTO-VALOR
               MOVE WS-PAGAMENTO-OK(LS-INDICE)
                   TO LS-PAGTO-OK

               EXEC SQL
                   INSERT INTO SOCIOS_PAGAMENTO
                   (NUMB_SOCIO_PRINCIPAL,
                    DATA_VENCIMENTO,
                    VALR_MENSALIDADE,
                    PAGAMENTO_OK)
                   VALUES
                   (:LS-NUMB-SOCIO,
                    :LS-PAGTO-DATA-VENC,
                    :LS-PAGTO-VALOR,
                    :LS-PAGTO-OK)
               END-EXEC

               IF SQLCODE NOT = WS-SQL-OK
                   MOVE SQLCODE TO WS-RETURN-CODE
                   EXIT PERFORM
               END-IF
           END-PERFORM.

       FINALIZE-PROGRAM.
           EXIT.
