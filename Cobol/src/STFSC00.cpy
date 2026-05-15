      * STFSC00.cpy - Copybook for Natural-COBOL Communication
      * Purpose: Data exchange between Natural STFPCS00 and COBOL
      *          programs STFSC00C (Consulta), STFSC00I (Inclusão)
      * Created: 2026-05-15

       01 STFSC00-AREA.
           05 WS-OPERACAO                 PIC X(1).
               88 OPERACAO-CONSULTA       VALUE 'C'.
               88 OPERACAO-INCLUSAO       VALUE 'I'.
               88 OPERACAO-ALTERACAO      VALUE 'A'.
               88 OPERACAO-EXCLUSAO       VALUE 'E'.
           05 WS-RETURN-CODE              PIC S9(4) COMP.

           05 WS-NUMB-SOCIO-PRINCIPAL     PIC 9(9).
           05 WS-NOME-SOCIO-PRINCIPAL     PIC X(40).
           05 WS-DATA-CADASTRO            PIC X(10).
               88 DADOS-VALIDOS           VALUE IS NUMERIC.
           05 WS-CATG-SOCIO               PIC S9(4) COMP.
           05 WS-DATA-BAIXA               PIC X(10).
           05 WS-HORA-BAIXA               PIC X(12).
           05 WS-OBSV-SOCIO               PIC X(500).

           05 WS-QTD-PAGAMENTOS           PIC 9(2) VALUE 0.
           05 WS-PAGAMENTOS.
              10 WS-PAGAMENTO OCCURS 12 TIMES.
                  15 WS-DATA-VENCIMENTO   PIC X(10).
                  15 WS-VALR-MENSALIDADE  PIC S9(4)V99 COMP-3.
                  15 WS-PAGAMENTO-OK      PIC X(1).
