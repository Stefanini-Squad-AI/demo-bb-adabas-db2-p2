       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00C.
      ******************************************************************
      * AUTOR     : MIGRACAO ADABAS-SOCIOS -> DB2 (DBATDP-1)            *
      * OBJETIVO  : SUBPROGRAMA DE CONSULTA DE SOCIO POR RG NO DB2.     *
      *             SUBSTITUI O ACESSO ADABAS (FIND) DO PROGRAMA        *
      *             NATURAL LEGADO DE CADASTRO DE SOCIOS.               *
      * CHAMADA   : CALLNAT 'STFSC00C' BK-SOCIO                         *
      * ENTRADA   : BKS-NUMB-SOCIO-PRIN (RG DO SOCIO).                  *
      * SAIDA     : DADOS DO SOCIO + ATE 12 MENSALIDADES EM             *
      *             BKS-TAB-MENSALIDADES, BKS-RETURN-CODE E             *
      *             BKS-MENSAGEM.                                       *
      * RETORNOS  : 0000 = SOCIO ENCONTRADO                             *
      *             0100 = SOCIO NAO ENCONTRADO                         *
      *             9999 = ERRO DE BANCO DE DADOS                       *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.

      *=================================================================
      * WORKING-STORAGE: APENAS CONSTANTES, LITERAIS, CODIGOS FIXOS,
      *                  MENSAGENS CONSTANTES, FLAGS CONSTANTES E
      *                  VALORES IMUTAVEIS.
      *=================================================================
       WORKING-STORAGE SECTION.
       01  WS-CONSTANTES.
           05  WK-PROG-ID            PIC X(08) VALUE 'STFSC00C'.
           05  WK-OP-CONSULTA        PIC X(01) VALUE 'C'.
           05  WK-RC-OK              PIC 9(04) VALUE 0000.
           05  WK-RC-NAO-ENCONTRADO  PIC 9(04) VALUE 0100.
           05  WK-RC-ERRO            PIC 9(04) VALUE 9999.
           05  WK-SQL-NOT-FOUND      PIC S9(09) COMP VALUE +100.
           05  WK-MAX-MENSALIDADES   PIC 9(02) VALUE 12.
           05  WK-MSG-OK             PIC X(72) VALUE
               'Socio ja cadastrado.'.
           05  WK-MSG-NAO-ENCONTRADO PIC X(72) VALUE
               'Socio nao encontrado.'.
           05  WK-MSG-ERRO-SOCIO     PIC X(72) VALUE
               'Erro ao consultar socio no DB2.'.
           05  WK-MSG-ERRO-MENS      PIC X(72) VALUE
               'Erro ao consultar mensalidades do socio no DB2.'.

      *=================================================================
      * LOCAL-STORAGE: SQLCA, BOOK DE ENTIDADE/COMUNICACAO (USO LOCAL),
      *                HOST VARIABLES, INDICADORES, CURSORES E
      *                ESTRUTURAS TEMPORARIAS.
      *=================================================================
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.

      *--- HOST VARIABLES DO SOCIO (TABELA PRINCIPAL) ------------------*
       01  HV-SOCIO.
           05  HV-NUMB-SOCIO-PRIN    PIC S9(09)     COMP-3.
           05  HV-NOME-SOCIO-PRIN    PIC X(40).
           05  HV-DATA-CADASTRO      PIC X(10).
           05  HV-CATG-SOCIO         PIC S9(04)     COMP.
           05  HV-INDI-DIVIDA        PIC X(01).
           05  HV-DATA-BAIXA         PIC X(10).
           05  HV-HORA-BAIXA         PIC X(26).
           05  HV-OBSV-SOCIO         PIC X(500).

      *--- INDICADORES DE NULL DO SOCIO --------------------------------*
       01  IND-SOCIO.
           05  IN-NUMB-SOCIO-PRIN    PIC S9(04) COMP.
           05  IN-NOME-SOCIO-PRIN    PIC S9(04) COMP.
           05  IN-DATA-CADASTRO      PIC S9(04) COMP.
           05  IN-CATG-SOCIO         PIC S9(04) COMP.
           05  IN-INDI-DIVIDA        PIC S9(04) COMP.
           05  IN-DATA-BAIXA         PIC S9(04) COMP.
           05  IN-HORA-BAIXA         PIC S9(04) COMP.
           05  IN-OBSV-SOCIO         PIC S9(04) COMP.

      *--- HOST VARIABLES DA MENSALIDADE -------------------------------*
       01  HV-MENSALIDADE.
           05  HV-NUMR-PARCELA       PIC S9(04)     COMP.
           05  HV-DATA-VENCIMENTO    PIC X(10).
           05  HV-VALR-MENSALIDADE   PIC S9(04)V99  COMP-3.
           05  HV-PAGAMENTO-OK       PIC X(01).

       01  IND-MENSALIDADE.
           05  IN-NUMR-PARCELA       PIC S9(04) COMP.
           05  IN-DATA-VENCIMENTO    PIC S9(04) COMP.
           05  IN-VALR-MENSALIDADE   PIC S9(04) COMP.
           05  IN-PAGAMENTO-OK       PIC S9(04) COMP.

      *--- ESTRUTURAS TEMPORARIAS DE CONTROLE --------------------------*
       01  WK-CONTROLE.
           05  WK-IDX                PIC 9(02) VALUE ZEROS.
           05  WK-FIM-CURSOR         PIC X(01) VALUE 'N'.
               88  FIM-CURSOR        VALUE 'S'.
               88  NAO-FIM-CURSOR    VALUE 'N'.

      *--- CURSOR DE LEITURA DAS MENSALIDADES --------------------------*
           EXEC SQL DECLARE CUR-MENSALIDADE CURSOR FOR
                SELECT NUMR_PARCELA,
                       CHAR(DATA_VENCIMENTO, ISO),
                       VALR_MENSALIDADE,
                       PAGAMENTO_OK
                  FROM TBSOCIO_MENSALIDADE
                 WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRIN
                 ORDER BY NUMR_PARCELA
           END-EXEC.

      *=================================================================
      * LINKAGE: AREA DE COMUNICACAO RECEBIDA DO PROGRAMA NATURAL.
      *=================================================================
       LINKAGE SECTION.
           COPY BKSOCIO.

       PROCEDURE DIVISION USING BK-SOCIO.

      *-----------------------------------------------------------------
       0000-PRINCIPAL SECTION.
       0000-INICIO.
           PERFORM 1000-INICIALIZA
           PERFORM 2000-CONSULTA-SOCIO
           IF BKS-RC-OK
              PERFORM 3000-CONSULTA-MENSALIDADES
           END-IF
           GOBACK.

      *-----------------------------------------------------------------
       1000-INICIALIZA SECTION.
       1000-INI.
           MOVE WK-OP-CONSULTA  TO BKS-OPERACAO
           MOVE WK-RC-OK        TO BKS-RETURN-CODE
           MOVE ZEROS           TO BKS-SQLCODE
           MOVE SPACES          TO BKS-MENSAGEM
           MOVE ZEROS           TO BKS-QTD-MENSALIDADES
           MOVE BKS-NUMB-SOCIO-PRIN TO HV-NUMB-SOCIO-PRIN
           SET NAO-FIM-CURSOR   TO TRUE
           PERFORM 1100-LIMPA-AREAS-SAIDA.

       1100-LIMPA-AREAS-SAIDA.
           MOVE SPACES TO BKS-NOME-SOCIO-PRIN
                          BKS-DATA-CADASTRO
                          BKS-INDI-DIVIDA
                          BKS-DATA-BAIXA
                          BKS-HORA-BAIXA
                          BKS-OBSV-SOCIO
           MOVE ZEROS  TO BKS-CATG-SOCIO
           PERFORM VARYING WK-IDX FROM 1 BY 1
                   UNTIL WK-IDX > WK-MAX-MENSALIDADES
               MOVE ZEROS  TO BKS-NUMR-PARCELA   (WK-IDX)
               MOVE SPACES TO BKS-DATA-VENCIMENTO(WK-IDX)
               MOVE ZEROS  TO BKS-VALR-MENSALIDADE(WK-IDX)
               MOVE SPACES TO BKS-PAGAMENTO-OK   (WK-IDX)
           END-PERFORM.

      *-----------------------------------------------------------------
       2000-CONSULTA-SOCIO SECTION.
       2000-INI.
           EXEC SQL
               SELECT NOME_SOCIO_PRINCIPAL,
                      CHAR(DATA_CADASTRO, ISO),
                      CATG_SOCIO,
                      INDI_DIVIDA,
                      CHAR(DATA_BAIXA,    ISO),
                      CHAR(HORA_BAIXA,    ISO),
                      OBSV_SOCIO
                 INTO :HV-NOME-SOCIO-PRIN :IN-NOME-SOCIO-PRIN,
                      :HV-DATA-CADASTRO   :IN-DATA-CADASTRO,
                      :HV-CATG-SOCIO      :IN-CATG-SOCIO,
                      :HV-INDI-DIVIDA     :IN-INDI-DIVIDA,
                      :HV-DATA-BAIXA      :IN-DATA-BAIXA,
                      :HV-HORA-BAIXA      :IN-HORA-BAIXA,
                      :HV-OBSV-SOCIO      :IN-OBSV-SOCIO
                 FROM TBSOCIO
                WHERE NUMB_SOCIO_PRINCIPAL = :HV-NUMB-SOCIO-PRIN
           END-EXEC

           MOVE SQLCODE TO BKS-SQLCODE
           EVALUATE TRUE
               WHEN SQLCODE = 0
                   PERFORM 2100-COPIA-RETORNO-SOCIO
                   MOVE WK-RC-OK         TO BKS-RETURN-CODE
                   MOVE WK-MSG-OK        TO BKS-MENSAGEM
               WHEN SQLCODE = WK-SQL-NOT-FOUND
                   MOVE WK-RC-NAO-ENCONTRADO TO BKS-RETURN-CODE
                   MOVE WK-MSG-NAO-ENCONTRADO TO BKS-MENSAGEM
               WHEN OTHER
                   MOVE WK-RC-ERRO       TO BKS-RETURN-CODE
                   MOVE WK-MSG-ERRO-SOCIO TO BKS-MENSAGEM
           END-EVALUATE.

       2100-COPIA-RETORNO-SOCIO.
           MOVE HV-NOME-SOCIO-PRIN TO BKS-NOME-SOCIO-PRIN
           MOVE HV-DATA-CADASTRO   TO BKS-DATA-CADASTRO
           MOVE HV-CATG-SOCIO      TO BKS-CATG-SOCIO
           MOVE HV-INDI-DIVIDA     TO BKS-INDI-DIVIDA
           MOVE HV-DATA-BAIXA      TO BKS-DATA-BAIXA
           MOVE HV-HORA-BAIXA      TO BKS-HORA-BAIXA
           MOVE HV-OBSV-SOCIO      TO BKS-OBSV-SOCIO.

      *-----------------------------------------------------------------
       3000-CONSULTA-MENSALIDADES SECTION.
       3000-INI.
           EXEC SQL OPEN CUR-MENSALIDADE END-EXEC
           MOVE SQLCODE TO BKS-SQLCODE
           IF SQLCODE NOT = 0
              MOVE WK-RC-ERRO      TO BKS-RETURN-CODE
              MOVE WK-MSG-ERRO-MENS TO BKS-MENSAGEM
              GO TO 3000-FIM
           END-IF

           MOVE ZEROS TO WK-IDX
           PERFORM 3100-FETCH-MENSALIDADE UNTIL FIM-CURSOR
                                            OR WK-IDX >= WK-MAX-MENSALIDADES

           MOVE WK-IDX TO BKS-QTD-MENSALIDADES

           EXEC SQL CLOSE CUR-MENSALIDADE END-EXEC.
       3000-FIM.
           EXIT.

       3100-FETCH-MENSALIDADE.
           EXEC SQL
               FETCH CUR-MENSALIDADE
                INTO :HV-NUMR-PARCELA     :IN-NUMR-PARCELA,
                     :HV-DATA-VENCIMENTO  :IN-DATA-VENCIMENTO,
                     :HV-VALR-MENSALIDADE :IN-VALR-MENSALIDADE,
                     :HV-PAGAMENTO-OK     :IN-PAGAMENTO-OK
           END-EXEC

           MOVE SQLCODE TO BKS-SQLCODE
           EVALUATE TRUE
               WHEN SQLCODE = 0
                   ADD 1 TO WK-IDX
                   MOVE HV-NUMR-PARCELA
                        TO BKS-NUMR-PARCELA      (WK-IDX)
                   MOVE HV-DATA-VENCIMENTO
                        TO BKS-DATA-VENCIMENTO   (WK-IDX)
                   MOVE HV-VALR-MENSALIDADE
                        TO BKS-VALR-MENSALIDADE  (WK-IDX)
                   MOVE HV-PAGAMENTO-OK
                        TO BKS-PAGAMENTO-OK      (WK-IDX)
               WHEN SQLCODE = WK-SQL-NOT-FOUND
                   SET FIM-CURSOR TO TRUE
               WHEN OTHER
                   SET FIM-CURSOR TO TRUE
                   MOVE WK-RC-ERRO      TO BKS-RETURN-CODE
                   MOVE WK-MSG-ERRO-MENS TO BKS-MENSAGEM
           END-EVALUATE.

       END PROGRAM STFSC00C.
