      ******************************************************************
      * STFSCBOI - Linkage inclusão (STFSC00I). RC: COPY STFSCRC.
      ******************************************************************
       01  STFSC-LNK-INSERT.
           05 LNK-I-RG-NUMB              PIC 9(09).
           05 LNK-I-RC                   PIC S9(04) COMP.
           05 LNK-I-NOME                 PIC X(40).
           05 LNK-I-DATA-CADASTRO        PIC X(10).
           05 LNK-I-CATG-SOCIO           PIC S9(04) COMP.
           05 LNK-I-INDI-DIVIDA          PIC X(01).
           05 LNK-I-DATA-BAIXA           PIC X(10).
           05 LNK-I-HORA-BAIXA           PIC X(12).
           05 LNK-I-OBSV-SOCIO           PIC X(500).
           05 LNK-I-SUPER1               PIC X(50).
           05 LNK-I-QTD-PAG              PIC S9(04) COMP.
           05 LNK-I-PAG OCCURS 120 TIMES.
              10 LNK-I-PAG-DATA-VENC     PIC X(10).
              10 LNK-I-PAG-VALR          PIC S9(06)V99 COMP-3.
              10 LNK-I-PAG-OK            PIC X(01).
