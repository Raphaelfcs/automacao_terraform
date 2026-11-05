# automacao_terraform

**Português** · [English](README.en.md)

Catálogo de módulos Terraform (AWS, Google Cloud e Azure) consolidado a partir de projetos reais de
arquitetura cloud entre 2017 e 2026: landing zones, plataformas de containers, dados, integração, FinOps e governança.
Cada módulo é uma *engine* reutilizável, com exemplos prontos, testes e diagrama de arquitetura.

> Projeto idealizado em setembro de 2017. Com a correria dos projetos, o repositório não foi mantido em dia;
> o conteúdo está sendo publicado e atualizado agora. Cada módulo informa no README quando foi idealizado.

**63 módulos** · AWS: 52 · Microsoft Azure: 4 · Google Cloud: 7

## Estrutura

```text
<nuvem>/<recurso>/
├── main.tf            # recursos principais
├── variables.tf       # entradas com validação
├── outputs.tf         # saídas consumidas por outros módulos
├── iam.tf             # políticas, papéis e permissões do recurso
├── versions.tf        # Terraform e providers
├── <tema>.tf          # arquivos específicos do recurso (ex.: routes.tf, addons.tf)
├── examples/<caso>/   # main.tf, locals.tf, backend.tf (state isolado por caso)
├── tests/             # terraform test com providers simulados
├── diagram.drawio     # arquitetura editável (ícones oficiais + legenda)
├── diagram.png        # prévia renderizada
└── README.md
```

Padrões e convenções: [`docs/padrao-de-modulos.md`](docs/padrao-de-modulos.md).

## AWS

| Módulo | Categoria | Descrição |
|---|---|---|
| [`acm-expiry-alert`](aws/acm-expiry-alert) | automacao | Alerta de expiração de certificados |
| [`api-gateway-lambda`](aws/api-gateway-lambda) | integracao | HTTP API -> Lambda |
| [`autoscaling-schedule`](aws/autoscaling-schedule) | finops | Desligamento agendado de node groups |
| [`backup-plan`](aws/backup-plan) | automacao | AWS Backup centralizado |
| [`bastion-ssm`](aws/bastion-ssm) | containers | Bastion SSM-only para EKS privado |
| [`budget-guardrail`](aws/budget-guardrail) | finops | Teto de custo com congelamento por SCP |
| [`cloudfront-spa`](aws/cloudfront-spa) | borda | SPA em S3 + CloudFront |
| [`cloudwatch-logs`](aws/cloudwatch-logs) | observabilidade | Log group de aplicação + IRSA do coletor |
| [`cognito-user-pool`](aws/cognito-user-pool) | seguranca | Cognito como IdP OAuth2/OIDC |
| [`control-tower-account-vending`](aws/control-tower-account-vending) | governanca | Conta pela Account Factory do Control Tower |
| [`control-tower-aft`](aws/control-tower-aft) | governanca | Account Factory for Terraform (AFT) sem VPC |
| [`control-tower-landing-zone`](aws/control-tower-landing-zone) | governanca | Control Tower: landing zone 4.0 |
| [`control-tower-ou-registration`](aws/control-tower-ou-registration) | governanca | Registro de OUs no Control Tower |
| [`cur-focus-export`](aws/cur-focus-export) | finops | Exportação de custos FOCUS 1.0 |
| [`ecr`](aws/ecr) | containers | Repositórios ECR com scan, KMS e retenção |
| [`eks-addons`](aws/eks-addons) | containers | Addons de plataforma EKS |
| [`eks-argocd`](aws/eks-argocd) | devops | Argo CD bootstrap (GitOps) |
| [`eks-cluster`](aws/eks-cluster) | containers | Cluster EKS privado |
| [`eks-fluent-bit`](aws/eks-fluent-bit) | observabilidade | Fluent Bit -> CloudWatch Logs |
| [`eks-node-group`](aws/eks-node-group) | containers | Node groups EKS com launch template |
| [`elasticache-redis`](aws/elasticache-redis) | dados | ElastiCache Valkey/Redis cifrado |
| [`eventbridge-bus-sqs`](aws/eventbridge-bus-sqs) | integracao | Barramento de eventos entre contas -> SQS |
| [`finops-cost-report`](aws/finops-cost-report) | automacao | Relatório diário de custos |
| [`iam-github-oidc`](aws/iam-github-oidc) | devops | GitHub Actions -> AWS por OIDC |
| [`iam-group`](aws/iam-group) | seguranca | Grupo IAM com MFA obrigatório |
| [`iam-inventory-export`](aws/iam-inventory-export) | automacao | Inventário IAM semanal |
| [`iam-mfa-audit`](aws/iam-mfa-audit) | automacao | Auditoria de MFA |
| [`identity-center-groups`](aws/identity-center-groups) | seguranca | IAM Identity Center: grupos e usuários |
| [`identity-center-permission-set`](aws/identity-center-permission-set) | seguranca | IAM Identity Center: permission sets e atribuições |
| [`instance-scheduler`](aws/instance-scheduler) | automacao | Agendador FinOps de EC2/RDS |
| [`kms-key`](aws/kms-key) | seguranca | Chave KMS (CMK) da plataforma |
| [`lambda-function`](aws/lambda-function) | computacao | Função Lambda empacotada |
| [`msk-kafka`](aws/msk-kafka) | integracao | Amazon MSK com SASL/IAM |
| [`network-hub`](aws/network-hub) | rede | Conta Network hub-and-spoke |
| [`organizations-scp`](aws/organizations-scp) | governanca | Organizations: OUs, SCPs e Tag Policy |
| [`rds-aurora`](aws/rds-aurora) | dados | Amazon Aurora (MySQL/PostgreSQL, provisionado ou Serverless v2) |
| [`rds-instance`](aws/rds-instance) | dados | RDS MySQL/PostgreSQL privado |
| [`route53-private-zone`](aws/route53-private-zone) | rede | Zona Route 53 privada multi-conta |
| [`route53-public-zone`](aws/route53-public-zone) | rede | Zona Route 53 pública com certificado curinga |
| [`route53-zone-delegation`](aws/route53-zone-delegation) | rede | Delegação de subdomínio entre contas |
| [`s3-bucket`](aws/s3-bucket) | armazenamento | Bucket S3 seguro por padrão |
| [`security-baseline`](aws/security-baseline) | seguranca | Baseline de segurança da organização |
| [`security-group`](aws/security-group) | rede | Security group declarativo |
| [`sns-topic`](aws/sns-topic) | integracao | Tópicos SNS com assinaturas |
| [`sqs-queue`](aws/sqs-queue) | integracao | Filas SQS com DLQ |
| [`tag-compliance`](aws/tag-compliance) | automacao | Conformidade de tags por evento |
| [`textract-pipeline`](aws/textract-pipeline) | automacao | Pipeline de extração com Textract |
| [`tf-backend-bootstrap`](aws/tf-backend-bootstrap) | devops | Bootstrap do backend S3 do Terraform |
| [`transit-gateway-attachment`](aws/transit-gateway-attachment) | rede | Attachment de VPC ao Transit Gateway |
| [`vpc`](aws/vpc) | rede | VPC em três camadas |
| [`vpc-endpoints`](aws/vpc-endpoints) | rede | VPC Endpoints Interface/Gateway |
| [`vpn-site-to-site`](aws/vpn-site-to-site) | rede | VPN Site-to-Site (TGW/VGW) declarativa |

