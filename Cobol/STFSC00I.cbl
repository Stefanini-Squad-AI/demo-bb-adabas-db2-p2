       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Inclusão sócio (ex-STORE ADABAS) via DB2.
      * Valida datas AAAAMMDD antes de INSERT (AC5 / HU-QA-003).
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  C-RC-OK                     PIC S9(4) COMP VALUE 0.
       01  C-RC-DATEINV                PIC S9(4) COMP VALUE 2.
       01  C-RC-SQLERR                 PIC S9(4) COMP VALUE 9.
       01  C-RC-DUPKEY                 PIC S9(4) COMP VALUE 97.
       01  C-RC-FK                     PIC S9(4) COMP VALUE 96.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-HV-NUMB                  PIC S9(9) COMP-5.
       01  WS-HV-NOME                  PIC X(40).
       01  WS-HV-OBSV                  PIC X(500).
       01  WS-HV-CATG                  PIC S9(4) COMP-5.
       01  WS-HV-INDI                  PIC S9(4) COMP-5.
       01  WS-HV-DATA-CAD              PIC X(10).
       01  WS-HV-DATA-BAI              PIC X(10).
       01  WS-HV-HORA-BAI              PIC X(12).
       01  WS-IND-DB                   PIC S9(4) COMP VALUE 0.
       01  WS-IND-HB                   PIC S9(4) COMP VALUE 0.
       01  WS-IND-DC                   PIC S9(4) COMP VALUE 0.
       01  WS-PER-DATA                 PIC X(10).
       01  WS-PER-VALR                 PIC S9(9)V9(2) COMP-3.
       01  WS-PER-PAGO                 PIC S9(4) COMP-5.
       01  WS-I                        PIC S9(4) COMP.
       01  WS-ISO-10                   PIC X(10).
       01  WS-YYYY                     PIC 9(4).
       01  WS-MM                       PIC 99.
       01  WS-DD                       PIC 99.
       01  WS-D8                       PIC X(08).
       01  WS-D8-NUM                   REDEFINES WS-D8 PIC 9(08).
       LINKAGE SECTION.
           COPY SOCIOS-BOOK.
       PROCEDURE DIVISION USING SOCIO-BOOK.
       MAIN-PARA.
           MOVE C-RC-OK TO SOCIO-RETURN-CODE
           MOVE ZERO TO SOCIO-SQLCODE-DISP
           MOVE SOCIO-DATA-CADASTRO TO WS-D8
           PERFORM P-VALIDA-YYYYMMDD
           IF SOCIO-RETURN-CODE NOT = C-RC-OK
               GOBACK
           END-IF
      *    Conversão AAAAMMDD -> literal DATE 'YYYY-MM-DD' (AC5: máscara 9(4)-9(2)-9(2))
           MOVE WS-YYYY TO WS-ISO-10(1:4)
           MOVE '-' TO WS-ISO-10(5:1)
           MOVE WS-MM TO WS-ISO-10(6:2)
           MOVE '-' TO WS-ISO-10(8:1)
           MOVE WS-DD TO WS-ISO-10(9:2)
           MOVE WS-ISO-10 TO WS-HV-DATA-CAD
           MOVE SOCIO-NUMB-PRINCIPAL TO WS-HV-NUMB
           MOVE SOCIO-NOME-PRINCIPAL TO WS-HV-NOME
           MOVE SOCIO-OBSV TO WS-HV-OBSV
           MOVE SOCIO-CATG TO WS-HV-CATG
           MOVE SOCIO-INDI-DIVIDA TO WS-HV-INDI
           MOVE ZERO TO WS-IND-DB WS-IND-HB
           IF SOCIO-DATA-BAIXA > SPACES
               MOVE SOCIO-DATA-BAIXA TO WS-D8
               PERFORM P-VALIDA-YYYYMMDD
               IF SOCIO-RETURN-CODE NOT = C-RC-OK
                   GOBACK
               END-IF
               MOVE WS-YYYY TO WS-ISO-10(1:4)
               MOVE '-' TO WS-ISO-10(5:1)
               MOVE WS-MM TO WS-ISO-10(6:2)
               MOVE '-' TO WS-ISO-10(8:1)
               MOVE WS-DD TO WS-ISO-10(9:2)
               MOVE WS-ISO-10 TO WS-HV-DATA-BAI
           ELSE
               MOVE -1 TO WS-IND-DB
           END-IF
           IF SOCIO-HORA-BAIXA > SPACES
               MOVE SOCIO-HORA-BAIXA TO WS-HV-HORA-BAI
           ELSE
               MOVE -1 TO WS-IND-HB
           END-IF
           EXEC SQL
             INSERT INTO SOCIOS (
               NUMB_SOCIO_PRINCIPAL,
               NOME_SOCIO_PRINCIPAL,
               DATA_CADASTRO,
               CATG_SOCIO,
               DATA_BAIXA,
               HORA_BAIXA,
               OBSV_SOCIO,
               INDI_DIVIDA
             ) VALUES (
               :WS-HV-NUMB,
               :WS-HV-NOME,
               DATE(:WS-HV-DATA-CAD),
               :WS-HV-CATG,
               :WS-HV-DATA-BAI :WS-IND-DB,
               TIME(:WS-HV-HORA-BAI) :WS-IND-HB,
               :WS-HV-OBSV,
               :WS-HV-INDI
             )
           END-EXEC
           IF SQLCODE = -803
               MOVE C-RC-DUPKEY TO SOCIO-RETURN-CODE
               MOVE SQLCODE TO SOCIO-SQLCODE-DISP
               GOBACK
           END-IF
           IF SQLCODE NOT = ZERO
               MOVE C-RC-SQLERR TO SOCIO-RETURN-CODE
               MOVE SQLCODE TO SOCIO-SQLCODE-DISP
               GOBACK
           END-IF
           PERFORM P-INSERT-PERIODICOS
           GOBACK
           .
       P-VALIDA-YYYYMMDD.
           MOVE C-RC-OK TO SOCIO-RETURN-CODE
           IF WS-D8 = SPACES OR LOW-VALUES
               MOVE C-RC-DATEINV TO SOCIO-RETURN-CODE
               EXIT PARAGRAPH
           END-IF
           IF WS-D8 NOT NUMERIC
               MOVE C-RC-DATEINV TO SOCIO-RETURN-CODE
               EXIT PARAGRAPH
           END-IF
           IF WS-D8-NUM = ZERO
               MOVE C-RC-DATEINV TO SOCIO-RETURN-CODE
               EXIT PARAGRAPH
           END-IF
           MOVE WS-D8(1:4) TO WS-YYYY
           MOVE WS-D8(5:2) TO WS-MM
           MOVE WS-D8(7:2) TO WS-DD
           IF WS-MM < 1 OR WS-MM > 12
               MOVE C-RC-DATEINV TO SOCIO-RETURN-CODE
               EXIT PARAGRAPH
           END-IF
           IF WS-DD < 1 OR WS-DD > 31
               MOVE C-RC-DATEINV TO SOCIO-RETURN-CODE
               EXIT PARAGRAPH
           END-IF
           .
       P-INSERT-PERIODICOS.
           MOVE 1 TO WS-I
           PERFORM UNTIL WS-I > SOCIO-PERIODICO-CNT-IN
               IF SOCIO-PER-DATA-VENC (WS-I) NOT = SPACES
                   MOVE SOCIO-PER-DATA-VENC (WS-I) TO WS-D8
                   PERFORM P-VALIDA-YYYYMMDD
                   IF SOCIO-RETURN-CODE NOT = C-RC-OK
                       EXIT PARAGRAPH
                   END-IF
                   MOVE WS-YYYY TO WS-ISO-10(1:4)
                   MOVE '-' TO WS-ISO-10(5:1)
                   MOVE WS-MM TO WS-ISO-10(6:2)
                   MOVE '-' TO WS-ISO-10(8:1)
                   MOVE WS-DD TO WS-ISO-10(9:2)
                   MOVE WS-ISO-10 TO WS-PER-DATA
                   MOVE SOCIO-PER-VALR (WS-I) TO WS-PER-VALR
                   IF SOCIO-PER-PAGO-OK (WS-I) = 'Y'
                       MOVE 1 TO WS-PER-PAGO
                   ELSE
                       MOVE 0 TO WS-PER-PAGO
                   END-IF
                   EXEC SQL
                     INSERT INTO SOCIOS_PERIODICO (
                       NUMB_SOCIO_PRINCIPAL,
                       DATA_VENCIMENTO,
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK
                     ) VALUES (
                       :WS-HV-NUMB,
                       DATE(:WS-PER-DATA),
                       :WS-PER-VALR,
                       :WS-PER-PAGO
                     )
                   END-EXEC
                   IF SQLCODE NOT = ZERO
                       IF SQLCODE = -530
                           MOVE C-RC-FK TO SOCIO-RETURN-CODE
                       ELSE
                           MOVE C-RC-SQLERR TO SOCIO-RETURN-CODE
                       END-IF
                       MOVE SQLCODE TO SOCIO-SQLCODE-DISP
                       EXIT PARAGRAPH
                   END-IF
               END-IF
               ADD 1 TO WS-I
           END-PERFORM
           .
