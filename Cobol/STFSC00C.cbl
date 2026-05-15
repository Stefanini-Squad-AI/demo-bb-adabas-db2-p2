       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * CONSULTA SOCIO + 12 PARCELAS (DB2) — DBATDP-9                  *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       78  RC-OK                    VALUE 00.
       78  RC-NOT-FOUND             VALUE 01.
       78  RC-SQL-ERROR             VALUE 90.

       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-IND-DATA-BAIXA        PIC S9(4) COMP.
       01  LS-IND-HORA-BAIXA        PIC S9(4) COMP.
       01  LS-I                     PIC S9(4) COMP.
       01  LS-HV-DATA-VENC          PIC X(10).
       01  LS-HV-VALR               PIC S9(4)V9(2) COMP-3.
       01  LS-HV-PAG-OK             PIC X(01).
       01  LS-HORA-FULL             PIC X(08).

       LINKAGE SECTION.
           COPY STFSC00BK.

       PROCEDURE DIVISION USING STFSC00-COMM-AREA.
       MAIN-PARA.
           MOVE RC-OK               TO STFSC00-RETURN-CODE
           MOVE ZERO                TO STFSC00-SQLCODE-DSP
           MOVE SPACES              TO STFSC00-SQLSTATE
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATE(DATA_CADASTRO)),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CHAR(DATE(DATA_BAIXA)),
                      CHAR(HORA_BAIXA),
                      OBSV_CLIENTE,
                      SUPER1
                 INTO :STFSC00-NOME-SOCIO-PRINCIPAL,
                      :STFSC00-DATA-CADASTRO,
                      :STFSC00-CATG-SOCIO,
                      :STFSC00-INDI-DIVIDA,
                      :STFSC00-DATA-BAIXA      :LS-IND-DATA-BAIXA,
                      :LS-HORA-FULL             :LS-IND-HORA-BAIXA,
                      :STFSC00-OBSV-CLIENTE,
                      :STFSC00-SUPER1
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL =
                      :STFSC00-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
             WHEN 0
               IF LS-IND-DATA-BAIXA LESS THAN ZERO
                 MOVE SPACES          TO STFSC00-DATA-BAIXA
               END-IF
               IF LS-IND-HORA-BAIXA LESS THAN ZERO
                 MOVE SPACES          TO STFSC00-HORA-BAIXA
               ELSE
                 PERFORM FORMAT-HORA-BAIXA
               END-IF
               PERFORM FETCH-PAGAMENTOS
             WHEN 100
               MOVE RC-NOT-FOUND      TO STFSC00-RETURN-CODE
             WHEN OTHER
               PERFORM P999-SQL-ERROR
           END-EVALUATE
           GOBACK
           .

       FORMAT-HORA-BAIXA.
      *    CHAR(TIME) tipico 'HH.MM.SS' -> HH:MM (5 posicoes)
           IF LS-HORA-FULL NOT EQUAL SPACES
               STRING LS-HORA-FULL(1:2) DELIMITED BY SIZE
                      ':' DELIMITED BY SIZE
                      LS-HORA-FULL(4:2) DELIMITED BY SIZE
                 INTO STFSC00-HORA-BAIXA
           END-IF
           .

       FETCH-PAGAMENTOS.
           PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I GREATER 12
               EXEC SQL
                   SELECT CHAR(DATE(DATA_VENCIMENTO)),
                          VALR_MENSALIDADE,
                          PAGAMENTO_OK
                     INTO :LS-HV-DATA-VENC,
                          :LS-HV-VALR,
                          :LS-HV-PAG-OK
                     FROM SOCIO_PAGAMENTO
                    WHERE NUMB_SOCIO_PRINCIPAL =
                          :STFSC00-NUMB-SOCIO-PRINCIPAL
                      AND NUM_PARCELA = :LS-I
               END-EXEC
               EVALUATE SQLCODE
                 WHEN 0
                   MOVE LS-HV-DATA-VENC TO STFSC00-DATA-VENCIMENTO(LS-I)
                   MOVE LS-HV-VALR TO STFSC00-VALR-MENSALIDADE(LS-I)
                   MOVE LS-HV-PAG-OK TO STFSC00-PAGAMENTO-OK(LS-I)
                 WHEN 100
                   MOVE SPACES TO STFSC00-DATA-VENCIMENTO(LS-I)
                   MOVE ZERO   TO STFSC00-VALR-MENSALIDADE(LS-I)
                   MOVE 'N'    TO STFSC00-PAGAMENTO-OK(LS-I)
                 WHEN OTHER
                   PERFORM P999-SQL-ERROR
                   GOBACK
               END-EVALUATE
           END-PERFORM
           .

       P999-SQL-ERROR.
           MOVE RC-SQL-ERROR          TO STFSC00-RETURN-CODE
           MOVE SQLCODE               TO STFSC00-SQLCODE-DSP
           MOVE SQLSTATE              TO STFSC00-SQLSTATE
           .
