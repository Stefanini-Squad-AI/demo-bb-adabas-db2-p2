       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.

       AUTHOR. STEFANINI SAI-APP.
       INSTALLATION. STEFANINI.
       DATE-WRITTEN. 2026-05-15.
      * PURPOSE: COBOL Consulta program - read SOCIOS and related
      *          SOCIOS_PAGAMENTO records from DB2
      *          Called from Natural program STFPCS00

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      * Constants and fixed values only
       01 WS-CONSTANTS.
           05 WS-PROG-NAME        PIC X(8) VALUE 'STFSC00C'.
           05 WS-MAX-PAGOS        PIC 9(2) VALUE 12.
           05 WS-SQL-OK           PIC S9(4) COMP VALUE 0.
           05 WS-NOT-FOUND        PIC S9(4) COMP VALUE 100.

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

      * Host variables for SOCIOS_PAGAMENTO cursor
       01 LS-PAGTO-VARS.
           05 LS-PAGTO-DATA-VENC  PIC X(10).
           05 LS-PAGTO-VALOR      PIC S9(4)V99 COMP-3.
           05 LS-PAGTO-OK         PIC X(1).

      * Working variables
       01 LS-WORK-VARS.
           05 LS-INDICE           PIC 9(2) VALUE 0.
           05 LS-QTD-PAGTOS       PIC 9(2) VALUE 0.

       LINKAGE SECTION.
       01 LS-PARM-STFSC00.
           COPY STFSC00 IN 'Cobol/src'.

       PROCEDURE DIVISION USING LS-PARM-STFSC00.
       MAIN-PROCEDURE.
           MOVE SPACES TO WS-PROG-NAME.
           MOVE 0 TO WS-RETURN-CODE.

      * Validate input: operation code must be 'C' (Consulta)
           IF WS-OPERACAO NOT = 'C'
               MOVE 1 TO WS-RETURN-CODE
               PERFORM FINALIZE-PROGRAM
               STOP RUN
           END-IF.

      * Check if member number is provided
           IF WS-NUMB-SOCIO-PRINCIPAL = 0
               MOVE 2 TO WS-RETURN-CODE
               PERFORM FINALIZE-PROGRAM
               STOP RUN
           END-IF.

      * Execute main query to fetch SOCIOS record
           PERFORM FETCH-SOCIOS.

           IF WS-RETURN-CODE NOT = WS-SQL-OK
               PERFORM FINALIZE-PROGRAM
               STOP RUN
           END-IF.

      * Execute cursor query to fetch SOCIOS_PAGAMENTO records
           PERFORM FETCH-PAGAMENTOS.

      * Copy results back to linkage area
           PERFORM COPY-RESULTS-TO-LINKAGE.

           PERFORM FINALIZE-PROGRAM.
           STOP RUN.

       FETCH-SOCIOS.
      * Query SOCIOS table by primary key
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      DATA_CADASTRO,
                      CATG_SOCIO,
                      DATA_BAIXA,
                      HORA_BAIXA,
                      OBSV_SOCIO
               INTO :LS-NOME-SOCIO,
                    :LS-DATA-CADAS-DB2,
                    :LS-CATG-SOCIO,
                    :LS-DATA-BAIXA-DB2,
                    :LS-HORA-BAIXA,
                    :LS-OBSV-SOCIO
               FROM SOCIOS
               WHERE NUMB_SOCIO_PRINCIPAL = :LS-NUMB-SOCIO
           END-EXEC.

           EVALUATE SQLCODE
               WHEN WS-SQL-OK
                   MOVE 0 TO WS-RETURN-CODE
               WHEN WS-NOT-FOUND
                   MOVE 100 TO WS-RETURN-CODE
               WHEN OTHER
                   MOVE SQLCODE TO WS-RETURN-CODE
           END-EVALUATE.

       FETCH-PAGAMENTOS.
      * Initialize payment count
           MOVE 0 TO LS-QTD-PAGTOS.

      * Declare and open cursor for SOCIOS_PAGAMENTO
           EXEC SQL
               DECLARE PAGTO-CURSOR CURSOR FOR
               SELECT DATA_VENCIMENTO,
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
               FROM SOCIOS_PAGAMENTO
               WHERE NUMB_SOCIO_PRINCIPAL = :LS-NUMB-SOCIO
               ORDER BY DATA_VENCIMENTO
           END-EXEC.

           EXEC SQL
               OPEN PAGTO-CURSOR
           END-EXEC.

      * Fetch each payment record
           PERFORM UNTIL LS-QTD-PAGTOS >= WS-MAX-PAGOS
                   OR SQLCODE NOT = WS-SQL-OK
               EXEC SQL
                   FETCH PAGTO-CURSOR
                   INTO :LS-PAGTO-DATA-VENC,
                        :LS-PAGTO-VALOR,
                        :LS-PAGTO-OK
               END-EXEC

               IF SQLCODE = WS-OK
                   ADD 1 TO LS-QTD-PAGTOS
                   MOVE LS-PAGTO-DATA-VENC TO
                       WS-DATA-VENCIMENTO(LS-QTD-PAGTOS)
                   MOVE LS-PAGTO-VALOR TO
                       WS-VALR-MENSALIDADE(LS-QTD-PAGTOS)
                   MOVE LS-PAGTO-OK TO
                       WS-PAGAMENTO-OK(LS-QTD-PAGTOS)
               END-IF
           END-PERFORM.

           EXEC SQL
               CLOSE PAGTO-CURSOR
           END-EXEC.

       COPY-RESULTS-TO-LINKAGE.
           MOVE LS-NOME-SOCIO TO WS-NOME-SOCIO-PRINCIPAL.
           MOVE LS-DATA-CADAS-DB2 TO WS-DATA-CADASTRO.
           MOVE LS-CATG-SOCIO TO WS-CATG-SOCIO.
           MOVE LS-DATA-BAIXA-DB2 TO WS-DATA-BAIXA.
           MOVE LS-HORA-BAIXA TO WS-HORA-BAIXA.
           MOVE LS-OBSV-SOCIO TO WS-OBSV-SOCIO.
           MOVE LS-QTD-PAGTOS TO WS-QTD-PAGAMENTOS.

       FINALIZE-PROGRAM.
           EXIT.
