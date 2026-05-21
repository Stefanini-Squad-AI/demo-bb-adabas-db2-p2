# Mapa de Arquivos e Módulos

Documento máquina-legível para rastrear os programas Natural, as dependências Adabas e os candidatos a serviços COBOL/DB2.

```json
{
  "generatedAt": "2026-05-21",
  "modules": [
    {
      "module": "socios",
      "naturalPrograms": [
        {
          "name": "STFPCS00-P2",
          "path": "prg-natural-p2/STFPCS00-P2.txt",
          "role": "Inclusão e consulta de sócio com acesso direto ao Adabas"
        }
      ],
      "adabasFiles": [
        {
          "name": "ADABAS-SOCIOS",
          "path": "prg-natural-p2/ADABAS-SOCIOS-P2.txt",
          "usage": "Cadastro de sócios com grupo periódico de pagamentos"
        }
      ],
      "adabasOperations": [
        "FIND",
        "STORE"
      ],
      "targetCobolServices": [
        {
          "name": "STFSC00C",
          "operation": "Consulta",
          "purpose": "Localizar sócio por RG e devolver status funcional"
        },
        {
          "name": "STFSC00I",
          "operation": "Inclusão",
          "purpose": "Persistir cadastro de sócio e periodicidades no DB2"
        }
      ],
      "targetDb2Entities": [
        "TB_SOCIO",
        "TB_SOCIO_PERIODICO"
      ],
      "businessRules": [
        "RG do sócio é obrigatório",
        "RG já existente impede inclusão",
        "Nome do sócio é obrigatório",
        "Categoria aceita apenas 1 ou 2",
        "Dia de vencimento aceito apenas em 1, 5, 15, 20 ou 25",
        "Primeira mensalidade deve ser criada como paga",
        "Mensalidades futuras devem ser inicializadas para 12 competências"
      ]
    }
  ]
}
```
