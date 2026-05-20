       01 SOCIO-RECORD.
           05 RETURN-CODE-DB2     PIC S9(4) COMP.
           05 OPERACAO            PIC X(1).
           05 NUMB-SOCIO-PRINCIPAL PIC 9(9) COMP-3.
           05 NOME-SOCIO-PRINCIPAL PIC X(40).
           05 DATA-CADASTRO       PIC X(10).
           05 CATG-SOCIO          PIC 9(4) COMP.
           05 INDI-DIVIDA         PIC 9(4) COMP.
           05 DATA-BAIXA          PIC X(10).
           05 HORA-BAIXA          PIC X(8).
           05 OBSV-SOCIO          PIC X(500).
           05 PAGAMENTOS-AREA.
               10 QTD-PAGAMENTOS  PIC 9(4) COMP VALUE 12.
               10 PAGAMENTO-ITEM  OCCURS 12 TIMES.
                   15 DATA-VENCIMENTO PIC X(10).
                   15 VALR-MENSALIDADE PIC 9(6)V99 COMP-3.
                   15 PAGAMENTO-OK    PIC 9(4) COMP.
