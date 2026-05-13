       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Inclusão de sócio + linhas de pagamento (Natural STORE).
      * Datas em DB2 como DATE a partir de strings AAAA-MM-DD.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY STFSCRC.
       01  WS-PROG-ID                   PIC X(08) VALUE 'STFSC00I'.

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

       LINKAGE SECTION.
       COPY STFSCBOI.

       PROCEDURE DIVISION USING STFSC-LNK-INSERT.
       000-MAIN.
           MOVE STFSC-RC-OK TO LNK-I-RC

           IF LNK-I-RG-NUMB NOT > ZERO
               MOVE STFSC-RC-INVALID-PARM TO LNK-I-RC
               GOBACK
           END-IF
           IF LNK-I-QTD-PAG < 1 OR LNK-I-QTD-PAG > 120
               MOVE STFSC-RC-INVALID-PARM TO LNK-I-RC
               GOBACK
           END-IF

           MOVE LNK-I-RG-NUMB TO LS-HV-NUMB
           MOVE LNK-I-NOME TO LS-HV-NOME
           MOVE LNK-I-DATA-CADASTRO TO LS-HV-DATA-CAD
           MOVE LNK-I-CATG-SOCIO TO LS-HV-CATG
           MOVE LNK-I-INDI-DIVIDA TO LS-HV-INDI
           MOVE LNK-I-HORA-BAIXA TO LS-HV-HORA-BAIXA
           MOVE LNK-I-OBSV-SOCIO TO LS-HV-OBSV
           MOVE LNK-I-SUPER1 TO LS-HV-SUPER1

           IF LNK-I-DATA-BAIXA = SPACES OR LOW-VALUE
               MOVE -1 TO LS-IND-DATA-BAIXA
           ELSE
               MOVE LNK-I-DATA-BAIXA TO LS-HV-DATA-BAIXA
               MOVE ZERO TO LS-IND-DATA-BAIXA
           END-IF

           IF LNK-I-SUPER1 = SPACES OR LOW-VALUE
               MOVE -1 TO LS-IND-SUPER1
           ELSE
               MOVE ZERO TO LS-IND-SUPER1
           END-IF

           EXEC SQL
               INSERT INTO T_ADABAS_SOCIOS (
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   INDI_DIVIDA,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_SOCIO,
                   SUPER1
               ) VALUES (
                   :LS-HV-NUMB,
                   :LS-HV-NOME,
                   DATE(:LS-HV-DATA-CAD),
                   :LS-HV-CATG,
                   :LS-HV-INDI,
                   :LS-HV-DATA-BAIXA:LS-IND-DATA-BAIXA,
                   :LS-HV-HORA-BAIXA,
                   :LS-HV-OBSV,
                   :LS-HV-SUPER1:LS-IND-SUPER1
               )
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   CONTINUE
               WHEN -803
                   MOVE STFSC-RC-DUP-RG TO LNK-I-RC
                   GOBACK
               WHEN OTHER
                   MOVE STFSC-RC-SQL-ERROR TO LNK-I-RC
                   GOBACK
           END-EVALUATE

           PERFORM VARYING LS-IDX FROM 1 BY 1
               UNTIL LS-IDX > LNK-I-QTD-PAG
               MOVE LNK-I-PAG-DATA-VENC(LS-IDX) TO LS-HV-PAG-DATA
               MOVE LNK-I-PAG-VALR(LS-IDX) TO LS-HV-PAG-VALR
               MOVE LNK-I-PAG-OK(LS-IDX) TO LS-HV-PAG-OK
               EXEC SQL
                   INSERT INTO T_ADABAS_SOCIOS_PAGT (
                       NUMB_SOCIO_PRINCIPAL,
                       DATA_VENCIMENTO,
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK
                   ) VALUES (
                       :LS-HV-NUMB,
                       DATE(:LS-HV-PAG-DATA),
                       :LS-HV-PAG-VALR,
                       :LS-HV-PAG-OK
                   )
               END-EXEC
               IF SQLCODE NOT = ZERO
                   MOVE STFSC-RC-SQL-ERROR TO LNK-I-RC
                   EXEC SQL ROLLBACK END-EXEC
                   GOBACK
               END-IF
           END-PERFORM

           EXEC SQL COMMIT END-EXEC
           GOBACK.
