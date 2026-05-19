       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * CONSULTA SOCIO / SOCIO_PAGAMENTO (DB2) - operacao FIND        *
      * DBATDP-14                                                     *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA              PIC X(08) VALUE 'STFSC00C'.
       01  WS-RC-OK                       PIC S9(04) VALUE +0.
       01  WS-RC-NOTFOUND                 PIC S9(04) VALUE +100.
       01  WS-RC-ERROR                    PIC S9(04) VALUE +999.
       01  WS-CONT-PAG                    PIC 9(02)  VALUE ZERO.
       01  WS-SQL-ERR                     PIC X(70)  VALUE SPACES.

           EXEC SQL
               DECLARE CSR-SOCIO-PAG CURSOR FOR
               SELECT SEQ_PAGAMENTO,
                      CHAR(DATA_VENCIMENTO, ISO),
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM SOCIO_PAGAMENTO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRINCIPAL
                ORDER BY SEQ_PAGAMENTO
           END-EXEC.

       LOCAL-STORAGE SECTION.
           COPY STFSC00HS.
           EXEC SQL INCLUDE SQLCA END-EXEC.

       LINKAGE SECTION.
           COPY STFSC00LK.

       PROCEDURE DIVISION USING STFSC00-LINKAGE.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.

       INICIALIZA.
           MOVE WS-RC-OK TO STFSC00-RETURN-CODE
           MOVE ZERO TO WS-CONT-PAG
           MOVE ZERO TO STFSC00-C-PERIODICO-PAGAMENTO
           .

       PROCESSA.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL
               TO HV-NUMB-SOCIO-PRINCIPAL

           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CHAR(DATA_BAIXA, ISO),
                      HORA_BAIXA,
                      OBSV_SOCIO
                 INTO :HV-NOME-SOCIO-PRINCIPAL,
                      :HV-DATA-CADASTRO,
                      :HV-CATG-SOCIO,
                      :HV-INDI-DIVIDA,
                      :HV-DATA-BAIXA:HV-NUL-DATA-BAIXA,
                      :HV-HORA-BAIXA:HV-NUL-HORA-BAIXA,
                      :HV-OBSV-SOCIO:HV-NUL-OBSV-SOCIO
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRINCIPAL
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   PERFORM GRAVA-SOCIO-LINKAGE
                   PERFORM ABRE-CURSOR-PAGAMENTO
               WHEN 100
                   MOVE WS-RC-NOTFOUND TO STFSC00-RETURN-CODE
               WHEN OTHER
                   MOVE WS-RC-ERROR TO STFSC00-RETURN-CODE
           END-EVALUATE
           .

       FINALIZA.
           .

       GRAVA-SOCIO-LINKAGE.
           MOVE HV-NOME-SOCIO-PRINCIPAL
               TO STFSC00-NOME-SOCIO-PRINCIPAL
           MOVE HV-DATA-CADASTRO TO STFSC00-DATA-CADASTRO
           MOVE HV-CATG-SOCIO TO STFSC00-CATG-SOCIO
           MOVE HV-INDI-DIVIDA TO STFSC00-INDI-DIVIDA
           IF HV-NUL-DATA-BAIXA = ZERO
               MOVE HV-DATA-BAIXA TO STFSC00-DATA-BAIXA
           ELSE
               MOVE SPACES TO STFSC00-DATA-BAIXA
           END-IF
           IF HV-NUL-HORA-BAIXA = ZERO
               MOVE HV-HORA-BAIXA TO STFSC00-HORA-BAIXA
           ELSE
               MOVE SPACES TO STFSC00-HORA-BAIXA
           END-IF
           IF HV-NUL-OBSV-SOCIO = ZERO
               MOVE HV-OBSV-SOCIO TO STFSC00-OBSV-SOCIO
           ELSE
               MOVE SPACES TO STFSC00-OBSV-SOCIO
           END-IF
           .

       ABRE-CURSOR-PAGAMENTO.
           EXEC SQL OPEN CSR-SOCIO-PAG END-EXEC
           IF SQLCODE NOT = 0
               MOVE WS-RC-ERROR TO STFSC00-RETURN-CODE
               GO TO ABRE-CURSOR-PAGAMENTO-EXIT
           END-IF
           PERFORM UNTIL WS-CONT-PAG >= 12
               EXEC SQL
                   FETCH CSR-SOCIO-PAG
                    INTO :HV-SEQ-PAGAMENTO,
                         :HV-DATA-VENCIMENTO,
                         :HV-VALR-MENSALIDADE,
                         :HV-PAGAMENTO-OK
               END-EXEC
               IF SQLCODE = 100
                   EXIT PERFORM
               END-IF
               IF SQLCODE NOT = 0
                   MOVE WS-RC-ERROR TO STFSC00-RETURN-CODE
                   EXIT PERFORM
               END-IF
               ADD 1 TO WS-CONT-PAG
               MOVE WS-CONT-PAG TO STFSC00-IDX-PAG
               MOVE HV-DATA-VENCIMENTO
                   TO STFSC00-DATA-VENCIMENTO(STFSC00-IDX-PAG)
               MOVE HV-VALR-MENSALIDADE
                   TO STFSC00-VALR-MENSALIDADE(STFSC00-IDX-PAG)
               MOVE HV-PAGAMENTO-OK
                   TO STFSC00-PAGAMENTO-OK(STFSC00-IDX-PAG)
           END-PERFORM
           MOVE WS-CONT-PAG TO STFSC00-C-PERIODICO-PAGAMENTO
           EXEC SQL CLOSE CSR-SOCIO-PAG END-EXEC
           .
       ABRE-CURSOR-PAGAMENTO-EXIT.
           EXIT.
