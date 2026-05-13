       IDENTIFICATION DIVISION.
       PROGRAM-ID. STFSC00I.
      ******************************************************************
      * AUTOR     : MIGRACAO ADABAS-SOCIOS -> DB2 (DBATDP-1)            *
      * OBJETIVO  : SUBPROGRAMA DE INCLUSAO DE SOCIO E DAS              *
      *             RESPECTIVAS MENSALIDADES (TABELA FILHA DO PE       *
      *             PERIODICO-PAGAMENTO) NO DB2. SUBSTITUI O STORE      *
      *             ADABAS DO PROGRAMA NATURAL LEGADO.                  *
      * CHAMADA   : CALLNAT 'STFSC00I' BK-SOCIO                         *
      * ENTRADA   : DADOS DO SOCIO + N MENSALIDADES (BKS-QTD-           *
      *             MENSALIDADES INDICA QUANTAS POSICOES DE             *
      *             BKS-TAB-MENSALIDADES ESTAO PREENCHIDAS;             *
      *             O FLUXO ATUAL CARREGA SEMPRE 12).                   *
      * SAIDA     : BKS-RETURN-CODE E BKS-MENSAGEM.                     *
      * RETORNOS  : 0000 = SOCIO INCLUIDO COM SUCESSO                   *
      *             0803 = SOCIO JA CADASTRADO (CHAVE DUPLICADA)        *
      *             9999 = ERRO DE BANCO DE DADOS                       *
      ******************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.

      *=================================================================
      * WORKING-STORAGE: APENAS CONSTANTES, LITERAIS E VALORES
      *                  IMUTAVEIS.
      *=================================================================
       WORKING-STORAGE SECTION.
       01  WS-CONSTANTES.
           05  WK-PROG-ID            PIC X(08) VALUE 'STFSC00I'.
           05  WK-OP-INCLUSAO        PIC X(01) VALUE 'I'.
           05  WK-RC-OK              PIC 9(04) VALUE 0000.
           05  WK-RC-DUPLICADO       PIC 9(04) VALUE 0803.
           05  WK-RC-ERRO            PIC 9(04) VALUE 9999.
           05  WK-SQL-DUPLICADO      PIC S9(09) COMP VALUE -803.
           05  WK-MAX-MENSALIDADES   PIC 9(02) VALUE 12.
           05  WK-MSG-OK             PIC X(72) VALUE
               'Novo socio incluido com sucesso.'.
           05  WK-MSG-DUPLICADO      PIC X(72) VALUE
               'Socio ja cadastrado.'.
           05  WK-MSG-ERRO-SOCIO     PIC X(72) VALUE
               'Erro ao incluir socio no DB2.'.
           05  WK-MSG-ERRO-MENS      PIC X(72) VALUE
               'Erro ao incluir mensalidades do socio no DB2.'.

      *=================================================================
      * LOCAL-STORAGE: SQLCA, HOST VARIABLES, INDICADORES E
      *                ESTRUTURAS TEMPORARIAS.
      *=================================================================
       LOCAL-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.

      *--- HOST VARIABLES DO SOCIO -------------------------------------*
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
           05  IN-DATA-VENCIMENTO    PIC S9(04) COMP.
           05  IN-VALR-MENSALIDADE   PIC S9(04) COMP.
           05  IN-PAGAMENTO-OK       PIC S9(04) COMP.

      *--- ESTRUTURAS TEMPORARIAS DE CONTROLE --------------------------*
       01  WK-CONTROLE.
           05  WK-IDX                PIC 9(02) VALUE ZEROS.
           05  WK-QTD-PROCESSAR      PIC 9(02) VALUE ZEROS.

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
           PERFORM 2000-INSERE-SOCIO
           IF BKS-RC-OK
              PERFORM 3000-INSERE-MENSALIDADES
           END-IF
           GOBACK.

      *-----------------------------------------------------------------
       1000-INICIALIZA SECTION.
       1000-INI.
           MOVE WK-OP-INCLUSAO TO BKS-OPERACAO
           MOVE WK-RC-OK       TO BKS-RETURN-CODE
           MOVE ZEROS          TO BKS-SQLCODE
           MOVE SPACES         TO BKS-MENSAGEM
           PERFORM 1100-INDICADORES-NULL
           PERFORM 1200-CARREGA-HV-SOCIO

      *    Define a quantidade efetiva de mensalidades a inserir.
      *    Mantem compatibilidade com o fluxo Natural atual, que
      *    sempre carrega 12 vencimentos.
           IF BKS-QTD-MENSALIDADES > ZEROS
              IF BKS-QTD-MENSALIDADES > WK-MAX-MENSALIDADES
                 MOVE WK-MAX-MENSALIDADES TO WK-QTD-PROCESSAR
              ELSE
                 MOVE BKS-QTD-MENSALIDADES TO WK-QTD-PROCESSAR
              END-IF
           ELSE
              MOVE WK-MAX-MENSALIDADES TO WK-QTD-PROCESSAR
           END-IF.

       1100-INDICADORES-NULL.
           MOVE ZEROS TO IN-NOME-SOCIO-PRIN
                         IN-DATA-CADASTRO
                         IN-CATG-SOCIO
                         IN-INDI-DIVIDA
                         IN-DATA-VENCIMENTO
                         IN-VALR-MENSALIDADE
                         IN-PAGAMENTO-OK
      *    Sem baixa registrada na inclusao: campos enviados como NULL.
           MOVE -1 TO IN-DATA-BAIXA
                      IN-HORA-BAIXA
      *    Observacao: o Natural sempre preenche OBSV-SOCIO (defaultado
      *    para 'Novo socio' quando vazio), portanto nao e NULL.
           MOVE ZEROS TO IN-OBSV-SOCIO.

       1200-CARREGA-HV-SOCIO.
           MOVE BKS-NUMB-SOCIO-PRIN TO HV-NUMB-SOCIO-PRIN
           MOVE BKS-NOME-SOCIO-PRIN TO HV-NOME-SOCIO-PRIN
           MOVE BKS-DATA-CADASTRO   TO HV-DATA-CADASTRO
           MOVE BKS-CATG-SOCIO      TO HV-CATG-SOCIO
           MOVE BKS-INDI-DIVIDA     TO HV-INDI-DIVIDA
           MOVE BKS-DATA-BAIXA      TO HV-DATA-BAIXA
           MOVE BKS-HORA-BAIXA      TO HV-HORA-BAIXA
           MOVE BKS-OBSV-SOCIO      TO HV-OBSV-SOCIO.

      *-----------------------------------------------------------------
       2000-INSERE-SOCIO SECTION.
       2000-INI.
           EXEC SQL
               INSERT INTO TBSOCIO
                    ( NUMB_SOCIO_PRINCIPAL
                    , NOME_SOCIO_PRINCIPAL
                    , DATA_CADASTRO
                    , CATG_SOCIO
                    , INDI_DIVIDA
                    , DATA_BAIXA
                    , HORA_BAIXA
                    , OBSV_SOCIO )
               VALUES
                    ( :HV-NUMB-SOCIO-PRIN
                    , :HV-NOME-SOCIO-PRIN :IN-NOME-SOCIO-PRIN
                    , DATE(:HV-DATA-CADASTRO) :IN-DATA-CADASTRO
                    , :HV-CATG-SOCIO     :IN-CATG-SOCIO
                    , :HV-INDI-DIVIDA    :IN-INDI-DIVIDA
                    , DATE(:HV-DATA-BAIXA) :IN-DATA-BAIXA
                    , TIMESTAMP(:HV-HORA-BAIXA) :IN-HORA-BAIXA
                    , :HV-OBSV-SOCIO     :IN-OBSV-SOCIO )
           END-EXEC

           MOVE SQLCODE TO BKS-SQLCODE
           EVALUATE TRUE
               WHEN SQLCODE = 0
                   MOVE WK-RC-OK         TO BKS-RETURN-CODE
                   MOVE WK-MSG-OK        TO BKS-MENSAGEM
               WHEN SQLCODE = WK-SQL-DUPLICADO
                   MOVE WK-RC-DUPLICADO  TO BKS-RETURN-CODE
                   MOVE WK-MSG-DUPLICADO TO BKS-MENSAGEM
               WHEN OTHER
                   MOVE WK-RC-ERRO        TO BKS-RETURN-CODE
                   MOVE WK-MSG-ERRO-SOCIO TO BKS-MENSAGEM
           END-EVALUATE.

      *-----------------------------------------------------------------
       3000-INSERE-MENSALIDADES SECTION.
       3000-INI.
           PERFORM 3100-INSERE-UMA
               VARYING WK-IDX FROM 1 BY 1
                 UNTIL WK-IDX > WK-QTD-PROCESSAR
                    OR NOT BKS-RC-OK.

       3100-INSERE-UMA.
           MOVE BKS-NUMR-PARCELA     (WK-IDX) TO HV-NUMR-PARCELA
           MOVE BKS-DATA-VENCIMENTO  (WK-IDX) TO HV-DATA-VENCIMENTO
           MOVE BKS-VALR-MENSALIDADE (WK-IDX) TO HV-VALR-MENSALIDADE
           MOVE BKS-PAGAMENTO-OK     (WK-IDX) TO HV-PAGAMENTO-OK

      *    Caso a parcela venha zerada (carga 1..12 deduzida), aplica
      *    o proprio indice como numero da parcela.
           IF HV-NUMR-PARCELA = ZEROS
              MOVE WK-IDX TO HV-NUMR-PARCELA
           END-IF

           EXEC SQL
               INSERT INTO TBSOCIO_MENSALIDADE
                    ( NUMB_SOCIO_PRINCIPAL
                    , NUMR_PARCELA
                    , DATA_VENCIMENTO
                    , VALR_MENSALIDADE
                    , PAGAMENTO_OK )
               VALUES
                    ( :HV-NUMB-SOCIO-PRIN
                    , :HV-NUMR-PARCELA
                    , DATE(:HV-DATA-VENCIMENTO) :IN-DATA-VENCIMENTO
                    , :HV-VALR-MENSALIDADE      :IN-VALR-MENSALIDADE
                    , :HV-PAGAMENTO-OK          :IN-PAGAMENTO-OK )
           END-EXEC

           MOVE SQLCODE TO BKS-SQLCODE
           IF SQLCODE NOT = 0
              MOVE WK-RC-ERRO       TO BKS-RETURN-CODE
              MOVE WK-MSG-ERRO-MENS TO BKS-MENSAGEM
           END-IF.

       END PROGRAM STFSC00I.
