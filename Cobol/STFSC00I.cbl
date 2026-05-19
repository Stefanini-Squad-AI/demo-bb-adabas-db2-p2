       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
       AUTHOR. DBATDP-10.
       REMARKS. Inclusao de socio (DB2 INSERT).
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-PROGRAM-ID                  PIC X(8) VALUE 'STFSC00I'.
       01  WS-SQLCODE-OK                  PIC S9(4) COMP VALUE 0.
       01  WS-SQLCODE-DUP                 PIC S9(4) COMP VALUE -803.
       01  WS-RETURN-OK                   PIC S9(4) COMP VALUE 0.
       01  WS-RETURN-DUP                  PIC S9(4) COMP VALUE 803.
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
       01  LS-PAG-IDX                      PIC 9(3) COMP.
       01  LS-PAG-LIMIT                    PIC 9(3) COMP.
       LINKAGE SECTION.
           COPY STFSSOCI.
       PROCEDURE DIVISION USING STFSSOCI-LINKAGE.
       MAIN-PARA.
           MOVE WS-RETURN-ERROR TO STFSSOCI-RETURN-CODE
           PERFORM MOVE-LINKAGE-TO-HOST
           IF LS-IND-DATA-BAIXA = WS-DATE-NULL
               MOVE SPACES TO LS-HV-DATA-BAIXA
           END-IF
           IF LS-IND-HORA-BAIXA = WS-TIME-NULL
               MOVE SPACES TO LS-HV-HORA-BAIXA
           END-IF
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
               VALUES
                   (:LS-HV-NUMB-SOCIO-PRINCIPAL,
                    :LS-HV-NOME-SOCIO-PRINCIPAL,
                    :LS-HV-DATA-CADASTRO,
                    :LS-HV-CATG-SOCIO,
                    :LS-HV-INDI-DIVIDA,
                    :LS-HV-DATA-BAIXA:LS-IND-DATA-BAIXA,
                    :LS-HV-HORA-BAIXA:LS-IND-HORA-BAIXA,
                    :LS-HV-OBSV-SOCIO)
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   PERFORM INSERT-PAGAMENTOS
                   IF STFSSOCI-RETURN-CODE = WS-RETURN-ERROR
                       EXEC SQL ROLLBACK END-EXEC
                   ELSE
                       EXEC SQL COMMIT END-EXEC
                       MOVE WS-RETURN-OK TO STFSSOCI-RETURN-CODE
                   END-IF
               WHEN -803
                   EXEC SQL ROLLBACK END-EXEC
                   MOVE WS-RETURN-DUP TO STFSSOCI-RETURN-CODE
               WHEN OTHER
                   EXEC SQL ROLLBACK END-EXEC
                   MOVE SQLCODE TO STFSSOCI-RETURN-CODE
           END-EVALUATE
           GOBACK
           .
       MOVE-LINKAGE-TO-HOST.
           MOVE STFSSOCI-NUMB-SOCIO-PRINCIPAL TO LS-HV-NUMB-SOCIO-PRINCIPAL
           MOVE STFSSOCI-NOME-SOCIO-PRINCIPAL TO LS-HV-NOME-SOCIO-PRINCIPAL
           MOVE STFSSOCI-DATA-CADASTRO TO LS-HV-DATA-CADASTRO
           MOVE STFSSOCI-CATG-SOCIO TO LS-HV-CATG-SOCIO
           MOVE STFSSOCI-INDI-DIVIDA TO LS-HV-INDI-DIVIDA
           IF STFSSOCI-DATA-BAIXA = SPACES
               MOVE WS-DATE-NULL TO LS-IND-DATA-BAIXA
           ELSE
               MOVE ZERO TO LS-IND-DATA-BAIXA
               MOVE STFSSOCI-DATA-BAIXA TO LS-HV-DATA-BAIXA
           END-IF
           IF STFSSOCI-HORA-BAIXA = SPACES
               MOVE WS-TIME-NULL TO LS-IND-HORA-BAIXA
           ELSE
               MOVE ZERO TO LS-IND-HORA-BAIXA
               MOVE STFSSOCI-HORA-BAIXA TO LS-HV-HORA-BAIXA
           END-IF
           MOVE STFSSOCI-OBSV-SOCIO TO LS-HV-OBSV-SOCIO
           .
       INSERT-PAGAMENTOS.
           IF STFSSOCI-C-PERIODICO-PAGAMENTO > 0
               MOVE STFSSOCI-C-PERIODICO-PAGAMENTO TO LS-PAG-LIMIT
           ELSE
               MOVE WS-MAX-PAGAMENTOS TO LS-PAG-LIMIT
           END-IF
           IF LS-PAG-LIMIT > WS-MAX-PAGAMENTOS
               MOVE WS-MAX-PAGAMENTOS TO LS-PAG-LIMIT
           END-IF
           PERFORM VARYING LS-PAG-IDX FROM 1 BY 1
               UNTIL LS-PAG-IDX > LS-PAG-LIMIT
               MOVE LS-PAG-IDX TO LS-HV-SEQ-PAGAMENTO
               MOVE STFSSOCI-DATA-VENCIMENTO (LS-PAG-IDX)
                   TO LS-HV-DATA-VENCIMENTO
               MOVE STFSSOCI-VALR-MENSALIDADE (LS-PAG-IDX)
                   TO LS-HV-VALR-MENSALIDADE
               IF STFSSOCI-PAGAMENTO-OK (LS-PAG-IDX) = WS-INDI-TRUE
                   MOVE WS-INDI-TRUE TO LS-HV-PAGAMENTO-OK
               ELSE
                   MOVE WS-INDI-FALSE TO LS-HV-PAGAMENTO-OK
               END-IF
               EXEC SQL
                   INSERT INTO SOCIOS_PAGAMENTO
                       (NUMB_SOCIO_PRINCIPAL,
                        SEQ_PAGAMENTO,
                        DATA_VENCIMENTO,
                        VALR_MENSALIDADE,
                        PAGAMENTO_OK)
                   VALUES
                       (:LS-HV-NUMB-SOCIO-PRINCIPAL,
                        :LS-HV-SEQ-PAGAMENTO,
                        :LS-HV-DATA-VENCIMENTO,
                        :LS-HV-VALR-MENSALIDADE,
                        :LS-HV-PAGAMENTO-OK)
               END-EXEC
               IF SQLCODE NOT = 0
                   MOVE SQLCODE TO STFSSOCI-RETURN-CODE
                   EXIT PARAGRAPH
               END-IF
           END-PERFORM
           .
