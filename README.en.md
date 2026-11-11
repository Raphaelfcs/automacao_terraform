# automacao_terraform

[Português](README.md) · **English**

Terraform module catalog (AWS, Google Cloud and Azure) consolidated from real cloud architecture projects between 2017 and 2026:
landing zones, container platforms, data, integration, FinOps and governance.
Each module is a reusable *engine*, with ready-made examples, tests and an architecture diagram.

> Project designed in September 2017. With the rush of projects, the repository was not kept up to date;
> the content is being published and updated now. Each module README says when it was designed.

**77 modules** · AWS: 58 · Microsoft Azure: 4 · Google Cloud: 15

## Hands-on AWS experience: where it lives in the code

These modules come from multi-account environments I built and ran: landing zones with Control Tower and AWS Organizations,
human access centralized in IAM Identity Center, hub-and-spoke networking with hybrid connectivity, and event-driven
governance automations. Each row points to the code, tests and diagram.

| Skill | What was done in practice | Code |
|---|---|---|
| **SCP and RCP** (AWS Organizations) | Two-level OUs; preventive SCPs (allowed regions, protection of CloudTrail/GuardDuty/Config/Security Hub, root denied, mandatory encryption, tags on create, suspended accounts); **data-perimeter RCPs**: resources only accept identities from the organization and declared trusted accounts, with mandatory TLS; budget-triggered freeze SCP | [`organizations-scp`](aws/organizations-scp/README.en.md) · [`budget-guardrail`](aws/budget-guardrail/README.en.md) · [`control-tower-ou-registration`](aws/control-tower-ou-registration/README.en.md) |
| **Control Tower and accounts** | Landing zone 4.0 as code, Log Archive and Audit, OU registration, Account Factory and AFT without a VPC (lower fixed cost) | [`control-tower-landing-zone`](aws/control-tower-landing-zone/README.en.md) · [`control-tower-aft`](aws/control-tower-aft/README.en.md) · [`control-tower-account-vending`](aws/control-tower-account-vending/README.en.md) |
| **IAM Identity Center** | Federated human access with no IAM users: directory groups, permission sets with managed, inline, customer managed policies and permissions boundary, group → account assignments; break-glass and OIDC for pipelines without long-lived keys | [`identity-center-groups`](aws/identity-center-groups/README.en.md) · [`identity-center-permission-set`](aws/identity-center-permission-set/README.en.md) · [`iam-group`](aws/iam-group/README.en.md) · [`iam-github-oidc`](aws/iam-github-oidc/README.en.md) |
| **VPC** | Three tiers per AZ (public, private, data with no internet route), flow logs, Interface/Gateway VPC endpoints for private traffic without NAT, security groups by reference | [`vpc`](aws/vpc/README.en.md) · [`vpc-endpoints`](aws/vpc-endpoints/README.en.md) · [`security-group`](aws/security-group/README.en.md) |
| **Connectivity** | Hub-and-spoke Network account: Transit Gateway shared through RAM, segmented route tables (prod, nonprod, shared), Direct Connect with transit VIF, backup Site-to-Site VPN with BGP, VPC attachments with routes to remote CIDRs | [`network-hub`](aws/network-hub/README.en.md) · [`transit-gateway-attachment`](aws/transit-gateway-attachment/README.en.md) · [`vpn-site-to-site`](aws/vpn-site-to-site/README.en.md) |
| **Route 53** | Private zones with stable names and cross-account authorization, hybrid DNS with Resolver, per-account public zones with wildcard ACM and CAA, cross-account subdomain delegation in its own state | [`route53-private-zone`](aws/route53-private-zone/README.en.md) · [`route53-public-zone`](aws/route53-public-zone/README.en.md) · [`route53-zone-delegation`](aws/route53-zone-delegation/README.en.md) · [`network-hub`](aws/network-hub/README.en.md) |
| **EventBridge and Lambda** | Cross-account bus into SQS with DLQ, archive and replay; least-privilege Lambda with DLQ, X-Ray and schedule, event-pattern or queue triggers; EventBridge Scheduler with time zones | [`eventbridge-bus-sqs`](aws/eventbridge-bus-sqs/README.en.md) · [`lambda-function`](aws/lambda-function/README.en.md) · [`api-gateway-lambda`](aws/api-gateway-lambda/README.en.md) |
| **Governance automations** | CloudTrail → EventBridge → Lambda for tag compliance; MFA audit (Config + Lambda); weekly IAM inventory; code-free certificate expiry alerts; security findings via EventBridge → SNS; EC2/RDS start/stop by tag; daily cost report; guide monitoring in Python | [`tag-compliance`](aws/tag-compliance/README.en.md) · [`iam-mfa-audit`](aws/iam-mfa-audit/README.en.md) · [`iam-inventory-export`](aws/iam-inventory-export/README.en.md) · [`acm-expiry-alert`](aws/acm-expiry-alert/README.en.md) · [`security-baseline`](aws/security-baseline/README.en.md) · [`instance-scheduler`](aws/instance-scheduler/README.en.md) · [`finops-cost-report`](aws/finops-cost-report/README.en.md) · [`labs/monitoria-de-guia`](labs/monitoria-de-guia/README.en.md) |

