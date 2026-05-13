       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consulta sócio por RG (equivalente Natural FIND SOCIO ...).
      * Retorna cabeçalho + até 500 linhas de T_ADABAS_SOCIOS_PAGT.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY STFSCRC.
       01  WS-PROG-ID                   PIC X(08) VALUE 'STFSC00C'.

       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-HV-NUMB                   PIC S9(09) COMP-3.
       01  LS-HV-NOME                   PIC X(40).
       01  LS-HV-DATA-CAD               PIC X(10).
       01  LS-HV-CATG                   PIC S9(4) COMP.
       01  LS-HV-INDI                   PIC X(01).
       01  LS-HV-DATA-BAIXA             PIC X(10).
       01  LS-HV-HORA-BAIXA             PIC X(12).
       01  LS-HV-OBSV                   PIC X(500).
       01  LS-HV-SUPER1                 PIC X(50).
       01  LS-HV-PAG-DATA               PIC X(10).
       01  LS-HV-PAG-VALR               PIC S9(6)V9(2) COMP-3.
       01  LS-HV-PAG-OK                 PIC X(01).
       01  LS-IND-DATA-BAIXA            PIC S9(4) COMP.
       01  LS-IND-SUPER1                PIC S9(4) COMP.
       01  LS-IDX                       PIC S9(4) COMP.
           EXEC SQL DECLARE C-PAG CURSOR FOR
               SELECT CHAR(DATE(DATA_VENCIMENTO)),
                      VALR_MENSALIDADE,
                      PAGAMENTO_OK
                 FROM T_ADABAS_SOCIOS_PAGT
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-NUMB
                ORDER BY DATA_VENCIMENTO, ID_PAGAMENTO
           END-EXEC.

       LINKAGE SECTION.
       COPY STFSCBOK.

       PROCEDURE DIVISION USING STFSC-LNK-CONSULT.
       000-MAIN.
           MOVE STFSC-RC-OK TO LNK-C-RC
           MOVE ZEROES TO LNK-C-QTD-PAG
           INITIALIZE LNK-C-NOME
           MOVE SPACES TO LNK-C-DATA-CADASTRO
                           LNK-C-DATA-BAIXA
                           LNK-C-HORA-BAIXA
                           LNK-C-OBSV-SOCIO
                           LNK-C-SUPER1
           MOVE ZERO TO LNK-C-CATG-SOCIO
           MOVE SPACE TO LNK-C-INDI-DIVIDA
           PERFORM VARYING LS-IDX FROM 1 BY 1 UNTIL LS-IDX > 500
               MOVE SPACES TO LNK-C-PAG-DATA-VENC(LS-IDX)
               MOVE ZERO TO LNK-C-PAG-VALR(LS-IDX)
               MOVE SPACE TO LNK-C-PAG-OK(LS-IDX)
           END-PERFORM

           IF LNK-C-RG-NUMB NOT > ZERO
               MOVE STFSC-RC-INVALID-PARM TO LNK-C-RC
               GOBACK
           END-IF

           MOVE LNK-C-RG-NUMB TO LS-HV-NUMB

           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATE(DATA_CADASTRO)),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CHAR(DATE(DATA_BAIXA)),
                      HORA_BAIXA,
                      OBSV_SOCIO,
                      SUPER1
                 INTO :LS-HV-NOME,
                      :LS-HV-DATA-CAD,
                      :LS-HV-CATG,
                      :LS-HV-INDI,
                      :LS-HV-DATA-BAIXA:LS-IND-DATA-BAIXA,
                      :LS-HV-HORA-BAIXA,
                      :LS-HV-OBSV,
                      :LS-HV-SUPER1:LS-IND-SUPER1
                 FROM T_ADABAS_SOCIOS
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-NUMB
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   CONTINUE
               WHEN +100
                   MOVE STFSC-RC-NOT-FOUND TO LNK-C-RC
                   GOBACK
               WHEN OTHER
                   MOVE STFSC-RC-SQL-ERROR TO LNK-C-RC
                   GOBACK
           END-EVALUATE

           MOVE LS-HV-NOME TO LNK-C-NOME
           MOVE LS-HV-DATA-CAD TO LNK-C-DATA-CADASTRO
           MOVE LS-HV-CATG TO LNK-C-CATG-SOCIO
           MOVE LS-HV-INDI TO LNK-C-INDI-DIVIDA
           IF LS-IND-DATA-BAIXA < ZERO
               MOVE SPACES TO LNK-C-DATA-BAIXA
           ELSE
               MOVE LS-HV-DATA-BAIXA TO LNK-C-DATA-BAIXA
           END-IF
           MOVE LS-HV-HORA-BAIXA TO LNK-C-HORA-BAIXA
           MOVE LS-HV-OBSV TO LNK-C-OBSV-SOCIO
           IF LS-IND-SUPER1 < ZERO
               MOVE SPACES TO LNK-C-SUPER1
           ELSE
               MOVE LS-HV-SUPER1 TO LNK-C-SUPER1
           END-IF

           EXEC SQL OPEN C-PAG END-EXEC
           IF SQLCODE NOT = ZERO
               MOVE STFSC-RC-SQL-ERROR TO LNK-C-RC
               GOBACK
           END-IF

           MOVE ZERO TO LNK-C-QTD-PAG
           PERFORM UNTIL 1 = 0
               EXEC SQL FETCH C-PAG
                    INTO :LS-HV-PAG-DATA,
                         :LS-HV-PAG-VALR,
                         :LS-HV-PAG-OK
               END-EXEC
               EVALUATE SQLCODE
                   WHEN +100
                       EXIT PERFORM
                   WHEN ZERO
                       ADD 1 TO LNK-C-QTD-PAG
                       IF LNK-C-QTD-PAG > 500
                           MOVE STFSC-RC-SQL-ERROR TO LNK-C-RC
                           EXEC SQL CLOSE C-PAG END-EXEC
                           GOBACK
                       END-IF
                       MOVE LS-HV-PAG-DATA TO
                            LNK-C-PAG-DATA-VENC(LNK-C-QTD-PAG)
                       MOVE LS-HV-PAG-VALR TO
                            LNK-C-PAG-VALR(LNK-C-QTD-PAG)
                       MOVE LS-HV-PAG-OK TO
                            LNK-C-PAG-OK(LNK-C-QTD-PAG)
                   WHEN OTHER
                       MOVE STFSC-RC-SQL-ERROR TO LNK-C-RC
                       EXEC SQL CLOSE C-PAG END-EXEC
                       GOBACK
               END-EVALUATE
           END-PERFORM

           EXEC SQL CLOSE C-PAG END-EXEC
           GOBACK.
