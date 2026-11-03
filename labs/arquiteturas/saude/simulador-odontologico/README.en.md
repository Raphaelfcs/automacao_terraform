# Cost preview simulator

[Português](README.md) · **English**

> AWS platform of a health insurer (2024)

Static front-end with WAF and calculation on EKS.

## Diagram

Editable source: [`desenho.drawio`](desenho.drawio), with pages in Portuguese and English. Open it in draw.io to browse.

The original drawing, anonymized, is kept in [`original/`](original) for reference.

### Cost preview simulator

![Cost preview simulator](desenho-2.png)

## Components found in the diagram

- Amazon EKS → module [`aws/eks-cluster`](../../../../aws/eks-cluster)
- Amazon S3 → module [`aws/s3-bucket`](../../../../aws/s3-bucket)
- API Gateway → module [`aws/api-gateway-lambda`](../../../../aws/api-gateway-lambda)
- Amazon CloudFront → module [`aws/cloudfront-spa`](../../../../aws/cloudfront-spa)
- Amazon VPC → module [`aws/vpc`](../../../../aws/vpc)
- Route 53 → module [`aws/route53-private-zone`](../../../../aws/route53-private-zone)
- AWS WAF: the Web ACL is passed by ARN to CloudFront (`web_acl_id`) or associated with the ALB

## Ready-made automation

The [`terraform/`](terraform) folder composes these catalog modules, in dependency order:

1. [`aws/kms-key`](../../../../aws/kms-key): Chave KMS (CMK) da plataforma
1. [`aws/vpc`](../../../../aws/vpc): VPC em três camadas
1. [`aws/eks-cluster`](../../../../aws/eks-cluster): Cluster EKS privado
1. [`aws/cloudfront-spa`](../../../../aws/cloudfront-spa): SPA em S3 + CloudFront
1. [`aws/route53-private-zone`](../../../../aws/route53-private-zone): Zona Route 53 privada multi-conta

One module's outputs feed the next (for example `module.vpc.private_subnet_ids` and `module.kms_key.key_arn`), so there are no hard-coded IDs between layers.

### How to run

```bash
cd labs/arquiteturas/saude/simulador-odontologico/terraform
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
| [`aws/vpc`](../../../../aws/vpc) | NAT Gateway per AZ and the traffic it processes | a single NAT in DEV and VPC endpoints for S3/ECR to keep traffic off the NAT |
| [`aws/cloudfront-spa`](../../../../aws/cloudfront-spa) | CDN data transfer | good caching and compression; the CDN usually lowers origin egress cost |
| [`aws/kms-key`](../../../../aws/kms-key) | KMS keys per month and API calls | S3 bucket keys reduce KMS calls |
| [`aws/route53-private-zone`](../../../../aws/route53-private-zone) | hosted zones and queries | consolidate private zones shared across VPCs |

The FinOps cycle (inform, optimize, operate) is in the [FinOps process](../../telecom/processo-finops) lab.
To close the loop for this solution, also apply: [`aws/tag-compliance`](../../../../aws/tag-compliance), [`aws/finops-cost-report`](../../../../aws/finops-cost-report), [`aws/cur-focus-export`](../../../../aws/cur-focus-export), [`aws/instance-scheduler`](../../../../aws/instance-scheduler).
