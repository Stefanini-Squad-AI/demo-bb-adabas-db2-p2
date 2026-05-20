       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       01 WS-CONSTANTS.
           05 WS-PROGRAMA        PIC X(8) VALUE 'STFSC00I'.
           05 WS-VERSAO          PIC X(5) VALUE '1.0'.
           05 WS-OPERACAO-INCL   PIC X(1) VALUE 'I'.
           05 WS-SQLCODE-OK      PIC S9(4) COMP VALUE 0.
           05 WS-SQLCODE-DUPLICADO PIC S9(4) COMP VALUE 803.

       01 WS-FLAGS.
           05 WS-FIM-PROGRAMA    PIC X(1) VALUE 'N'.
           05 WS-TRANSACAO-OK    PIC X(1) VALUE 'N'.

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

       01 LS-PAGAMENTO-VARS.
           05 LS-SEQ-PAGAMENTO   PIC 9(4) COMP.
           05 LS-DATA-VENC       PIC X(10).
           05 LS-VALR-MENS       PIC 9(6)V99 COMP-3.
           05 LS-PAGTO-OK        PIC 9(4) COMP.
           05 PAGAMENTO-INDEX    PIC 9(4) COMP.

       01 Socio-RECORD           COPY SOCIO.

       PROCEDURE DIVISION USING SOCIO-RECORD.

           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA

           STOP RUN.

       INICIALIZA.
           MOVE 0 TO RETURN-CODE-DB2 IN SOCIO-RECORD
           MOVE 'N' TO WS-TRANSACAO-OK

           ACCEPT SQLCA FROM ENVIRONMENT SQLCA
           .

       PROCESSA.
           IF OPERACAO IN SOCIO-RECORD NOT EQUAL 'I'
               MOVE 999 TO RETURN-CODE-DB2 IN SOCIO-RECORD
               GO TO FIM-PROCESSA
           END-IF

           MOVE NUMB-SOCIO-PRINCIPAL FROM SOCIO-RECORD
               TO LS-NUMB-SOCIO
           MOVE NOME-SOCIO-PRINCIPAL FROM SOCIO-RECORD
               TO LS-NOME-SOCIO
           MOVE DATA-CADASTRO FROM SOCIO-RECORD
               TO LS-DATA-CADASTRO
           MOVE CATG-SOCIO FROM SOCIO-RECORD
               TO LS-CATG-SOCIO
           MOVE INDI-DIVIDA FROM SOCIO-RECORD
               TO LS-INDI-DIVIDA
           MOVE DATA-BAIXA FROM SOCIO-RECORD
               TO LS-DATA-BAIXA
           MOVE HORA-BAIXA FROM SOCIO-RECORD
               TO LS-HORA-BAIXA
           MOVE OBSV-SOCIO FROM SOCIO-RECORD
               TO LS-OBSV-SOCIO

           PERFORM INICIA-TRANSACAO

           IF RETURN-CODE-DB2 IN SOCIO-RECORD = 0
               PERFORM INSERE-SOCIO
               IF RETURN-CODE-DB2 IN SOCIO-RECORD = 0
                   PERFORM INSERE-PAGAMENTOS
               END-IF
           END-IF

           IF RETURN-CODE-DB2 IN SOCIO-RECORD = 0
               PERFORM COMMIT-TRANSACAO
           ELSE
               PERFORM ROLLBACK-TRANSACAO
           END-IF

           FIM-PROCESSA.
           .

       INICIA-TRANSACAO.
           EXEC SQL
               BEGIN WORK
           END-EXEC
           .

       INSERE-SOCIO.
           EXEC SQL
               INSERT INTO SOCIOS
                   (NUMB_SOCIO_PRINCIPAL,
                    NOME_SOCIO_PRINCIPAL,
                    DATA_CADASTRO,
                    CATG_SOCIO,
                    INDI_DIVIDA,
                    DATA_BAIXA,
                    HORA_BAIXA,
                    OBSV_SOCIO)
               VALUES (:LS-NUMB-SOCIO,
                       :LS-NOME-SOCIO,
                       :LS-DATA-CADASTRO,
                       :LS-CATG-SOCIO,
                       :LS-INDI-DIVIDA,
                       :LS-DATA-BAIXA,
                       :LS-HORA-BAIXA,
                       :LS-OBSV-SOCIO)
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   MOVE 0 TO RETURN-CODE-DB2 IN SOCIO-RECORD
               WHEN -803
                   MOVE 803 TO RETURN-CODE-DB2 IN SOCIO-RECORD
               WHEN OTHER
                   MOVE SQLCODE TO
                       RETURN-CODE-DB2 IN SOCIO-RECORD
           END-EVALUATE
           .

       INSERE-PAGAMENTOS.
           MOVE 1 TO PAGAMENTO-INDEX

           PERFORM UNTIL PAGAMENTO-INDEX > 12
               MOVE DATA-VENCIMENTO(PAGAMENTO-INDEX)
                   FROM SOCIO-RECORD TO LS-DATA-VENC
               MOVE VALR-MENSALIDADE(PAGAMENTO-INDEX)
                   FROM SOCIO-RECORD TO LS-VALR-MENS
               MOVE PAGAMENTO-OK(PAGAMENTO-INDEX)
                   FROM SOCIO-RECORD TO LS-PAGTO-OK

               IF LS-DATA-VENC NOT = SPACES AND
                  LS-VALR-MENS > 0
                   MOVE PAGAMENTO-INDEX TO LS-SEQ-PAGAMENTO

                   EXEC SQL
                       INSERT INTO SOCIOS_PAGAMENTO
                           (NUMB_SOCIO_PRINCIPAL,
                            SEQ_PAGAMENTO,
                            DATA_VENCIMENTO,
                            VALR_MENSALIDADE,
                            PAGAMENTO_OK)
                       VALUES (:LS-NUMB-SOCIO,
                               :LS-SEQ-PAGAMENTO,
                               :LS-DATA-VENC,
                               :LS-VALR-MENS,
                               :LS-PAGTO-OK)
                   END-EXEC

                   IF SQLCODE NOT = 0
                       MOVE SQLCODE TO
                           RETURN-CODE-DB2 IN SOCIO-RECORD
                       MOVE 12 TO PAGAMENTO-INDEX
                   END-IF
               END-IF

               ADD 1 TO PAGAMENTO-INDEX
           END-PERFORM
           .

       COMMIT-TRANSACAO.
           EXEC SQL
               COMMIT WORK
           END-EXEC
           .

       ROLLBACK-TRANSACAO.
           EXEC SQL
               ROLLBACK WORK
           END-EXEC
           .

       FINALIZA.
           .
