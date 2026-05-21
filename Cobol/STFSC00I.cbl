       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * STFSC00I - Inclusao socio (STORE) via DB2
      * DBATDP-18 - Migracao ADABAS-SOCIOS
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA            PIC X(08) VALUE 'STFSC00I'.
       01  WS-CONST-OPERACAO            PIC X(01) VALUE 'I'.
       01  WS-CONST-RC-OK               PIC S9(09) VALUE +0.
       01  WS-CONST-RC-DUPKEY           PIC S9(09) VALUE +803.
       01  WS-CONST-MSG-OK              PIC X(72)
           VALUE 'Registro incluido com sucesso.'.
       01  WS-CONST-MSG-DUPKEY          PIC X(72)
           VALUE 'Chave duplicada - socio ja cadastrado.'.
       01  WS-CONST-MSG-ERRO            PIC X(72)
           VALUE 'Erro na inclusao DB2.'.
       01  WS-CONST-SIM                 PIC X(01) VALUE 'Y'.
       01  WS-CONST-NAO                 PIC X(01) VALUE 'N'.
       01  WS-MAX-PAGAMENTO             PIC 9(03) VALUE 12.
       01  WS-IDX-PAGAMENTO             PIC 9(03).
       01  WS-EDIT-DATA                 PIC X(10).
       01  WS-MASK-DATA                 PIC X(10) VALUE 'YYYY-MM-DD'.
      *
       EXEC SQL INCLUDE SQLCA END-EXEC.
      *
       LOCAL-STORAGE SECTION.
       COPY STFSC00B.
      *
       01  HV-NUMB-SOCIO                PIC S9(09)V9(00) COMP-3.
       01  HV-NOME-SOCIO                PIC X(40).
       01  HV-DATA-CADASTRO             PIC X(10).
       01  HV-CATG-SOCIO                PIC S9(04) COMP.
       01  HV-INDI-DIVIDA               PIC X(01).
       01  HV-DATA-BAIXA                PIC X(10).
       01  HV-HORA-BAIXA                PIC X(05).
       01  HV-OBSV-SOCIO                PIC X(500).
       01  HV-NUL-DATA-BAIXA            PIC S9(04) COMP VALUE -1.
       01  HV-NUL-HORA-BAIXA            PIC S9(04) COMP VALUE -1.
       01  HV-NUL-OBSV-SOCIO            PIC S9(04) COMP VALUE 0.
      *
       01  HV-PAG-NUM                   PIC S9(04) COMP.
       01  HV-PAG-DATA-VENC             PIC X(10).
       01  HV-PAG-VALR                  PIC S9(04)V9(02) COMP-3.
       01  HV-PAG-OK                    PIC X(01).
      *
       LINKAGE SECTION.
       01  LK-STFSC00-AREA              PIC X(4096).
      *
       PROCEDURE DIVISION USING LK-STFSC00-AREA.
           SET ADDRESS OF STFSC00-AREA TO LK-STFSC00-AREA
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           STOP RUN.
      *
       INICIALIZA.
           MOVE ZEROS TO STFSC00-SQLCODE
           MOVE SPACES TO STFSC00-SQLSTATE STFSC00-MSG
           .
      *
       PROCESSA.
           PERFORM INCLUI-SOCIO
           IF STFSC00-SQLCODE = WS-CONST-RC-OK
               PERFORM INCLUI-SOC-PAGAMENTOS
           END-IF
           .
      *
       FINALIZA.
           .
      *
       INCLUI-SOCIO.
           MOVE NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO
           MOVE NOME-SOCIO-PRINCIPAL TO HV-NOME-SOCIO
           MOVE CATG-SOCIO TO HV-CATG-SOCIO
           PERFORM CONVERTE-INDI-DIVIDA
           MOVE OBSV-CLIENTE TO HV-OBSV-SOCIO
           PERFORM CONVERTE-DATA-CADASTRO
           PERFORM CONVERTE-DATA-BAIXA
           PERFORM CONVERTE-HORA-BAIXA
           EXEC SQL
               INSERT INTO SOCIO (
                   NUMB_SOCIO_PRINCIPAL,
                   NOME_SOCIO_PRINCIPAL,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   INDI_DIVIDA,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_SOCIO)
               VALUES (
                   :HV-NUMB-SOCIO,
                   :HV-NOME-SOCIO,
                   DATE(:HV-DATA-CADASTRO),
                   :HV-CATG-SOCIO,
                   :HV-INDI-DIVIDA,
                   :HV-DATA-BAIXA:HV-NUL-DATA-BAIXA,
                   :HV-HORA-BAIXA:HV-NUL-HORA-BAIXA,
                   :HV-OBSV-SOCIO:HV-NUL-OBSV-SOCIO)
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-CONST-RC-OK TO STFSC00-SQLCODE
                   MOVE SQLSTATE TO STFSC00-SQLSTATE
                   MOVE WS-CONST-MSG-OK TO STFSC00-MSG
               WHEN -803
                   MOVE WS-CONST-RC-DUPKEY TO STFSC00-SQLCODE
                   MOVE SQLSTATE TO STFSC00-SQLSTATE
                   MOVE WS-CONST-MSG-DUPKEY TO STFSC00-MSG
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-SQLCODE
                   MOVE SQLSTATE TO STFSC00-SQLSTATE
                   MOVE WS-CONST-MSG-ERRO TO STFSC00-MSG
           END-EVALUATE
           .
      *
       CONVERTE-INDI-DIVIDA.
           EVALUATE INDI-DIVIDA
               WHEN WS-CONST-SIM
               WHEN '1'
                   MOVE WS-CONST-SIM TO HV-INDI-DIVIDA
               WHEN OTHER
                   MOVE WS-CONST-NAO TO HV-INDI-DIVIDA
           END-EVALUATE
           .
      *
       CONVERTE-DATA-CADASTRO.
           MOVE SPACES TO WS-EDIT-DATA
           IF DATA-CADASTRO NOT = SPACES
               MOVE DATA-CADASTRO TO WS-EDIT-DATA
               INSPECT WS-EDIT-DATA REPLACING ALL '/' BY '-'
               MOVE WS-EDIT-DATA TO HV-DATA-CADASTRO
           ELSE
               MOVE SPACES TO HV-DATA-CADASTRO
           END-IF
           .
      *
       CONVERTE-DATA-BAIXA.
           IF DATA-BAIXA = SPACES
               MOVE -1 TO HV-NUL-DATA-BAIXA
               MOVE SPACES TO HV-DATA-BAIXA
           ELSE
               MOVE 0 TO HV-NUL-DATA-BAIXA
               MOVE DATA-BAIXA TO WS-EDIT-DATA
               INSPECT WS-EDIT-DATA REPLACING ALL '/' BY '-'
               MOVE WS-EDIT-DATA TO HV-DATA-BAIXA
           END-IF
           .
      *
       CONVERTE-HORA-BAIXA.
           IF HORA-BAIXA = SPACES
               MOVE -1 TO HV-NUL-HORA-BAIXA
               MOVE SPACES TO HV-HORA-BAIXA
           ELSE
               MOVE 0 TO HV-NUL-HORA-BAIXA
               MOVE HORA-BAIXA(1:5) TO HV-HORA-BAIXA
           END-IF
           .
      *
       INCLUI-SOC-PAGAMENTOS.
           PERFORM VARYING WS-IDX-PAGAMENTO FROM 1 BY 1
               UNTIL WS-IDX-PAGAMENTO > WS-MAX-PAGAMENTO
               PERFORM INCLUI-SOC-PAG-ITEM
               IF STFSC00-SQLCODE NOT = WS-CONST-RC-OK
                   GO TO INCLUI-SOC-PAG-FIM
               END-IF
           END-PERFORM
           .
       INCLUI-SOC-PAG-FIM.
           EXIT.
      *
       INCLUI-SOC-PAG-ITEM.
           MOVE WS-IDX-PAGAMENTO TO HV-PAG-NUM
           MOVE NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO
           MOVE DATA-VENCIMENTO(WS-IDX-PAGAMENTO) TO WS-EDIT-DATA
           INSPECT WS-EDIT-DATA REPLACING ALL '/' BY '-'
           MOVE WS-EDIT-DATA TO HV-PAG-DATA-VENC
           MOVE VALR-MENSALIDADE(WS-IDX-PAGAMENTO) TO HV-PAG-VALR
           EVALUATE PAGAMENTO-OK(WS-IDX-PAGAMENTO)
               WHEN WS-CONST-SIM
               WHEN '1'
               WHEN 'T'
                   MOVE WS-CONST-SIM TO HV-PAG-OK
               WHEN OTHER
                   MOVE WS-CONST-NAO TO HV-PAG-OK
           END-EVALUATE
           EXEC SQL
               INSERT INTO SOCIO_PAGAMENTO (
                   NUMB_SOCIO_PRINCIPAL,
                   NUM_PAGAMENTO,
                   DATA_VENCIMENTO,
                   VALR_MENSALIDADE,
                   PAGAMENTO_OK)
               VALUES (
                   :HV-NUMB-SOCIO,
                   :HV-PAG-NUM,
                   DATE(:HV-PAG-DATA-VENC),
                   :HV-PAG-VALR,
                   :HV-PAG-OK)
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE WS-CONST-RC-OK TO STFSC00-SQLCODE
                   MOVE SQLSTATE TO STFSC00-SQLSTATE
               WHEN -803
                   MOVE WS-CONST-RC-DUPKEY TO STFSC00-SQLCODE
                   MOVE SQLSTATE TO STFSC00-SQLSTATE
                   MOVE WS-CONST-MSG-DUPKEY TO STFSC00-MSG
               WHEN OTHER
                   MOVE SQLCODE TO STFSC00-SQLCODE
                   MOVE SQLSTATE TO STFSC00-SQLSTATE
                   MOVE WS-CONST-MSG-ERRO TO STFSC00-MSG
           END-EVALUATE
           .
      *
