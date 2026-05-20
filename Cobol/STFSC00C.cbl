       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       01 WS-CONSTANTS.
           05 WS-PROGRAMA        PIC X(8) VALUE 'STFSC00C'.
           05 WS-VERSAO          PIC X(5) VALUE '1.0'.
           05 WS-OPERACAO-CONS   PIC X(1) VALUE 'C'.
           05 WS-SQLCODE-OK      PIC S9(4) COMP VALUE 0.
           05 WS-SQLCODE-NREC    PIC S9(4) COMP VALUE 100.
           05 WS-SQLCODE-ERRO    PIC S9(4) COMP VALUE 803.

       01 WS-FLAGS.
           05 WS-FIM-PROGRAMA    PIC X(1) VALUE 'N'.
           05 WS-REGISTRO-ENCONTRADO PIC X(1) VALUE 'N'.

       LOCAL-STORAGE SECTION.
       01 SQLCA.
           05 SQLCABC            PIC X(8).
           05 SQLCODE            PIC S9(4) COMP.
           05 SQLERRM.
               10 SQLERRML       PIC S9(4) COMP.
               10 SQLERRMX       PIC X(70).
           05 SQLERRP            PIC X(8).
           05 SQLWARN.
               10 SQLWARN0       PIC X(1).
               10 SQLWARN1       PIC X(1).
               10 SQLWARN2       PIC X(1).
               10 SQLWARN3       PIC X(1).
               10 SQLWARN4       PIC X(1).
               10 SQLWARN5       PIC X(1).
               10 SQLWARN6       PIC X(1).
               10 SQLWARN7       PIC X(1).
           05 SQLSTATE           PIC X(5).

       01 LS-HOST-VARIABLES.
           05 LS-NUMB-SOCIO      PIC 9(9) COMP-3.
           05 LS-NOME-SOCIO      PIC X(40).
           05 LS-DATA-CADASTRO   PIC X(10).
           05 LS-CATG-SOCIO      PIC 9(4) COMP.
           05 LS-INDI-DIVIDA     PIC 9(4) COMP.
           05 LS-DATA-BAIXA      PIC X(10).
           05 LS-HORA-BAIXA      PIC X(8).
           05 LS-OBSV-SOCIO      PIC X(500).

       01 LS-CURSOR-SQL-PAGAMENTO.
           05 CURSOR-STATEMENT   PIC X(500).

       01 SOCIO-RECORD           COPY SOCIO.

       01 SOCIO-COMUNICACAO.
           05 NUMB-SOCIO-TEMP    PIC 9(9) COMP-3.
           05 PAGAMENTO-INDEX    PIC 9(4) COMP VALUE 0.
           05 LS-SEQ-PAGAMENTO   PIC 9(4) COMP.
           05 LS-DATA-VENC       PIC X(10).
           05 LS-VALR-MENS       PIC 9(6)V99 COMP-3.
           05 LS-PAGTO-OK        PIC 9(4) COMP.

       PROCEDURE DIVISION USING SOCIO-RECORD.

           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA

           STOP RUN.

       INICIALIZA.
           MOVE 0 TO RETURN-CODE-DB2 IN SOCIO-RECORD
           MOVE 'N' TO WS-REGISTRO-ENCONTRADO
           MOVE NUMB-SOCIO-PRINCIPAL FROM SOCIO-RECORD
               TO NUMB-SOCIO-TEMP
           MOVE 0 TO PAGAMENTO-INDEX

           ACCEPT SQLCA FROM ENVIRONMENT SQLCA
           .

       PROCESSA.
           IF OPERACAO IN SOCIO-RECORD NOT EQUAL 'C'
               MOVE 999 TO RETURN-CODE-DB2 IN SOCIO-RECORD
               GO TO FIM-PROCESSA
           END-IF

           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      DATA_CADASTRO,
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      DATA_BAIXA,
                      HORA_BAIXA,
                      OBSV_SOCIO
               INTO :LS-NOME-SOCIO,
                    :LS-DATA-CADASTRO,
                    :LS-CATG-SOCIO,
                    :LS-INDI-DIVIDA,
                    :LS-DATA-BAIXA,
                    :LS-HORA-BAIXA,
                    :LS-OBSV-SOCIO
               FROM SOCIOS
               WHERE NUMB_SOCIO_PRINCIPAL = :NUMB-SOCIO-TEMP
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   MOVE LS-NOME-SOCIO TO
                       NOME-SOCIO-PRINCIPAL IN SOCIO-RECORD
                   MOVE LS-DATA-CADASTRO TO
                       DATA-CADASTRO IN SOCIO-RECORD
                   MOVE LS-CATG-SOCIO TO
                       CATG-SOCIO IN SOCIO-RECORD
                   MOVE LS-INDI-DIVIDA TO
                       INDI-DIVIDA IN SOCIO-RECORD
                   MOVE LS-DATA-BAIXA TO
                       DATA-BAIXA IN SOCIO-RECORD
                   MOVE LS-HORA-BAIXA TO
                       HORA-BAIXA IN SOCIO-RECORD
                   MOVE LS-OBSV-SOCIO TO
                       OBSV-SOCIO IN SOCIO-RECORD
                   MOVE 'Y' TO WS-REGISTRO-ENCONTRADO
                   MOVE 0 TO RETURN-CODE-DB2 IN SOCIO-RECORD

                   PERFORM PROCESSA-PAGAMENTOS

               WHEN 100
                   MOVE 100 TO RETURN-CODE-DB2 IN SOCIO-RECORD
               WHEN OTHER
                   MOVE SQLCODE TO
                       RETURN-CODE-DB2 IN SOCIO-RECORD
           END-EVALUATE

           FIM-PROCESSA.
           .

       PROCESSA-PAGAMENTOS.
           MOVE 1 TO PAGAMENTO-INDEX

           EXEC SQL
               DECLARE PAGTO-CURSOR CURSOR FOR
                   SELECT SEQ_PAGAMENTO,
                          DATA_VENCIMENTO,
                          VALR_MENSALIDADE,
                          PAGAMENTO_OK
                   FROM SOCIOS_PAGAMENTO
                   WHERE NUMB_SOCIO_PRINCIPAL = :NUMB-SOCIO-TEMP
                   ORDER BY SEQ_PAGAMENTO
           END-EXEC

           EXEC SQL
               OPEN PAGTO-CURSOR
           END-EXEC

           PERFORM UNTIL PAGAMENTO-INDEX > 12 OR SQLCODE NOT = 0
               EXEC SQL
                   FETCH PAGTO-CURSOR INTO :LS-SEQ-PAGAMENTO,
                                           :LS-DATA-VENC,
                                           :LS-VALR-MENS,
                                           :LS-PAGTO-OK
               END-EXEC

               IF SQLCODE = 0
                   MOVE LS-DATA-VENC TO
                       DATA-VENCIMENTO(PAGAMENTO-INDEX)
                       IN SOCIO-RECORD
                   MOVE LS-VALR-MENS TO
                       VALR-MENSALIDADE(PAGAMENTO-INDEX)
                       IN SOCIO-RECORD
                   MOVE LS-PAGTO-OK TO
                       PAGAMENTO-OK(PAGAMENTO-INDEX)
                       IN SOCIO-RECORD
                   ADD 1 TO PAGAMENTO-INDEX
               ELSE
                   IF SQLCODE NOT = 100
                       MOVE SQLCODE TO
                           RETURN-CODE-DB2 IN SOCIO-RECORD
                   END-IF
               END-IF
           END-PERFORM

           EXEC SQL
               CLOSE PAGTO-CURSOR
           END-EXEC
           .

       FINALIZA.
           .
