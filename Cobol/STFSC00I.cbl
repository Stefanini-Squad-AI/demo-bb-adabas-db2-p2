       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Inclusao de socio e parcelas periodicas
      * SQLCODE +000 sucesso / +803 chave duplicada
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-OPER-INCLUSAO        PIC X(01) VALUE 'I'.
       01  WS-IND-PER                    PIC 9(03) VALUE ZEROES.

           EXEC SQL INCLUDE SQLCA END-EXEC.

       LINKAGE SECTION.
           COPY STFSC00B.

       LOCAL-STORAGE SECTION.
       01  HV-NUMB-SOCIO-PRINCIPAL       PIC 9(09).
       01  HV-NOME-SOCIO-PRINCIPAL       PIC X(40).
       01  HV-DATA-CADASTRO              PIC X(10).
       01  HV-CATG-SOCIO                 PIC 9(02).
       01  HV-INDI-DIVIDA                PIC X(01).
       01  HV-DATA-BAIXA                 PIC X(10).
       01  HV-HORA-BAIXA                 PIC X(05).
       01  HV-OBSV-SOCIO                 PIC X(500).
       01  HV-SEQ-PERIODICO              PIC 9(09).
       01  HV-DATA-VENCIMENTO            PIC X(10).
       01  HV-VALR-MENSALIDADE           PIC S9(4)V99 COMP-3.
       01  HV-PAGAMENTO-OK               PIC X(01).

       PROCEDURE DIVISION USING STFSC00-AREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.

       INICIALIZA.
           MOVE WS-CONST-OPER-INCLUSAO TO STFSC00-OPERACAO
           MOVE ZEROES TO STFSC00-SQLCODE
           .

       PROCESSA.
           PERFORM GRAVA-SOCIO
           IF STFSC00-SQLCODE NOT = ZEROES
               GO TO PROCESSA-FIM
           END-IF
           PERFORM GRAVA-PERIODICO
           .

       PROCESSA-FIM.
           .

       GRAVA-SOCIO.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL
               TO HV-NUMB-SOCIO-PRINCIPAL
           MOVE STFSC00-NOME-SOCIO-PRINCIPAL
               TO HV-NOME-SOCIO-PRINCIPAL
           MOVE STFSC00-DATA-CADASTRO TO HV-DATA-CADASTRO
           MOVE STFSC00-CATG-SOCIO TO HV-CATG-SOCIO
           MOVE STFSC00-INDI-DIVIDA TO HV-INDI-DIVIDA
           MOVE STFSC00-DATA-BAIXA TO HV-DATA-BAIXA
           MOVE STFSC00-HORA-BAIXA TO HV-HORA-BAIXA
           MOVE STFSC00-OBSV-CLIENTE TO HV-OBSV-SOCIO

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
                     NULLIF(:HV-DATA-BAIXA, '          '),
                     NULLIF(:HV-HORA-BAIXA, '     '),
                     :HV-OBSV-SOCIO)
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   MOVE ZEROES TO STFSC00-SQLCODE
               WHEN -803
                   MOVE 803 TO STFSC00-SQLCODE
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-SQLCODE
           END-EVALUATE
           .

       GRAVA-PERIODICO.
           IF STFSC00-SQLCODE NOT = ZEROES
               GO TO GRAVA-PERIODICO-FIM
           END-IF

           IF STFSC00-C-PERIODICO-PAGAMENTO = ZEROES
               MOVE 12 TO STFSC00-C-PERIODICO-PAGAMENTO
           END-IF

           PERFORM VARYING WS-IND-PER FROM 1 BY 1
               UNTIL WS-IND-PER > STFSC00-C-PERIODICO-PAGAMENTO
                  OR WS-IND-PER > 12
               MOVE WS-IND-PER TO HV-SEQ-PERIODICO
               MOVE STFSC00-DATA-VENCIMENTO(WS-IND-PER)
                   TO HV-DATA-VENCIMENTO
               MOVE STFSC00-VALR-MENSALIDADE(WS-IND-PER)
                   TO HV-VALR-MENSALIDADE
               MOVE STFSC00-PAGAMENTO-OK(WS-IND-PER)
                   TO HV-PAGAMENTO-OK

               EXEC SQL
                    INSERT INTO SOCIO_PERIODICO_PAGAMENTO
                        (NUMB_SOCIO_PRINCIPAL,
                         SEQ_PERIODICO,
                         DATA_VENCIMENTO,
                         VALR_MENSALIDADE,
                         PAGAMENTO_OK)
                    VALUES
                        (:HV-NUMB-SOCIO-PRINCIPAL,
                         :HV-SEQ-PERIODICO,
                         DATE(:HV-DATA-VENCIMENTO),
                         :HV-VALR-MENSALIDADE,
                         :HV-PAGAMENTO-OK)
               END-EXEC

               IF SQLCODE NOT = 0
                   MOVE SQLCODE TO STFSC00-SQLCODE
                   EXEC SQL ROLLBACK END-EXEC
                   GO TO GRAVA-PERIODICO-FIM
               END-IF
           END-PERFORM

       GRAVA-PERIODICO-FIM.
           .

       FINALIZA.
           IF STFSC00-SQLCODE = ZEROES
               EXEC SQL COMMIT END-EXEC
           ELSE
               EXEC SQL ROLLBACK END-EXEC
           END-IF
           .
