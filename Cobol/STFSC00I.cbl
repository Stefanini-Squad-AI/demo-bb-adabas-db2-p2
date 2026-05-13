       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      *> Inclusão sócio + linhas de pagamento periódico (equivalente ao STORE Natural).
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-LITERALS.
           05 WS-OP-INCLUSAO                PIC X(01) VALUE 'I'.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-IX                            PIC S9(4) COMP-5.
       01  LS-DATA-BAIXA-IND                PIC S9(4) COMP-5.
       01  LS-HORA-BAIXA-IND                PIC S9(4) COMP-5.
       LINKAGE SECTION.
           COPY STFSCSOC.
       PROCEDURE DIVISION USING COMM-AREA.
       MAIN SECTION.
           IF COMM-OPERATION NOT = WS-OP-INCLUSAO
               MOVE 9 TO COMM-RETURN-CODE
               GOBACK
           END-IF
           IF COMM-DATA-BAIXA = SPACES
               MOVE -1 TO LS-DATA-BAIXA-IND
           ELSE
               MOVE 0 TO LS-DATA-BAIXA-IND
           END-IF
           IF COMM-HORA-BAIXA = SPACES
               MOVE -1 TO LS-HORA-BAIXA-IND
           ELSE
               MOVE 0 TO LS-HORA-BAIXA-IND
           END-IF
           EXEC SQL
               INSERT INTO TB_SOCIO_MEMBRO (
                       NUMB_SOCIO_PRINCIPAL,
                       NOME_SOCIO_PRINCIPAL,
                       DATA_CADASTRO,
                       CATG_SOCIO,
                       INDI_DIVIDA,
                       DATA_BAIXA,
                       HORA_BAIXA,
                       OBSV_CLIENTE,
                       SUPER1)
               VALUES (
                       :COMM-NUMB-SOCIO-PRINCIPAL,
                       :COMM-NOME-SOCIO-PRINCIPAL,
                       DATE(:COMM-DATA-CADASTRO),
                       :COMM-CATG-SOCIO,
                       :COMM-INDI-DIVIDA,
                       :COMM-DATA-BAIXA :LS-DATA-BAIXA-IND,
                       :COMM-HORA-BAIXA :LS-HORA-BAIXA-IND,
                       :COMM-OBSV-CLIENTE,
                       :COMM-SUPER1)
           END-EXEC
           IF SQLCODE NOT = 0
               MOVE 9 TO COMM-RETURN-CODE
               GOBACK
           END-IF
           PERFORM VARYING LS-IX FROM 1 BY 1 UNTIL LS-IX > 12
               EXEC SQL
                   INSERT INTO TB_SOCIO_PAGAMENTO_PERIODICO (
                           NUMB_SOCIO_PRINCIPAL,
                           DATA_VENCIMENTO,
                           VALR_MENSALIDADE,
                           PAGAMENTO_OK)
                   VALUES (
                           :COMM-NUMB-SOCIO-PRINCIPAL,
                           DATE(:COMM-DATA-VENCIMENTO(LS-IX)),
                           :COMM-VALR-MENSALIDADE(LS-IX),
                           :COMM-PAGAMENTO-OK(LS-IX))
               END-EXEC
               IF SQLCODE NOT = 0
                   MOVE 9 TO COMM-RETURN-CODE
                   GOBACK
               END-IF
           END-PERFORM
           MOVE 0 TO COMM-RETURN-CODE
           GOBACK
           .
