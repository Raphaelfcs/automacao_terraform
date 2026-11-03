# Kong externo na DMZ do GKE

**Português** · [English](README.en.md)

> Rede, gateways e dados no Google Cloud (2024)

Cloud Armor, LB externo, Kong isolado com network policy e LB interno até os microsserviços.

## Desenho

Fonte editável: [`desenho.drawio`](desenho.drawio), com páginas em português e em inglês. Abra no draw.io para navegar.

O desenho original, anonimizado, está em [`original/`](original) como referência.

### Kong externo na DMZ do GKE: AS-IS x TO-BE

![Kong externo na DMZ do GKE: AS-IS x TO-BE](desenho-1.png)

## Componentes identificados no desenho

- GKE → módulo [`gcp/gke-private`](../../../../gcp/gke-private)
- Cloud Load Balancing + Cloud Armor → módulo [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer)

## Automação pronta

A pasta [`terraform/`](terraform) compõe estes módulos do catálogo, na ordem de dependência:

1. [`gcp/project-foundation`](../../../../gcp/project-foundation): Projeto GCP com APIs e org policies
1. [`gcp/vpc-network`](../../../../gcp/vpc-network): VPC GCP com ranges secundários e PSA
1. [`gcp/gke-private`](../../../../gcp/gke-private): GKE privado com Workload Identity
1. [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer): Load Balancer global + Cloud Armor

As saídas de um módulo alimentam o próximo (por exemplo, `module.vpc.private_subnet_ids` e `module.kms_key.key_arn`), então não há IDs fixos entre camadas.

### Como executar

```bash
cd labs/arquiteturas/consultoria-gcp/api-gateway-externo-kong/terraform
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
| [`gcp/vpc-network`](../../../../gcp/vpc-network) | Cloud NAT e tráfego entre zonas/regiões | Private Google Access e manter tráfego na mesma região |
| [`gcp/project-foundation`](../../../../gcp/project-foundation) | custo nasce em projetos sem dono | labels em todo projeto (o módulo já aplica) e orçamento com alerta no Billing |
| [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer) | regras de encaminhamento e Cloud Armor | consolidar regras e usar Cloud CDN para cache |

O ciclo de FinOps (informar, otimizar, operar) está no lab [Processo de FinOps](../../telecom/processo-finops).
