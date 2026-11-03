# Batch processing with AWS Batch

[Português](README.md) · **English**

> AWS platform of a health insurer (2024)

S3 event submits a Batch job with on-demand compute and output to DynamoDB.

## Diagram

Editable source: [`desenho.drawio`](desenho.drawio), with pages in Portuguese and English. Open it in draw.io to browse.

The original drawing, anonymized, is kept in [`original/`](original) for reference.

### Batch processing with AWS Batch

![Batch processing with AWS Batch](desenho-2.png)

## Components found in the diagram

- Amazon ECS/Fargate: ECS/Fargate services live in the application repository (task definition + service); network, ECR and database come from here
- Amazon S3 → module [`aws/s3-bucket`](../../../../aws/s3-bucket)
- Amazon VPC → module [`aws/vpc`](../../../../aws/vpc)
- Amazon EventBridge → module [`aws/eventbridge-bus-sqs`](../../../../aws/eventbridge-bus-sqs)
- AWS Batch: batch jobs can be triggered by the EventBridge rule created here
- Amazon DynamoDB: control tables live with the service that uses them

## Ready-made automation

The [`terraform/`](terraform) folder composes these catalog modules, in dependency order:

1. [`aws/s3-bucket`](../../../../aws/s3-bucket): Bucket S3 seguro por padrão
1. [`aws/eventbridge-bus-sqs`](../../../../aws/eventbridge-bus-sqs): Barramento de eventos entre contas -> SQS
1. [`aws/lambda-function`](../../../../aws/lambda-function): Função Lambda empacotada

One module's outputs feed the next (for example `module.vpc.private_subnet_ids` and `module.kms_key.key_arn`), so there are no hard-coded IDs between layers.

### How to run

```bash
cd labs/arquiteturas/saude/processamento-em-lote/terraform
# adjust locals.tf (prefix, region, tags) and backend.tf (state bucket/account)
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

Sample values (accounts, IDs, domains) are fictitious; replace them with your own before applying.

## FinOps for this architecture

What weighs most on the bill for this solution and the lever for each item:

| Component | Cost driver | Lever |
|---|---|---|
| [`aws/s3-bucket`](../../../../aws/s3-bucket) | S3 storage and old object versions | lifecycle to IA/Glacier and expiration of noncurrent versions |
| [`aws/lambda-function`](../../../../aws/lambda-function) | function duration × memory | tune memory with Power Tuning and use arm64 |
| [`aws/eventbridge-bus-sqs`](../../../../aws/eventbridge-bus-sqs) | published custom events | group events and filter in the rule |

The FinOps cycle (inform, optimize, operate) is in the [FinOps process](../../telecom/processo-finops) lab.
To close the loop for this solution, also apply: [`aws/tag-compliance`](../../../../aws/tag-compliance), [`aws/finops-cost-report`](../../../../aws/finops-cost-report), [`aws/cur-focus-export`](../../../../aws/cur-focus-export), [`aws/instance-scheduler`](../../../../aws/instance-scheduler).
