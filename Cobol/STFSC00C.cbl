       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consulta socio por NUMB-SOCIO-PRINCIPAL (RG) em DB2          *
      * Retorno: +000 localizado, +100 nao localizado, demais erro     *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-LITERALA          PIC X(20) VALUE 'STFSC00C-CONSULTA'.
       01  WS-CONST-TRUE              PIC X(01) VALUE 'Y'.
       01  WS-CONST-FALSE             PIC X(01) VALUE 'N'.

       LOCAL-STORAGE SECTION.
           COPY STFSC00BK.
           COPY STFSCSOC.
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
       01  LS-IND-DATA-BAIXA          PIC S9(4) COMP.
       01  LS-IND-HORA                PIC S9(4) COMP.
       01  LS-IND-OBSV                PIC S9(4) COMP.
       01  LS-IND-SEQ                 PIC S9(4) COMP.
       01  LS-IND-DATA-VENC           PIC S9(4) COMP.
       01  LS-IND-VALR                PIC S9(4) COMP.
       01  LS-IND-PAG                 PIC S9(4) COMP.
       01  LS-CONTADOR                PIC 9(03) VALUE ZERO.
       01  LS-WS-VALR-DISPLAY         PIC 9(06)V9(02).

           EXEC SQL
               DECLARE CSR-PERIODICO CURSOR FOR
               SELECT SEQ_OCORRENCIA,
                      CHAR(DATA_VENCIMENTO, ISO),
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM SOCIO_PERIODICO_PAGAMENTO
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-NUMB
                ORDER BY SEQ_OCORRENCIA
           END-EXEC.

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
           MOVE ZERO TO LS-CONTADOR
           .

       PROCESSA.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL OF LK-AREA-COMUNICACAO
             TO LS-HV-NUMB-SOCIO
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL OF LK-AREA-COMUNICACAO
             TO STFSCSOC-NUMB-SOCIO-PRINCIPAL

           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      COALESCE(CHAR(DATA_BAIXA, ISO), '          '),
                      COALESCE(HORA_BAIXA, '     '),
                      COALESCE(OBSV_SOCIO, ' ')
                 INTO :LS-HV-NOME:LS-IND-NOME,
                      :LS-HV-DATA-CADASTRO:LS-IND-DATA-CAD,
                      :LS-HV-CATG:LS-IND-CATG,
                      :LS-HV-INDI-DIVIDA:LS-IND-INDI,
                      :LS-HV-DATA-BAIXA:LS-IND-DATA-BAIXA,
                      :LS-HV-HORA-BAIXA:LS-IND-HORA,
                      :LS-HV-OBSV:LS-IND-OBSV
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-NUMB-SOCIO
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   MOVE 0 TO STFSC00-SQLCODE OF LK-AREA-COMUNICACAO
                   PERFORM CARREGA-PRINCIPAL
                   PERFORM CARREGA-PERIODICOS
               WHEN 100
                   MOVE 100 TO STFSC00-SQLCODE OF LK-AREA-COMUNICACAO
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-SQLCODE OF LK-AREA-COMUNICACAO
           END-EVALUATE
           .

       CARREGA-PRINCIPAL.
           MOVE LS-HV-NUMB-SOCIO TO STFSC00-NUMB-SOCIO-PRINCIPAL
             OF LK-AREA-COMUNICACAO
           MOVE LS-HV-NOME TO STFSC00-NOME-SOCIO-PRINCIPAL
             OF LK-AREA-COMUNICACAO
           MOVE LS-HV-DATA-CADASTRO TO STFSC00-DATA-CADASTRO
             OF LK-AREA-COMUNICACAO
           MOVE LS-HV-CATG TO STFSC00-CATG-SOCIO OF LK-AREA-COMUNICACAO
           MOVE LS-HV-INDI-DIVIDA TO STFSC00-INDI-DIVIDA
             OF LK-AREA-COMUNICACAO
           MOVE LS-HV-DATA-BAIXA TO STFSC00-DATA-BAIXA
             OF LK-AREA-COMUNICACAO
           MOVE LS-HV-HORA-BAIXA TO STFSC00-HORA-BAIXA
             OF LK-AREA-COMUNICACAO
           MOVE LS-HV-OBSV TO STFSC00-OBSV-SOCIO OF LK-AREA-COMUNICACAO
           .

       CARREGA-PERIODICOS.
           MOVE ZERO TO STFSC00-QTD-PERIODICO OF LK-AREA-COMUNICACAO
           EXEC SQL OPEN CSR-PERIODICO END-EXEC
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO STFSC00-SQLCODE OF LK-AREA-COMUNICACAO
               GO TO CARREGA-PERIODICOS-FIM
           END-IF
           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL
                   FETCH CSR-PERIODICO
                    INTO :LS-HV-SEQ:LS-IND-SEQ,
                         :LS-HV-DATA-VENC:LS-IND-DATA-VENC,
                         :LS-HV-VALR:LS-IND-VALR,
                         :LS-HV-PAG-OK:LS-IND-PAG
               END-EXEC
               IF SQLCODE = 0
                   ADD 1 TO LS-CONTADOR
                   MOVE LS-HV-SEQ TO STFSC00-SEQ-OCORRENCIA
                     (LS-CONTADOR) OF LK-AREA-COMUNICACAO
                   MOVE LS-HV-DATA-VENC TO STFSC00-DATA-VENCIMENTO
                     (LS-CONTADOR) OF LK-AREA-COMUNICACAO
                   MOVE LS-HV-VALR TO STFSC00-VALR-MENSALIDADE
                     (LS-CONTADOR) OF LK-AREA-COMUNICACAO
                   MOVE LS-HV-PAG-OK TO STFSC00-PAGAMENTO-OK
                     (LS-CONTADOR) OF LK-AREA-COMUNICACAO
               END-IF
           END-PERFORM
           EXEC SQL CLOSE CSR-PERIODICO END-EXEC
           MOVE LS-CONTADOR TO STFSC00-QTD-PERIODICO OF LK-AREA-COMUNICACAO
           IF STFSC00-SQLCODE OF LK-AREA-COMUNICACAO = 0
               CONTINUE
           END-IF
           .
       CARREGA-PERIODICOS-FIM.
           EXIT.

       FINALIZA.
           MOVE 'C' TO STFSC00-ACAO OF LK-AREA-COMUNICACAO
           .
