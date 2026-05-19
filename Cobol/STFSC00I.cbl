       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Inclusao de socio e pagamentos periodicos em DB2               *
      * Retorno: +000 sucesso, +803 chave duplicada, demais erro       *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-LITERALA          PIC X(20) VALUE 'STFSC00I-INCLUSAO'.
       01  WS-CONST-TRUE              PIC X(01) VALUE 'Y'.
       01  WS-CONST-FALSE             PIC X(01) VALUE 'N'.

       LOCAL-STORAGE SECTION.
           COPY STFSC00BK.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-HV-NUMB-SOCIO           PIC S9(9)V USAGE COMP-3.
       01  LS-HV-NOME                 PIC X(40).
       01  LS-HV-DATA-CADASTRO        PIC X(10).
       01  LS-HV-CATG                 PIC S9(4) USAGE COMP.
       01  LS-HV-INDI-DIVIDA          PIC X(01).
       01  LS-HV-DATA-BAIXA           PIC X(10).
       01  LS-HV-HORA-BAIXA           PIC X(05).
       01  LS-HV-OBSV                 PIC X(500).
       01  LS-HV-SEQ                  PIC S9(9) USAGE COMP.
       01  LS-HV-DATA-VENC            PIC X(10).
       01  LS-HV-VALR                 PIC S9(6)V9(2) USAGE COMP-3.
       01  LS-HV-PAG-OK               PIC X(01).
       01  LS-IND-NUMB                PIC S9(4) COMP.
       01  LS-IND-NOME                PIC S9(4) COMP.
       01  LS-IND-DATA-CAD            PIC S9(4) COMP.
       01  LS-IND-CATG                PIC S9(4) COMP.
       01  LS-IND-INDI                PIC S9(4) COMP.
       01  LS-IND-DATA-BAIXA          PIC S9(4) COMP VALUE -1.
       01  LS-IND-HORA                PIC S9(4) COMP VALUE -1.
       01  LS-IND-OBSV                PIC S9(4) COMP.
       01  LS-IDX                     PIC 9(03) VALUE ZERO.

       LINKAGE SECTION.
       01  LK-AREA-COMUNICACAO.
           COPY STFSC00BK.

       PROCEDURE DIVISION USING LK-AREA-COMUNICACAO.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.

       INICIALIZA.
           MOVE ZERO TO STFSC00-SQLCODE OF LK-AREA-COMUNICACAO
           .

       PROCESSA.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL OF LK-AREA-COMUNICACAO
             TO LS-HV-NUMB-SOCIO
           MOVE STFSC00-NOME-SOCIO-PRINCIPAL OF LK-AREA-COMUNICACAO
             TO LS-HV-NOME
           MOVE STFSC00-DATA-CADASTRO OF LK-AREA-COMUNICACAO
             TO LS-HV-DATA-CADASTRO
           MOVE STFSC00-CATG-SOCIO OF LK-AREA-COMUNICACAO
             TO LS-HV-CATG
           MOVE STFSC00-INDI-DIVIDA OF LK-AREA-COMUNICACAO
             TO LS-HV-INDI-DIVIDA
           IF STFSC00-DATA-BAIXA OF LK-AREA-COMUNICACAO = SPACES
               MOVE -1 TO LS-IND-DATA-BAIXA
           ELSE
               MOVE STFSC00-DATA-BAIXA OF LK-AREA-COMUNICACAO
                 TO LS-HV-DATA-BAIXA
               MOVE ZERO TO LS-IND-DATA-BAIXA
           END-IF
           IF STFSC00-HORA-BAIXA OF LK-AREA-COMUNICACAO = SPACES
               MOVE -1 TO LS-IND-HORA
           ELSE
               MOVE STFSC00-HORA-BAIXA OF LK-AREA-COMUNICACAO
                 TO LS-HV-HORA-BAIXA
               MOVE ZERO TO LS-IND-HORA
           END-IF
           MOVE STFSC00-OBSV-SOCIO OF LK-AREA-COMUNICACAO TO LS-HV-OBSV

           EXEC SQL
               INSERT INTO SOCIO (
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   INDI_DIVIDA,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_SOCIO
               ) VALUES (
                   :LS-HV-NUMB-SOCIO,
                   :LS-HV-NOME:LS-IND-NOME,
                   DATE(:LS-HV-DATA-CADASTRO:LS-IND-DATA-CAD),
                   :LS-HV-CATG:LS-IND-CATG,
                   :LS-HV-INDI-DIVIDA:LS-IND-INDI,
                   :LS-HV-DATA-BAIXA:LS-IND-DATA-BAIXA,
                   :LS-HV-HORA-BAIXA:LS-IND-HORA,
                   :LS-HV-OBSV:LS-IND-OBSV
               )
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   MOVE 0 TO STFSC00-SQLCODE OF LK-AREA-COMUNICACAO
                   PERFORM INSERE-PERIODICOS
               WHEN -803
                   MOVE 803 TO STFSC00-SQLCODE OF LK-AREA-COMUNICACAO
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-SQLCODE OF LK-AREA-COMUNICACAO
           END-EVALUATE
           .

       INSERE-PERIODICOS.
           PERFORM VARYING LS-IDX FROM 1 BY 1
               UNTIL LS-IDX > STFSC00-QTD-PERIODICO OF LK-AREA-COMUNICACAO
               MOVE STFSC00-SEQ-OCORRENCIA (LS-IDX) OF LK-AREA-COMUNICACAO
                 TO LS-HV-SEQ
               IF LS-HV-SEQ = ZERO
                   MOVE LS-IDX TO LS-HV-SEQ
               END-IF
               MOVE STFSC00-DATA-VENCIMENTO (LS-IDX) OF LK-AREA-COMUNICACAO
                 TO LS-HV-DATA-VENC
               MOVE STFSC00-VALR-MENSALIDADE (LS-IDX) OF LK-AREA-COMUNICACAO
                 TO LS-HV-VALR
               MOVE STFSC00-PAGAMENTO-OK (LS-IDX) OF LK-AREA-COMUNICACAO
                 TO LS-HV-PAG-OK
               EXEC SQL
                   INSERT INTO SOCIO_PERIODICO_PAGAMENTO (
                       NUMB_SOCIO_PRINCIPAL,
                       SEQ_OCORRENCIA,
                       DATA_VENCIMENTO,
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK
                   ) VALUES (
                       :LS-HV-NUMB-SOCIO,
                       :LS-HV-SEQ,
                       DATE(:LS-HV-DATA-VENC),
                       :LS-HV-VALR,
                       :LS-HV-PAG-OK
                   )
               END-EXEC
               IF SQLCODE NOT = 0
                   MOVE SQLCODE TO STFSC00-SQLCODE OF LK-AREA-COMUNICACAO
                   EXEC SQL ROLLBACK END-EXEC
                   GO TO INSERE-PERIODICOS-FIM
               END-IF
           END-PERFORM
           IF STFSC00-SQLCODE OF LK-AREA-COMUNICACAO = 0
               EXEC SQL COMMIT END-EXEC
               MOVE 0 TO STFSC00-SQLCODE OF LK-AREA-COMUNICACAO
           END-IF
           .
       INSERE-PERIODICOS-FIM.
           EXIT.

       FINALIZA.
           MOVE 'I' TO STFSC00-ACAO OF LK-AREA-COMUNICACAO
           .
