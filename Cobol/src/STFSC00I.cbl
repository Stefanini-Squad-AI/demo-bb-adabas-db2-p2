       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * Insert sócio + 12 periodic payment rows (Natural STORE path).
      * Expects mensalidades pre-filled (e.g. after CALLNAT 'VERVALOR').
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-RG                         PIC S9(9) COMP-3.
       01  WS-SEQ                        PIC S9(4) COMP.
       01  WS-DATA-CAD-D                 PIC X(10).
       01  WS-DATA-VEN-D                 PIC X(10).
       01  IND-DATA-BAIXA                PIC S9(4) COMP.
       01  IND-HORA-BAIXA                PIC S9(4) COMP.
       01  IND-SUPER1                    PIC S9(4) COMP.

       LINKAGE SECTION.
           COPY STFSC00.

       PROCEDURE DIVISION USING STFSC00-PARM.

       MAIN-PARA.
           MOVE '99' TO STFSC00-RETURN-CODE
           MOVE STFSC00-NUMB-SOCIO-PRINCIPAL TO WS-RG
           MOVE STFSC00-DATA-CADASTRO TO WS-DATA-CAD-D

           IF STFSC00-DATA-BAIXA = SPACE
               MOVE -1 TO IND-DATA-BAIXA
           ELSE
               MOVE 0 TO IND-DATA-BAIXA
           END-IF

           IF STFSC00-HORA-BAIXA = SPACE
               MOVE -1 TO IND-HORA-BAIXA
           ELSE
               MOVE 0 TO IND-HORA-BAIXA
           END-IF

           IF STFSC00-SUPER1 = SPACE
               MOVE -1 TO IND-SUPER1
           ELSE
               MOVE 0 TO IND-SUPER1
           END-IF

           EXEC SQL
               INSERT INTO TB_SOCIO (
                   SOCIO_RG,
                   SOCIO_NOME,
                   DATA_CADASTRO,
                   CATG_SOCIO,
                   INDI_DIVIDA,
                   DATA_BAIXA,
                   HORA_BAIXA,
                   OBSV_CLIENTE,
                   SUPER1
               ) VALUES (
                   :WS-RG,
                   :STFSC00-NOME-SOCIO-PRINCIPAL,
                   DATE(:WS-DATA-CAD-D),
                   :STFSC00-CATG-SOCIO,
                   :STFSC00-INDI-DIVIDA,
                   :STFSC00-DATA-BAIXA:IND-DATA-BAIXA,
                   :STFSC00-HORA-BAIXA:IND-HORA-BAIXA,
                   :STFSC00-OBSV-CLIENTE,
                   :STFSC00-SUPER1:IND-SUPER1
               )
           END-EXEC

           EVALUATE SQLCODE
               WHEN ZERO
                   CONTINUE
               WHEN -803
                   MOVE '02' TO STFSC00-RETURN-CODE
                   GO TO FIN-PARA
               WHEN OTHER
                   GO TO FIN-PARA
           END-EVALUATE

           PERFORM VARYING WS-SEQ FROM 1 BY 1 UNTIL WS-SEQ > 12
               MOVE STFSC00-DATA-VENCIMENTO(WS-SEQ) TO WS-DATA-VEN-D
               EXEC SQL
                   INSERT INTO TB_SOCIO_PAGAMENTO_PERIODICO (
                       SOCIO_RG,
                       SEQ_PERIODO,
                       DATA_VENCIMENTO,
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK
                   ) VALUES (
                       :WS-RG,
                       :WS-SEQ,
                       DATE(:WS-DATA-VEN-D),
                       :STFSC00-VALR-MENSALIDADE(WS-SEQ),
                       :STFSC00-PAGAMENTO-OK(WS-SEQ)
                   )
               END-EXEC
               IF SQLCODE NOT = ZERO
                   MOVE '99' TO STFSC00-RETURN-CODE
                   EXEC SQL ROLLBACK END-EXEC
                   GO TO FIN-PARA
               END-IF
           END-PERFORM

           EXEC SQL COMMIT END-EXEC
           MOVE '00' TO STFSC00-RETURN-CODE

       FIN-PARA.
           GOBACK
           .
