# Plataforma de templates de IaC

> Portal do desenvolvedor e templates de infraestrutura (2024)

Portal do desenvolvedor com catálogo de templates, repositórios, CI/CD de infraestrutura, autenticação e exemplos (RDS), do MVP à arquitetura completa.

## Desenho

Fonte editável: [`desenho.drawio`](desenho.drawio). Abra no draw.io para navegar pelas páginas.

### 1. Repository Structure

![Repository Structure](desenho-1.png)

### 2. Template Authoring

![Template Authoring](desenho-2.png)

### 3. IaC Deployment

![IaC Deployment](desenho-3.png)

### 4. Example RDS

![Example RDS](desenho-4.png)

### 5. MVP

![MVP](desenho-5.png)

### 6. Catalog

![Catalog](desenho-6.png)

### 7. Blueprint

![Blueprint](desenho-7.png)

### 8. Templates

![Templates](desenho-8.png)

### 9. Infrastructure - PRD

![Infrastructure - PRD](desenho-9.png)

### 10. Infrastructure - DEV

![Infrastructure - DEV](desenho-10.png)

### 11. AuthN & AuthZ Details

![AuthN & AuthZ Details](desenho-11.png)

### 12. Git Repositories

![Git Repositories](desenho-12.png)

### 13. CI

![CI](desenho-13.png)

### 14. CD

![CD](desenho-14.png)

### 15. OLD-Catalog

![OLD-Catalog](desenho-15.png)

### 16. CD-IAC

![CD-IAC](desenho-16.png)

## Componentes identificados no desenho

- Amazon ECS/Fargate: serviços em ECS/Fargate ficam no repositório da aplicação (task definition + service); a rede, o ECR e o banco vêm daqui
- Amazon RDS → módulo [`aws/rds-instance`](../../../../aws/rds-instance)
- Amazon S3 → módulo [`aws/s3-bucket`](../../../../aws/s3-bucket)
- AWS Lambda → módulo [`aws/lambda-function`](../../../../aws/lambda-function)
- API Gateway → módulo [`aws/api-gateway-lambda`](../../../../aws/api-gateway-lambda)
- Amazon VPC → módulo [`aws/vpc`](../../../../aws/vpc)
- Route 53 → módulo [`aws/route53-private-zone`](../../../../aws/route53-private-zone)
- Amazon ECR → módulo [`aws/ecr`](../../../../aws/ecr)
- Amazon EventBridge → módulo [`aws/eventbridge-bus-sqs`](../../../../aws/eventbridge-bus-sqs)
- Amazon MSK → módulo [`aws/msk-kafka`](../../../../aws/msk-kafka)
- AWS Secrets Manager: a senha master do RDS já é gerenciada pelo próprio RDS no Secrets Manager; segredos de aplicação entram via External Secrets
- Amazon DynamoDB: tabelas de controle ficam junto do serviço que as usa
- Amazon CloudWatch → módulo [`aws/cloudwatch-logs`](../../../../aws/cloudwatch-logs)

## Automação pronta

A pasta [`terraform/`](terraform) compõe estes módulos do catálogo, na ordem de dependência:

1. [`aws/tf-backend-bootstrap`](../../../../aws/tf-backend-bootstrap): Bootstrap do backend S3 do Terraform
1. [`aws/iam-github-oidc`](../../../../aws/iam-github-oidc): GitHub Actions -> AWS por OIDC
1. [`aws/kms-key`](../../../../aws/kms-key): Chave KMS (CMK) da plataforma
1. [`aws/vpc`](../../../../aws/vpc): VPC em três camadas
1. [`aws/rds-instance`](../../../../aws/rds-instance): RDS MySQL/PostgreSQL privado

As saídas de um módulo alimentam o próximo (por exemplo, `module.vpc.private_subnet_ids` e `module.kms_key.key_arn`),
então não há IDs fixos entre camadas.

### Como executar

```bash
cd labs/arquiteturas/plataforma-iac/templates-de-iac/terraform
# ajuste locals.tf (prefixo, região, tags) e backend.tf (bucket/conta de state)
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

Valores de exemplo (contas, IDs, domínios) são fictícios; troque pelos do seu ambiente antes do apply.
