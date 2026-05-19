       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Inclusao SOCIO + SOCIO_PAGAMENTO (operacao STORE Natural)
      * Return codes: 000=ok, 803=chave duplicada, outros=erro generico
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA            PIC X(08) VALUE 'STFSC00I'.
       01  WS-CONST-RET-OK              PIC S9(04) COMP VALUE +0.
       01  WS-CONST-RET-DUP             PIC S9(04) COMP VALUE +803.
       01  WS-CONST-RET-ERR             PIC S9(04) COMP VALUE +999.
       01  WS-IDX-GRAVACAO              PIC 9(04) VALUE ZEROES.

       LOCAL-STORAGE SECTION.
           COPY SQLCA.
       01  LS-HOST-VARS.
           05  HV-NUMB-SOCIO-PRINCIPAL    PIC 9(09).
           05  HV-NOME-SOCIO-PRINCIPAL    PIC X(40).
           05  HV-DATA-CADASTRO           PIC X(10).
           05  HV-CATG-SOCIO              PIC 9(02).
           05  HV-INDI-DIVIDA             PIC X(01).
           05  HV-DATA-BAIXA               PIC X(10).
           05  HV-HORA-BAIXA              PIC X(05).
           05  HV-OBSV-SOCIO              PIC X(500).
           05  HV-DATA-VENCIMENTO         PIC X(10).
           05  HV-VALR-MENSALIDADE        PIC S9(06)V9(02) COMP-3.
           05  HV-PAGAMENTO-OK            PIC X(01).

       LINKAGE SECTION.
           COPY STFSSOCIO.

       PROCEDURE DIVISION USING STFSSOCIO-LNK.

           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA

           STOP RUN.

       INICIALIZA SECTION.
       INICIALIZA-INICIO.
           MOVE WS-CONST-RET-OK TO WS-RETORNO
           .
       INICIALIZA-FIM.
           EXIT.

       PROCESSA SECTION.
       PROCESSA-INICIO.
           PERFORM PROCESSA-CARREGA-HOST
           PERFORM PROCESSA-INSERT-SOCIO
           IF WS-RETORNO NOT = WS-CONST-RET-OK
               GO TO PROCESSA-FIM
           END-IF
           PERFORM PROCESSA-INSERT-PAGAMENTOS
           .
       PROCESSA-FIM.
           EXIT.

       PROCESSA-CARREGA-HOST.
           MOVE WS-NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO-PRINCIPAL
           MOVE WS-NOME-SOCIO-PRINCIPAL TO HV-NOME-SOCIO-PRINCIPAL
           MOVE WS-DATA-CADASTRO TO HV-DATA-CADASTRO
           MOVE WS-CATG-SOCIO TO HV-CATG-SOCIO
           MOVE WS-INDI-DIVIDA TO HV-INDI-DIVIDA
           IF WS-DATA-BAIXA = SPACES
               MOVE SPACES TO HV-DATA-BAIXA
           ELSE
               MOVE WS-DATA-BAIXA TO HV-DATA-BAIXA
           END-IF
           IF WS-HORA-BAIXA = SPACES
               MOVE SPACES TO HV-HORA-BAIXA
           ELSE
               MOVE WS-HORA-BAIXA TO HV-HORA-BAIXA
           END-IF
           MOVE WS-OBSV-SOCIO TO HV-OBSV-SOCIO
           .

       PROCESSA-INSERT-SOCIO.
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
                   :HV-NUMB-SOCIO-PRINCIPAL,
                   :HV-NOME-SOCIO-PRINCIPAL,
                   DATE(:HV-DATA-CADASTRO),
                   :HV-CATG-SOCIO,
                   :HV-INDI-DIVIDA,
                   CASE WHEN TRIM(:HV-DATA-BAIXA) = ''
                        THEN NULL
                        ELSE DATE(:HV-DATA-BAIXA)
                   END,
                   CASE WHEN TRIM(:HV-HORA-BAIXA) = ''
                        THEN NULL
                        ELSE :HV-HORA-BAIXA
                   END,
                   :HV-OBSV-SOCIO
               )
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-CONST-RET-OK TO WS-RETORNO
               WHEN -803
                   MOVE WS-CONST-RET-DUP TO WS-RETORNO
               WHEN OTHER
                   MOVE WS-CONST-RET-ERR TO WS-RETORNO
           END-EVALUATE
           .

       PROCESSA-INSERT-PAGAMENTOS.
           IF WS-QTD-PAGAMENTO = ZEROES
               MOVE 12 TO WS-QTD-PAGAMENTO
           END-IF

           PERFORM VARYING WS-IDX-GRAVACAO FROM 1 BY 1
               UNTIL WS-IDX-GRAVACAO > WS-QTD-PAGAMENTO
                  OR WS-IDX-GRAVACAO > 12
               MOVE WS-IDX-GRAVACAO TO WS-IDX-PAG
               MOVE WS-DATA-VENCIMENTO (WS-IDX-PAG)
                 TO HV-DATA-VENCIMENTO
               MOVE WS-VALR-MENSALIDADE (WS-IDX-PAG)
                 TO HV-VALR-MENSALIDADE
               MOVE WS-PAGAMENTO-OK (WS-IDX-PAG)
                 TO HV-PAGAMENTO-OK

               EXEC SQL
                   INSERT INTO SOCIO_PAGAMENTO (
                       NUMB_SOCIO_PRINCIPAL,
                       DATA_VENCIMENTO,
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK
                   ) VALUES (
                       :HV-NUMB-SOCIO-PRINCIPAL,
                       DATE(:HV-DATA-VENCIMENTO),
                       :HV-VALR-MENSALIDADE,
                       :HV-PAGAMENTO-OK
                   )
               END-EXEC

               IF SQLCODE NOT = 0
                   MOVE WS-CONST-RET-ERR TO WS-RETORNO
                   EXIT PERFORM
               END-IF
           END-PERFORM
           .

       FINALIZA SECTION.
       FINALIZA-INICIO.
           .
       FINALIZA-FIM.
           EXIT.
