       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * STFSC00I - Inclusão de sócio (DBATDP-18)
      * Natural > COBOL > DB2
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA            PIC X(08) VALUE 'STFSC00I'.
       01  WS-CONST-VERSAO              PIC X(04) VALUE 'P2  '.
       01  WS-CONST-OPER-INCLUSAO       PIC X(01) VALUE 'I'.
       01  WS-MSG-ERRO-GENERICO         PIC X(72)
           VALUE 'ERRO DB2 NA INCLUSAO DE SOCIO.'.
       01  WS-TRUE-CHAR                 PIC X(01) VALUE 'Y'.
       01  WS-FALSE-CHAR                PIC X(01) VALUE 'N'.
      *
       LOCAL-STORAGE SECTION.
       01  LS-SQLCA                     SQLCA.
       01  LS-STFSC00-AREA.
           COPY STFSC00B.
       01  LS-HV-NUMB-SOCIO             PIC S9(09) COMP-3.
       01  LS-HV-NOME                   PIC X(40).
       01  LS-HV-DATA-CAD               PIC X(10).
       01  LS-HV-CATG                   PIC S9(04) COMP-3.
       01  LS-HV-INDI-DIVIDA            PIC X(01).
       01  LS-HV-DATA-BAIXA             PIC X(10).
       01  LS-HV-HORA-BAIXA             PIC X(12).
       01  LS-HV-OBSV                   PIC X(500).
       01  LS-HV-SEQ-PE                 PIC S9(09) COMP-3.
       01  LS-HV-DATA-VENC               PIC X(10).
       01  LS-HV-VALR-MENS               PIC S9(06)V9(02) COMP-3.
       01  LS-HV-PAGAMENTO-OK           PIC X(01).
       01  LS-IDX-PE                    PIC S9(04) COMP.
       01  LS-SQLCODE-AUX               PIC S9(09) COMP.
       01  LS-DATA-CAD-DATE             PIC X(10).
       01  LS-DATA-BAIXA-DATE           PIC X(10).
       01  LS-DATA-VENC-DATE            PIC X(10).
      *
       LINKAGE SECTION.
       01  LNK-STFSC00-AREA.
           COPY STFSC00B.
      *
       PROCEDURE DIVISION USING LNK-STFSC00-AREA.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
      *
       INICIALIZA.
           MOVE LNK-STFSC00-AREA TO LS-STFSC00-AREA
           MOVE WS-CONST-OPER-INCLUSAO TO STFSC00-OPERACAO
           MOVE ZERO TO STFSC00-RETURN-CODE
           .
      *
       PROCESSA.
           IF NOT STFSC00-OP-INCLUSAO
               MOVE +9999 TO STFSC00-RETURN-CODE
               GO TO PROCESSA-EXIT
           END-IF
           PERFORM INSERT-PRINCIPAL
           IF STFSC00-RC-OK
               PERFORM INSERT-PERIODICO
           END-IF
           .
       PROCESSA-EXIT.
           EXIT.
      *
       INSERT-PRINCIPAL.
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL TO LS-HV-NUMB-SOCIO
           MOVE STFSC00-NOME-SOCIO-PRINCIPAL TO LS-HV-NOME
           MOVE STFSC00-DATA-CADASTRO TO LS-DATA-CAD-DATE
           MOVE STFSC00-CATG-SOCIO TO LS-HV-CATG
           IF STFSC00-DIVIDA-SIM
               MOVE WS-TRUE-CHAR TO LS-HV-INDI-DIVIDA
           ELSE
               MOVE WS-FALSE-CHAR TO LS-HV-INDI-DIVIDA
           END-IF
           MOVE STFSC00-DATA-BAIXA TO LS-DATA-BAIXA-DATE
           MOVE STFSC00-HORA-BAIXA TO LS-HV-HORA-BAIXA
           MOVE STFSC00-OBSV-SOCIO TO LS-HV-OBSV
           EXEC SQL
               INSERT INTO TB_SOCIO (
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   INDI_DIVIDA,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_SOCIO)
               VALUES (
                   :LS-HV-NUMB-SOCIO,
                   :LS-HV-NOME,
                   DATE(:LS-DATA-CAD-DATE),
                   :LS-HV-CATG,
                   :LS-HV-INDI-DIVIDA,
                   CASE WHEN TRIM(:LS-DATA-BAIXA-DATE) = SPACES
                        THEN NULL
                        ELSE DATE(:LS-DATA-BAIXA-DATE)
                   END,
                   :LS-HV-HORA-BAIXA,
                   :LS-HV-OBSV)
           END-EXEC
           PERFORM MAPEIA-SQLCODE
           .
      *
       INSERT-PERIODICO.
           PERFORM VARYING LS-IDX-PE FROM 1 BY 1
               UNTIL LS-IDX-PE > 12
               IF STFSC00-DATA-VENCIMENTO(LS-IDX-PE) NOT = SPACES
                   MOVE STFSC00-NUMB-SOCIO-PRINCIPAL
                       TO LS-HV-NUMB-SOCIO
                   MOVE LS-IDX-PE TO LS-HV-SEQ-PE
                   MOVE STFSC00-DATA-VENCIMENTO(LS-IDX-PE)
                       TO LS-DATA-VENC-DATE
                   MOVE STFSC00-VALR-MENSALIDADE(LS-IDX-PE)
                       TO LS-HV-VALR-MENS
                   IF STFSC00-PGTO-SIM(LS-IDX-PE)
                       MOVE WS-TRUE-CHAR TO LS-HV-PAGAMENTO-OK
                   ELSE
                       MOVE WS-FALSE-CHAR TO LS-HV-PAGAMENTO-OK
                   END-IF
                   EXEC SQL
                       INSERT INTO TB_SOCIO_PERIODICO_PAGAMENTO (
                           NUMB_SOCIO_PRINCIPAL,
                           SEQ_PERIODICO,
                           DATA_VENCIMENTO,
                           VALR_MENSALIDADE,
                           PAGAMENTO_OK)
                       VALUES (
                           :LS-HV-NUMB-SOCIO,
                           :LS-HV-SEQ-PE,
                           DATE(:LS-DATA-VENC-DATE),
                           :LS-HV-VALR-MENS,
                           :LS-HV-PAGAMENTO-OK)
                   END-EXEC
                   IF SQLCODE NOT = 0
                       PERFORM MAPEIA-SQLCODE
                       GO TO INSERT-PERIODICO-EXIT
                   END-IF
               END-IF
           END-PERFORM
           .
       INSERT-PERIODICO-EXIT.
           EXIT.
      *
       MAPEIA-SQLCODE.
           MOVE SQLCODE TO LS-SQLCODE-AUX
           EVALUATE LS-SQLCODE-AUX
               WHEN 0
                   MOVE +0 TO STFSC00-RETURN-CODE
               WHEN -803
                   MOVE +803 TO STFSC00-RETURN-CODE
               WHEN OTHER
                   IF LS-SQLCODE-AUX < 0
                       COMPUTE STFSC00-RETURN-CODE =
                           LS-SQLCODE-AUX * -1
                   ELSE
                       MOVE LS-SQLCODE-AUX TO STFSC00-RETURN-CODE
                   END-IF
           END-EVALUATE
           .
      *
       FINALIZA.
           MOVE LS-STFSC00-AREA TO LNK-STFSC00-AREA
           .
