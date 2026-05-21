       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consulta sócio (FIND) - Natural STFPCS00-P2 / DB2 SOCIO
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA            PIC X(08) VALUE 'STFSC00C'.
       01  WS-CONST-VERSAO              PIC X(04) VALUE 'P2  '.
       01  WS-MAX-PE                    PIC 9(04) COMP VALUE 12.

       EXEC SQL
           DECLARE CSR-PE CURSOR FOR
               SELECT SEQ_PERIODICO,
                      DATA_VENCIMENTO,
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM SOCIO_PERIODICO_PAGAMENTO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO
                ORDER BY SEQ_PERIODICO
       END-EXEC.

       LOCAL-STORAGE SECTION.
       01  LS-SQLCA.
           EXEC SQL INCLUDE SQLCA END-EXEC.

       01  HV-NUMB-SOCIO                PIC S9(09) COMP.
       01  HV-NOME                      PIC X(40).
       01  HV-DATA-CAD                  PIC X(10).
       01  HV-CATG                      PIC S9(04) COMP.
       01  HV-INDI-DIVIDA               PIC X(01).
       01  HV-DATA-BAIXA                PIC X(10).
       01  HV-HORA-BAIXA                PIC X(05).
       01  HV-OBSV                      PIC X(500).
       01  HV-SEQ-PE                    PIC S9(09) COMP.
       01  HV-DATA-VENC                 PIC X(10).
       01  HV-VALR-MENS                 PIC S9(06)V9(02) COMP-3.
       01  HV-PAG-OK                    PIC X(01).
       01  WS-IX-PE                     PIC 9(04) COMP.

       LINKAGE SECTION.
       COPY STFSC00.

       PROCEDURE DIVISION USING STFSC00-AREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.

       INICIALIZA.
           MOVE 'C' TO STFSC00-OPERACAO
           MOVE ZERO TO STFSC00-RETURN-CODE
           MOVE ZERO TO STFSC00-C-PERIODICO-PAGAMENTO
           PERFORM ZERAR-PERIODICO-AREA
           .

       PROCESSA.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CHAR(DATA_BAIXA, ISO),
                      HORA_BAIXA,
                      OBSV_SOCIO
                 INTO :HV-NOME,
                      :HV-DATA-CAD,
                      :HV-CATG,
                      :HV-INDI-DIVIDA,
                      :HV-DATA-BAIXA,
                      :HV-HORA-BAIXA,
                      :HV-OBSV
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE +000 TO STFSC00-RETURN-CODE
                   MOVE HV-NOME TO STFSC00-NOME-SOCIO-PRINCIPAL
                   MOVE HV-DATA-CAD TO STFSC00-DATA-CADASTRO
                   MOVE HV-CATG TO STFSC00-CATG-SOCIO
                   MOVE HV-INDI-DIVIDA TO STFSC00-INDI-DIVIDA
                   MOVE HV-DATA-BAIXA TO STFSC00-DATA-BAIXA
                   MOVE HV-HORA-BAIXA TO STFSC00-HORA-BAIXA
                   MOVE HV-OBSV TO STFSC00-OBSV-SOCIO
                   PERFORM LER-PERIODICO-CURSOR
               WHEN 100
                   MOVE +100 TO STFSC00-RETURN-CODE
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-RETURN-CODE
           END-EVALUATE
           .

       LER-PERIODICO-CURSOR.
           MOVE ZERO TO WS-IX-PE
           EXEC SQL OPEN CSR-PE END-EXEC
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO STFSC00-RETURN-CODE
               GO TO LER-PERIODICO-FIM
           END-IF
           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL
                   FETCH CSR-PE
                    INTO :HV-SEQ-PE,
                         :HV-DATA-VENC,
                         :HV-VALR-MENS,
                         :HV-PAG-OK
               END-EXEC
               IF SQLCODE = 0
                   ADD 1 TO WS-IX-PE
                   IF WS-IX-PE > WS-MAX-PE
                       GO TO LER-PERIODICO-FIM
                   END-IF
                   MOVE HV-DATA-VENC TO
                       STFSC00-DATA-VENCIMENTO(WS-IX-PE)
                   MOVE HV-VALR-MENS TO
                       STFSC00-VALR-MENSALIDADE(WS-IX-PE)
                   MOVE HV-PAG-OK TO
                       STFSC00-PAGAMENTO-OK(WS-IX-PE)
               END-IF
           END-PERFORM
           MOVE WS-IX-PE TO STFSC00-C-PERIODICO-PAGAMENTO
           .

       LER-PERIODICO-FIM.
           EXEC SQL CLOSE CSR-PE END-EXEC
           .

       ZERAR-PERIODICO-AREA.
           PERFORM VARYING WS-IX-PE FROM 1 BY 1
               UNTIL WS-IX-PE > WS-MAX-PE
               MOVE SPACES TO STFSC00-DATA-VENCIMENTO(WS-IX-PE)
               MOVE ZERO TO STFSC00-VALR-MENSALIDADE(WS-IX-PE)
               MOVE 'N' TO STFSC00-PAGAMENTO-OK(WS-IX-PE)
           END-PERFORM
           .

       FINALIZA.
           .

       END PROGRAM STFSC00C.
