      ******************************************************************
      * BOOK ......: BKSOCIO                                           *
      * OBJETIVO ..: AREA DE COMUNICACAO ENTRE PROGRAMA NATURAL E      *
      *              SUBPROGRAMAS COBOL DE ACESSO A DB2 PARA A         *
      *              ENTIDADE SOCIO (ADABAS-SOCIOS).                   *
      * USO .......: STFSC00C (CONSULTA) E STFSC00I (INCLUSAO).        *
      *              SUPORTA AS QUATRO OPERACOES PADRAO (I/A/E/C) E    *
      *              POSSUI RETURN CODE COMUM, MESMO QUE APENAS        *
      *              I E C SEJAM USADOS NESTA MIGRACAO.                *
      * ATENCAO ...: ESTE BOOK DEVE ESTAR SEMPRE EM SINCRONIA COM A    *
      *              LDA NATURAL prg-natural-p2/LOCAL/BKSOCIO.NSL.     *
      *              QUALQUER MUDANCA AQUI EXIGE MUDANCA LA.           *
      *                                                                *
      * DATAS .....: TODOS OS CAMPOS DE DATA TRAFEGAM COMO PIC X(10)   *
      *              NO FORMATO ISO YYYY-MM-DD. O NATURAL E O COBOL    *
      *              REALIZAM A CONVERSAO DE/PARA O FORMATO INTERNO    *
      *              VIA MOVE EDITED USANDO A MASCARA YYYY-MM-DD.      *
      ******************************************************************
       01  BK-SOCIO.
      *--- AREA DE CONTROLE -------------------------------------------*
           05  BKS-OPERACAO              PIC X(01).
               88  BKS-OP-INCLUSAO       VALUE 'I'.
               88  BKS-OP-ALTERACAO      VALUE 'A'.
               88  BKS-OP-EXCLUSAO       VALUE 'E'.
               88  BKS-OP-CONSULTA       VALUE 'C'.
           05  BKS-RETURN-CODE           PIC 9(04).
               88  BKS-RC-OK             VALUE 0000.
               88  BKS-RC-NAO-ENCONTRADO VALUE 0100.
               88  BKS-RC-DUPLICADO      VALUE 0803.
               88  BKS-RC-ERRO           VALUE 9999.
           05  BKS-SQLCODE               PIC S9(09) COMP.
           05  BKS-MENSAGEM              PIC X(72).
      *--- DADOS DO SOCIO (TABELA PRINCIPAL) --------------------------*
           05  BKS-DADOS-SOCIO.
               10  BKS-NUMB-SOCIO-PRIN   PIC 9(09).
               10  BKS-NOME-SOCIO-PRIN   PIC X(40).
               10  BKS-DATA-CADASTRO     PIC X(10).
               10  BKS-CATG-SOCIO        PIC 9(02).
               10  BKS-INDI-DIVIDA       PIC X(01).
               10  BKS-DATA-BAIXA        PIC X(10).
               10  BKS-HORA-BAIXA        PIC X(26).
               10  BKS-OBSV-SOCIO        PIC X(500).
      *--- MENSALIDADES (PE PERIODICO-PAGAMENTO - TABELA FILHA) -------*
           05  BKS-QTD-MENSALIDADES      PIC 9(02).
           05  BKS-TAB-MENSALIDADES OCCURS 12 TIMES
                                    INDEXED BY BKS-IDX-MENS.
               10  BKS-NUMR-PARCELA      PIC 9(02).
               10  BKS-DATA-VENCIMENTO   PIC X(10).
               10  BKS-VALR-MENSALIDADE  PIC S9(04)V99 COMP-3.
               10  BKS-PAGAMENTO-OK      PIC X(01).
