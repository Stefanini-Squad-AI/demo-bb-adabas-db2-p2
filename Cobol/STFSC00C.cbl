       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      *> Consulta existência de sócio principal (equivalente ao FIND Natural).
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-LITERALS.
           05 WS-OP-CONSULTA                PIC X(01) VALUE 'C'.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       01  LS-HOST-COUNT                    PIC S9(9) COMP-5.
       LINKAGE SECTION.
           COPY STFSCSOC.
       PROCEDURE DIVISION USING COMM-AREA.
       MAIN SECTION.
           IF COMM-OPERATION NOT = WS-OP-CONSULTA
               MOVE 9 TO COMM-RETURN-CODE
               GOBACK
           END-IF
           MOVE ZERO TO LS-HOST-COUNT
           EXEC SQL
               SELECT COUNT(*)
                 INTO :LS-HOST-COUNT
                 FROM TB_SOCIO_MEMBRO
                WHERE NUMB_SOCIO_PRINCIPAL = :COMM-NUMB-SOCIO-PRINCIPAL
           END-EXEC
           IF SQLCODE NOT = 0
               MOVE 9 TO COMM-RETURN-CODE
               GOBACK
           END-IF
           IF LS-HOST-COUNT > 0
               MOVE 1 TO COMM-RETURN-CODE
           ELSE
               MOVE 0 TO COMM-RETURN-CODE
           END-IF
           GOBACK
           .
