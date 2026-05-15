       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      *> Inclusão sócio + mensalidades (equivalente STORE ADABAS) — DBATDP-8
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-RC-SUCCESS               PIC 99 VALUE 00.
       01  WS-RC-DUP                   PIC 99 VALUE 02.
       01  WS-RC-SYSERR                PIC 99 VALUE 99.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-J                        PIC S9(4) COMP.
       01  HV-SEQ                      PIC S9(4) COMP.
       01  HV-NUMB                     PIC 9(9) DISPLAY.
       01  HV-NOME                     PIC X(40).
       01  HV-CATG                     PIC S9(4) COMP.
       01  HV-DCAD                     PIC X(8).
       01  HV-DBAI                     PIC X(8).
       01  HV-HBAI                     PIC X(8).
       01  HV-OBSV                     PIC X(500).
       01  HV-DVEN                     PIC X(8).
       01  HV-VALR                     PIC S9(7)V9(2) USAGE DISPLAY.
       01  HV-PAG-OK                   PIC X(1).
       LINKAGE SECTION.
           COPY BKSTFSOC.
       PROCEDURE DIVISION USING BOOK-STF-SOCIOS.
       STFSC00I-MAIN SECTION.
           MOVE WS-RC-SYSERR TO WS-RETURN-CODE
           MOVE WS-NUMB-SOCIO-PRINCIPAL TO HV-NUMB
           MOVE WS-NOME-SOCIO-PRINCIPAL TO HV-NOME
           MOVE WS-CATG-SOCIO TO HV-CATG
           MOVE WS-DATA-CADASTRO-IN TO HV-DCAD
           MOVE WS-DATA-BAIXA-IN TO HV-DBAI
           MOVE WS-HORA-BAIXA TO HV-HBAI
           MOVE WS-OBSV-SOCIO TO HV-OBSV
           EXEC SQL
               INSERT INTO SOCIOS (
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_SOCIO)
               VALUES (
                   :HV-NUMB,
                   :HV-NOME,
                   DATE(TIMESTAMP_FORMAT(:HV-DCAD, 'YYYYMMDD')),
                   :HV-CATG,
                   CASE WHEN :HV-DBAI = '        '
                        THEN NULL
                        ELSE DATE(TIMESTAMP_FORMAT(:HV-DBAI, 'YYYYMMDD'))
                   END,
                   CASE WHEN :HV-HBAI = '        '
                        THEN NULL
                        ELSE :HV-HBAI
                   END,
                   :HV-OBSV)
           END-EXEC
           EVALUATE SQLCODE
               WHEN ZERO
                   CONTINUE
               WHEN -803
                   MOVE WS-RC-DUP TO WS-RETURN-CODE
                   EXEC SQL ROLLBACK END-EXEC
                   GOBACK
               WHEN OTHER
                   MOVE WS-RC-SYSERR TO WS-RETURN-CODE
                   EXEC SQL ROLLBACK END-EXEC
                   GOBACK
           END-EVALUATE
           MOVE WS-RC-SUCCESS TO WS-RETURN-CODE
           PERFORM STFSC00I-INSERE-PAGAMENTOS
           IF WS-RETURN-CODE NOT = WS-RC-SUCCESS
               EXEC SQL ROLLBACK END-EXEC
               GOBACK
           END-IF
           EXEC SQL COMMIT END-EXEC
           MOVE WS-RC-SUCCESS TO WS-RETURN-CODE
           GOBACK
           .
       STFSC00I-INSERE-PAGAMENTOS SECTION.
           PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 12
               MOVE WS-J TO HV-SEQ
               MOVE WS-DATA-VENCIMENTO-IN (WS-J) TO HV-DVEN
               MOVE WS-VALR-MENSALIDADE (WS-J) TO HV-VALR
               MOVE WS-PAGAMENTO-OK (WS-J) TO HV-PAG-OK
               IF HV-DVEN NOT = SPACE AND HV-DVEN NOT LOW-VALUE
                   EXEC SQL
                       INSERT INTO SOCIOS_PAGAMENTOS (
                           NUMB_SOCIO_PRINCIPAL,
                           SEQ_ORDEM,
                           DATA_VENCIMENTO,
                           VALR_MENSALIDADE,
                           PAGAMENTO_OK)
                       VALUES (
                           :HV-NUMB,
                           :HV-SEQ,
                           DATE(TIMESTAMP_FORMAT(:HV-DVEN, 'YYYYMMDD')),
                           :HV-VALR,
                           :HV-PAG-OK)
                   END-EXEC
                   IF SQLCODE NOT = ZERO
                       MOVE WS-RC-SYSERR TO WS-RETURN-CODE
                       EXIT SECTION
                   END-IF
               END-IF
           END-PERFORM
           MOVE WS-RC-SUCCESS TO WS-RETURN-CODE
           EXIT SECTION
           .
