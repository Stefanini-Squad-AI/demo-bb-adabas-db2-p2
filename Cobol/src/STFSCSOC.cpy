      *> STFSCSOC: communication layout Natural <-> COBOL (member + payments).
      *> Operation codes at interface: I A E C (only I and C used by current flow).
      *> Dates on the wire and in DB2: YYYY-MM-DD (PIC X(10)).
      *> COMM-NUM-PAGAMENTOS: number of populated COMM-PAGAMENTO slots (0-100).

       01  SOCIO-DB2-COMM.
           05  COMM-OP-TYPE                  PIC X(01).
      *>      I=inclusion  A=alteration  E=exclusion  C=consultation
           05  COMM-RETURN-CODE              PIC X(02).
      *>      00=OK  01=not found (query)  02=duplicate (insert)  99=error
           05  COMM-NUMB-SOCIO-PRINCIPAL     PIC X(09).
           05  COMM-NOME-SOCIO-PRINCIPAL     PIC X(40).
           05  COMM-DATA-CADASTRO            PIC X(10).
           05  COMM-CATG-SOCIO               PIC X(02).
           05  COMM-INDI-DIVIDA              PIC X(01).
           05  COMM-DATA-BAIXA               PIC X(10).
           05  COMM-HORA-BAIXA               PIC X(12).
           05  COMM-OBSV-SOCIO               PIC X(500).
           05  COMM-NUM-PAGAMENTOS           PIC X(04).
           05  COMM-PAGAMENTO                OCCURS 100 TIMES.
               10  COMM-DATA-VENCIMENTO      PIC X(10).
               10  COMM-VALR-MENSALIDADE     PIC X(12).
               10  COMM-PAGAMENTO-OK         PIC X(01).
