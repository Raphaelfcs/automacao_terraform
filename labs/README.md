# Labs

Exercícios de cursos e estudos (2019-2021), mantidos como registro histórico de aprendizado.
O código está no estado em que foi escrito na época (sintaxe Terraform 0.12, provider AWS 2.x)
e **não segue** o padrão dos módulos do catálogo. IDs, buckets e IPs foram trocados por valores fictícios.

| Lab | O que pratica | Versão moderna no catálogo |
|---|---|---|
| [`gitlab-ci-terraform-tfvars`](gitlab-ci-terraform-tfvars) | Pipeline GitLab CI aplicando Terraform com `tfvars` por ambiente | [`.github/workflows/terraform-ci.yml`](../.github/workflows/terraform-ci.yml) |
| [`istio-cluster-eks`](istio-cluster-eks) | Cluster Kubernetes em EC2 para laboratório de Istio, SG dinâmico por porta | [`aws/eks-cluster`](../aws/eks-cluster), [`aws/eks-node-group`](../aws/eks-node-group) |

## O que mudou desde então

- `user_data` inline e chave SSH deram lugar a SSM Session Manager ([`aws/bastion-ssm`](../aws/bastion-ssm)).
- `version` dentro do bloco `provider` foi para `required_providers` em `versions.tf`.
- Security group liberando lista de IPs virou regra por security group de origem ([`aws/security-group`](../aws/security-group)).
- Backend sem lock passou a usar `use_lockfile = true` no S3 (Terraform >= 1.10).

O material teórico dos cursos é dos respectivos autores e não está neste repositório; aqui ficam apenas os arquivos `.tf` que escrevi durante os exercícios.
