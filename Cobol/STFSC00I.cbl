       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * INCLUSAO SOCIO / SOCIO_PAGAMENTO (DB2) - operacao STORE       *
      * DBATDP-14                                                     *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA              PIC X(08) VALUE 'STFSC00I'.
       01  WS-RC-OK                       PIC S9(04) VALUE +0.
       01  WS-RC-DUPKEY                   PIC S9(04) VALUE +803.
       01  WS-RC-ERROR                    PIC S9(04) VALUE +999.
       01  WS-IDX                         PIC 9(02)  VALUE ZERO.

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
           .

       PROCESSA.
           PERFORM GRAVA-HOST-SOCIO
           IF HV-NUL-DATA-BAIXA NOT = ZERO
               MOVE -1 TO HV-NUL-DATA-BAIXA
           END-IF
           IF HV-NUL-HORA-BAIXA NOT = ZERO
               MOVE -1 TO HV-NUL-HORA-BAIXA
           END-IF
           IF HV-NUL-OBSV-SOCIO NOT = ZERO
               MOVE -1 TO HV-NUL-OBSV-SOCIO
           END-IF
           EXEC SQL
               INSERT INTO SOCIO
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
                    :HV-DATA-BAIXA:HV-NUL-DATA-BAIXA,
                    :HV-HORA-BAIXA:HV-NUL-HORA-BAIXA,
                    :HV-OBSV-SOCIO:HV-NUL-OBSV-SOCIO)
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   PERFORM INSERE-PAGAMENTOS
               WHEN -803
                   MOVE WS-RC-DUPKEY TO STFSC00-RETURN-CODE
               WHEN OTHER
                   MOVE WS-RC-ERROR TO STFSC00-RETURN-CODE
           END-EVALUATE
           .

       FINALIZA.
           .

       GRAVA-HOST-SOCIO.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL
               TO HV-NUMB-SOCIO-PRINCIPAL
           MOVE STFSC00-NOME-SOCIO-PRINCIPAL
               TO HV-NOME-SOCIO-PRINCIPAL
           MOVE STFSC00-DATA-CADASTRO TO HV-DATA-CADASTRO
           MOVE STFSC00-CATG-SOCIO TO HV-CATG-SOCIO
           MOVE STFSC00-INDI-DIVIDA TO HV-INDI-DIVIDA
           IF STFSC00-DATA-BAIXA = SPACES
               MOVE -1 TO HV-NUL-DATA-BAIXA
           ELSE
               MOVE ZERO TO HV-NUL-DATA-BAIXA
               MOVE STFSC00-DATA-BAIXA TO HV-DATA-BAIXA
           END-IF
           IF STFSC00-HORA-BAIXA = SPACES
               MOVE -1 TO HV-NUL-HORA-BAIXA
           ELSE
               MOVE ZERO TO HV-NUL-HORA-BAIXA
               MOVE STFSC00-HORA-BAIXA TO HV-HORA-BAIXA
           END-IF
           IF STFSC00-OBSV-SOCIO = SPACES
               MOVE -1 TO HV-NUL-OBSV-SOCIO
           ELSE
               MOVE ZERO TO HV-NUL-OBSV-SOCIO
               MOVE STFSC00-OBSV-SOCIO TO HV-OBSV-SOCIO
           END-IF
           .

       INSERE-PAGAMENTOS.
           PERFORM VARYING STFSC00-IDX-PAG FROM 1 BY 1
               UNTIL STFSC00-IDX-PAG > 12
               MOVE STFSC00-IDX-PAG TO HV-SEQ-PAGAMENTO
               MOVE STFSC00-DATA-VENCIMENTO(STFSC00-IDX-PAG)
                   TO HV-DATA-VENCIMENTO
               MOVE STFSC00-VALR-MENSALIDADE(STFSC00-IDX-PAG)
                   TO HV-VALR-MENSALIDADE
               MOVE STFSC00-PAGAMENTO-OK(STFSC00-IDX-PAG)
                   TO HV-PAGAMENTO-OK
               EXEC SQL
                   INSERT INTO SOCIO_PAGAMENTO
                       (NUMB_SOCIO_PRINCIPAL,
                        SEQ_PAGAMENTO,
                        DATA_VENCIMENTO,
                        VALR_MENSALIDADE,
                        PAGAMENTO_OK)
                   VALUES
                       (:HV-NUMB-SOCIO-PRINCIPAL,
                        :HV-SEQ-PAGAMENTO,
                        DATE(:HV-DATA-VENCIMENTO),
                        :HV-VALR-MENSALIDADE,
                        :HV-PAGAMENTO-OK)
               END-EXEC
               IF SQLCODE NOT = 0
                   MOVE WS-RC-ERROR TO STFSC00-RETURN-CODE
                   EXIT PERFORM
               END-IF
           END-PERFORM
           .
