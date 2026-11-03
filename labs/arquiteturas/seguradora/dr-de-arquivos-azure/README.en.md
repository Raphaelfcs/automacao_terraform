# File system DR on Azure

[Português](README.md) · **English**

> Azure governance and modernization for an insurer (2024-2025)

Azure Files with File Sync, GRS replication and cross-region failover via F5.

## Diagram

Editable source: [`desenho.drawio`](desenho.drawio), with pages in Portuguese and English. Open it in draw.io to browse.

The original drawing, anonymized, is kept in [`original/`](original) for reference.

### File system DR on Azure

![File system DR on Azure](desenho-2.png)

## Components found in the diagram

- Azure Storage → module [`azure/storage-account`](../../../../azure/storage-account)

## Ready-made automation

The [`terraform/`](terraform) folder composes these catalog modules, in dependency order:

1. [`azure/storage-account`](../../../../azure/storage-account): Storage Account seguro com CMK

One module's outputs feed the next (for example `module.vpc.private_subnet_ids` and `module.kms_key.key_arn`), so there are no hard-coded IDs between layers.

### How to run

```bash
cd labs/arquiteturas/seguradora/dr-de-arquivos-azure/terraform
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
| [`azure/storage-account`](../../../../azure/storage-account) | Storage capacity and transactions | Cool/Archive tiers through lifecycle policies |

The FinOps cycle (inform, optimize, operate) is in the [FinOps process](../../telecom/processo-finops) lab.