## Microsoft Azure

| Módulo | Categoria | Descrição |
|---|---|---|
| [`monitor-alerts`](azure/monitor-alerts) | observabilidade | Azure Monitor: action group e alertas de métrica |
| [`monitor-diagnostic-setting`](azure/monitor-diagnostic-setting) | observabilidade | Diagnostic settings em lote |
| [`sql-database`](azure/sql-database) | dados | Azure SQL com Entra ID e auditoria |
| [`storage-account`](azure/storage-account) | armazenamento | Storage Account seguro com CMK |

## Google Cloud

| Módulo | Categoria | Descrição |
|---|---|---|
| [`cloud-sql`](gcp/cloud-sql) | dados | Cloud SQL privado |
| [`edge-load-balancer`](gcp/edge-load-balancer) | borda | Load Balancer global + Cloud Armor |
| [`gke-private`](gcp/gke-private) | containers | GKE privado com Workload Identity |
| [`project-foundation`](gcp/project-foundation) | governanca | Projeto GCP com APIs e org policies |
| [`pubsub`](gcp/pubsub) | integracao | Pub/Sub + Cloud Function (notificação) |
| [`static-site`](gcp/static-site) | borda | Site estático em Cloud Storage |
| [`vpc-network`](gcp/vpc-network) | rede | VPC GCP com ranges secundários e PSA |

## Labs e arquiteturas

- [`labs/arquiteturas/`](labs/arquiteturas): 65 desenhos de arquitetura de projetos reais (AWS, Google Cloud, Azure e OCI), anonimizados e redesenhados num padrão único, em português e inglês, com README, seção de FinOps e automação Terraform pronta composta com estes módulos.
- [`padrao-iac/`](padrao-iac): padrão de IaC em monorepo com três esteiras (engine, boilerplate, workload) em GitLab CI, GitHub Actions e Azure DevOps, com esqueleto de exemplo.
- [`pipelines/`](pipelines): pipelines de Terraform e de aplicação em GitLab CI, GitHub Actions, Azure DevOps e Jenkins, com OIDC e GitOps.
- [`kubernetes/`](kubernetes): design de cluster multi-time, estratégias de deploy (rolling, blue-green, canary), Argo CD hub-spoke e DR com Velero.
- [`labs/monitoria-de-guia/`](labs/monitoria-de-guia): Lambda Python agendada que monitora o guia de programação, com alarme e relatório por e-mail.
- [`labs/`](labs): exercícios históricos de cursos, fora do padrão do catálogo.

## Como usar um módulo

```hcl
module "vpc" {
  source = "git::https://github.com/raphaelfcs/automacao_terraform.git//aws/vpc?ref=v1.0.0"

  name_prefix = "app-prod"
  cidr_block  = "10.20.0.0/16"
  azs         = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
}
```

## Qualidade

```bash
make fmt        # terraform fmt -recursive
make validate   # init -backend=false + validate em cada módulo
make test       # terraform test em cada módulo
make lint       # tflint
```

O mesmo fluxo roda no GitHub Actions ([`terraform-ci.yml`](.github/workflows/terraform-ci.yml)), dividido por provedor e visto num painel só:

- cada provedor (AWS, Google Cloud, Azure) roda a sua esteira, com fmt, tflint, checkov e a matriz de módulos com `validate` e `test`. As três vêm do mesmo motor reutilizável ([`_terraform-provedor.yml`](.github/workflows/_terraform-provedor.yml));
- no pull request, só roda o provedor cuja pasta mudou. Na `main`, rodam todos;
- dá para disparar manualmente um provedor só (Actions → terraform-ci → Run workflow);
- o job `resultado` consolida os três e é o check a exigir na proteção de branch.

## Referências

- AWS Well-Architected Framework, Google Cloud Architecture Framework e Azure Well-Architected Framework.
- *Infrastructure as Code* (Kief Morris), *Cloud FinOps* (Storment e Fuller) e *Software Architecture: The Hard Parts* (Ford et al.).

## Licença

MIT. Veja [`LICENSE`](LICENSE).
