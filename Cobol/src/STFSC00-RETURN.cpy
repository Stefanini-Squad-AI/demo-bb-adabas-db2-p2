      * COPYBOOK STFSC00-RETURN
      * ESTRUTURA DE RETORNO PARA OPERAÇÕES DB2
      * CÓDIGOS COMPATÍVEIS COM DB2

       01 RETURN-CODE-STRUCT.
           05 RC-STATUS               PIC S9(9) COMP.
           05 RC-MESSAGE              PIC X(100).
           05 RC-SQLCODE              PIC S9(9) COMP.

      * Códigos de retorno DB2 padrão:
      * +000 = Operação localizada/sucesso
      * +100 = Nenhum registro localizado
      * +803 = Chave duplicada (constraint violation)
      * Negativos = Erro (DB2 error codes)
