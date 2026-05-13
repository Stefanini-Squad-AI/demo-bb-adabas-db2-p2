      ******************************************************************
      * STFSCBOK - Linkage consulta (STFSC00C). RC: COPY STFSCRC.
      ******************************************************************
       01  STFSC-LNK-CONSULT.
           05 LNK-C-RG-NUMB              PIC 9(09).
           05 LNK-C-RC                   PIC S9(04) COMP.
           05 LNK-C-NOME                 PIC X(40).
           05 LNK-C-DATA-CADASTRO        PIC X(10).
           05 LNK-C-CATG-SOCIO           PIC S9(04) COMP.
           05 LNK-C-INDI-DIVIDA          PIC X(01).
           05 LNK-C-DATA-BAIXA           PIC X(10).
           05 LNK-C-HORA-BAIXA           PIC X(12).
           05 LNK-C-OBSV-SOCIO           PIC X(500).
           05 LNK-C-SUPER1               PIC X(50).
           05 LNK-C-QTD-PAG              PIC S9(04) COMP.
           05 LNK-C-PAG OCCURS 500 TIMES.
              10 LNK-C-PAG-DATA-VENC     PIC X(10).
              10 LNK-C-PAG-VALR          PIC S9(06)V99 COMP-3.
              10 LNK-C-PAG-OK            PIC X(01).
