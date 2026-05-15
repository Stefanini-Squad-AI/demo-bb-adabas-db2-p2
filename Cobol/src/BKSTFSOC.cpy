      *> Book de comunicação Natural ↔ COBOL (I A E C + return code)
       01  BOOK-STF-SOCIOS.
           05 WS-OPER-CD                    PIC X.
      *>     C=Consulta I=Inclusão A=Alteração E=Exclusão
           05 WS-RETURN-CODE                PIC 99.
      *>     0=OK 1=Não encontrado 2=Duplicidade 99=Erro sistema
           05 WS-NUMB-SOCIO-PRINCIPAL       PIC 9(9) DISPLAY.
           05 WS-NOME-SOCIO-PRINCIPAL       PIC X(40).
      *> Datas em trânsito YYYYMMDD (8) — COBOL converte para DATE DB2
           05 WS-DATA-CADASTRO-IN          PIC X(8).
           05 WS-CATG-SOCIO                PIC 9(2) DISPLAY.
           05 WS-DATA-BAIXA-IN             PIC X(8).
           05 WS-HORA-BAIXA                PIC X(8).
           05 WS-OBSV-SOCIO                PIC X(500).
           05 WS-PAGAMENTO OCCURS 12 TIMES.
              10 WS-DATA-VENCIMENTO-IN     PIC X(8).
              10 WS-VALR-MENSALIDADE       PIC 9(7)V99 DISPLAY.
              10 WS-PAGAMENTO-OK           PIC X.
