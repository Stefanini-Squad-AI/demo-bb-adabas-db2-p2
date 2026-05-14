       01 SOCIOS-COMM.
           05 NUMB-SOCIO-PRINCIPAL   PIC 9(9).
           05 NOME-SOCIO-PRINCIPAL   PIC X(40).
           05 DATA-CADASTRO          PIC X(10).
           05 CATG-SOCIO             PIC S9(4) COMP.
           05 DATA-BAIXA             PIC X(10).
           05 HORA-BAIXA             PIC X(12).
           05 OBSV-SOCIO             PIC X(500).
           05 PAGAMENTO-TABLE.
              10 PAGAMENTO-ENTRY OCCURS 12 TIMES.
                 15 DATA-VENCIMENTO  PIC X(10).
                 15 VALR-MENSALIDADE PIC S9(4)V9(2) COMP-3.
                 15 PAGAMENTO-OK     PIC S9(4) COMP.
           05 RETURN-CODE            PIC S9(4) COMP.
