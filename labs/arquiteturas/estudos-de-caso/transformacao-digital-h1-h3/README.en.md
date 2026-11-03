# Architecture evolution in three horizons

[Português](README.md) · **English**

> Architecture case studies (2026)

Three-horizon modernization roadmap (stabilize, integrate, innovate) for a mid-size company with legacy systems.

## Diagram

Editable source: [`desenho.drawio`](desenho.drawio), with pages in Portuguese and English. Open it in draw.io to browse.

### Case 1 — Evolution architecture (H1, H2, H3)

![Case 1 — Evolution architecture (H1, H2, H3)](desenho-2.png)

## Components found in the diagram

- Amazon EKS → module [`aws/eks-cluster`](../../../../aws/eks-cluster)
- Amazon ECS/Fargate: ECS/Fargate services live in the application repository (task definition + service); network, ECR and database come from here
- Amazon RDS → module [`aws/rds-instance`](../../../../aws/rds-instance)
- ElastiCache → module [`aws/elasticache-redis`](../../../../aws/elasticache-redis)
- Amazon S3 → module [`aws/s3-bucket`](../../../../aws/s3-bucket)
- Amazon SQS → module [`aws/sqs-queue`](../../../../aws/sqs-queue)
- Amazon SNS → module [`aws/sns-topic`](../../../../aws/sns-topic)
- AWS Lambda → module [`aws/lambda-function`](../../../../aws/lambda-function)
- Transit Gateway → module [`aws/transit-gateway-attachment`](../../../../aws/transit-gateway-attachment)
- VPN Site-to-Site → module [`aws/vpn-site-to-site`](../../../../aws/vpn-site-to-site)
- Route 53 → module [`aws/route53-private-zone`](../../../../aws/route53-private-zone)
- AWS Backup → module [`aws/backup-plan`](../../../../aws/backup-plan)
- AWS Organizations / SCP → module [`aws/organizations-scp`](../../../../aws/organizations-scp)
- Amazon CloudWatch → module [`aws/cloudwatch-logs`](../../../../aws/cloudwatch-logs)
- IAM Identity Center → module [`aws/identity-center-permission-set`](../../../../aws/identity-center-permission-set)
- GuardDuty / Security Hub → module [`aws/security-baseline`](../../../../aws/security-baseline)

## Ready-made automation

The [`terraform/`](terraform) folder composes these catalog modules, in dependency order:

1. [`aws/organizations-scp`](../../../../aws/organizations-scp): Organizations: OUs, SCPs e Tag Policy
1. [`aws/security-baseline`](../../../../aws/security-baseline): Baseline de segurança da organização
1. [`aws/kms-key`](../../../../aws/kms-key): Chave KMS (CMK) da plataforma
1. [`aws/vpc`](../../../../aws/vpc): VPC em três camadas
1. [`aws/eks-cluster`](../../../../aws/eks-cluster): Cluster EKS privado
1. [`aws/rds-instance`](../../../../aws/rds-instance): RDS MySQL/PostgreSQL privado
1. [`aws/backup-plan`](../../../../aws/backup-plan): AWS Backup centralizado

One module's outputs feed the next (for example `module.vpc.private_subnet_ids` and `module.kms_key.key_arn`), so there are no hard-coded IDs between layers.

### How to run

```bash
cd labs/arquiteturas/estudos-de-caso/transformacao-digital-h1-h3/terraform
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
| [`aws/eks-cluster`](../../../../aws/eks-cluster) | EKS nodes (EC2) and the per-cluster control plane | node autoscaling (Karpenter/Cluster Autoscaler), Spot for tolerant workloads and Savings Plans for the baseline |
| [`aws/rds-instance`](../../../../aws/rds-instance) | RDS instance class and Multi-AZ | right-size from real metrics, reserve PRD and stop HML/DEV after hours |
| [`aws/vpc`](../../../../aws/vpc) | NAT Gateway per AZ and the traffic it processes | a single NAT in DEV and VPC endpoints for S3/ECR to keep traffic off the NAT |
| [`aws/backup-plan`](../../../../aws/backup-plan) | recovery point retention | retention by criticality and cold storage for long-term copies |
| [`aws/security-baseline`](../../../../aws/security-baseline) | Config, GuardDuty and Security Hub in every account | record only the relevant resource types in Config |
| [`aws/kms-key`](../../../../aws/kms-key) | KMS keys per month and API calls | S3 bucket keys reduce KMS calls |

The FinOps cycle (inform, optimize, operate) is in the [FinOps process](../../telecom/processo-finops) lab.
To close the loop for this solution, also apply: [`aws/tag-compliance`](../../../../aws/tag-compliance), [`aws/finops-cost-report`](../../../../aws/finops-cost-report), [`aws/cur-focus-export`](../../../../aws/cur-focus-export), [`aws/instance-scheduler`](../../../../aws/instance-scheduler).
