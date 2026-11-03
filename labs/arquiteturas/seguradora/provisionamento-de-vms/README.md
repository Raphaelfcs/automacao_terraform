# Provisionamento de VMs automatizado

**Português** · [English](README.en.md)

> Governança e modernização em Azure para uma seguradora (2024-2025)

Catálogo de VM, automação de IP e tarefas de IPAM, DNS e firewall em paralelo.

## Desenho

Fonte editável: [`desenho.drawio`](desenho.drawio), com páginas em português e em inglês. Abra no draw.io para navegar.

O desenho original, anonimizado, está em [`original/`](original) como referência.

### Provisionamento de VMs: processo atual

![Provisionamento de VMs: processo atual](desenho-1.png)

### Provisionamento de VMs: processo proposto

![Provisionamento de VMs: processo proposto](desenho-2.png)

## Automação pronta

A pasta [`terraform/`](terraform) compõe estes módulos do catálogo, na ordem de dependência:

1. [`azure/sql-database`](../../../../azure/sql-database): Azure SQL com Entra ID e auditoria
1. [`azure/monitor-alerts`](../../../../azure/monitor-alerts): Azure Monitor: action group e alertas de métrica

As saídas de um módulo alimentam o próximo (por exemplo, `module.vpc.private_subnet_ids` e `module.kms_key.key_arn`), então não há IDs fixos entre camadas.

### Como executar

```bash
cd labs/arquiteturas/seguradora/provisionamento-de-vms/terraform
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
| [`azure/sql-database`](../../../../azure/sql-database) | vCores ou DTUs do banco | serverless para cargas intermitentes e reserva para PRD |
| [`azure/monitor-alerts`](../../../../azure/monitor-alerts) | alertas e ingestão no Log Analytics | retenção por tabela e alertas de orçamento (Cost Management) |

O ciclo de FinOps (informar, otimizar, operar) está no lab [Processo de FinOps](../../telecom/processo-finops).
