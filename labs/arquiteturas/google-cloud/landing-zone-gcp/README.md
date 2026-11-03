# Landing zone no Google Cloud

**Português** · [English](README.en.md)

> Arquiteturas de referência no Google Cloud (2026)

Landing zone completa em dez visões: hierarquia, conectividade, GKE e Cloud Run, segurança de dados, DevOps, migração, APIs, web e storage.

## Desenho

Fonte editável: [`desenho.drawio`](desenho.drawio), com páginas em português e em inglês. Abra no draw.io para navegar.

### 1 · Landing zone (árvore de recursos)

![1 · Landing zone (árvore de recursos)](desenho-1.png)

### 2 · Conectividade

![2 · Conectividade](desenho-2.png)

### 3 · GKE e Cloud Run

![3 · GKE e Cloud Run](desenho-3.png)

### 4 · Segurança e dados

![4 · Segurança e dados](desenho-4.png)

### 5 · DevOps e GitOps

![5 · DevOps e GitOps](desenho-5.png)

### 6 · Migração de cargas

![6 · Migração de cargas](desenho-6.png)

### 7 · Migração de dados

![7 · Migração de dados](desenho-7.png)

### 8 · APIs e serverless

![8 · APIs e serverless](desenho-8.png)

### 9 · Camada web

![9 · Camada web](desenho-9.png)

### 10 · Storage

![10 · Storage](desenho-10.png)

## Componentes identificados no desenho

- Amazon DynamoDB: tabelas de controle ficam junto do serviço que as usa
- GKE → módulo [`gcp/gke-private`](../../../../gcp/gke-private)
- Cloud SQL → módulo [`gcp/cloud-sql`](../../../../gcp/cloud-sql)
- Pub/Sub → módulo [`gcp/pubsub`](../../../../gcp/pubsub)
- Cloud Load Balancing + Cloud Armor → módulo [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer)
- VPC do Google Cloud → módulo [`gcp/vpc-network`](../../../../gcp/vpc-network)
- Projetos e org policies → módulo [`gcp/project-foundation`](../../../../gcp/project-foundation)
- Cloud Storage → módulo [`gcp/static-site`](../../../../gcp/static-site)

## Automação pronta

A pasta [`terraform/`](terraform) compõe estes módulos do catálogo, na ordem de dependência:

1. [`gcp/project-foundation`](../../../../gcp/project-foundation): Projeto GCP com APIs e org policies
1. [`gcp/vpc-network`](../../../../gcp/vpc-network): VPC GCP com ranges secundários e PSA
1. [`gcp/gke-private`](../../../../gcp/gke-private): GKE privado com Workload Identity
1. [`gcp/cloud-sql`](../../../../gcp/cloud-sql): Cloud SQL privado
1. [`gcp/pubsub`](../../../../gcp/pubsub): Pub/Sub + Cloud Function (notificação)
1. [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer): Load Balancer global + Cloud Armor

As saídas de um módulo alimentam o próximo (por exemplo, `module.vpc.private_subnet_ids` e `module.kms_key.key_arn`), então não há IDs fixos entre camadas.

### Como executar

```bash
cd labs/arquiteturas/google-cloud/landing-zone-gcp/terraform
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
| [`gcp/gke-private`](../../../../gcp/gke-private) | nós do GKE (ou pods no Autopilot) | Autopilot para pagar por pod, Spot VMs e CUDs para a base |
| [`gcp/cloud-sql`](../../../../gcp/cloud-sql) | vCPU/memória e HA do Cloud SQL | dimensionar pela métrica, CUD para PRD e parar não produtivos |
| [`gcp/vpc-network`](../../../../gcp/vpc-network) | Cloud NAT e tráfego entre zonas/regiões | Private Google Access e manter tráfego na mesma região |
| [`gcp/project-foundation`](../../../../gcp/project-foundation) | custo nasce em projetos sem dono | labels em todo projeto (o módulo já aplica) e orçamento com alerta no Billing |
| [`gcp/pubsub`](../../../../gcp/pubsub) | volume de mensagens e retenção | retenção mínima e filtros de assinatura |
| [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer) | regras de encaminhamento e Cloud Armor | consolidar regras e usar Cloud CDN para cache |

O ciclo de FinOps (informar, otimizar, operar) está no lab [Processo de FinOps](../../telecom/processo-finops).
