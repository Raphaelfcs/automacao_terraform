# OCR de documentos em escala

**Português** · [English](README.en.md)

> Plataforma AWS de uma operadora de saúde (2024)

Textract assíncrono, validações em Step Functions, resultados no DynamoDB e API de consulta.

## Desenho

Fonte editável: [`desenho.drawio`](desenho.drawio), com páginas em português e em inglês. Abra no draw.io para navegar.

O desenho original, anonimizado, está em [`original/`](original) como referência.

### OCR de documentos em escala

![OCR de documentos em escala](desenho-1.png)

## Componentes identificados no desenho

- Amazon S3 → módulo [`aws/s3-bucket`](../../../../aws/s3-bucket)
- Amazon SQS → módulo [`aws/sqs-queue`](../../../../aws/sqs-queue)
- Amazon SNS → módulo [`aws/sns-topic`](../../../../aws/sns-topic)
- AWS Lambda → módulo [`aws/lambda-function`](../../../../aws/lambda-function)
- API Gateway → módulo [`aws/api-gateway-lambda`](../../../../aws/api-gateway-lambda)
- Amazon Textract → módulo [`aws/textract-pipeline`](../../../../aws/textract-pipeline)
- Amazon VPC → módulo [`aws/vpc`](../../../../aws/vpc)
- Amazon DynamoDB: tabelas de controle ficam junto do serviço que as usa

## Automação pronta

A pasta [`terraform/`](terraform) compõe estes módulos do catálogo, na ordem de dependência:

1. [`aws/kms-key`](../../../../aws/kms-key): Chave KMS (CMK) da plataforma
1. [`aws/textract-pipeline`](../../../../aws/textract-pipeline): Pipeline de extração com Textract
1. [`aws/sqs-queue`](../../../../aws/sqs-queue): Filas SQS com DLQ
1. [`aws/sns-topic`](../../../../aws/sns-topic): Tópicos SNS com assinaturas
1. [`aws/lambda-function`](../../../../aws/lambda-function): Função Lambda empacotada
1. [`aws/api-gateway-lambda`](../../../../aws/api-gateway-lambda): HTTP API -> Lambda
1. [`aws/cognito-user-pool`](../../../../aws/cognito-user-pool): Cognito como IdP OAuth2/OIDC

As saídas de um módulo alimentam o próximo (por exemplo, `module.vpc.private_subnet_ids` e `module.kms_key.key_arn`), então não há IDs fixos entre camadas.

### Como executar

```bash
cd labs/arquiteturas/saude/ocr-de-documentos/terraform
# ajuste locals.tf (prefixo, região, tags) e backend.tf (bucket/conta de state)
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

Valores de exemplo (contas, IDs, domínios) são fictícios; troque pelos do seu ambiente antes do apply.

## FinOps desta arquitetura

O que mais pesa na conta desta solução e a alavanca para cada item:

| Componente | O que pesa | Alavanca |
|---|---|---|
| [`aws/textract-pipeline`](../../../../aws/textract-pipeline) | custo por página processada no Textract | filtrar e classificar antes de extrair e usar só as features necessárias (texto x formulário x tabela) |
| [`aws/lambda-function`](../../../../aws/lambda-function) | duração x memória das funções | ajustar memória com Power Tuning e usar arm64 |
| [`aws/cognito-user-pool`](../../../../aws/cognito-user-pool) | usuários ativos por mês (MAU) no Cognito | escolher o tier certo e limpar contas inativas |
| [`aws/kms-key`](../../../../aws/kms-key) | chaves KMS por mês e chamadas de API | bucket keys no S3 reduzem chamadas ao KMS |
| [`aws/sqs-queue`](../../../../aws/sqs-queue) | requisições nas filas | long polling e envio em lote |
| [`aws/sns-topic`](../../../../aws/sns-topic) | mensagens e entregas por protocolo | filtros de assinatura para não entregar o que o consumidor descarta |
| [`aws/api-gateway-lambda`](../../../../aws/api-gateway-lambda) | requisições no API Gateway | HTTP API em vez de REST API quando não precisa dos recursos extras, e cache na borda |

O ciclo de FinOps (informar, otimizar, operar) está no lab [Processo de FinOps](../../telecom/processo-finops).
Para fechar o ciclo nesta solução, aplique também: [`aws/tag-compliance`](../../../../aws/tag-compliance), [`aws/finops-cost-report`](../../../../aws/finops-cost-report), [`aws/cur-focus-export`](../../../../aws/cur-focus-export), [`aws/instance-scheduler`](../../../../aws/instance-scheduler).
