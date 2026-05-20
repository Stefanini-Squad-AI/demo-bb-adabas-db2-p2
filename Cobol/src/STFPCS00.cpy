      * ================================================================
      * COPYBOOK: STFPCS00
      * Descrição: Estrutura de comunicação Natural <> COBOL
      *            para acesso à tabela SOCIOS em DB2
      * Data: 2026-05-20
      * ================================================================

       01 STFPCS00-AREA.

           05 STFPCS00-OPERACAO         PIC X(1).
                88 STFPCS00-CONSULTAR    VALUE 'C'.
                88 STFPCS00-INCLUIR      VALUE 'I'.
                88 STFPCS00-ALTERAR      VALUE 'A'.
                88 STFPCS00-EXCLUIR      VALUE 'E'.

           05 STFPCS00-RETURN-CODE      PIC 9(3).
                88 STFPCS00-LOCALIZADO    VALUE 0.
                88 STFPCS00-NAO-LOCALIZADO VALUE 100.
                88 STFPCS00-CHAVE-DUPLICADA VALUE 803.

           05 STFPCS00-DADOS.

               10 SOCIOS-RG             PIC 9(9).
               10 SOCIOS-NOME           PIC X(40).
               10 SOCIOS-DATA-CADASTRO  PIC X(10).
               10 SOCIOS-CATG           PIC 9(2).
               10 SOCIOS-DIVIDA         PIC 9(1).
               10 SOCIOS-DATA-BAIXA     PIC X(10).
               10 SOCIOS-HORA-BAIXA     PIC X(5).
               10 SOCIOS-OBSV           PIC X(500).

               10 SOCIOS-PAGAMENTOS OCCURS 12 TIMES.
                   15 PAGO-DATA-VENCIMENTO PIC X(10).
                   15 PAGO-VALOR           PIC 9(4)V99.
                   15 PAGO-STATUS          PIC 9(1).
