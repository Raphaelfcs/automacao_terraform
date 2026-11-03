# Google Cloud resource and permission tree

[Português](README.md) · **English**

> Architecture case studies (2026)

Organization, per-environment folders, projects and groups with roles granted at the right level of the hierarchy.

## Diagram

Editable source: [`desenho.drawio`](desenho.drawio), with pages in Portuguese and English. Open it in draw.io to browse.

### Google Cloud — resource and permission tree

![Google Cloud — resource and permission tree](desenho-2.png)

## Components found in the diagram

- GKE → module [`gcp/gke-private`](../../../../gcp/gke-private)
- Cloud SQL → module [`gcp/cloud-sql`](../../../../gcp/cloud-sql)
- VPC do Google Cloud → module [`gcp/vpc-network`](../../../../gcp/vpc-network)
- Projetos e org policies → module [`gcp/project-foundation`](../../../../gcp/project-foundation)

## Ready-made automation

The [`terraform/`](terraform) folder composes these catalog modules, in dependency order:

1. [`gcp/project-foundation`](../../../../gcp/project-foundation): Projeto GCP com APIs e org policies

One module's outputs feed the next (for example `module.vpc.private_subnet_ids` and `module.kms_key.key_arn`), so there are no hard-coded IDs between layers.

### How to run

```bash
cd labs/arquiteturas/estudos-de-caso/arvore-iam-google-cloud/terraform
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
| [`gcp/project-foundation`](../../../../gcp/project-foundation) | cost starts in projects without an owner | labels on every project (the module already applies them) and a budget alert in Billing |

The FinOps cycle (inform, optimize, operate) is in the [FinOps process](../../telecom/processo-finops) lab.
