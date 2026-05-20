       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
       AUTHOR. DBATDP-17.
       REMARKS. Consulta socio por RG (substitui FIND ADABAS).
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       OBJECT-COMPUTER. IBM-ZOS.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-PROGRAMA                   PIC  X(08) VALUE 'STFSC00C'.
       01  WS-ACAO-CONSULTA              PIC  X(01) VALUE 'C'.
       01  WS-SQLCODE-NAO-LOCALIZADO     PIC S9(04) COMP-3
                                                   VALUE +100.
       01  WS-SQLCODE-SUCESSO            PIC S9(04) COMP-3
                                                   VALUE +0.
       01  WS-CURSOR-ABERTO              PIC  X(01) VALUE 'N'.
           88  WS-CURSOR-ESTA-ABERTO                 VALUE 'S'.
       01  WS-SEQ-PE                     PIC  9(03) VALUE 0.
       01  WS-IND-PE                     PIC  9(03) VALUE 0.
       01  WS-INDI-S                     PIC  X(01) VALUE 'S'.
       01  WS-INDI-N                     PIC  X(01) VALUE 'N'.
           EXEC SQL DECLARE CUR-PERIODICO CURSOR FOR
               SELECT SEQ_PERIODICO,
                      CHAR(DATA_VENCIMENTO, ISO),
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM TB_SOCIO_PERIODICO_PAGAMENTO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRINCIPAL
                ORDER BY SEQ_PERIODICO
           END-EXEC.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  HV-NUMB-SOCIO-PRINCIPAL       PIC S9(09) COMP-3.
       01  HV-NOME-SOCIO-PRINCIPAL       PIC  X(40).
       01  HV-DATA-CADASTRO              PIC  X(10).
       01  HV-CATG-SOCIO                 PIC S9(04) COMP.
       01  HV-INDI-DIVIDA                PIC  X(01).
       01  HV-DATA-BAIXA                 PIC  X(10).
       01  HV-HORA-BAIXA                 PIC  X(12).
       01  HV-OBSV-SOCIO                 PIC  X(500).
       01  HV-SEQ-PERIODICO              PIC S9(09) COMP.
       01  HV-DATA-VENCIMENTO            PIC  X(10).
       01  HV-VALR-MENSALIDADE           PIC S9(06)V9(02) COMP-3.
       01  HV-PAGAMENTO-OK               PIC  X(01).
       LINKAGE SECTION.
           COPY STFSCSOC.
      ******************************************************************
       PROCEDURE DIVISION USING STFSCSOC-AREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           GOBACK.
      ******************************************************************
       INICIALIZA SECTION.
       INICIALIZA-INICIO.
           IF STFSCSOC-ACAO OF STFSCSOC-AREA NOT = WS-ACAO-CONSULTA
               MOVE WS-ACAO-CONSULTA TO STFSCSOC-ACAO OF STFSCSOC-AREA
           END-IF
           MOVE ZERO TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
           MOVE ZERO TO C-PERIODICO-PAGAMENTO OF STFSCSOC-AREA
           MOVE 'N' TO WS-CURSOR-ABERTO
           .
       INICIALIZA-EXIT.
           EXIT.
      ******************************************************************
       PROCESSA SECTION.
       PROCESSA-INICIO.
           MOVE NUMB-SOCIO-PRINCIPAL OF STFSCSOC-AREA
             TO HV-NUMB-SOCIO-PRINCIPAL
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      COALESCE(CHAR(DATA_BAIXA, ISO), '          '),
                      COALESCE(HORA_BAIXA, '            '),
                      COALESCE(OBSV_SOCIO, ' ')
                 INTO :HV-NOME-SOCIO-PRINCIPAL,
                      :HV-DATA-CADASTRO,
                      :HV-CATG-SOCIO,
                      :HV-INDI-DIVIDA,
                      :HV-DATA-BAIXA,
                      :HV-HORA-BAIXA,
                      :HV-OBSV-SOCIO
                 FROM TB_SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   PERFORM MOVE-DADOS-PRINCIPAL
                   PERFORM LE-PERIODICOS
               WHEN 100
                   MOVE WS-SQLCODE-NAO-LOCALIZADO
                     TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
               WHEN OTHER
                   MOVE SQLCODE TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
           END-EVALUATE
           .
       PROCESSA-EXIT.
           EXIT.
      ******************************************************************
       FINALIZA SECTION.
       FINALIZA-INICIO.
           IF WS-CURSOR-ESTA-ABERTO
               EXEC SQL CLOSE CUR-PERIODICO END-EXEC
               MOVE 'N' TO WS-CURSOR-ABERTO
           END-IF
           .
       FINALIZA-EXIT.
           EXIT.
      ******************************************************************
       MOVE-DADOS-PRINCIPAL.
           MOVE WS-SQLCODE-SUCESSO TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
           MOVE HV-NUMB-SOCIO-PRINCIPAL
             TO NUMB-SOCIO-PRINCIPAL OF STFSCSOC-AREA
           MOVE HV-NOME-SOCIO-PRINCIPAL
             TO NOME-SOCIO-PRINCIPAL OF STFSCSOC-AREA
           MOVE HV-DATA-CADASTRO TO DATA-CADASTRO OF STFSCSOC-AREA
           MOVE HV-CATG-SOCIO TO CATG-SOCIO OF STFSCSOC-AREA
           MOVE HV-INDI-DIVIDA TO INDI-DIVIDA OF STFSCSOC-AREA
           MOVE HV-DATA-BAIXA TO DATA-BAIXA OF STFSCSOC-AREA
           MOVE HV-HORA-BAIXA(1:5) TO HORA-BAIXA OF STFSCSOC-AREA
           MOVE HV-OBSV-SOCIO TO OBSV-SOCIO OF STFSCSOC-AREA
           .
       LE-PERIODICOS.
           EXEC SQL OPEN CUR-PERIODICO END-EXEC
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
               GO TO LE-PERIODICOS-FIM
           END-IF
           MOVE 'S' TO WS-CURSOR-ABERTO
           MOVE ZERO TO WS-IND-PE
           PERFORM UNTIL WS-IND-PE >= 12
               EXEC SQL FETCH CUR-PERIODICO
                   INTO :HV-SEQ-PERIODICO,
                        :HV-DATA-VENCIMENTO,
                        :HV-VALR-MENSALIDADE,
                        :HV-PAGAMENTO-OK
               END-EXEC
               IF SQLCODE = 100
                   GO TO LE-PERIODICOS-FIM
               END-IF
               IF SQLCODE NOT = 0
                   MOVE SQLCODE TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
                   GO TO LE-PERIODICOS-FIM
               END-IF
               ADD 1 TO WS-IND-PE
               MOVE HV-DATA-VENCIMENTO
                 TO DATA-VENCIMENTO OF STFSCSOC-AREA (WS-IND-PE)
               MOVE HV-VALR-MENSALIDADE
                 TO VALR-MENSALIDADE OF STFSCSOC-AREA (WS-IND-PE)
               MOVE HV-PAGAMENTO-OK
                 TO PAGAMENTO-OK OF STFSCSOC-AREA (WS-IND-PE)
           END-PERFORM
       LE-PERIODICOS-FIM.
           MOVE WS-IND-PE TO C-PERIODICO-PAGAMENTO OF STFSCSOC-AREA
           .
