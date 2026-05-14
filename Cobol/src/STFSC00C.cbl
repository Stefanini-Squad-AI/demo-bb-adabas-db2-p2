       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * Consult sócio by RG (Natural FIND SOCIO equivalent read path).
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-RG                         PIC S9(9) COMP-3.
       01  WS-NOME                       PIC X(40).
       01  WS-DATA-CAD                   PIC X(10).
       01  WS-CATG                       PIC S9(4) COMP.
       01  WS-INDI-DIV                   PIC S9(4) COMP.
       01  WS-DATA-BAIXA                 PIC X(10).
       01  WS-HORA-BAIXA                 PIC X(12).
       01  WS-OBSV                       PIC X(500).
       01  WS-SUPER1                     PIC X(80).
       01  WS-SEQ                        PIC S9(4) COMP.
       01  WS-DATA-VEN                   PIC X(10).
       01  WS-VALR                       PIC S9(5)V9(2) COMP-3.
       01  WS-PAG-OK                     PIC X(01).

       LINKAGE SECTION.
           COPY STFSC00.

       PROCEDURE DIVISION USING STFSC00-PARM.

       MAIN-PARA.
           MOVE '99' TO STFSC00-RETURN-CODE
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL TO WS-RG

           EXEC SQL
               SELECT SOCIO_NOME,
                      CHAR(DATE(DATA_CADASTRO), ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      COALESCE(CHAR(DATE(DATA_BAIXA), ISO), ''),
                      COALESCE(HORA_BAIXA, ''),
                      OBSV_CLIENTE,
                      COALESCE(SUPER1, '')
                 INTO :WS-NOME,
                      :WS-DATA-CAD,
                      :WS-CATG,
                      :WS-INDI-DIV,
                      :WS-DATA-BAIXA,
                      :WS-HORA-BAIXA,
                      :WS-OBSV,
                      :WS-SUPER1
                 FROM TB_SOCIO
                WHERE SOCIO_RG = :WS-RG
           END-EXEC

           EVALUATE SQLCODE
               WHEN 100
                   MOVE '01' TO STFSC00-RETURN-CODE
                   GO TO FIN-PARA
               WHEN ZERO
                   CONTINUE
               WHEN OTHER
                   GO TO FIN-PARA
           END-EVALUATE

           MOVE WS-NOME TO STFSC00-NOME-SOCIO-PRINCIPAL
           MOVE WS-DATA-CAD TO STFSC00-DATA-CADASTRO
           MOVE WS-CATG TO STFSC00-CATG-SOCIO
           MOVE WS-INDI-DIV TO STFSC00-INDI-DIVIDA
           MOVE WS-DATA-BAIXA TO STFSC00-DATA-BAIXA
           MOVE WS-HORA-BAIXA TO STFSC00-HORA-BAIXA
           MOVE WS-OBSV TO STFSC00-OBSV-CLIENTE
           MOVE WS-SUPER1 TO STFSC00-SUPER1

           PERFORM VARYING WS-SEQ FROM 1 BY 1 UNTIL WS-SEQ > 12
               INITIALIZE WS-DATA-VEN WS-VALR WS-PAG-OK
               EXEC SQL
                   SELECT CHAR(DATE(DATA_VENCIMENTO), ISO),
                          VALR_MENSALIDADE,
                          PAGAMENTO_OK
                     INTO :WS-DATA-VEN,
                          :WS-VALR,
                          :WS-PAG-OK
                     FROM TB_SOCIO_PAGAMENTO_PERIODICO
                    WHERE SOCIO_RG = :WS-RG
                      AND SEQ_PERIODO = :WS-SEQ
               END-EXEC
               IF SQLCODE = ZERO
                   MOVE WS-DATA-VEN TO STFSC00-DATA-VENCIMENTO(WS-SEQ)
                   MOVE WS-VALR TO STFSC00-VALR-MENSALIDADE(WS-SEQ)
                   MOVE WS-PAG-OK TO STFSC00-PAGAMENTO-OK(WS-SEQ)
               ELSE
                   MOVE SPACE TO STFSC00-DATA-VENCIMENTO(WS-SEQ)
                   MOVE ZERO TO STFSC00-VALR-MENSALIDADE(WS-SEQ)
                   MOVE 'N' TO STFSC00-PAGAMENTO-OK(WS-SEQ)
               END-IF
           END-PERFORM

           MOVE '00' TO STFSC00-RETURN-CODE

       FIN-PARA.
           GOBACK
           .
