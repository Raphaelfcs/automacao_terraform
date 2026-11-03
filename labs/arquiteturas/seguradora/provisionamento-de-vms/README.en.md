# Automated VM provisioning

[Português](README.md) · **English**

> Azure governance and modernization for an insurer (2024-2025)

VM catalog, IP automation and IPAM, DNS and firewall tasks in parallel.

## Diagram

Editable source: [`desenho.drawio`](desenho.drawio), with pages in Portuguese and English. Open it in draw.io to browse.

The original drawing, anonymized, is kept in [`original/`](original) for reference.

### VM provisioning: current vs proposed process

![VM provisioning: current vs proposed process](desenho-2.png)

## Ready-made automation

The [`terraform/`](terraform) folder composes these catalog modules, in dependency order:

1. [`azure/sql-database`](../../../../azure/sql-database): Azure SQL com Entra ID e auditoria
1. [`azure/monitor-alerts`](../../../../azure/monitor-alerts): Azure Monitor: action group e alertas de métrica

One module's outputs feed the next (for example `module.vpc.private_subnet_ids` and `module.kms_key.key_arn`), so there are no hard-coded IDs between layers.

### How to run

```bash
cd labs/arquiteturas/seguradora/provisionamento-de-vms/terraform
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
| [`azure/sql-database`](../../../../azure/sql-database) | database vCores or DTUs | serverless for intermittent workloads and reservations for PRD |
| [`azure/monitor-alerts`](../../../../azure/monitor-alerts) | alerts and Log Analytics ingestion | per-table retention and budget alerts (Cost Management) |

The FinOps cycle (inform, optimize, operate) is in the [FinOps process](../../telecom/processo-finops) lab.
