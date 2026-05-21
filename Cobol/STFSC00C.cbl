       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * STFSC00C - Consulta socio (FIND) via DB2
      * DBATDP-18 - Migracao ADABAS-SOCIOS
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA            PIC X(08) VALUE 'STFSC00C'.
       01  WS-CONST-OPERACAO            PIC X(01) VALUE 'C'.
       01  WS-CONST-RC-OK               PIC S9(09) VALUE +0.
       01  WS-CONST-RC-NOTFOUND         PIC S9(09) VALUE +100.
       01  WS-CONST-MSG-OK              PIC X(72)
           VALUE 'Registro localizado.'.
       01  WS-CONST-MSG-NOTFOUND        PIC X(72)
           VALUE 'Registro nao localizado.'.
       01  WS-CONST-MSG-ERRO            PIC X(72)
           VALUE 'Erro na consulta DB2.'.
       01  WS-CONST-SIM                 PIC X(01) VALUE 'Y'.
       01  WS-CONST-NAO                 PIC X(01) VALUE 'N'.
       01  WS-MAX-PAGAMENTO             PIC 9(03) VALUE 12.
       01  WS-IDX-PAGAMENTO             PIC 9(03).
       01  WS-EDIT-DATA                 PIC X(10).
       01  WS-EDIT-HORA                 PIC X(05).
      *
       EXEC SQL INCLUDE SQLCA END-EXEC.
       EXEC SQL
           DECLARE CSR-SOC-PAG CURSOR FOR
               SELECT NUM_PAGAMENTO,
                      CHAR(DATA_VENCIMENTO, ISO),
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM SOCIO_PAGAMENTO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO
                ORDER BY NUM_PAGAMENTO
       END-EXEC.
      *
       LOCAL-STORAGE SECTION.
       COPY STFSC00B.
      *
       01  HV-NUMB-SOCIO                PIC S9(09)V9(00) COMP-3.
       01  HV-NOME-SOCIO                PIC X(40).
       01  HV-DATA-CADASTRO             PIC X(10).
       01  HV-CATG-SOCIO                PIC S9(04) COMP.
       01  HV-INDI-DIVIDA               PIC X(01).
       01  HV-DATA-BAIXA                PIC X(10).
       01  HV-HORA-BAIXA                PIC X(05).
       01  HV-OBSV-SOCIO                PIC X(500).
       01  HV-NUL-DATA-BAIXA            PIC S9(04) COMP.
       01  HV-NUL-HORA-BAIXA            PIC S9(04) COMP.
       01  HV-NUL-OBSV-SOCIO            PIC S9(04) COMP.
      *
       01  HV-PAG-NUM                   PIC S9(04) COMP.
       01  HV-PAG-DATA-VENC             PIC X(10).
       01  HV-PAG-VALR                  PIC S9(04)V9(02) COMP-3.
       01  HV-PAG-OK                    PIC X(01).
      *
       LINKAGE SECTION.
       01  LK-STFSC00-AREA              PIC X(4096).
      *
       PROCEDURE DIVISION USING LK-STFSC00-AREA.
           SET ADDRESS OF STFSC00-AREA TO LK-STFSC00-AREA
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
      *
       INICIALIZA.
           MOVE ZEROS TO STFSC00-SQLCODE
           MOVE SPACES TO STFSC00-SQLSTATE STFSC00-MSG
           MOVE ZEROS TO WS-IDX-PAGAMENTO
           PERFORM VARYING WS-IDX-PAGAMENTO FROM 1 BY 1
               UNTIL WS-IDX-PAGAMENTO > WS-MAX-PAGAMENTO
               MOVE ZEROS TO VALR-MENSALIDADE(WS-IDX-PAGAMENTO)
               MOVE SPACES TO DATA-VENCIMENTO(WS-IDX-PAGAMENTO)
                          PAGAMENTO-OK(WS-IDX-PAGAMENTO)
           END-PERFORM
           MOVE ZEROS TO WS-IDX-PAGAMENTO
           .
      *
       PROCESSA.
           PERFORM CONSULTA-SOCIO
           IF STFSC00-SQLCODE = WS-CONST-RC-OK
               PERFORM CARREGA-SOC-PAG-CURSOR
           END-IF
           .
      *
       FINALIZA.
           .
      *
       CONSULTA-SOCIO.
           MOVE NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      COALESCE(CHAR(DATA_BAIXA, ISO), ' '),
                      COALESCE(HORA_BAIXA, ' '),
                      COALESCE(OBSV_SOCIO, ' ')
                 INTO :HV-NOME-SOCIO,
                      :HV-DATA-CADASTRO,
                      :HV-CATG-SOCIO,
                      :HV-INDI-DIVIDA,
                      :HV-DATA-BAIXA,
                      :HV-HORA-BAIXA,
                      :HV-OBSV-SOCIO
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-CONST-RC-OK TO STFSC00-SQLCODE
                   MOVE SQLSTATE TO STFSC00-SQLSTATE
                   MOVE WS-CONST-MSG-OK TO STFSC00-MSG
                   MOVE HV-NOME-SOCIO TO NOME-SOCIO-PRINCIPAL
                   MOVE HV-DATA-CADASTRO TO DATA-CADASTRO
                   MOVE HV-CATG-SOCIO TO CATG-SOCIO
                   MOVE HV-INDI-DIVIDA TO INDI-DIVIDA
                   MOVE HV-DATA-BAIXA TO DATA-BAIXA
                   MOVE HV-HORA-BAIXA TO HORA-BAIXA
                   MOVE HV-OBSV-SOCIO TO OBSV-CLIENTE
               WHEN 100
                   MOVE WS-CONST-RC-NOTFOUND TO STFSC00-SQLCODE
                   MOVE SQLSTATE TO STFSC00-SQLSTATE
                   MOVE WS-CONST-MSG-NOTFOUND TO STFSC00-MSG
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-SQLCODE
                   MOVE SQLSTATE TO STFSC00-SQLSTATE
                   MOVE WS-CONST-MSG-ERRO TO STFSC00-MSG
           END-EVALUATE
           .
      *
       CARREGA-SOC-PAG-CURSOR.
           MOVE ZEROS TO C-PERIODICO-PAGAMENTO
           EXEC SQL OPEN CSR-SOC-PAG END-EXEC
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO STFSC00-SQLCODE
               MOVE SQLSTATE TO STFSC00-SQLSTATE
               MOVE WS-CONST-MSG-ERRO TO STFSC00-MSG
               GO TO CARREGA-SOC-PAG-FIM
           END-IF
           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL
                   FETCH CSR-SOC-PAG
                    INTO :HV-PAG-NUM,
                         :HV-PAG-DATA-VENC,
                         :HV-PAG-VALR,
                         :HV-PAG-OK
               END-EXEC
               IF SQLCODE = 0
                   IF HV-PAG-NUM > 0
                       AND HV-PAG-NUM <= WS-MAX-PAGAMENTO
                       MOVE HV-PAG-NUM TO WS-IDX-PAGAMENTO
                       MOVE HV-PAG-DATA-VENC
                           TO DATA-VENCIMENTO(WS-IDX-PAGAMENTO)
                       MOVE HV-PAG-VALR
                           TO VALR-MENSALIDADE(WS-IDX-PAGAMENTO)
                       MOVE HV-PAG-OK
                           TO PAGAMENTO-OK(WS-IDX-PAGAMENTO)
                       ADD 1 TO C-PERIODICO-PAGAMENTO
                   END-IF
               END-IF
           END-PERFORM
           EXEC SQL CLOSE CSR-SOC-PAG END-EXEC
           .
       CARREGA-SOC-PAG-FIM.
           EXIT.
      *
