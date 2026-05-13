      *> STFSCSOC — entidade / área de comunicação Natural ↔ COBOL (DBATDP-1)
      *> Operações: C=consulta existência, I=inclusão (alinhado ao FIND/STORE Natural)
      *> Retorno consulta: 0=não existe (fluxo inclusão), 1=já cadastrado, 9=erro SQL
      *> Retorno inclusão: 0=OK, 9=erro SQL
      *> Numéricos em DISPLAY para alinhar buffer com Natural (sem COMP-3 no período).
       01  COMM-AREA.
           05 COMM-OPERATION                 PIC X(01).
           05 COMM-RETURN-CODE               PIC 9(02).
           05 COMM-NUMB-SOCIO-PRINCIPAL      PIC 9(09) DISPLAY.
           05 COMM-NOME-SOCIO-PRINCIPAL      PIC X(40).
           05 COMM-DATA-CADASTRO             PIC X(10).
           05 COMM-CATG-SOCIO               PIC 9(02) DISPLAY.
           05 COMM-INDI-DIVIDA               PIC 9(04) DISPLAY.
           05 COMM-DATA-BAIXA                PIC X(10).
           05 COMM-HORA-BAIXA                PIC X(12).
           05 COMM-OBSV-CLIENTE              PIC X(500).
           05 COMM-SUPER1                    PIC X(01).
           05 COMM-PERIODICO OCCURS 12 TIMES.
              10 COMM-DATA-VENCIMENTO        PIC X(10).
              10 COMM-VALR-MENSALIDADE       PIC 9(06)V9(02) DISPLAY.
              10 COMM-PAGAMENTO-OK           PIC X(01).
