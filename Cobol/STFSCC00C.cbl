       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSCC00C.
      *> DBATDP-1: Consult sócio by principal RG (duplicate check path).
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-RC-NF                        PIC X(02) VALUE 'NF'.
       01  WS-RC-EX                        PIC X(02) VALUE 'EX'.
       01  WS-RC-ER                        PIC X(02) VALUE 'ER'.
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA           END-EXEC.
       01  LS-HV-RG                        PIC S9(9) COMP-3.
       01  LS-HV-CNT                       PIC S9(9) COMP.
       LINKAGE SECTION.
           COPY STFSCCSOC.
       PROCEDURE DIVISION USING SOCIO-COMMAREA.
       MAIN-PARA.
           MOVE SPACES TO SOCIO-CN-RC
           MOVE ZERO TO LS-HV-RG LS-HV-CNT
           MOVE SOCIO-CN-RG-NUM TO LS-HV-RG
           EXEC SQL
               SELECT COUNT(*)
                 INTO :LS-HV-CNT
                 FROM SOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :LS-HV-RG
           END-EXEC
           IF SQLCODE NOT = ZERO
               MOVE WS-RC-ER TO SOCIO-CN-RC
               GOBACK
           END-IF
           IF LS-HV-CNT > ZERO
               MOVE WS-RC-EX TO SOCIO-CN-RC
           ELSE
               MOVE WS-RC-NF TO SOCIO-CN-RC
           END-IF
           GOBACK
           .
