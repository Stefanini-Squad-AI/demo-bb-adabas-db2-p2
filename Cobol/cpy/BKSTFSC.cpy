      *> BKSTFSC - Livro de ligacao compartilhado Natural <-> COBOL (DB2 socio)
      *> Inclui codigo de retorno padronizado para o programa chamador.
       01  LK-STFSC-AREA.
           05 LK-RETCODE                     PIC XX.
               88 STFSC-RC-OK                VALUE '00'.
               88 STFSC-RC-NOTFOUND          VALUE '01'.
               88 STFSC-RC-DUPKEY            VALUE '98'.
               88 STFSC-RC-DBERR            VALUE '99'.
           05 LK-NUMB-SOCIO-PRINCIPAL        PIC 9(09).
           05 LK-NOME-SOCIO-PRINCIPAL        PIC X(40).
           05 LK-DATA-CADASTRO               PIC X(10).
           05 LK-CATG-SOCIO                  PIC S9(4) COMP.
           05 LK-INDI-DIVIDA                 PIC S9(4) COMP.
           05 LK-DATA-BAIXA                  PIC X(10).
           05 LK-DATA-BAIXA-IND              PIC S9(4) COMP.
           05 LK-HORA-BAIXA                  PIC X(12).
           05 LK-HORA-BAIXA-IND              PIC S9(4) COMP.
           05 LK-OBSV-CLIENTE                PIC X(500).
           05 LK-PAGAMENTO-TAB.
              07 LK-PAGAMENTO OCCURS 12 TIMES.
                 10 LK-DATA-VENCIMENTO       PIC X(10).
                 10 LK-VALR-MENSALIDADE      PIC S9(6)V9(2) COMP-3.
                 10 LK-PAGAMENTO-OK         PIC X(01).
