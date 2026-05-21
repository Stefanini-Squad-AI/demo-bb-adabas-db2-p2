       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * STFSC00C - Consulta sócio por NUMB-SOCIO-PRINCIPAL (RG)
      * Return codes: +000 encontrado, +100 não encontrado, outros genérico
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-MAX-PAGAMENTOS        PIC 9(3) VALUE 12.
       01  WS-CONST-PROGRAMA              PIC X(8) VALUE 'STFSC00C'.
       01  WS-CONST-SQL-OK                PIC X(5) VALUE '+000'.
       01  WS-CONST-SQL-NOT-FOUND         PIC X(5) VALUE '+100'.
       01  WS-CONST-SQL-OTHER             PIC X(5) VALUE '+999'.
       01  WS-CONTADOR-PAG                PIC 9(3) VALUE ZERO.
       01  WS-IND-PAG                     PIC 9(3) VALUE ZERO.
      *
       EXEC SQL DECLARE CSR-SOCIO-PAG CURSOR FOR
           SELECT SEQ_PAGAMENTO,
                  DATA_VENCIMENTO,
                  VALR_MENSALIDADE,
                  PAGAMENTO_OK
             FROM SOCIO_PAGAMENTO
            WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-NUMB-SOCIO-PRINCIPAL
            ORDER BY SEQ_PAGAMENTO
       END-EXEC.
      *
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-COMMAREA                    COPY STFSC00B.
       01  LS-HV-NUMB-SOCIO-PRINCIPAL     PIC S9(9)V9(0) USAGE COMP-3.
       01  LS-HV-NOME-SOCIO-PRINCIPAL     PIC X(40).
       01  LS-HV-DATA-CADASTRO            PIC X(10).
       01  LS-HV-CATG-SOCIO               PIC S9(4) USAGE COMP.
       01  LS-HV-INDI-DIVIDA              PIC X(1).
       01  LS-HV-DATA-BAIXA               PIC X(10).
       01  LS-HV-HORA-BAIXA               PIC X(5).
       01  LS-HV-OBSV-SOCIO               PIC X(500).
       01  LS-HV-SEQ-PAGAMENTO            PIC S9(4) USAGE COMP.
       01  LS-HV-DATA-VENCIMENTO          PIC X(10).
       01  LS-HV-VALR-MENSALIDADE         PIC S9(6)V9(2) USAGE COMP-3.
       01  LS-HV-PAGAMENTO-OK             PIC X(1).
       01  LS-HV-NULL-DATA-BAIXA          PIC S9(4) USAGE COMP.
       01  LS-HV-NULL-HORA-BAIXA         PIC S9(4) USAGE COMP.
      *
       LINKAGE SECTION.
       01  DFHCOMMAREA.
           05  LK-COMMAREA                PIC X(2000).
      *
       PROCEDURE DIVISION USING DFHCOMMAREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
      *
       INICIALIZA.
           MOVE LK-COMMAREA TO LS-COMMAREA
           MOVE WS-CONST-SQL-OTHER TO STFSC00B-RETURN-CODE
           MOVE ZERO TO WS-CONTADOR-PAG WS-IND-PAG
           MOVE ZERO TO STFSC00B-C-PERIODICO-PAGAMENTO
           .
      *
       PROCESSA.
           MOVE STFSC00B-NUMB-SOCIO-PRINCIPAL
               TO LS-HV-NUMB-SOCIO-PRINCIPAL
           PERFORM CONSULTA-SOCIO
           IF STFSC00B-RC-OK
               PERFORM CARREGA-SOCIO-PAG-CURSOR
           END-IF
           MOVE LS-COMMAREA TO LK-COMMAREA
           .
      *
       CONSULTA-SOCIO.
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      CASE INDI_DIVIDA
                           WHEN 'Y' THEN 'Y' ELSE 'N' END,
                      COALESCE(CHAR(DATA_BAIXA, ISO), '          '),
                      COALESCE(HORA_BAIXA, '     '),
                      OBSV_SOCIO
                 INTO :LS-HV-NOME-SOCIO-PRINCIPAL,
                      :LS-HV-DATA-CADASTRO,
                      :LS-HV-CATG-SOCIO,
                      :LS-HV-INDI-DIVIDA,
                      :LS-HV-DATA-BAIXA,
                      :LS-HV-HORA-BAIXA,
                      :LS-HV-OBSV-SOCIO
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-CONST-SQL-OK TO STFSC00B-RETURN-CODE
                   MOVE LS-HV-NOME-SOCIO-PRINCIPAL
                       TO STFSC00B-NOME-SOCIO-PRINCIPAL
                   MOVE LS-HV-DATA-CADASTRO TO STFSC00B-DATA-CADASTRO
                   MOVE LS-HV-CATG-SOCIO TO STFSC00B-CATG-SOCIO
                   MOVE LS-HV-INDI-DIVIDA TO STFSC00B-INDI-DIVIDA
                   MOVE LS-HV-DATA-BAIXA TO STFSC00B-DATA-BAIXA
                   MOVE LS-HV-HORA-BAIXA TO STFSC00B-HORA-BAIXA
                   MOVE LS-HV-OBSV-SOCIO TO STFSC00B-OBSV-SOCIO
                   MOVE STFSC00B-CATG-SOCIO TO STFSC00B-SUPER-CATG
                   MOVE STFSC00B-INDI-DIVIDA TO STFSC00B-SUPER-INDI
               WHEN 100
                   MOVE WS-CONST-SQL-NOT-FOUND TO STFSC00B-RETURN-CODE
               WHEN OTHER
                   MOVE WS-CONST-SQL-OTHER TO STFSC00B-RETURN-CODE
           END-EVALUATE
           .
      *
       CARREGA-SOCIO-PAG-CURSOR.
           MOVE ZERO TO WS-IND-PAG
           EXEC SQL OPEN CSR-SOCIO-PAG END-EXEC
           IF SQLCODE = 0
               PERFORM UNTIL SQLCODE NOT = 0
                          OR WS-IND-PAG >= WS-CONST-MAX-PAGAMENTOS
                   EXEC SQL FETCH CSR-SOCIO-PAG
                       INTO :LS-HV-SEQ-PAGAMENTO,
                            :LS-HV-DATA-VENCIMENTO,
                            :LS-HV-VALR-MENSALIDADE,
                            :LS-HV-PAGAMENTO-OK
                   END-EXEC
                   IF SQLCODE = 0
                       ADD 1 TO WS-IND-PAG
                       MOVE LS-HV-DATA-VENCIMENTO
                           TO STFSC00B-DATA-VENCIMENTO(WS-IND-PAG)
                       MOVE LS-HV-VALR-MENSALIDADE
                           TO STFSC00B-VALR-MENSALIDADE(WS-IND-PAG)
                       MOVE LS-HV-PAGAMENTO-OK
                           TO STFSC00B-PAGAMENTO-OK(WS-IND-PAG)
                   END-IF
               END-PERFORM
               MOVE WS-IND-PAG TO STFSC00B-C-PERIODICO-PAGAMENTO
               EXEC SQL CLOSE CSR-SOCIO-PAG END-EXEC
           END-IF
           .
      *
       FINALIZA.
           IF STFSC00B-RC-OK
               AND STFSC00B-C-PERIODICO-PAGAMENTO = ZERO
               CONTINUE
           END-IF
           .
