       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Inclusão sócio (STORE) - Natural STFPCS00-P2 / DB2 SOCIO
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA            PIC X(08) VALUE 'STFSC00I'.
       01  WS-CONST-VERSAO              PIC X(04) VALUE 'P2  '.
       01  WS-MAX-PE                    PIC 9(04) COMP VALUE 12.

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
       01  WS-QTD-PE                    PIC 9(04) COMP.

       LINKAGE SECTION.
       COPY STFSC00.

       PROCEDURE DIVISION USING STFSC00-AREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.

       INICIALIZA.
           MOVE 'I' TO STFSC00-OPERACAO
           MOVE ZERO TO STFSC00-RETURN-CODE
           .

       PROCESSA.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO
           MOVE STFSC00-NOME-SOCIO-PRINCIPAL TO HV-NOME
           MOVE STFSC00-DATA-CADASTRO TO HV-DATA-CAD
           MOVE STFSC00-CATG-SOCIO TO HV-CATG
           MOVE STFSC00-INDI-DIVIDA TO HV-INDI-DIVIDA
           IF HV-INDI-DIVIDA = SPACES
               MOVE 'N' TO HV-INDI-DIVIDA
           END-IF
           MOVE STFSC00-DATA-BAIXA TO HV-DATA-BAIXA
           MOVE STFSC00-HORA-BAIXA TO HV-HORA-BAIXA
           MOVE STFSC00-OBSV-SOCIO TO HV-OBSV
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
                   :HV-NUMB-SOCIO,
                   :HV-NOME,
                   DATE(:HV-DATA-CAD),
                   :HV-CATG,
                   :HV-INDI-DIVIDA,
                   NULLIF(:HV-DATA-BAIXA, '          '),
                   NULLIF(:HV-HORA-BAIXA, '     '),
                   :HV-OBSV
               )
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE +000 TO STFSC00-RETURN-CODE
                   PERFORM GRAVAR-PERIODICO
               WHEN -803
                   MOVE +803 TO STFSC00-RETURN-CODE
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-RETURN-CODE
           END-EVALUATE
           .

       GRAVAR-PERIODICO.
           IF STFSC00-C-PERIODICO-PAGAMENTO > ZERO
               MOVE STFSC00-C-PERIODICO-PAGAMENTO TO WS-QTD-PE
           ELSE
               MOVE WS-MAX-PE TO WS-QTD-PE
           END-IF
           PERFORM VARYING WS-IX-PE FROM 1 BY 1
               UNTIL WS-IX-PE > WS-QTD-PE
               MOVE STFSC00-NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO
               MOVE WS-IX-PE TO HV-SEQ-PE
               MOVE STFSC00-DATA-VENCIMENTO(WS-IX-PE) TO HV-DATA-VENC
               MOVE STFSC00-VALR-MENSALIDADE(WS-IX-PE) TO HV-VALR-MENS
               MOVE STFSC00-PAGAMENTO-OK(WS-IX-PE) TO HV-PAG-OK
               IF HV-PAG-OK = '1' OR HV-PAG-OK = LOW-VALUE
                   IF HV-PAG-OK = '1'
                       MOVE 'Y' TO HV-PAG-OK
                   ELSE
                       MOVE 'N' TO HV-PAG-OK
                   END-IF
               END-IF
               EXEC SQL
                   INSERT INTO SOCIO_PERIODICO_PAGAMENTO (
                       NUMB_SOCIO_PRINCIPAL,
                       SEQ_PERIODICO,
                       DATA_VENCIMENTO,
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK
                   ) VALUES (
                       :HV-NUMB-SOCIO,
                       :HV-SEQ-PE,
                       DATE(:HV-DATA-VENC),
                       :HV-VALR-MENS,
                       :HV-PAG-OK
                   )
               END-EXEC
               IF SQLCODE NOT = 0
                   MOVE SQLCODE TO STFSC00-RETURN-CODE
                   GO TO GRAVAR-PERIODICO-FIM
               END-IF
           END-PERFORM
           .

       GRAVAR-PERIODICO-FIM.
           .

       FINALIZA.
           .

       END PROGRAM STFSC00I.
