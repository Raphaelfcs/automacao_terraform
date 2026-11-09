# Organizations: OUs, SCPs, RCPs and Tag Policy

[Português](README.md) · **English**

> `aws/organizations-scp` · category **governanca** · origin: Telecom CCoE and landing zone (2025)

> Designed in October 2025. With no time to keep the repository up to date back then, it is being published and updated now.

AWS Organizations governance as code: two-level OUs, preventive SCPs (allowed region, organization and security service protection, root denied, mandatory encryption, tags at creation), a "deny all" SCP for suspended accounts, a FinOps Tag Policy and optional data-perimeter RCPs. Runs in the management account; Control Tower/AFT creates the accounts.

## Architecture

![Diagram](diagram.en.png)

Editable source: [`diagram.drawio`](diagram.drawio) (open it in draw.io / diagrams.net), with Portuguese and English pages.

1. Two-level OUs.
2. Region SCP, security protection, root denied, encryption.
3. Mandatory tags at creation (optional).
4. Tag Policy standardizes FinOps keys.
5. Data-perimeter RCPs (optional, `enable_rcp = true`).

## SCP and RCP: the data perimeter

| | SCP (Service Control Policy) | RCP (Resource Control Policy) |
|---|---|---|
| Limits | what the organization's **identities** can do | who can reach the organization's **resources** |
| Reaches outside identities? | no | yes |
| Example | "nobody here turns CloudTrail off" | "this bucket rejects an outside account, even with a bucket policy opened by mistake" |

With `enable_rcp = true` the module creates two RCPs, attached to the same targets as the SCPs (`attach_target`):

- `rcp-perimetro-de-identidade`: S3, STS (AssumeRole), KMS, SQS and Secrets Manager only accept identities from the organization (`aws:PrincipalOrgID`), AWS services and the accounts in `rcp_trusted_accounts` (partner, backup vendor).
- `rcp-exigir-tls`: denies access to those resources without TLS, wherever it comes from.

Prerequisite: the `RESOURCE_CONTROL_POLICY` type enabled on the organization root. If it is not, the plan fails with a message explaining what to enable, instead of breaking at apply. Start by attaching to a sandbox OU: a wrong RCP blocks legitimate third-party integrations.

## Usage

```hcl
module "organizations_scp" {
  source = "git::https://github.com/raphaelfcs/automacao_terraform.git//aws/organizations-scp?ref=v1.0.0"

  allowed_regions        = ["sa-east-1", "us-east-1"]
  required_tags          = ["CentroCusto", "Ambiente", "Dono"]
  create_tag_enforcement = ["CentroCusto"]
  attach_target          = ["Workloads", "Sandbox"]
  enable_rcp             = true
  tags                   = local.tags
}
```

## Examples

| Example | Files |
|---|---|
| [`landing-zone`](examples/landing-zone) | `main.tf`, `locals.tf`, `backend.tf` |

Each example has its own backend (state isolated per module and example). Different environments only use another `backend.tf`/`*.tfvars`, without duplicating code.

## Inputs

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `allowed_regions` | `list(string)` | `["sa-east-1"]` | no | Allowed regions for data and workloads (data residency). |
| `organizational_units` | `map(object({ parent = string }))` | `{ Security = { parent = "root" } Infr...` | no | Organization OUs. parent = "root" or the name of another top-level OU. |
| `exempt_role_patterns` | `list(string)` | `[ "arn:aws:iam::*:role/AWSControlTowe...` | no | Roles exempt from the protection SCPs (Control Tower, AFT and break-glass). |
| `global_services_exempt` | `list(string)` | `[ "iam:*", "organizations:*", "sts:*"...` | no | Global service actions that the region SCP must not block. |
| `required_tags` | `list(string)` | `["CentroCusto", "Ambiente", "Dono", "...` | no | Tag keys required by the tag policy (FinOps: cost per unit). |
| `attach_target` | `list(string)` | `["root"]` | no | Where to attach the protection SCPs: root (whole organization) or a list of OU names. |
| `tags` | `map(string)` | `{}` | no | Policy tags. |
| `create_tag_enforcement` | `list(string)` | `[]` | no | Tags required AT CREATION of resources (SCP). Empty = SCP not created. Start in a sandbox OU: a wrong SCP blocks deploys. |
| `enable_rcp` | `bool` | `false` | no | Creates the data-perimeter RCPs. Requires RESOURCE_CONTROL_POLICY enabled on the root. |
| `rcp_services` | `list(string)` | `["s3:*", "sts:AssumeRole", "kms:*", ...` | no | Actions covered by the RCPs (only services that support RCPs). |
| `rcp_trusted_accounts` | `list(string)` | `[]` | no | Accounts outside the organization allowed to reach the resources. Empty = organization only. |
| `tag_enforced_actions` | `list(string)` | `[ "ec2:RunInstances", "ec2:CreateVolu...` | no | Create actions subject to the tag requirement (must support tag-on-create). |

## Outputs

| Name | Description |
|---|---|
| `root_id` | Organization root ID. |
| `organization_arn` | Organization ARN (used for the Transit Gateway RAM share). |
| `ou_ids` | OU IDs by name. |
| `ou_arns` | OU ARNs by name. |
| `scp_ids` | IDs of the SCPs created. |
| `rcp_ids` | IDs of the RCPs created (empty when `enable_rcp = false`). |

## Files

- `iam.tf`: policies, roles and permissions
- `locals.tf`: derived values
- `main.tf`: main resources
- `outputs.tf`: outputs
- `variables.tf`: inputs and validations
- `versions.tf`: Terraform and provider versions
- `examples/`: ready-to-use compositions
- `tests/`: `terraform test` with mocked providers

## Well-Architected

- Security: preventive guardrails at the organization (SCP/org policies) instead of manual fixes; data perimeter with SCP + RCP (SEC03, layered access control).
- Operational excellence: standards applied when the account/project is created, not afterwards.

## Tests

```bash
cd aws/organizations-scp
terraform init -backend=false
terraform test
```
