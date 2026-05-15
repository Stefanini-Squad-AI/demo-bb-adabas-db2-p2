       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * INCLUSAO SOCIO + 12 PARCELAS (DB2) — DBATDP-9                 *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       78  RC-OK                    VALUE 00.
       78  RC-SQL-ERROR             VALUE 90.

       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-IND-DATA-BAIXA        PIC S9(4) COMP.
       01  LS-IND-HORA-BAIXA        PIC S9(4) COMP.
       01  LS-I                     PIC S9(4) COMP.
       01  LS-HV-DATA-VENC          PIC X(10).
       01  LS-HV-VALR               PIC S9(4)V9(2) COMP-3.
       01  LS-HV-PAG-OK             PIC X(01).
       01  LS-TIME-FULL             PIC X(08).

       LINKAGE SECTION.
           COPY STFSC00BK.

       PROCEDURE DIVISION USING STFSC00-COMM-AREA.
       MAIN-PARA.
           MOVE RC-OK               TO STFSC00-RETURN-CODE
           MOVE ZERO                TO STFSC00-SQLCODE-DSP
           MOVE SPACES              TO STFSC00-SQLSTATE
           IF STFSC00-DATA-BAIXA EQUAL SPACES
               MOVE -1              TO LS-IND-DATA-BAIXA
           ELSE
               MOVE ZERO            TO LS-IND-DATA-BAIXA
           END-IF
           IF STFSC00-HORA-BAIXA EQUAL SPACES
               MOVE -1              TO LS-IND-HORA-BAIXA
           ELSE
               MOVE ZERO            TO LS-IND-HORA-BAIXA
               PERFORM BUILD-TIME-HOST
           END-IF
           EXEC SQL
               INSERT INTO SOCIO (
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   INDI_DIVIDA,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_CLIENTE,
                   SUPER1)
               VALUES (
                   :STFSC00-NUMB-SOCIO-PRINCIPAL,
                   :STFSC00-NOME-SOCIO-PRINCIPAL,
                   DATE(:STFSC00-DATA-CADASTRO),
                   :STFSC00-CATG-SOCIO,
                   :STFSC00-INDI-DIVIDA,
                   DATE(:STFSC00-DATA-BAIXA) :LS-IND-DATA-BAIXA,
                   TIME(:LS-TIME-FULL) :LS-IND-HORA-BAIXA,
                   :STFSC00-OBSV-CLIENTE,
                   :STFSC00-SUPER1)
           END-EXEC
           IF SQLCODE NOT EQUAL ZERO
               PERFORM P999-SQL-ERROR
               EXEC SQL ROLLBACK END-EXEC
               GOBACK
           END-IF
           PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I GREATER 12
               MOVE STFSC00-DATA-VENCIMENTO(LS-I) TO LS-HV-DATA-VENC
               MOVE STFSC00-VALR-MENSALIDADE(LS-I) TO LS-HV-VALR
               MOVE STFSC00-PAGAMENTO-OK(LS-I) TO LS-HV-PAG-OK
               EXEC SQL
                   INSERT INTO SOCIO_PAGAMENTO (
                       NUMB_SOCIO_PRINCIPAL,
                       NUM_PARCELA,
                       DATA_VENCIMENTO,
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK)
                   VALUES (
                       :STFSC00-NUMB-SOCIO-PRINCIPAL,
                       :LS-I,
                       DATE(:LS-HV-DATA-VENC),
                       :LS-HV-VALR,
                       :LS-HV-PAG-OK)
               END-EXEC
               IF SQLCODE NOT EQUAL ZERO
                   PERFORM P999-SQL-ERROR
                   EXEC SQL ROLLBACK END-EXEC
                   GOBACK
               END-IF
           END-PERFORM
           EXEC SQL COMMIT END-EXEC
           GOBACK
           .

       BUILD-TIME-HOST.
      *    HH:MM (entrada) -> HH.MM.SS para TIME(:host)
           STRING STFSC00-HORA-BAIXA(1:2) DELIMITED BY SIZE
                  '.' DELIMITED BY SIZE
                  STFSC00-HORA-BAIXA(4:2) DELIMITED BY SIZE
                  '.00' DELIMITED BY SIZE
             INTO LS-TIME-FULL
           .

       P999-SQL-ERROR.
           MOVE RC-SQL-ERROR          TO STFSC00-RETURN-CODE
           MOVE SQLCODE               TO STFSC00-SQLCODE-DSP
           MOVE SQLSTATE              TO STFSC00-SQLSTATE
           .
