# Secure GKE end to end

[Português](README.md) · **English**

> Google Cloud reference architectures (2026)

Private GKE lab with Workload Identity, private Cloud SQL, Pub/Sub and a Cloud Armor edge.

## Diagram

Editable source: [`desenho.drawio`](desenho.drawio), with pages in Portuguese and English. Open it in draw.io to browse.

### 1 · Architecture and journey

![1 · Architecture and journey](desenho-4.png)

### 2 · Foundation and IAM

![2 · Foundation and IAM](desenho-5.png)

### 3 · Terraform structure

![3 · Terraform structure](desenho-6.png)

## Components found in the diagram

- AWS WAF: the Web ACL is passed by ARN to CloudFront (`web_acl_id`) or associated with the ALB
- GKE → module [`gcp/gke-private`](../../../../gcp/gke-private)
- Cloud SQL → module [`gcp/cloud-sql`](../../../../gcp/cloud-sql)
- Pub/Sub → module [`gcp/pubsub`](../../../../gcp/pubsub)
- Cloud Load Balancing + Cloud Armor → module [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer)
- VPC do Google Cloud → module [`gcp/vpc-network`](../../../../gcp/vpc-network)

## Ready-made automation

The [`terraform/`](terraform) folder composes these catalog modules, in dependency order:

1. [`gcp/project-foundation`](../../../../gcp/project-foundation): Projeto GCP com APIs e org policies
1. [`gcp/vpc-network`](../../../../gcp/vpc-network): VPC GCP com ranges secundários e PSA
1. [`gcp/gke-private`](../../../../gcp/gke-private): GKE privado com Workload Identity
1. [`gcp/cloud-sql`](../../../../gcp/cloud-sql): Cloud SQL privado
1. [`gcp/pubsub`](../../../../gcp/pubsub): Pub/Sub + Cloud Function (notificação)
1. [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer): Load Balancer global + Cloud Armor

One module's outputs feed the next (for example `module.vpc.private_subnet_ids` and `module.kms_key.key_arn`), so there are no hard-coded IDs between layers.

### How to run

```bash
cd labs/arquiteturas/google-cloud/gke-seguro/terraform
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
| [`gcp/cloud-sql`](../../../../gcp/cloud-sql) | Cloud SQL vCPU/memory and HA | right-size from metrics, CUDs for PRD and stop non-production |
| [`gcp/vpc-network`](../../../../gcp/vpc-network) | Cloud NAT and cross-zone/region traffic | Private Google Access and keep traffic in the same region |
| [`gcp/project-foundation`](../../../../gcp/project-foundation) | cost starts in projects without an owner | labels on every project (the module already applies them) and a budget alert in Billing |
| [`gcp/pubsub`](../../../../gcp/pubsub) | message volume and retention | minimum retention and subscription filters |
| [`gcp/edge-load-balancer`](../../../../gcp/edge-load-balancer) | forwarding rules and Cloud Armor | consolidate rules and use Cloud CDN for caching |

The FinOps cycle (inform, optimize, operate) is in the [FinOps process](../../telecom/processo-finops) lab.
