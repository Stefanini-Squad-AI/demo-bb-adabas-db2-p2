      * COPYBOOK STFSC00-SOCIO-IO
      * ESTRUTURA DE DADOS PARA ACESSO AO ARQUIVO SOCIOS EM DB2
      * EQUIVALENTE AO DDM ADABAS-SOCIOS COM CAMPOS PARA I/O COM NATURAL

       01 SOCIO-RECORD.
           05 NUMB-SOCIO-PRINCIPAL    PIC 9(9).
           05 NOME-SOCIO-PRINCIPAL    PIC X(40).
           05 DATA-CADASTRO           PIC X(10).
           05 CATG-SOCIO              PIC 9(2).
           05 INDI-DIVIDA             PIC X(1).
           05 DATA-BAIXA              PIC X(10).
           05 HORA-BAIXA              PIC X(8).
           05 OBSV-SOCIO              PIC X(500).
           05 PERIODICO-PAGAMENTO OCCURS 12 TIMES.
               10 DATA-VENCIMENTO     PIC X(10).
               10 VALR-MENSALIDADE    PIC S9(4)V99 COMP-3.
               10 PAGAMENTO-OK        PIC X(1).
           05 SUPER1.
               10 SUPER1-CATG         PIC 9(2).
               10 SUPER1-DIVIDA       PIC X(1).
