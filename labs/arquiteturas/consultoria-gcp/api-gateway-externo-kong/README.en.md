# External Kong in the GKE DMZ

[Português](README.md) · **English**

> Network, gateways and data on Google Cloud (2024)

Cloud Armor, external LB, network-policy-isolated Kong and an internal LB to the microservices.

## Diagram

Editable source: [`desenho.drawio`](desenho.drawio), with pages in Portuguese and English. Open it in draw.io to browse.

The original drawing, anonymized, is kept in [`original/`](original) for reference.

### External Kong in the GKE DMZ: AS-IS vs TO-BE

![External Kong in the GKE DMZ: AS-IS vs TO-BE](desenho-2.png)

## Components found in the diagram

- GKE → module [`gcp/gke-private`](../../../../gcp/gke-private)
- Cloud Load Balancing + Cloud Armor → module [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer)

## Ready-made automation

The [`terraform/`](terraform) folder composes these catalog modules, in dependency order:

1. [`gcp/project-foundation`](../../../../gcp/project-foundation): Projeto GCP com APIs e org policies
1. [`gcp/vpc-network`](../../../../gcp/vpc-network): VPC GCP com ranges secundários e PSA
1. [`gcp/gke-private`](../../../../gcp/gke-private): GKE privado com Workload Identity
1. [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer): Load Balancer global + Cloud Armor

One module's outputs feed the next (for example `module.vpc.private_subnet_ids` and `module.kms_key.key_arn`), so there are no hard-coded IDs between layers.

### How to run

```bash
cd labs/arquiteturas/consultoria-gcp/api-gateway-externo-kong/terraform
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
| [`gcp/gke-private`](../../../../gcp/gke-private) | GKE nodes (or pods on Autopilot) | Autopilot to pay per pod, Spot VMs and CUDs for the baseline |
| [`gcp/vpc-network`](../../../../gcp/vpc-network) | Cloud NAT and cross-zone/region traffic | Private Google Access and keep traffic in the same region |
| [`gcp/project-foundation`](../../../../gcp/project-foundation) | cost starts in projects without an owner | labels on every project (the module already applies them) and a budget alert in Billing |
| [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer) | forwarding rules and Cloud Armor | consolidate rules and use Cloud CDN for caching |

The FinOps cycle (inform, optimize, operate) is in the [FinOps process](../../telecom/processo-finops) lab.
