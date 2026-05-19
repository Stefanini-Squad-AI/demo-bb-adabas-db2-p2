      ******************************************************************
      * COPYBOOK: SOCIO
      * Purpose: Communication structure between Natural and COBOL
      *          for SOCIO (member) entity
      * Author: Automated Migration
      * Date: 2026-05-19
      ******************************************************************
      01  SOCIO-RECORD.
          05  NUMB-SOCIO-PRINCIPAL       PIC 9(9).
          05  NOME-SOCIO-PRINCIPAL       PIC X(40).
          05  DATA-CADASTRO              PIC X(10).
          05  PERIODICO-PAGAMENTO.
              10  PAGAMENTO-ITEM         OCCURS 12 TIMES.
                  15  DATA-VENCIMENTO    PIC X(10).
                  15  VALR-MENSALIDADE   PIC 9(4)V99.
                  15  PAGAMENTO-OK       PIC X(1).
          05  CATG-SOCIO                 PIC 9(4).
          05  INDI-DIVIDA                PIC X(1).
          05  DATA-BAIXA                 PIC X(10).
          05  HORA-BAIXA                 PIC X(8).
          05  OBSV-SOCIO                 PIC X(500).
          05  RETURN-CODE-SOCIO          PIC S9(9) COMP.
