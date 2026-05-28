       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      *> Consulta sócio (equivalente FIND ADABAS) — DBATDP-8
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-RC-SUCCESS               PIC 99 VALUE 00.
       01  WS-RC-NOTFOUND              PIC 99 VALUE 01.
       01  WS-RC-SYSERR                PIC 99 VALUE 99.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-I                        PIC S9(4) COMP.
       01  WS-J                        PIC S9(4) COMP.
       01  HV-NUMB                     PIC 9(9) DISPLAY.
       01  HV-NOME                     PIC X(40).
       01  HV-CATG                     PIC S9(4) COMP.
       01  HV-DATA-CAD                 PIC X(8).
       01  HV-DATA-BAIXA               PIC X(8).
       01  HV-HORA-BAIXA               PIC X(8).
       01  HV-OBSV                     PIC X(500).
       01  HV-DATA-VEN                 PIC X(8).
       01  HV-VALR                     PIC S9(7)V9(2) USAGE DISPLAY.
       01  HV-PAG-OK                   PIC X(1).
           EXEC SQL
               DECLARE C1 CURSOR FOR
               SELECT VARCHAR_FORMAT(DATA_VENCIMENTO, 'YYYYMMDD'),
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
               FROM SOCIOS_PAGAMENTOS
               WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB
               ORDER BY SEQ_ORDEM
           END-EXEC.
       LINKAGE SECTION.
           COPY BKSTFSOC.
       PROCEDURE DIVISION USING BOOK-STF-SOCIOS.
       STFSC00C-MAIN SECTION.
           MOVE WS-RC-SYSERR TO WS-RETURN-CODE
           MOVE WS-NUMB-SOCIO-PRINCIPAL TO HV-NUMB
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      VARCHAR_FORMAT(DATA_CADASTRO, 'YYYYMMDD'),
                      CATG_SOCIO,
                      COALESCE(VARCHAR_FORMAT(DATA_BAIXA, 'YYYYMMDD'), ''),
                      COALESCE(RTRIM(HORA_BAIXA), ''),
                      OBSV_SOCIO
               INTO :HV-NOME,
                    :HV-DATA-CAD,
                    :HV-CATG,
                    :HV-DATA-BAIXA,
                    :HV-HORA-BAIXA,
                    :HV-OBSV
               FROM SOCIOS
               WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB
           END-EXEC
           EVALUATE SQLCODE
               WHEN +100
                   MOVE WS-RC-NOTFOUND TO WS-RETURN-CODE
                   GOBACK
               WHEN ZERO
                   CONTINUE
               WHEN OTHER
                   MOVE WS-RC-SYSERR TO WS-RETURN-CODE
                   GOBACK
           END-EVALUATE
           MOVE HV-NOME TO WS-NOME-SOCIO-PRINCIPAL
           MOVE HV-DATA-CAD TO WS-DATA-CADASTRO-IN
           MOVE HV-CATG TO WS-CATG-SOCIO
           MOVE HV-DATA-BAIXA TO WS-DATA-BAIXA-IN
           MOVE HV-HORA-BAIXA TO WS-HORA-BAIXA
           MOVE HV-OBSV TO WS-OBSV-SOCIO
           PERFORM STFSC00C-CARREGA-PAGAMENTOS
           IF WS-RETURN-CODE NOT = WS-RC-SUCCESS
               GOBACK
           END-IF
           MOVE WS-RC-SUCCESS TO WS-RETURN-CODE
           GOBACK
           .
       STFSC00C-CARREGA-PAGAMENTOS SECTION.
           PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 12
               MOVE SPACE TO WS-DATA-VENCIMENTO-IN (WS-J)
               MOVE ZERO TO WS-VALR-MENSALIDADE (WS-J)
               MOVE 'N' TO WS-PAGAMENTO-OK (WS-J)
           END-PERFORM
           EXEC SQL OPEN C1 END-EXEC
           IF SQLCODE NOT = ZERO
               MOVE WS-RC-SYSERR TO WS-RETURN-CODE
               EXIT SECTION
           END-IF
           MOVE ZERO TO WS-I
           PERFORM UNTIL SQLCODE NOT = ZERO OR WS-I >= 12
               EXEC SQL FETCH C1
                   INTO :HV-DATA-VEN,
                        :HV-VALR,
                        :HV-PAG-OK
               END-EXEC
               IF SQLCODE = ZERO
                   ADD 1 TO WS-I
                   MOVE HV-DATA-VEN TO WS-DATA-VENCIMENTO-IN (WS-I)
                   MOVE HV-VALR TO WS-VALR-MENSALIDADE (WS-I)
                   MOVE HV-PAG-OK TO WS-PAGAMENTO-OK (WS-I)
               END-IF
           END-PERFORM
           EXEC SQL CLOSE C1 END-EXEC
           MOVE WS-RC-SUCCESS TO WS-RETURN-CODE
           EXIT SECTION
           .