## Structure

```text
<cloud>/<resource>/
├── main.tf            # main resources
├── variables.tf       # validated inputs
├── outputs.tf         # outputs consumed by other modules
├── iam.tf             # resource policies, roles and permissions
├── versions.tf        # Terraform and providers
├── <topic>.tf         # resource-specific files (e.g. routes.tf, addons.tf)
├── examples/<case>/   # main.tf, locals.tf, backend.tf (state isolated per case)
├── tests/             # terraform test with mocked providers
├── diagram.drawio     # editable architecture (official icons + legend, PT and EN pages)
├── diagram.png / diagram.en.png
└── README.md / README.en.md
```

Standards and conventions (Portuguese): [`docs/padrao-de-modulos.md`](docs/padrao-de-modulos.md).

## AWS

| Module | Category | Description |
|---|---|---|
| [`acm-certificate`](aws/acm-certificate/README.en.md) | borda | DNS-validated ACM certificate |
| [`acm-expiry-alert`](aws/acm-expiry-alert/README.en.md) | automacao | Certificate expiration alerts |
| [`api-gateway-lambda`](aws/api-gateway-lambda/README.en.md) | integracao | HTTP API -> Lambda |
| [`autoscaling-schedule`](aws/autoscaling-schedule/README.en.md) | finops | Scheduled node group shutdown |
| [`backup-plan`](aws/backup-plan/README.en.md) | automacao | Centralized AWS Backup |
| [`bastion-ssm`](aws/bastion-ssm/README.en.md) | containers | SSM-only bastion for private EKS |
| [`budget-guardrail`](aws/budget-guardrail/README.en.md) | finops | Cost cap with SCP freeze |
| [`cloudfront-spa`](aws/cloudfront-spa/README.en.md) | borda | SPA on S3 + CloudFront |
| [`cloudwatch-logs`](aws/cloudwatch-logs/README.en.md) | observabilidade | Application log group + collector IRSA |
| [`cognito-user-pool`](aws/cognito-user-pool/README.en.md) | seguranca | Cognito as OAuth2/OIDC IdP |
| [`control-tower-account-vending`](aws/control-tower-account-vending/README.en.md) | governanca | Account via Control Tower Account Factory |
| [`control-tower-aft`](aws/control-tower-aft/README.en.md) | governanca | Account Factory for Terraform (AFT) without VPC |
| [`control-tower-landing-zone`](aws/control-tower-landing-zone/README.en.md) | governanca | Control Tower: landing zone 4.0 |
| [`control-tower-ou-registration`](aws/control-tower-ou-registration/README.en.md) | governanca | OU registration in Control Tower |
| [`cur-focus-export`](aws/cur-focus-export/README.en.md) | finops | FOCUS 1.0 cost export |
| [`dynamodb-table`](aws/dynamodb-table/README.en.md) | dados | On-demand DynamoDB with stream, PITR and KMS |
| [`ecr`](aws/ecr/README.en.md) | containers | ECR repositories with scan, KMS and retention |
| [`eks-addons`](aws/eks-addons/README.en.md) | containers | EKS platform add-ons |
| [`eks-argocd`](aws/eks-argocd/README.en.md) | devops | Argo CD bootstrap (GitOps) |
| [`eks-cluster`](aws/eks-cluster/README.en.md) | containers | Private EKS cluster |
| [`eks-fluent-bit`](aws/eks-fluent-bit/README.en.md) | observabilidade | Fluent Bit -> CloudWatch Logs |
| [`eks-node-group`](aws/eks-node-group/README.en.md) | containers | EKS node groups with launch template |
| [`elasticache-redis`](aws/elasticache-redis/README.en.md) | dados | Encrypted ElastiCache Valkey/Redis |
| [`eventbridge-bus-sqs`](aws/eventbridge-bus-sqs/README.en.md) | integracao | Cross-account event bus -> SQS |
| [`finops-cost-report`](aws/finops-cost-report/README.en.md) | automacao | Daily cost report |
| [`iam-github-oidc`](aws/iam-github-oidc/README.en.md) | devops | GitHub Actions -> AWS through OIDC |
| [`iam-group`](aws/iam-group/README.en.md) | seguranca | IAM group with mandatory MFA |
| [`iam-inventory-export`](aws/iam-inventory-export/README.en.md) | automacao | Weekly IAM inventory |
| [`iam-mfa-audit`](aws/iam-mfa-audit/README.en.md) | automacao | MFA audit |
| [`iam-role-gcp-federation`](aws/iam-role-gcp-federation/README.en.md) | seguranca | Keyless IAM role for Google Cloud workloads |
| [`identity-center-groups`](aws/identity-center-groups/README.en.md) | seguranca | IAM Identity Center: groups and users |
| [`identity-center-permission-set`](aws/identity-center-permission-set/README.en.md) | seguranca | IAM Identity Center: permission sets and assignments |
| [`instance-scheduler`](aws/instance-scheduler/README.en.md) | automacao | FinOps scheduler for EC2/RDS |
| [`kms-key`](aws/kms-key/README.en.md) | seguranca | Platform KMS key (CMK) |
| [`lambda-function`](aws/lambda-function/README.en.md) | computacao | Packaged Lambda function |
| [`msk-kafka`](aws/msk-kafka/README.en.md) | integracao | Amazon MSK with SASL/IAM |
| [`network-hub`](aws/network-hub/README.en.md) | rede | Hub-and-spoke Network account |
| [`organizations-scp`](aws/organizations-scp/README.en.md) | governanca | Organizations: OUs, SCPs, RCPs and Tag Policy |
| [`rds-aurora`](aws/rds-aurora/README.en.md) | dados | Amazon Aurora (MySQL/PostgreSQL, provisioned or Serverless v2) |
| [`rds-instance`](aws/rds-instance/README.en.md) | dados | Private RDS MySQL/PostgreSQL |
| [`route53-health-routing`](aws/route53-health-routing/README.en.md) | rede | Active-active cross-cloud DNS with health checks |
| [`route53-private-zone`](aws/route53-private-zone/README.en.md) | rede | Multi-account private Route 53 zone |
| [`route53-public-zone`](aws/route53-public-zone/README.en.md) | rede | Public Route 53 zone with wildcard certificate |
| [`route53-records`](aws/route53-records/README.en.md) | rede | Standalone Route 53 DNS records |
| [`route53-zone-delegation`](aws/route53-zone-delegation/README.en.md) | rede | Cross-account subdomain delegation |
| [`s3-bucket`](aws/s3-bucket/README.en.md) | armazenamento | Secure-by-default S3 bucket |
| [`security-baseline`](aws/security-baseline/README.en.md) | seguranca | Organization security baseline |
| [`security-group`](aws/security-group/README.en.md) | rede | Declarative security group |
| [`sns-topic`](aws/sns-topic/README.en.md) | integracao | SNS topics with subscriptions |
| [`sqs-queue`](aws/sqs-queue/README.en.md) | integracao | SQS queues with DLQ |
| [`tag-compliance`](aws/tag-compliance/README.en.md) | automacao | Event-driven tag compliance |
| [`textract-pipeline`](aws/textract-pipeline/README.en.md) | automacao | Textract extraction pipeline |
| [`tf-backend-bootstrap`](aws/tf-backend-bootstrap/README.en.md) | devops | Terraform S3 backend bootstrap |
| [`transit-gateway-attachment`](aws/transit-gateway-attachment/README.en.md) | rede | VPC attachment to Transit Gateway |
| [`vpc`](aws/vpc/README.en.md) | rede | Three-tier VPC |
| [`vpc-endpoints`](aws/vpc-endpoints/README.en.md) | rede | VPC Endpoints Interface/Gateway |
| [`vpn-site-to-site`](aws/vpn-site-to-site/README.en.md) | rede | Declarative Site-to-Site VPN (TGW/VGW) |
| [`waf-web-acl`](aws/waf-web-acl/README.en.md) | borda | AWS WAF with managed rules and per-IP limit |

