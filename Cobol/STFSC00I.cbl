       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      * ================================================================
      * Programa: STFSC00I
      * Descrição: Programa de Inclusão de Sócio em DB2
      *            Migração: ADABAS-SOCIOS para DB2
      * Data: 2026-05-20
      * Operação: I (Inclusão/STORE)
      * ================================================================

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       01 WS-CONSTANTS.
           05 WS-PROGRAMA          PIC X(8) VALUE 'STFSC00I'.
           05 WS-VERSAO            PIC X(4) VALUE '1.0'.
           05 WS-TABELA            PIC X(20) VALUE 'SOCIOS'.
           05 WS-TABELA-PAGO       PIC X(20) VALUE 'SOCIOS_PAGAMENTO'.

       01 WS-MENSAGENS.
           05 WS-MSG-SUCESSO       PIC X(30)
               VALUE 'Inclusão realizada com sucesso'.
           05 WS-MSG-DUP-CHAVE      PIC X(30)
               VALUE 'Chave primária duplicada'.
           05 WS-MSG-ERRO-DB2      PIC X(30)
               VALUE 'Erro ao acessar DB2'.

       LOCAL-STORAGE SECTION.
       01 LS-SQLCA.
           05 SQLCODE              PIC S9(9) COMP VALUE 0.
           05 SQLERRM              PIC X(70).
           05 SQLSTATE             PIC X(5).
           05 SQLERRD OCCURS 6 TIMES
                                   PIC S9(9) COMP.

       01 LS-HOST-VARIABLES.
           05 LS-RG-INSERT         PIC 9(9).
           05 LS-NOME              PIC X(40).
           05 LS-DATA-CADASTRO     PIC X(10).
           05 LS-CATG              PIC 9(2).
           05 LS-DIVIDA            PIC 9(1).
           05 LS-DATA-BAIXA        PIC X(10).
           05 LS-HORA-BAIXA        PIC X(5).
           05 LS-OBSV              PIC X(500).

       01 LS-HOST-VARIABLES-PAGO.
           05 LS-SEQUENCIAL        PIC 9(2).
           05 LS-DATA-VENCIMENTO   PIC X(10).
           05 LS-VALOR-MENSALIDADE PIC 9(4)V99.
           05 LS-PAGAMENTO-OK      PIC 9(1).

       01 LS-CONTROLES.
           05 LS-INDICE-PAGO       PIC 9(2) VALUE 0.

       COPY STFPCS00.

       LINKAGE SECTION.
       01 LK-AREA.
           05 LK-STFPCS00-AREA   USAGE POINTER.

       PROCEDURE DIVISION USING LK-AREA.

           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA

           GOBACK.

       INICIALIZA SECTION.
           MOVE 0 TO STFPCS00-RETURN-CODE.

           EXEC SQL
               CONNECT TO DSN-DB2
           END-EXEC.

       PROCESSA SECTION.
           IF STFPCS00-INCLUIR
               PERFORM PROCESSA-INCLUSAO
           END-IF.

       PROCESSA-INCLUSAO SECTION.
           MOVE SOCIOS-RG TO LS-RG-INSERT.
           MOVE SOCIOS-NOME TO LS-NOME.
           MOVE SOCIOS-DATA-CADASTRO TO LS-DATA-CADASTRO.
           MOVE SOCIOS-CATG TO LS-CATG.
           MOVE SOCIOS-DIVIDA TO LS-DIVIDA.
           MOVE SOCIOS-DATA-BAIXA TO LS-DATA-BAIXA.
           MOVE SOCIOS-HORA-BAIXA TO LS-HORA-BAIXA.
           MOVE SOCIOS-OBSV TO LS-OBSV.

           EXEC SQL
               INSERT INTO SOCIOS
               (NUMB_SOCIO, NOME_SOCIO, DATA_CADASTRO,
                CATG_SOCIO, INDI_DIVIDA, DATA_BAIXA,
                HORA_BAIXA, OBSV_SOCIO)
               VALUES
               (:LS-RG-INSERT, :LS-NOME, :LS-DATA-CADASTRO,
                :LS-CATG, :LS-DIVIDA, :LS-DATA-BAIXA,
                :LS-HORA-BAIXA, :LS-OBSV)
           END-EXEC.

           IF SQLCODE = 0
               PERFORM INSERE-PAGAMENTOS
               MOVE 0 TO STFPCS00-RETURN-CODE
           ELSE IF SQLCODE = -803
               MOVE 803 TO STFPCS00-RETURN-CODE
           ELSE
               MOVE 999 TO STFPCS00-RETURN-CODE
           END-IF
           END-IF.

       INSERE-PAGAMENTOS SECTION.
           PERFORM VARYING LS-INDICE-PAGO FROM 1 BY 1
               UNTIL LS-INDICE-PAGO > 12

               MOVE LS-INDICE-PAGO TO LS-SEQUENCIAL
               MOVE PAGO-DATA-VENCIMENTO(LS-INDICE-PAGO)
                   TO LS-DATA-VENCIMENTO
               MOVE PAGO-VALOR(LS-INDICE-PAGO)
                   TO LS-VALOR-MENSALIDADE
               MOVE PAGO-STATUS(LS-INDICE-PAGO)
                   TO LS-PAGAMENTO-OK

               IF LS-DATA-VENCIMENTO NOT = SPACES
                   EXEC SQL
                       INSERT INTO SOCIOS_PAGAMENTO
                       (NUMB_SOCIO, SEQUENCIAL, DATA_VENCIMENTO,
                        VALR_MENSALIDADE, PAGAMENTO_OK)
                       VALUES
                       (:LS-RG-INSERT, :LS-SEQUENCIAL,
                        :LS-DATA-VENCIMENTO, :LS-VALOR-MENSALIDADE,
                        :LS-PAGAMENTO-OK)
                   END-EXEC

                   IF SQLCODE NOT = 0
                       EXEC SQL
                           ROLLBACK
                       END-EXEC
                       MOVE 999 TO STFPCS00-RETURN-CODE
                       EXIT PERFORM
                   END-IF
               END-IF
           END-PERFORM.

           IF STFPCS00-RETURN-CODE = 0
               EXEC SQL
                   COMMIT
               END-EXEC
           END-IF.

       FINALIZA SECTION.
           EXEC SQL
               DISCONNECT ALL
           END-EXEC.

           STOP RUN.
