       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
       AUTHOR. DBATDP-10.
       REMARKS. Consulta de socio (DB2 SELECT + cursor pagamentos).
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-PROGRAM-ID                  PIC X(8) VALUE 'STFSC00C'.
       01  WS-SQLCODE-OK                  PIC S9(4) COMP VALUE 0.
       01  WS-SQLCODE-NOTFOUND            PIC S9(4) COMP VALUE 100.
       01  WS-RETURN-FOUND                PIC S9(4) COMP VALUE 0.
       01  WS-RETURN-NOTFOUND             PIC S9(4) COMP VALUE 100.
       01  WS-RETURN-ERROR                PIC S9(4) COMP VALUE 999.
       01  WS-MAX-PAGAMENTOS              PIC 9(3) COMP VALUE 12.
       01  WS-INDI-TRUE                   PIC X(1) VALUE '1'.
       01  WS-INDI-FALSE                  PIC X(1) VALUE '0'.
       01  WS-DATE-NULL                   PIC S9(4) COMP VALUE -1.
       01  WS-TIME-NULL                   PIC S9(4) COMP VALUE -1.
       LOCAL-STORAGE SECTION.
           COPY SQLCA.
       01  LS-HV-NUMB-SOCIO-PRINCIPAL      PIC 9(9).
       01  LS-HV-NOME-SOCIO-PRINCIPAL      PIC X(40).
       01  LS-HV-DATA-CADASTRO             PIC X(10).
       01  LS-HV-CATG-SOCIO                PIC 9(2).
       01  LS-HV-INDI-DIVIDA               PIC X(1).
       01  LS-HV-DATA-BAIXA                PIC X(10).
       01  LS-HV-HORA-BAIXA                PIC X(5).
       01  LS-HV-OBSV-SOCIO                PIC X(500).
       01  LS-IND-DATA-BAIXA               PIC S9(4) COMP.
       01  LS-IND-HORA-BAIXA               PIC S9(4) COMP.
       01  LS-HV-SEQ-PAGAMENTO             PIC 9(9) COMP.
       01  LS-HV-DATA-VENCIMENTO           PIC X(10).
       01  LS-HV-VALR-MENSALIDADE          PIC S9(6)V9(2) COMP-3.
       01  LS-HV-PAGAMENTO-OK              PIC X(1).
       01  LS-PAG-COUNT                    PIC 9(3) COMP VALUE 0.
       01  LS-PAG-IDX                      PIC 9(3) COMP.
           EXEC SQL
               DECLARE PAG-CUR CURSOR FOR
               SELECT SEQ_PAGAMENTO,
                      CHAR(DATA_VENCIMENTO, ISO),
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM SOCIOS_PAGAMENTO
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-NUMB-SOCIO-PRINCIPAL
                ORDER BY SEQ_PAGAMENTO
           END-EXEC.
       LINKAGE SECTION.
           COPY STFSSOCI.
       PROCEDURE DIVISION USING STFSSOCI-LINKAGE.
       MAIN-PARA.
           MOVE WS-RETURN-ERROR TO STFSSOCI-RETURN-CODE
           MOVE ZERO TO STFSSOCI-C-PERIODICO-PAGAMENTO
           PERFORM VARYING STFSSOCI-PAG-IDX FROM 1 BY 1
               UNTIL STFSSOCI-PAG-IDX > 12
               MOVE SPACES TO STFSSOCI-DATA-VENCIMENTO (STFSSOCI-PAG-IDX)
               MOVE ZERO TO STFSSOCI-VALR-MENSALIDADE (STFSSOCI-PAG-IDX)
               MOVE WS-INDI-FALSE TO STFSSOCI-PAGAMENTO-OK (STFSSOCI-PAG-IDX)
           END-PERFORM
           MOVE STFSSOCI-NUMB-SOCIO-PRINCIPAL TO LS-HV-NUMB-SOCIO-PRINCIPAL
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CHAR(DATA_BAIXA, ISO),
                      HORA_BAIXA,
                      OBSV_SOCIO
                 INTO :LS-HV-NOME-SOCIO-PRINCIPAL,
                      :LS-HV-DATA-CADASTRO,
                      :LS-HV-CATG-SOCIO,
                      :LS-HV-INDI-DIVIDA,
                      :LS-HV-DATA-BAIXA:LS-IND-DATA-BAIXA,
                      :LS-HV-HORA-BAIXA:LS-IND-HORA-BAIXA,
                      :LS-HV-OBSV-SOCIO
                 FROM SOCIOS
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   PERFORM MOVE-SOCIO-TO-LINKAGE
                   PERFORM FETCH-PAGAMENTOS
                   MOVE WS-RETURN-FOUND TO STFSSOCI-RETURN-CODE
               WHEN 100
                   MOVE WS-RETURN-NOTFOUND TO STFSSOCI-RETURN-CODE
               WHEN OTHER
                   MOVE SQLCODE TO STFSSOCI-RETURN-CODE
           END-EVALUATE
           GOBACK
           .
       MOVE-SOCIO-TO-LINKAGE.
           MOVE LS-HV-NOME-SOCIO-PRINCIPAL TO STFSSOCI-NOME-SOCIO-PRINCIPAL
           MOVE LS-HV-DATA-CADASTRO TO STFSSOCI-DATA-CADASTRO
           MOVE LS-HV-CATG-SOCIO TO STFSSOCI-CATG-SOCIO
           MOVE LS-HV-INDI-DIVIDA TO STFSSOCI-INDI-DIVIDA
           IF LS-IND-DATA-BAIXA = WS-DATE-NULL
               MOVE SPACES TO STFSSOCI-DATA-BAIXA
           ELSE
               MOVE LS-HV-DATA-BAIXA TO STFSSOCI-DATA-BAIXA
           END-IF
           IF LS-IND-HORA-BAIXA = WS-TIME-NULL
               MOVE SPACES TO STFSSOCI-HORA-BAIXA
           ELSE
               MOVE LS-HV-HORA-BAIXA TO STFSSOCI-HORA-BAIXA
           END-IF
           MOVE LS-HV-OBSV-SOCIO TO STFSSOCI-OBSV-SOCIO
           .
       FETCH-PAGAMENTOS.
           MOVE ZERO TO LS-PAG-COUNT
           EXEC SQL OPEN PAG-CUR END-EXEC
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO STFSSOCI-RETURN-CODE
               GOBACK
           END-IF
           PERFORM UNTIL SQLCODE = 100
               EXEC SQL
                   FETCH PAG-CUR
                    INTO :LS-HV-SEQ-PAGAMENTO,
                         :LS-HV-DATA-VENCIMENTO,
                         :LS-HV-VALR-MENSALIDADE,
                         :LS-HV-PAGAMENTO-OK
               END-EXEC
               IF SQLCODE = 0
                   ADD 1 TO LS-PAG-COUNT
                   IF LS-PAG-COUNT NOT > WS-MAX-PAGAMENTOS
                       MOVE LS-PAG-COUNT TO LS-PAG-IDX
                       MOVE LS-HV-DATA-VENCIMENTO
                           TO STFSSOCI-DATA-VENCIMENTO (LS-PAG-IDX)
                       MOVE LS-HV-VALR-MENSALIDADE
                           TO STFSSOCI-VALR-MENSALIDADE (LS-PAG-IDX)
                       MOVE LS-HV-PAGAMENTO-OK
                           TO STFSSOCI-PAGAMENTO-OK (LS-PAG-IDX)
                   END-IF
               ELSE
                   IF SQLCODE NOT = 100
                       MOVE SQLCODE TO STFSSOCI-RETURN-CODE
                   END-IF
               END-IF
           END-PERFORM
           EXEC SQL CLOSE PAG-CUR END-EXEC
           MOVE LS-PAG-COUNT TO STFSSOCI-C-PERIODICO-PAGAMENTO
           .
