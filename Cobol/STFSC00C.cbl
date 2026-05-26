      * PROGRAMA STFSC00C - SELECT OPERACAO
      * ACESSA DADOS DE SOCIOS EM DB2
      * OPERACAO: C (Consulta/Select)

       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       01 WS-CONSTANTS.
           05 WS-PROGRAM-ID           PIC X(8) VALUE 'STFSC00C'.
           05 WS-PROGRAM-VERSION      PIC X(5) VALUE '1.0.0'.

       LOCAL-STORAGE SECTION.
       01 SQLCA                       COPY SQLCA.
       01 SOCIO-RECORD                COPY STFSC00-SOCIO-IO.
       01 RETURN-CODE-STRUCT          COPY STFSC00-RETURN.

       01 LS-LOCALS.
           05 LS-RC                   PIC S9(9) COMP.
           05 LS-MSG                  PIC X(100).

       01 HOST-VARS.
           05 HV-NUMB-SOCIO           PIC 9(9).
           05 HV-NOME-SOCIO           PIC X(40).
           05 HV-DATA-CAD             PIC X(10).
           05 HV-CATG                 PIC 9(2).
           05 HV-DIVIDA               PIC X(1).
           05 HV-DATA-BAIXA           PIC X(10).
           05 HV-HORA-BAIXA           PIC X(8).
           05 HV-OBS                  PIC X(500).

       01 CURSOR-VARS.
           05 CV-INDICE               PIC 9(2) COMP VALUE 0.
           05 HV-VALR                 PIC S9(4)V99 COMP-3.
           05 HV-DATA-VENC            PIC X(10).
           05 HV-PAGTO-OK             PIC X(1).

       LINKAGE SECTION.
       01 LS-OPERACAO                 PIC X(1).
       01 LS-NUMB-SOCIO               PIC 9(9).
       01 LS-SOCIO-RECORD             COPY STFSC00-SOCIO-IO.
       01 LS-RETURN-CODE              PIC S9(9) COMP.
       01 LS-RETURN-MSG               PIC X(100).

       PROCEDURE DIVISION USING LS-OPERACAO LS-NUMB-SOCIO
                                LS-SOCIO-RECORD LS-RETURN-CODE
                                LS-RETURN-MSG.

           PERFORM INICIALIZA.
           PERFORM PROCESSA.
           PERFORM FINALIZA.
           STOP RUN.

       INICIALIZA.
           INITIALIZE SOCIO-RECORD.
           MOVE 0 TO RC-STATUS.
           MOVE SPACES TO RC-MESSAGE.
           MOVE 0 TO RC-SQLCODE.
           MOVE LS-NUMB-SOCIO TO HV-NUMB-SOCIO.

       PROCESSA.
           EXEC SQL
               SELECT NUMB_SOCIO_PRINCIPAL,
                      NOME_SOCIO_PRINCIPAL,
                      DATA_CADASTRO,
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      DATA_BAIXA,
                      HORA_BAIXA,
                      OBSV_SOCIO
               INTO :HV-NUMB-SOCIO,
                    :HV-NOME-SOCIO,
                    :HV-DATA-CAD,
                    :HV-CATG,
                    :HV-DIVIDA,
                    :HV-DATA-BAIXA,
                    :HV-HORA-BAIXA,
                    :HV-OBS
               FROM SOCIOS
               WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO
           END-EXEC.

           EVALUATE TRUE
               WHEN SQLCODE = 0
                   MOVE HV-NUMB-SOCIO
                       TO NUMB-SOCIO-PRINCIPAL
                   MOVE HV-NOME-SOCIO
                       TO NOME-SOCIO-PRINCIPAL
                   MOVE HV-DATA-CAD TO DATA-CADASTRO
                   MOVE HV-CATG TO CATG-SOCIO
                   MOVE HV-DIVIDA TO INDI-DIVIDA
                   MOVE HV-DATA-BAIXA TO DATA-BAIXA
                   MOVE HV-HORA-BAIXA TO HORA-BAIXA
                   MOVE HV-OBS TO OBSV-SOCIO

                   PERFORM BUSCA-PERIODICOS

                   MOVE 0 TO RC-STATUS
                   MOVE 'Registro localizado' TO RC-MESSAGE
               WHEN SQLCODE = 100
                   MOVE 100 TO RC-STATUS
                   MOVE 'Nenhum registro localizado' TO RC-MESSAGE
               WHEN OTHER
                   MOVE SQLCODE TO RC-SQLCODE
                   MOVE SQLCODE TO RC-STATUS
                   STRING 'Erro DB2: ' SQLCODE DELIMITED BY SIZE
                       INTO RC-MESSAGE
                   END-STRING
           END-EVALUATE.

           MOVE RC-STATUS TO LS-RETURN-CODE.
           MOVE RC-MESSAGE TO LS-RETURN-MSG.
           MOVE SOCIO-RECORD TO LS-SOCIO-RECORD.

       BUSCA-PERIODICOS.
           PERFORM VARYING CV-INDICE FROM 1 BY 1
               UNTIL CV-INDICE > 12
               EXEC SQL
                   SELECT DATA_VENCIMENTO,
                          VALR_MENSALIDADE,
                          PAGAMENTO_OK
                   INTO :HV-DATA-VENC,
                        :HV-VALR,
                        :HV-PAGTO-OK
                   FROM PERIODICO_PAGAMENTO
                   WHERE NUMB_SOCIO = :HV-NUMB-SOCIO
                     AND SEQUENCIA = :CV-INDICE
               END-EXEC

               IF SQLCODE = 0
                   MOVE HV-DATA-VENC TO
                       DATA-VENCIMENTO(CV-INDICE)
                   MOVE HV-VALR TO
                       VALR-MENSALIDADE(CV-INDICE)
                   MOVE HV-PAGTO-OK TO
                       PAGAMENTO-OK(CV-INDICE)
               END-IF
           END-PERFORM.

       FINALIZA.
           MOVE LS-RETURN-CODE TO RETURN-CODE.
