      *================================================================*
      * COBOL Copybook: STFSC00-SOCIOS
      * Purpose: Communication structure between Natural and COBOL
      *          for Member (SOCIOS) management
      * Date: 2026-05-15
      * Operations: I(Inclusion), A(Alteration), E(Exclusion), C(Consultation)
      *================================================================*
       01 SOCIOS-RECORD.
           05 RETURN-CODE-OPER          PIC 9(4) VALUE 0.
           05 NUMB-SOCIO-PRINCIPAL      PIC 9(9).
           05 NOME-SOCIO-PRINCIPAL      PIC X(40).
           05 DATA-CADASTRO             PIC X(10).
           05 CATG-SOCIO                PIC 9(2).
           05 INDI-DIVIDA               PIC X(1).
           05 DATA-BAIXA                PIC X(10).
           05 HORA-BAIXA                PIC X(12).
           05 OBSV-SOCIO                PIC X(500).
           05 FILLER                    PIC X(13) VALUE SPACES.
           05 PERIODICO-PAGAMENTO.
               10 PAGAMENTO-ITEM        OCCURS 12 TIMES
                   INDEXED BY PAG-IDX.
                   15 DATA-VENCIMENTO   PIC X(10).
                   15 VALR-MENSALIDADE  PIC S9(6)V99.
                   15 PAGAMENTO-OK      PIC 9(1).