## Microsoft Azure

| Module | Category | Description |
|---|---|---|
| [`monitor-alerts`](azure/monitor-alerts/README.en.md) | observabilidade | Azure Monitor: action group and metric alerts |
| [`monitor-diagnostic-setting`](azure/monitor-diagnostic-setting/README.en.md) | observabilidade | Diagnostic settings in bulk |
| [`sql-database`](azure/sql-database/README.en.md) | dados | Azure SQL with Entra ID and auditing |
| [`storage-account`](azure/storage-account/README.en.md) | armazenamento | Secure Storage Account with CMK |

## Google Cloud

| Module | Category | Description |
|---|---|---|
| [`cloud-run-service`](gcp/cloud-run-service/README.en.md) | computacao | Cloud Run with its own service account and NEG |
| [`cloud-sql`](gcp/cloud-sql/README.en.md) | dados | Private Cloud SQL |
| [`edge-load-balancer`](gcp/edge-load-balancer/README.en.md) | borda | Global Load Balancer + Cloud Armor |
| [`eventarc-trigger`](gcp/eventarc-trigger/README.en.md) | integracao | Eventarc to a private Cloud Run |
| [`firestore-database`](gcp/firestore-database/README.en.md) | dados | Native Firestore with CMEK, PITR and backups |
| [`gcs-bucket`](gcp/gcs-bucket/README.en.md) | armazenamento | Private Cloud Storage for sensitive data |
| [`gke-private`](gcp/gke-private/README.en.md) | containers | Private GKE with Workload Identity |
| [`kms-key`](gcp/kms-key/README.en.md) | seguranca | Cloud KMS: CMEK key with rotation |
| [`project-foundation`](gcp/project-foundation/README.en.md) | governanca | GCP project with APIs and org policies |
| [`pubsub`](gcp/pubsub/README.en.md) | integracao | Pub/Sub + Cloud Function (notification) |
| [`serverless-edge`](gcp/serverless-edge/README.en.md) | borda | Global edge: HTTPS LB, Cloud Armor and CDN |
| [`service-accounts`](gcp/service-accounts/README.en.md) | seguranca | Service accounts with minimum roles |
| [`static-site`](gcp/static-site/README.en.md) | borda | Static site on Cloud Storage |
| [`vpc-network`](gcp/vpc-network/README.en.md) | rede | GCP VPC with secondary ranges and PSA |
| [`workload-identity-aws`](gcp/workload-identity-aws/README.en.md) | seguranca | Workload Identity Federation AWS -> Google Cloud |

