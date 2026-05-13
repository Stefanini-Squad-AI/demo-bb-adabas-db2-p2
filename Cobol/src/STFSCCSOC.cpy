      *> STFSCCSOC - Sócio commarea (Natural LDA mirror; linkage for STFSCC00C/I)
      *> Return codes: NF = not found (consult); EX = already exists;
      *>               OK = inserted; DU = duplicate on insert; ER = error
       01  SOCIO-COMMAREA.
           05  SOCIO-CN-RC                     PIC X(02).
           05  SOCIO-CN-RG-NUM                 PIC 9(09).
           05  SOCIO-CN-NOME                   PIC X(40).
           05  SOCIO-CN-DATA-CADASTRO          PIC X(10).
           05  SOCIO-CN-CATG                   PIC 9(02).
           05  SOCIO-CN-INDI-DIVIDA            PIC X(01).
           05  SOCIO-CN-DATA-BAIXA             PIC X(10).
           05  SOCIO-CN-HORA-BAIXA             PIC X(12).
           05  SOCIO-CN-OBSV                   PIC X(500).
           05  SOCIO-CN-SUPER1                 PIC X(20).
           05  SOCIO-CN-PAG-ROW OCCURS 12 TIMES.
               10  SOCIO-CN-PAG-DATA-VENC      PIC X(10).
               10  SOCIO-CN-PAG-VALR           PIC S9(4)V9(2) COMP-3.
               10  SOCIO-CN-PAG-OK             PIC X(01).
