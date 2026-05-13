      ******************************************************************
      * SOCIOLNK - Linkage / communication area (COBOL copybook).
      * Keep field order, level, picture, and usage aligned with
      * prg-natural-p2/SOCIOLNK-LDA.txt for Natural CALL.
      ******************************************************************
       01  SOCIO-LNK-AREA.
           05 SOCIO-LNK-OP-CODE          PIC X.
              88 SOCIO-LNK-OP-CONSULT    VALUE 'C'.
              88 SOCIO-LNK-OP-INSERT     VALUE 'I'.
           05 SOCIO-LNK-RETCODE          PIC XX.
              88 SOCIO-LNK-RC-OK         VALUE '00'.
              88 SOCIO-LNK-RC-NOTFND     VALUE '01'.
              88 SOCIO-LNK-RC-DUP        VALUE '02'.
              88 SOCIO-LNK-RC-VAL        VALUE '03'.
              88 SOCIO-LNK-RC-SQL        VALUE '99'.
           05 SOCIO-LNK-NUMB             PIC S9(09) DISPLAY.
           05 SOCIO-LNK-NOME             PIC X(40).
           05 SOCIO-LNK-DATA-CAD         PIC X(10).
           05 SOCIO-LNK-CATG             PIC S9(4) DISPLAY.
           05 SOCIO-LNK-INDI-DIVIDA      PIC X(01).
           05 SOCIO-LNK-DATA-BAIXA       PIC X(10).
           05 SOCIO-LNK-HORA-BAIXA       PIC X(12).
           05 SOCIO-LNK-OBSV             PIC X(500).
           05 SOCIO-LNK-PAG-QTD         PIC 9(03).
           05 SOCIO-LNK-PAG OCCURS 12 TIMES.
              10 SOCIO-LNK-PAG-DATA-VENC PIC X(10).
              10 SOCIO-LNK-PAG-VALR      PIC S9(6)V9(2) DISPLAY.
              10 SOCIO-LNK-PAG-OK        PIC X(01).