## Complete apps

- [`apps/docs-pacientes/`](apps/docs-pacientes/README.en.md): patient records (exams, diagnoses, prescriptions) as an active-active serverless app on AWS and Google Cloud, event-driven, with per-clinic and per-patient isolation, PWA, Terraform roots per resource and environment, 57 app tests and a cost model (US$ 48/month with 20 clinics, US$ 75 with 100).

## Labs and architectures

- [`labs/arquiteturas/`](labs/arquiteturas/README.en.md): 65 architecture drawings from real projects (AWS, Google Cloud, Azure and OCI), anonymized and redrawn in a single style, in Portuguese and English, with README, a FinOps section and ready-made Terraform automation built from these modules.
- [`padrao-iac/`](padrao-iac/README.en.md): IaC monorepo pattern with three pipelines (engine, boilerplate, workload) in GitLab CI, GitHub Actions and Azure DevOps, with an example skeleton.
- [`pipelines/`](pipelines): Terraform and application pipelines in GitLab CI, GitHub Actions, Azure DevOps and Jenkins, with OIDC and GitOps.
- [`kubernetes/`](kubernetes): multi-team cluster design, deployment strategies (rolling, blue-green, canary), hub-spoke Argo CD and DR with Velero.
- [`labs/monitoria-de-guia/`](labs/monitoria-de-guia/README.en.md): scheduled Python Lambda that monitors the TV program guide, with alarm and email report.
- [`labs/`](labs): historical course exercises, outside the catalog standard.

## Using a module

```hcl
module "vpc" {
  source = "git::https://github.com/raphaelfcs/automacao_terraform.git//aws/vpc?ref=v1.0.0"

  name_prefix = "app-prod"
  cidr_block  = "10.20.0.0/16"
  azs         = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
}
```

## Quality

```bash
make fmt        # terraform fmt -recursive
make validate   # init -backend=false + validate in every module
make test       # terraform test in every module
make lint       # tflint
```

The same flow runs on GitHub Actions ([`terraform-ci.yml`](.github/workflows/terraform-ci.yml)), split by cloud provider and shown on a single panel:

- each provider (AWS, Google Cloud, Azure) runs its own pipeline, with fmt, tflint, checkov and the module matrix with `validate` and `test`. All three come from one reusable engine ([`_terraform-provedor.yml`](.github/workflows/_terraform-provedor.yml));
- on pull requests, only the provider whose folder changed runs. On `main`, all of them run;
- a single provider can be triggered manually (Actions → terraform-ci → Run workflow);
- the `resultado` job consolidates all three and is the check to require in branch protection.

## References

- AWS Well-Architected Framework, Google Cloud Architecture Framework and Azure Well-Architected Framework.
- *Infrastructure as Code* (Kief Morris), *Cloud FinOps* (Storment and Fuller) and *Software Architecture: The Hard Parts* (Ford et al.).

## License

MIT. See [`LICENSE`](LICENSE).
