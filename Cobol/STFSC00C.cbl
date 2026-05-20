       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
       AUTHOR. STEFANINI-MIGRACAO-ADABAS-DB2.
       DATE-WRITTEN. 2026-05-20.
      ******************************************************************
      * Consulta socio por RG (NUMB-SOCIO-PRINCIPAL) em TB_SOCIO
      * Substitui FIND no Adabas - retorno +000 localizado / +100 nao
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONST-PROGRAMA               PIC X(08) VALUE 'STFSC00C'.
       01  WS-CONST-ACAO-VALIDA            PIC X(01) VALUE 'C'.
       01  WS-CONST-MSG-ACAO-INVALIDA      PIC X(40)
           VALUE 'ACAO INVALIDA PARA STFSC00C'.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-HOST-VARS.
           05  HV-NUMB-SOCIO-PRINCIPAL     PIC S9(09) COMP-3.
           05  HV-CONTADOR                 PIC S9(09) COMP.
       LINKAGE SECTION.
           COPY STFSOCIO.
       PROCEDURE DIVISION USING STFSOCIO-LINKAGE.
           PERFORM INICIALIZA
           PERFORM PROCESSA
           PERFORM FINALIZA
           GOBACK.
       INICIALIZA.
           MOVE ZEROES TO WS-RETORNO-CODIGO
           IF NOT WS-ACAO-CONSULTA
               MOVE +100 TO WS-RETORNO-CODIGO
           END-IF
           .
       PROCESSA.
           IF WS-RETORNO-CODIGO NOT = ZERO
               GO TO PROCESSA-FIM
           END-IF
           MOVE NUMB-SOCIO-PRINCIPAL TO HV-NUMB-SOCIO-PRINCIPAL
           EXEC SQL
               SELECT COUNT(*)
                 INTO :HV-CONTADOR
                 FROM TB_SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   IF HV-CONTADOR > ZERO
                       MOVE ZERO TO WS-RETORNO-CODIGO
                   ELSE
                       MOVE +100 TO WS-RETORNO-CODIGO
                   END-IF
               WHEN +100
                   MOVE +100 TO WS-RETORNO-CODIGO
               WHEN OTHER
                   MOVE SQLCODE TO WS-RETORNO-CODIGO
           END-EVALUATE
           .
       PROCESSA-FIM.
           EXIT.
       FINALIZA.
           .
