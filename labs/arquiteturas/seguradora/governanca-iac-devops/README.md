# Governança de IaC e DevOps no Azure

**Português** · [English](README.en.md)

> Governança e modernização em Azure para uma seguradora (2024-2025)

Engines versionadas, revisão obrigatória e Azure Pipelines com state por projeto.

## Desenho

Fonte editável: [`desenho.drawio`](desenho.drawio), com páginas em português e em inglês. Abra no draw.io para navegar.

O desenho original, anonimizado, está em [`original/`](original) como referência.

### Governança de IaC e DevOps no Azure

![Governança de IaC e DevOps no Azure](desenho-1.png)

## Componentes identificados no desenho

- Azure Storage → módulo [`azure/storage-account`](../../../../azure/storage-account)

## Automação pronta

A pasta [`terraform/`](terraform) compõe estes módulos do catálogo, na ordem de dependência:

1. [`azure/storage-account`](../../../../azure/storage-account): Storage Account seguro com CMK
1. [`azure/monitor-diagnostic-setting`](../../../../azure/monitor-diagnostic-setting): Diagnostic settings em lote

As saídas de um módulo alimentam o próximo (por exemplo, `module.vpc.private_subnet_ids` e `module.kms_key.key_arn`), então não há IDs fixos entre camadas.

### Como executar

```bash
cd labs/arquiteturas/seguradora/governanca-iac-devops/terraform
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
| [`azure/storage-account`](../../../../azure/storage-account) | capacidade e transações no Storage | tiers Cool/Archive por política de ciclo de vida |
| [`azure/monitor-diagnostic-setting`](../../../../azure/monitor-diagnostic-setting) | ingestão de logs de diagnóstico | enviar só as categorias necessárias e arquivar no Storage |

O ciclo de FinOps (informar, otimizar, operar) está no lab [Processo de FinOps](../../telecom/processo-finops).
