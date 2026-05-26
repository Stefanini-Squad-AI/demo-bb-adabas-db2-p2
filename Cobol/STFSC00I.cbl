      * PROGRAMA STFSC00I - INSERT OPERACAO
      * INSERE NOVOS SOCIOS EM DB2
      * OPERACAO: I (Insert/Store)

       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       01 WS-CONSTANTS.
           05 WS-PROGRAM-ID           PIC X(8) VALUE 'STFSC00I'.
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

       01 PERIODICO-VARS.
           05 PV-INDICE               PIC 9(2) COMP VALUE 0.
           05 HV-VALR                 PIC S9(4)V99 COMP-3.
           05 HV-DATA-VENC            PIC X(10).
           05 HV-PAGTO-OK             PIC X(1).

       LINKAGE SECTION.
       01 LS-OPERACAO                 PIC X(1).
       01 LS-SOCIO-RECORD             COPY STFSC00-SOCIO-IO.
       01 LS-RETURN-CODE              PIC S9(9) COMP.
       01 LS-RETURN-MSG               PIC X(100).

       PROCEDURE DIVISION USING LS-OPERACAO LS-SOCIO-RECORD
                                LS-RETURN-CODE LS-RETURN-MSG.

           PERFORM INICIALIZA.
           PERFORM PROCESSA.
           PERFORM FINALIZA.
           STOP RUN.

       INICIALIZA.
           INITIALIZE SOCIO-RECORD.
           MOVE 0 TO RC-STATUS.
           MOVE SPACES TO RC-MESSAGE.
           MOVE 0 TO RC-SQLCODE.
           MOVE LS-SOCIO-RECORD TO SOCIO-RECORD.

           MOVE NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO.
           MOVE NOME-SOCIO-PRINCIPAL TO HV-NOME-SOCIO.
           MOVE DATA-CADASTRO TO HV-DATA-CAD.
           MOVE CATG-SOCIO TO HV-CATG.
           MOVE INDI-DIVIDA TO HV-DIVIDA.
           MOVE DATA-BAIXA TO HV-DATA-BAIXA.
           MOVE HORA-BAIXA TO HV-HORA-BAIXA.
           MOVE OBSV-SOCIO TO HV-OBS.

       PROCESSA.
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
               VALUES (:HV-NUMB-SOCIO,
                       :HV-NOME-SOCIO,
                       :HV-DATA-CAD,
                       :HV-CATG,
                       :HV-DIVIDA,
                       :HV-DATA-BAIXA,
                       :HV-HORA-BAIXA,
                       :HV-OBS)
           END-EXEC.

           EVALUATE TRUE
               WHEN SQLCODE = 0
                   PERFORM INSERE-PERIODICOS
                   MOVE 0 TO RC-STATUS
                   MOVE 'Novo sócio incluído com sucesso'
                       TO RC-MESSAGE
               WHEN SQLCODE = -803
                   MOVE 803 TO RC-STATUS
                   MOVE 'Chave duplicada - Sócio já existe'
                       TO RC-MESSAGE
               WHEN OTHER
                   MOVE SQLCODE TO RC-SQLCODE
                   MOVE SQLCODE TO RC-STATUS
                   STRING 'Erro DB2 ao inserir: ' SQLCODE
                       DELIMITED BY SIZE
                       INTO RC-MESSAGE
                   END-STRING
           END-EVALUATE.

           MOVE RC-STATUS TO LS-RETURN-CODE.
           MOVE RC-MESSAGE TO LS-RETURN-MSG.

       INSERES-PERIODICOS.
           PERFORM VARYING PV-INDICE FROM 1 BY 1
               UNTIL PV-INDICE > 12
               OR SQLCODE NOT = 0

               MOVE DATA-VENCIMENTO(PV-INDICE) TO HV-DATA-VENC
               MOVE VALR-MENSALIDADE(PV-INDICE) TO HV-VALR
               MOVE PAGAMENTO-OK(PV-INDICE) TO HV-PAGTO-OK

               EXEC SQL
                   INSERT INTO PERIODICO_PAGAMENTO
                   (NUMB_SOCIO,
                    SEQUENCIA,
                    DATA_VENCIMENTO,
                    VALR_MENSALIDADE,
                    PAGAMENTO_OK)
                   VALUES (:HV-NUMB-SOCIO,
                           :PV-INDICE,
                           :HV-DATA-VENC,
                           :HV-VALR,
                           :HV-PAGTO-OK)
               END-EXEC

               IF SQLCODE NOT = 0
                   MOVE SQLCODE TO RC-STATUS
                   STRING 'Erro ao inserir periódico ' PV-INDICE
                       DELIMITED BY SIZE
                       INTO RC-MESSAGE
                   END-STRING
                   MOVE RC-STATUS TO LS-RETURN-CODE
                   MOVE RC-MESSAGE TO LS-RETURN-MSG
               END-IF
           END-PERFORM.

       FINALIZA.
           MOVE LS-RETURN-CODE TO RETURN-CODE.
