       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consulta sócio (ex-FIND ADABAS) via DB2.
      * WORKING-STORAGE: apenas constantes / literais.
      * LOCAL-STORAGE: SQLCA, variáveis host, cursores.
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  C-RC-OK                     PIC S9(4) COMP VALUE 0.
       01  C-RC-NOTFOUND               PIC S9(4) COMP VALUE 1.
       01  C-RC-SQLERR                 PIC S9(4) COMP VALUE 9.
       01  C-RC-DATEINV                PIC S9(4) COMP VALUE 2.
       01  C-MAX-PER                   PIC S9(4) COMP VALUE 12.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  WS-HV-NUMB                  PIC S9(9) COMP-5.
       01  WS-HV-NOME                  PIC X(40).
       01  WS-HV-DATA-CAD-ISO          PIC X(10).
       01  WS-HV-CATG                  PIC S9(4) COMP-5.
       01  WS-HV-INDI                  PIC S9(4) COMP-5.
       01  WS-HV-DATA-BAI-ISO          PIC X(10).
       01  WS-HV-HORA-BAI              PIC X(12).
       01  WS-HV-OBSV                  PIC X(500).
       01  WS-IND-DB                   PIC S9(4) COMP.
       01  WS-IND-HB                   PIC S9(4) COMP.
       01  WS-PER-DATA-ISO             PIC X(10).
       01  WS-PER-VALR                 PIC S9(9)V9(2) COMP-3.
       01  WS-PER-PAGO                 PIC S9(4) COMP-5.
       01  WS-I                        PIC S9(4) COMP.
       01  WS-ISO-IN                   PIC X(10).
       01  WS-YYYYMMDD-OUT             PIC X(08).
       01  WS-YYYY                     PIC X(04).
       01  WS-MM                       PIC X(02).
       01  WS-DD                       PIC X(02).
           EXEC SQL DECLARE C_PER CURSOR FOR
             SELECT
               CHAR(DATA_VENCIMENTO, ISO),
               VALR_MENSALIDADE,
               PAGAMENTO_OK
             FROM SOCIOS_PERIODICO
             WHERE NUMB_SOCIO_PRINCIPAL = :WS-HV-NUMB
             ORDER BY PERIODICO_ID
           END-EXEC.
       LINKAGE SECTION.
           COPY SOCIOS-BOOK.
       PROCEDURE DIVISION USING SOCIO-BOOK.
       MAIN-PARA.
           MOVE C-RC-OK TO SOCIO-RETURN-CODE
           MOVE ZERO TO SOCIO-SQLCODE-DISP
           MOVE ZERO TO SOCIO-PERIODICO-CNT-OUT
           MOVE SOCIO-NUMB-PRINCIPAL TO WS-HV-NUMB
           EXEC SQL
             SELECT
               NOME_SOCIO_PRINCIPAL,
               CHAR(DATA_CADASTRO, ISO),
               CATG_SOCIO,
               INDI_DIVIDA,
               CHAR(DATA_BAIXA, ISO),
               CHAR(HORA_BAIXA),
               OBSV_SOCIO
             INTO
               :WS-HV-NOME,
               :WS-HV-DATA-CAD-ISO,
               :WS-HV-CATG,
               :WS-HV-INDI,
               :WS-HV-DATA-BAI-ISO :WS-IND-DB,
               :WS-HV-HORA-BAI :WS-IND-HB,
               :WS-HV-OBSV
             FROM SOCIOS
             WHERE NUMB_SOCIO_PRINCIPAL = :WS-HV-NUMB
           END-EXEC
           IF SQLCODE = 100
               MOVE C-RC-NOTFOUND TO SOCIO-RETURN-CODE
               MOVE SQLCODE TO SOCIO-SQLCODE-DISP
               GOBACK
           END-IF
           IF SQLCODE NOT = ZERO
               MOVE C-RC-SQLERR TO SOCIO-RETURN-CODE
               MOVE SQLCODE TO SOCIO-SQLCODE-DISP
               GOBACK
           END-IF
           MOVE WS-HV-NOME TO SOCIO-NOME-PRINCIPAL
           MOVE WS-HV-DATA-CAD-ISO TO WS-ISO-IN
           PERFORM P-ISO-TO-YYYYMMDD
           IF SOCIO-RETURN-CODE NOT = C-RC-OK
               GOBACK
           END-IF
           MOVE WS-YYYYMMDD-OUT TO SOCIO-DATA-CADASTRO
           MOVE WS-HV-CATG TO SOCIO-CATG
           MOVE WS-HV-INDI TO SOCIO-INDI-DIVIDA
           IF WS-IND-DB < ZERO
               MOVE SPACES TO SOCIO-DATA-BAIXA
           ELSE
               MOVE WS-HV-DATA-BAI-ISO TO WS-ISO-IN
               PERFORM P-ISO-TO-YYYYMMDD
               IF SOCIO-RETURN-CODE NOT = C-RC-OK
                   GOBACK
               END-IF
               MOVE WS-YYYYMMDD-OUT TO SOCIO-DATA-BAIXA
           END-IF
           IF WS-IND-HB < ZERO
               MOVE SPACES TO SOCIO-HORA-BAIXA
           ELSE
               MOVE WS-HV-HORA-BAI TO SOCIO-HORA-BAIXA
           END-IF
           MOVE WS-HV-OBSV TO SOCIO-OBSV
           PERFORM P-FETCH-PERIODICOS
           GOBACK
           .
       P-FETCH-PERIODICOS.
           EXEC SQL OPEN C_PER END-EXEC
           IF SQLCODE NOT = ZERO
               MOVE C-RC-SQLERR TO SOCIO-RETURN-CODE
               MOVE SQLCODE TO SOCIO-SQLCODE-DISP
               GOBACK
           END-IF
           MOVE 1 TO WS-I
           PERFORM UNTIL WS-I > C-MAX-PER
               EXEC SQL FETCH C_PER
                 INTO :WS-PER-DATA-ISO,
                      :WS-PER-VALR,
                      :WS-PER-PAGO
               END-EXEC
               IF SQLCODE = 100
                   EXIT PERFORM
               END-IF
               IF SQLCODE NOT = ZERO
                   MOVE C-RC-SQLERR TO SOCIO-RETURN-CODE
                   MOVE SQLCODE TO SOCIO-SQLCODE-DISP
                   EXIT PERFORM
               END-IF
               MOVE WS-PER-DATA-ISO TO WS-ISO-IN
               PERFORM P-ISO-TO-YYYYMMDD
               IF SOCIO-RETURN-CODE NOT = C-RC-OK
                   EXIT PERFORM
               END-IF
               MOVE WS-YYYYMMDD-OUT TO SOCIO-PER-DATA-VENC (WS-I)
               MOVE WS-PER-VALR TO SOCIO-PER-VALR (WS-I)
               IF WS-PER-PAGO = 1
                   MOVE 'Y' TO SOCIO-PER-PAGO-OK (WS-I)
               ELSE
                   MOVE 'N' TO SOCIO-PER-PAGO-OK (WS-I)
               END-IF
               ADD 1 TO SOCIO-PERIODICO-CNT-OUT
               ADD 1 TO WS-I
           END-PERFORM
           EXEC SQL CLOSE C_PER END-EXEC
           .
       P-ISO-TO-YYYYMMDD.
           MOVE C-RC-OK TO SOCIO-RETURN-CODE
           IF WS-ISO-IN = SPACES OR LOW-VALUES
               MOVE SPACES TO WS-YYYYMMDD-OUT
               EXIT PARAGRAPH
           END-IF
           UNSTRING WS-ISO-IN DELIMITED BY '-'
             INTO WS-YYYY WS-MM WS-DD
           END-UNSTRING
           STRING WS-YYYY WS-MM WS-DD DELIMITED BY SIZE
             INTO WS-YYYYMMDD-OUT
           END-STRING
           IF WS-YYYYMMDD-OUT NOT NUMERIC
               MOVE C-RC-DATEINV TO SOCIO-RETURN-CODE
           END-IF
           .
