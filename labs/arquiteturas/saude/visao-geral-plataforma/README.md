# Plataforma AWS de uma operadora de saúde

**Português** · [English](README.en.md)

> Plataforma AWS de uma operadora de saúde (2024)

Backup multi-região com rede compartilhada e a evolução do IaC para um state por recurso e ambiente.

## Desenho

Fonte editável: [`desenho.drawio`](desenho.drawio), com páginas em português e em inglês. Abra no draw.io para navegar.

O desenho original, anonimizado, está em [`original/`](original) como referência.

### Backup multi-região com rede compartilhada

![Backup multi-região com rede compartilhada](desenho-1.png)

### IaC: um state por recurso e por ambiente

![IaC: um state por recurso e por ambiente](desenho-2.png)

## Componentes identificados no desenho

- Amazon S3 → módulo [`aws/s3-bucket`](../../../../aws/s3-bucket)
- AWS KMS → módulo [`aws/kms-key`](../../../../aws/kms-key)
- Amazon VPC → módulo [`aws/vpc`](../../../../aws/vpc)
- Transit Gateway → módulo [`aws/transit-gateway-attachment`](../../../../aws/transit-gateway-attachment)

## Automação pronta

A pasta [`terraform/`](terraform) compõe estes módulos do catálogo, na ordem de dependência:

1. [`aws/kms-key`](../../../../aws/kms-key): Chave KMS (CMK) da plataforma
1. [`aws/vpc`](../../../../aws/vpc): VPC em três camadas
1. [`aws/vpc-endpoints`](../../../../aws/vpc-endpoints): VPC Endpoints Interface/Gateway
1. [`aws/transit-gateway-attachment`](../../../../aws/transit-gateway-attachment): Attachment de VPC ao Transit Gateway
1. [`aws/ecr`](../../../../aws/ecr): Repositórios ECR com scan, KMS e retenção
1. [`aws/backup-plan`](../../../../aws/backup-plan): AWS Backup centralizado

As saídas de um módulo alimentam o próximo (por exemplo, `module.vpc.private_subnet_ids` e `module.kms_key.key_arn`), então não há IDs fixos entre camadas.

### Como executar

```bash
cd labs/arquiteturas/saude/visao-geral-plataforma/terraform
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
| [`aws/vpc`](../../../../aws/vpc) | NAT Gateway por AZ e tráfego que passa por ele | um NAT só em DEV e VPC endpoints para S3/ECR tirarem tráfego do NAT |
| [`aws/transit-gateway-attachment`](../../../../aws/transit-gateway-attachment) | attachments e GB processados no Transit Gateway | consolidar attachments e manter tráfego de alto volume fora do TGW |
| [`aws/ecr`](../../../../aws/ecr) | imagens antigas acumuladas no ECR | lifecycle policy mantendo só as últimas N imagens por repositório |
| [`aws/backup-plan`](../../../../aws/backup-plan) | retenção de recovery points | retenção por criticidade e cold storage para cópias longas |
| [`aws/kms-key`](../../../../aws/kms-key) | chaves KMS por mês e chamadas de API | bucket keys no S3 reduzem chamadas ao KMS |
| [`aws/vpc-endpoints`](../../../../aws/vpc-endpoints) | endpoints de interface cobrados por hora e por AZ | criar só os endpoints que o workload usa e preferir gateway endpoint para S3/DynamoDB |

O ciclo de FinOps (informar, otimizar, operar) está no lab [Processo de FinOps](../../telecom/processo-finops).
Para fechar o ciclo nesta solução, aplique também: [`aws/tag-compliance`](../../../../aws/tag-compliance), [`aws/finops-cost-report`](../../../../aws/finops-cost-report), [`aws/cur-focus-export`](../../../../aws/cur-focus-export), [`aws/instance-scheduler`](../../../../aws/instance-scheduler).
