      ******************************************************************
      * Book de comunicacao Natural x COBOL - ADABAS-SOCIOS (DBATDP-17)
      * Operacoes: C=Consulta I=Inclusao A=Alteracao E=Exclusao
      * Return code: +000 localizado/sucesso, +100 nao localizado,
      *              +803 chave duplicada (insert), demais = erro generico
      ******************************************************************
       01  STFSCB00-COMUNICACAO.
           05  STFSCB00-OPERACAO           PIC X(01).
               88  STFSCB00-OP-CONSULTA    VALUE 'C'.
               88  STFSCB00-OP-INCLUSAO    VALUE 'I'.
               88  STFSCB00-OP-ALTERACAO   VALUE 'A'.
               88  STFSCB00-OP-EXCLUSAO    VALUE 'E'.
           05  STFSCB00-RETURN-CODE        PIC X(05).
           05  STFSCB00-NUMB-SOCIO-PRINC   PIC 9(09).
           05  STFSCB00-NOME-SOCIO-PRINC   PIC X(40).
           05  STFSCB00-DATA-CADASTRO      PIC X(10).
           05  STFSCB00-CATG-SOCIO         PIC 9(02).
           05  STFSCB00-INDI-DIVIDA        PIC X(01).
           05  STFSCB00-DATA-BAIXA         PIC X(10).
           05  STFSCB00-HORA-BAIXA         PIC X(05).
           05  STFSCB00-OBSV-SOCIO         PIC X(500).
           05  STFSCB00-C-PERIODICO        PIC 9(03).
           05  STFSCB00-PERIODICO OCCURS 12 TIMES
                                       INDEXED BY STFSCB00-IDX-PE.
               10  STFSCB00-DATA-VENC      PIC X(10).
               10  STFSCB00-VALR-MENSAL    PIC S9(06)V9(02)
                                       SIGN IS LEADING SEPARATE
                                       CHARACTER.
               10  STFSCB00-PAGAMENTO-OK   PIC X(01).
