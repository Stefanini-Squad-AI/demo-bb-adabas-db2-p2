       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
       AUTHOR. DBATDP-17.
       REMARKS. Inclusao socio + pagamentos periodicos (substitui STORE).
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       OBJECT-COMPUTER. IBM-ZOS.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-PROGRAMA                   PIC  X(08) VALUE 'STFSC00I'.
       01  WS-ACAO-INCLUSAO              PIC  X(01) VALUE 'I'.
       01  WS-SQLCODE-SUCESSO            PIC S9(04) COMP-3 VALUE +0.
       01  WS-SQLCODE-DUPLICADO          PIC S9(04) COMP-3
                                                   VALUE +803.
       01  WS-INDI-S                     PIC  X(01) VALUE 'S'.
       01  WS-INDI-N                     PIC  X(01) VALUE 'N'.
       01  WS-IND-PE                     PIC  9(03) VALUE 0.
       01  WS-MAX-PE                     PIC  9(03) VALUE 12.
       01  WS-HV-INDI-DIVIDA             PIC  X(01).
       01  WS-HV-PAGAMENTO-OK            PIC  X(01).
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
       01  HV-CONTADOR                   PIC S9(09) COMP VALUE 0.
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
           IF STFSCSOC-ACAO OF STFSCSOC-AREA NOT = WS-ACAO-INCLUSAO
               MOVE WS-ACAO-INCLUSAO TO STFSCSOC-ACAO OF STFSCSOC-AREA
           END-IF
           MOVE ZERO TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
           .
       INICIALIZA-EXIT.
           EXIT.
      ******************************************************************
       PROCESSA SECTION.
       PROCESSA-INICIO.
           PERFORM VERIFICA-DUPLICIDADE
           IF STFSCSOC-SQLCODE OF STFSCSOC-AREA = WS-SQLCODE-DUPLICADO
               GO TO PROCESSA-EXIT
           END-IF
           IF STFSCSOC-SQLCODE OF STFSCSOC-AREA NOT = ZERO
               GO TO PROCESSA-EXIT
           END-IF
           PERFORM INSERE-PRINCIPAL
           IF STFSCSOC-SQLCODE OF STFSCSOC-AREA NOT = ZERO
               EXEC SQL ROLLBACK END-EXEC
               GO TO PROCESSA-EXIT
           END-IF
           PERFORM INSERE-PERIODICOS
           IF STFSCSOC-SQLCODE OF STFSCSOC-AREA = ZERO
               EXEC SQL COMMIT END-EXEC
           ELSE
               EXEC SQL ROLLBACK END-EXEC
           END-IF
           .
       PROCESSA-EXIT.
           EXIT.
      ******************************************************************
       FINALIZA SECTION.
       FINALIZA-INICIO.
           .
       FINALIZA-EXIT.
           EXIT.
      ******************************************************************
       VERIFICA-DUPLICIDADE.
           MOVE NUMB-SOCIO-PRINCIPAL OF STFSCSOC-AREA
             TO HV-NUMB-SOCIO-PRINCIPAL
           EXEC SQL
               SELECT 1 INTO :HV-CONTADOR
                 FROM TB_SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-SQLCODE-DUPLICADO
                     TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
               WHEN 100
                   MOVE WS-SQLCODE-SUCESSO
                     TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
               WHEN OTHER
                   MOVE SQLCODE TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
           END-EVALUATE
           .
       INSERE-PRINCIPAL.
           MOVE NUMB-SOCIO-PRINCIPAL OF STFSCSOC-AREA
             TO HV-NUMB-SOCIO-PRINCIPAL
           MOVE NOME-SOCIO-PRINCIPAL OF STFSCSOC-AREA
             TO HV-NOME-SOCIO-PRINCIPAL
           MOVE DATA-CADASTRO OF STFSCSOC-AREA TO HV-DATA-CADASTRO
           MOVE CATG-SOCIO OF STFSCSOC-AREA TO HV-CATG-SOCIO
           MOVE INDI-DIVIDA OF STFSCSOC-AREA TO WS-HV-INDI-DIVIDA
           IF WS-HV-INDI-DIVIDA = SPACE OR LOW-VALUE
               MOVE WS-INDI-N TO WS-HV-INDI-DIVIDA
           END-IF
           MOVE WS-HV-INDI-DIVIDA TO HV-INDI-DIVIDA
           MOVE DATA-BAIXA OF STFSCSOC-AREA TO HV-DATA-BAIXA
           MOVE HORA-BAIXA OF STFSCSOC-AREA TO HV-HORA-BAIXA(1:5)
           MOVE OBSV-SOCIO OF STFSCSOC-AREA TO HV-OBSV-SOCIO
           IF HV-DATA-BAIXA = SPACE OR LOW-VALUE
               EXEC SQL
                   INSERT INTO TB_SOCIO
                       (NUMB_SOCIO_PRINCIPAL,
                        NOME_SOCIO_PRINCIPAL,
                        DATA_CADASTRO,
                        CATG_SOCIO,
                        INDI_DIVIDA,
                        DATA_BAIXA,
                        HORA_BAIXA,
                        OBSV_SOCIO)
                   VALUES
                       (:HV-NUMB-SOCIO-PRINCIPAL,
                        :HV-NOME-SOCIO-PRINCIPAL,
                        DATE(:HV-DATA-CADASTRO),
                        :HV-CATG-SOCIO,
                        :HV-INDI-DIVIDA,
                        NULL,
                        NULL,
                        :HV-OBSV-SOCIO)
               END-EXEC
           ELSE
               EXEC SQL
                   INSERT INTO TB_SOCIO
                       (NUMB_SOCIO_PRINCIPAL,
                        NOME_SOCIO_PRINCIPAL,
                        DATA_CADASTRO,
                        CATG_SOCIO,
                        INDI_DIVIDA,
                        DATA_BAIXA,
                        HORA_BAIXA,
                        OBSV_SOCIO)
                   VALUES
                       (:HV-NUMB-SOCIO-PRINCIPAL,
                        :HV-NOME-SOCIO-PRINCIPAL,
                        DATE(:HV-DATA-CADASTRO),
                        :HV-CATG-SOCIO,
                        :HV-INDI-DIVIDA,
                        DATE(:HV-DATA-BAIXA),
                        :HV-HORA-BAIXA,
                        :HV-OBSV-SOCIO)
               END-EXEC
           END-IF
           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-SQLCODE-SUCESSO
                     TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
               WHEN -803
                   MOVE WS-SQLCODE-DUPLICADO
                     TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
               WHEN OTHER
                   MOVE SQLCODE TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
           END-EVALUATE
           .
       INSERE-PERIODICOS.
           IF C-PERIODICO-PAGAMENTO OF STFSCSOC-AREA > ZERO
               AND C-PERIODICO-PAGAMENTO OF STFSCSOC-AREA < 13
               MOVE C-PERIODICO-PAGAMENTO OF STFSCSOC-AREA
                 TO WS-MAX-PE
           END-IF
           PERFORM VARYING WS-IND-PE FROM 1 BY 1
                   UNTIL WS-IND-PE > WS-MAX-PE
               MOVE WS-IND-PE TO HV-SEQ-PERIODICO
               MOVE DATA-VENCIMENTO OF STFSCSOC-AREA (WS-IND-PE)
                 TO HV-DATA-VENCIMENTO
               MOVE VALR-MENSALIDADE OF STFSCSOC-AREA (WS-IND-PE)
                 TO HV-VALR-MENSALIDADE
               MOVE PAGAMENTO-OK OF STFSCSOC-AREA (WS-IND-PE)
                 TO WS-HV-PAGAMENTO-OK
               IF WS-HV-PAGAMENTO-OK = SPACE OR LOW-VALUE
                   MOVE WS-INDI-N TO WS-HV-PAGAMENTO-OK
               END-IF
               MOVE WS-HV-PAGAMENTO-OK TO HV-PAGAMENTO-OK
               EXEC SQL
                   INSERT INTO TB_SOCIO_PERIODICO_PAGAMENTO
                       (NUMB_SOCIO_PRINCIPAL,
                        SEQ_PERIODICO,
                        DATA_VENCIMENTO,
                        VALR_MENSALIDADE,
                        PAGAMENTO_OK)
                   VALUES
                       (:HV-NUMB-SOCIO-PRINCIPAL,
                        :HV-SEQ-PERIODICO,
                        DATE(:HV-DATA-VENCIMENTO),
                        :HV-VALR-MENSALIDADE,
                        :HV-PAGAMENTO-OK)
               END-EXEC
               IF SQLCODE NOT = 0
                   MOVE SQLCODE TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
                   GO TO INSERE-PERIODICOS-FIM
               END-IF
           END-PERFORM
       INSERE-PERIODICOS-FIM.
           IF STFSCSOC-SQLCODE OF STFSCSOC-AREA = ZERO
               MOVE WS-SQLCODE-SUCESSO
                 TO STFSCSOC-SQLCODE OF STFSCSOC-AREA
           END-IF
           .
