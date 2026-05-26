       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      *>
      *> Purpose: Consult member data from SOCIOS tables (DB2)
      *> Operation: C (Consultation - FIND)
      *> Source: ADABAS-SOCIOS via DB2 migration
      *> ================================================================
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
      *> Constants and literals
       01  WS-DB2-MSG-NOTFOUND    PIC X(30) VALUE
           'RECORD NOT FOUND'.
       01  WS-DB2-MSG-SUCCESS     PIC X(30) VALUE
           'OPERATION SUCCESSFUL'.
       01  WS-DB2-MSG-ERROR       PIC X(30) VALUE
           'DATABASE ERROR'.

      *> DB2 Return codes
       01  WS-SQLCODE             PIC S9(9) COMP VALUE 0.
       01  WS-RC-SUCCESS          PIC S9(4) COMP VALUE 0.
       01  WS-RC-NOTFOUND         PIC S9(4) COMP VALUE 100.
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

      *> Cursor for payment records
           EXEC SQL
               DECLARE CURS-PAGAMENTO CURSOR FOR
                   SELECT SEQ_PAGAMENTO, DATA_VENCIMENTO,
                          VALR_MENSALIDADE, PAGAMENTO_OK
                   FROM SOCIOS_PAGAMENTO
                   WHERE NUMB_SOCIO_PRINCIPAL = :LS-NUMB-SOCIO
                   ORDER BY SEQ_PAGAMENTO
           END-EXEC.

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
           MOVE 'N' TO LS-ERRO-FLAG.
           MOVE ZERO TO LS-INDICE.

       PROCESSA.
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL, DATA_CADASTRO,
                      CATG_SOCIO, INDI_DIVIDA, DATA_BAIXA,
                      HORA_BAIXA, OBSV_SOCIO
               INTO :LS-NOME-SOCIO, :LS-DATA-CADASTRO,
                    :LS-CATG-SOCIO, :LS-INDI-DIVIDA, :LS-DATA-BAIXA,
                    :LS-HORA-BAIXA, :LS-OBSV-SOCIO
               FROM SOCIOS
               WHERE NUMB_SOCIO_PRINCIPAL = :LS-NUMB-SOCIO
           END-EXEC.

           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-RC-SUCCESS TO SO-RETURN-CODE
                   MOVE LS-NOME-SOCIO TO SO-NOME-SOCIO-PRINCIPAL
                   MOVE LS-DATA-CADASTRO TO SO-DATA-CADASTRO
                   MOVE LS-CATG-SOCIO TO SO-CATG-SOCIO
                   MOVE LS-INDI-DIVIDA TO SO-INDI-DIVIDA
                   MOVE LS-DATA-BAIXA TO SO-DATA-BAIXA
                   MOVE LS-HORA-BAIXA TO SO-HORA-BAIXA
                   MOVE LS-OBSV-SOCIO TO SO-OBSV-SOCIO

                   PERFORM LOAD-PAYMENTS

               WHEN 100
                   MOVE WS-RC-NOTFOUND TO SO-RETURN-CODE
                   MOVE WS-DB2-MSG-NOTFOUND TO SO-MSG-ERROR
                   MOVE 'Y' TO LS-ERRO-FLAG

               WHEN OTHER
                   MOVE WS-RC-ERROR TO SO-RETURN-CODE
                   MOVE WS-DB2-MSG-ERROR TO SO-MSG-ERROR
                   MOVE 'Y' TO LS-ERRO-FLAG
           END-EVALUATE.

       LOAD-PAYMENTS.
           EXEC SQL
               OPEN CURS-PAGAMENTO
           END-EXEC.

           MOVE 1 TO LS-INDICE.
           PERFORM UNTIL LS-INDICE > 12 OR SQLCODE NOT = 0
               EXEC SQL
                   FETCH CURS-PAGAMENTO
                   INTO :LS-SEQ-PAGAMENTO, :LS-DATA-VENC,
                        :LS-VALR-MENSA, :LS-PAG-OK
               END-EXEC

               IF SQLCODE = 0
                   MOVE LS-DATA-VENC TO
                       SO-DATA-VENCIMENTO(LS-INDICE)
                   MOVE LS-VALR-MENSA TO
                       SO-VALR-MENSALIDADE(LS-INDICE)
                   MOVE LS-PAG-OK TO
                       SO-PAGAMENTO-OK(LS-INDICE)
               END-IF

               ADD 1 TO LS-INDICE
           END-PERFORM.

           EXEC SQL
               CLOSE CURS-PAGAMENTO
           END-EXEC.

       FINALIZA.
           MOVE SOCIO-LKSP TO LK-SOCIO-LKSP.
