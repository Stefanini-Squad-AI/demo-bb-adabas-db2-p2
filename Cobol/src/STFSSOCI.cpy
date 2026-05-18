      ******************************************************************
      * Communication copybook: SOCIOS entity (Natural x COBOL x DB2)
      * Single level-01 structure for LINKAGE / LOCAL-STORAGE
      * Return codes: 000=found, 100=not found, 803=duplicate key
      ******************************************************************
       01  STFSSOCI-LINKAGE.
           05  STFSSOCI-RETURN-CODE          PIC S9(4) COMP.
           05  STFSSOCI-NUMB-SOCIO-PRINCIPAL  PIC 9(9).
           05  STFSSOCI-NOME-SOCIO-PRINCIPAL   PIC X(40).
           05  STFSSOCI-DATA-CADASTRO          PIC X(10).
           05  STFSSOCI-C-PERIODICO-PAGAMENTO  PIC 9(3).
           05  STFSSOCI-PERIODICO-PAGAMENTO OCCURS 12 TIMES
                                       INDEXED BY STFSSOCI-PAG-IDX.
               10  STFSSOCI-DATA-VENCIMENTO  PIC X(10).
               10  STFSSOCI-VALR-MENSALIDADE PIC S9(6)V9(2) COMP-3.
               10  STFSSOCI-PAGAMENTO-OK     PIC X(1).
           05  STFSSOCI-CATG-SOCIO             PIC 9(2).
           05  STFSSOCI-INDI-DIVIDA            PIC X(1).
           05  STFSSOCI-DATA-BAIXA             PIC X(10).
           05  STFSSOCI-HORA-BAIXA             PIC X(5).
           05  STFSSOCI-OBSV-SOCIO             PIC X(500).
