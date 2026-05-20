       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      * ================================================================
      * Programa: STFSC00C
      * Descrição: Programa de Consulta de Sócio em DB2
      *            Migração: ADABAS-SOCIOS para DB2
      * Data: 2026-05-20
      * Operação: C (Consulta/FIND)
      * ================================================================

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       01 WS-CONSTANTS.
           05 WS-PROGRAMA          PIC X(8) VALUE 'STFSC00C'.
           05 WS-VERSAO            PIC X(4) VALUE '1.0'.
           05 WS-TABELA            PIC X(20) VALUE 'SOCIOS'.
           05 WS-TABELA-PAGO       PIC X(20) VALUE 'SOCIOS_PAGAMENTO'.

       01 WS-MENSAGENS.
           05 WS-MSG-SUCESSO       PIC X(30)
               VALUE 'Consulta realizada com sucesso'.
           05 WS-MSG-NAO-ENCONTRADO PIC X(30)
               VALUE 'Sócio não encontrado'.
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
           05 LS-RG-BUSCA          PIC 9(9).
           05 LS-NOME              PIC X(40).
           05 LS-DATA-CADASTRO     PIC X(10).
           05 LS-CATG              PIC 9(2).
           05 LS-DIVIDA            PIC 9(1).
           05 LS-DATA-BAIXA        PIC X(10).
           05 LS-HORA-BAIXA        PIC X(5).
           05 LS-OBSV              PIC X(500).

       01 LS-HOST-VARIABLES-PAGO.
           05 LS-DATA-VENCIMENTO   PIC X(10).
           05 LS-VALOR-MENSALIDADE PIC 9(4)V99.
           05 LS-PAGAMENTO-OK      PIC 9(1).

       01 LS-CURSORES.
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
           MOVE LS-RG-BUSCA TO STFPCS00-DADOS.

           EXEC SQL
               CONNECT TO DSN-DB2
           END-EXEC.

       PROCESSA SECTION.
           IF STFPCS00-CONSULTAR
               PERFORM PROCESSA-CONSULTA
           END-IF.

       PROCESSA-CONSULTA SECTION.
           MOVE SOCIOS-RG TO LS-RG-BUSCA.

           EXEC SQL
               SELECT NUMB_SOCIO, NOME_SOCIO, DATA_CADASTRO,
                      CATG_SOCIO, INDI_DIVIDA, DATA_BAIXA,
                      HORA_BAIXA, OBSV_SOCIO
               INTO :LS-RG-BUSCA, :LS-NOME, :LS-DATA-CADASTRO,
                    :LS-CATG, :LS-DIVIDA, :LS-DATA-BAIXA,
                    :LS-HORA-BAIXA, :LS-OBSV
               FROM SOCIOS
               WHERE NUMB_SOCIO = :LS-RG-BUSCA
           END-EXEC.

           IF SQLCODE = 0
               PERFORM BUSCA-PAGAMENTOS
               MOVE 0 TO STFPCS00-RETURN-CODE
               MOVE LS-NOME TO SOCIOS-NOME
               MOVE LS-DATA-CADASTRO TO SOCIOS-DATA-CADASTRO
               MOVE LS-CATG TO SOCIOS-CATG
               MOVE LS-DIVIDA TO SOCIOS-DIVIDA
               MOVE LS-DATA-BAIXA TO SOCIOS-DATA-BAIXA
               MOVE LS-HORA-BAIXA TO SOCIOS-HORA-BAIXA
               MOVE LS-OBSV TO SOCIOS-OBSV
           ELSE IF SQLCODE = 100
               MOVE 100 TO STFPCS00-RETURN-CODE
           ELSE
               MOVE 999 TO STFPCS00-RETURN-CODE
           END-IF
           END-IF.

       BUSCA-PAGAMENTOS SECTION.
           MOVE 0 TO LS-INDICE-PAGO.

           EXEC SQL
               DECLARE CURSOR_PAGO CURSOR FOR
               SELECT DATA_VENCIMENTO, VALR_MENSALIDADE, PAGAMENTO_OK
               FROM SOCIOS_PAGAMENTO
               WHERE NUMB_SOCIO = :LS-RG-BUSCA
               ORDER BY SEQUENCIAL
           END-EXEC.

           EXEC SQL
               OPEN CURSOR_PAGO
           END-EXEC.

           PERFORM UNTIL SQLCODE NOT = 0
               ADD 1 TO LS-INDICE-PAGO
               IF LS-INDICE-PAGO > 12
                   EXIT PERFORM
               END-IF

               EXEC SQL
                   FETCH CURSOR_PAGO
                   INTO :LS-DATA-VENCIMENTO, :LS-VALOR-MENSALIDADE,
                        :LS-PAGAMENTO-OK
               END-EXEC

               IF SQLCODE = 0
                   MOVE LS-DATA-VENCIMENTO
                       TO PAGO-DATA-VENCIMENTO(LS-INDICE-PAGO)
                   MOVE LS-VALOR-MENSALIDADE
                       TO PAGO-VALOR(LS-INDICE-PAGO)
                   MOVE LS-PAGAMENTO-OK
                       TO PAGO-STATUS(LS-INDICE-PAGO)
               END-IF
           END-PERFORM.

           EXEC SQL
               CLOSE CURSOR_PAGO
           END-EXEC.

       FINALIZA SECTION.
           EXEC SQL
               DISCONNECT ALL
           END-EXEC.

           STOP RUN.
