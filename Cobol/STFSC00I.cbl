       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      *>
      *> Purpose: Insert new member data into SOCIOS tables (DB2)
      *> Operation: I (Inclusion - STORE)
      *> Source: ADABAS-SOCIOS via DB2 migration
      *> ================================================================
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      *> Constants and literals
       01  WS-DB2-MSG-SUCCESS     PIC X(30) VALUE
           'RECORD INSERTED'.
       01  WS-DB2-MSG-DUPLICATE   PIC X(30) VALUE
           'DUPLICATE KEY ERROR'.
       01  WS-DB2-MSG-ERROR       PIC X(30) VALUE
           'DATABASE ERROR'.

      *> DB2 Return codes
       01  WS-SQLCODE             PIC S9(9) COMP VALUE 0.
       01  WS-RC-SUCCESS          PIC S9(4) COMP VALUE 0.
       01  WS-RC-DUPLICATE        PIC S9(4) COMP VALUE 803.
       01  WS-RC-ERROR            PIC S9(4) COMP VALUE -1.

       LOCAL-STORAGE SECTION.
      *> SQLCA for DB2 operations
           EXEC SQL
               INCLUDE SQLCA
           END-EXEC.

      *> Include communication book
           COPY SOCIO-LKSP.

      *> DB2 Host variables
       01  LS-DB2-SOCIOS.
           05  LS-NUMB-SOCIO      PIC 9(9) COMP VALUE 0.
           05  LS-NOME-SOCIO      PIC X(40) VALUE SPACES.
           05  LS-DATA-CADASTRO   PIC X(10) VALUE SPACES.
           05  LS-CATG-SOCIO      PIC S9(4) COMP VALUE 0.
           05  LS-INDI-DIVIDA     PIC X(1) VALUE '0'.
           05  LS-DATA-BAIXA      PIC X(10) VALUE SPACES.
           05  LS-HORA-BAIXA      PIC X(8) VALUE SPACES.
           05  LS-OBSV-SOCIO      PIC X(500) VALUE SPACES.

       01  LS-DB2-PAGAMENTO.
           05  LS-SEQ-PAGAMENTO   PIC S9(4) COMP VALUE 0.
           05  LS-DATA-VENC       PIC X(10) VALUE SPACES.
           05  LS-VALR-MENSA      PIC S9(4)V9(2) COMP-3 VALUE 0.
           05  LS-PAG-OK          PIC X(1) VALUE '0'.

      *> Working variables
       01  LS-INDICE              PIC S9(4) COMP VALUE 0.
       01  LS-ERRO-FLAG           PIC X(1) VALUE 'N'.

       LINKAGE SECTION.
       01  LK-SOCIO-LKSP.
           COPY SOCIO-LKSP.

       PROCEDURE DIVISION USING LK-SOCIO-LKSP.
           PERFORM INICIALIZA.
           PERFORM PROCESSA.
           PERFORM FINALIZA.
           STOP RUN.

       INICIALIZA.
           MOVE LK-SOCIO-LKSP TO SOCIO-LKSP.
           MOVE SO-NUMB-SOCIO-PRINCIPAL TO LS-NUMB-SOCIO.
           MOVE SO-NOME-SOCIO-PRINCIPAL TO LS-NOME-SOCIO.
           MOVE SO-DATA-CADASTRO TO LS-DATA-CADASTRO.
           MOVE SO-CATG-SOCIO TO LS-CATG-SOCIO.
           MOVE SO-INDI-DIVIDA TO LS-INDI-DIVIDA.
           MOVE SO-DATA-BAIXA TO LS-DATA-BAIXA.
           MOVE SO-HORA-BAIXA TO LS-HORA-BAIXA.
           MOVE SO-OBSV-SOCIO TO LS-OBSV-SOCIO.
           MOVE 'N' TO LS-ERRO-FLAG.
           MOVE ZERO TO LS-INDICE.

       PROCESSA.
      *> Insert main record into SOCIOS
           EXEC SQL
               INSERT INTO SOCIOS
               (NUMB_SOCIO_PRINCIPAL, NOME_SOCIO_PRINCIPAL,
                DATA_CADASTRO, CATG_SOCIO, INDI_DIVIDA,
                DATA_BAIXA, HORA_BAIXA, OBSV_SOCIO)
               VALUES (:LS-NUMB-SOCIO, :LS-NOME-SOCIO,
                       :LS-DATA-CADASTRO, :LS-CATG-SOCIO,
                       :LS-INDI-DIVIDA, :LS-DATA-BAIXA,
                       :LS-HORA-BAIXA, :LS-OBSV-SOCIO)
           END-EXEC.

           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-RC-SUCCESS TO SO-RETURN-CODE
                   PERFORM INSERT-PAYMENTS

               WHEN -803
                   MOVE WS-RC-DUPLICATE TO SO-RETURN-CODE
                   MOVE WS-DB2-MSG-DUPLICATE TO SO-MSG-ERROR
                   MOVE 'Y' TO LS-ERRO-FLAG

               WHEN OTHER
                   MOVE WS-RC-ERROR TO SO-RETURN-CODE
                   MOVE WS-DB2-MSG-ERROR TO SO-MSG-ERROR
                   MOVE 'Y' TO LS-ERRO-FLAG
           END-EVALUATE.

       INSERT-PAYMENTS.
           IF LS-ERRO-FLAG = 'Y'
               EXIT PARAGRAPH
           END-IF.

           PERFORM VARYING LS-INDICE FROM 1 BY 1
               UNTIL LS-INDICE > 12 OR LS-ERRO-FLAG = 'Y'

               MOVE SO-DATA-VENCIMENTO(LS-INDICE) TO LS-DATA-VENC
               MOVE SO-VALR-MENSALIDADE(LS-INDICE) TO LS-VALR-MENSA
               MOVE SO-PAGAMENTO-OK(LS-INDICE) TO LS-PAG-OK

               IF LS-DATA-VENC NOT = SPACES
                   EXEC SQL
                       INSERT INTO SOCIOS_PAGAMENTO
                       (NUMB_SOCIO_PRINCIPAL, SEQ_PAGAMENTO,
                        DATA_VENCIMENTO, VALR_MENSALIDADE,
                        PAGAMENTO_OK)
                       VALUES (:LS-NUMB-SOCIO, :LS-INDICE,
                               :LS-DATA-VENC, :LS-VALR-MENSA,
                               :LS-PAG-OK)
                   END-EXEC

                   IF SQLCODE NOT = 0
                       MOVE WS-RC-ERROR TO SO-RETURN-CODE
                       MOVE WS-DB2-MSG-ERROR TO SO-MSG-ERROR
                       MOVE 'Y' TO LS-ERRO-FLAG
                   END-IF
               END-IF
           END-PERFORM.

       FINALIZA.
           MOVE SOCIO-LKSP TO LK-SOCIO-LKSP.
