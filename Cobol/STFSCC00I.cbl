       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSCC00I.
      *> DBATDP-1: Insert sócio + periodic payment rows (normalized).
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-RC-OK                        PIC X(02) VALUE 'OK'.
       01  WS-RC-DU                        PIC X(02) VALUE 'DU'.
       01  WS-RC-ER                        PIC X(02) VALUE 'ER'.
       01  WS-IDX                          PIC 9(02) VALUE ZERO.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA           END-EXEC.
       01  LS-HV-RG                        PIC S9(9) COMP-3.
       01  LS-HV-NOME                      PIC X(40).
       01  LS-HV-DATA-CAD                  PIC X(10).
       01  LS-HV-CATG                      PIC S9(4) COMP.
       01  LS-HV-INDI                      PIC X(01).
       01  LS-HV-DATA-BAIXA                 PIC X(10).
       01  LS-HV-HORA-BAIXA                 PIC X(12).
       01  LS-HV-OBSV                      PIC X(500).
       01  LS-HV-SUPER1                    PIC X(20).
       01  LS-IND-DATA-BAIXA               PIC S9(4) COMP.
       01  LS-IND-HORA-BAIXA               PIC S9(4) COMP.
       01  LS-IND-SUPER1                   PIC S9(4) COMP.
       01  LS-HV-PAG-DATA                  PIC X(10).
       01  LS-HV-PAG-VALR                  PIC S9(4)V9(2) COMP-3.
       01  LS-HV-PAG-OK                    PIC X(01).
       01  LS-HV-SEQ                       PIC S9(4) COMP.
       LINKAGE SECTION.
           COPY STFSCCSOC.
       PROCEDURE DIVISION USING SOCIO-COMMAREA.
       MAIN-PARA.
           MOVE SPACES TO SOCIO-CN-RC
           PERFORM MAP-LINKAGE-TO-HOSTS
           PERFORM INSERT-PARENT
           IF SOCIO-CN-RC NOT = SPACES
               GOBACK
           END-IF
           PERFORM INSERT-CHILDREN
           IF SOCIO-CN-RC NOT = SPACES
               GOBACK
           END-IF
           MOVE WS-RC-OK TO SOCIO-CN-RC
           GOBACK
           .
       MAP-LINKAGE-TO-HOSTS.
           MOVE SOCIO-CN-RG-NUM TO LS-HV-RG
           MOVE SOCIO-CN-NOME TO LS-HV-NOME
           MOVE SOCIO-CN-DATA-CADASTRO TO LS-HV-DATA-CAD
           MOVE SOCIO-CN-CATG TO LS-HV-CATG
           MOVE SOCIO-CN-INDI-DIVIDA TO LS-HV-INDI
           MOVE SOCIO-CN-DATA-BAIXA TO LS-HV-DATA-BAIXA
           MOVE SOCIO-CN-HORA-BAIXA TO LS-HV-HORA-BAIXA
           MOVE SOCIO-CN-OBSV TO LS-HV-OBSV
           MOVE SOCIO-CN-SUPER1 TO LS-HV-SUPER1
           IF LS-HV-DATA-BAIXA = SPACES
               MOVE -1 TO LS-IND-DATA-BAIXA
           ELSE
               MOVE ZERO TO LS-IND-DATA-BAIXA
           END-IF
           IF LS-HV-HORA-BAIXA = SPACES
               MOVE -1 TO LS-IND-HORA-BAIXA
           ELSE
               MOVE ZERO TO LS-IND-HORA-BAIXA
           END-IF
           IF LS-HV-SUPER1 = SPACES
               MOVE -1 TO LS-IND-SUPER1
           ELSE
               MOVE ZERO TO LS-IND-SUPER1
           END-IF
           .
       INSERT-PARENT.
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
                   SUPER1
               ) VALUES (
                   :LS-HV-RG,
                   :LS-HV-NOME,
                   DATE(:LS-HV-DATA-CAD),
                   :LS-HV-CATG,
                   :LS-HV-INDI,
                   :LS-HV-DATA-BAIXA:LS-IND-DATA-BAIXA,
                   :LS-HV-HORA-BAIXA:LS-IND-HORA-BAIXA,
                   :LS-HV-OBSV,
                   :LS-HV-SUPER1:LS-IND-SUPER1
               )
           END-EXEC
           EVALUATE SQLCODE
               WHEN ZERO
                   CONTINUE
               WHEN -803
                   MOVE WS-RC-DU TO SOCIO-CN-RC
               WHEN OTHER
                   MOVE WS-RC-ER TO SOCIO-CN-RC
           END-EVALUATE
           .
       INSERT-CHILDREN.
           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 12
               MOVE WS-IDX TO LS-HV-SEQ
               MOVE SOCIO-CN-PAG-DATA-VENC(WS-IDX) TO LS-HV-PAG-DATA
               MOVE SOCIO-CN-PAG-VALR(WS-IDX) TO LS-HV-PAG-VALR
               MOVE SOCIO-CN-PAG-OK(WS-IDX) TO LS-HV-PAG-OK
               EXEC SQL
                   INSERT INTO SOCIO_PAGAMENTO (
                       NUMB_SOCIO_PRINCIPAL,
                       SEQ_MENSALIDADE,
                       DATA_VENCIMENTO,
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK
                   ) VALUES (
                       :LS-HV-RG,
                       :LS-HV-SEQ,
                       DATE(:LS-HV-PAG-DATA),
                       :LS-HV-PAG-VALR,
                       :LS-HV-PAG-OK
                   )
               END-EXEC
               IF SQLCODE NOT = ZERO
                   EXEC SQL
                       DELETE FROM SOCIO
                        WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-RG
                   END-EXEC
                   MOVE WS-RC-ER TO SOCIO-CN-RC
                   EXIT PARAGRAPH
               END-IF
           END-PERFORM
           .
