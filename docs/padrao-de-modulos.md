# Padrão de módulos

## Engine (módulo filho)

| Arquivo | Conteúdo |
|---|---|
| `main.tf` | Recursos principais. Começa com um comentário que descreve o módulo (usado no README). |
| `variables.tf` | Entradas tipadas, com `description` e `validation` sempre que houver regra de negócio. |
| `outputs.tf` | IDs, ARNs e nomes que outros módulos consomem. |
| `iam.tf` | Tudo que concede permissão: `aws_iam_*`, `*_policy`, `aws_lambda_permission`, access entries do EKS, `google_*_iam_*`, `azurerm_role_assignment`. |
| `versions.tf` | `required_version` e `required_providers`. Sem bloco `provider` e sem `backend`. |
| `locals.tf` | Valores derivados, quando o módulo precisa. |
| `<tema>.tf` | Partes grandes e coesas do recurso (`routes.tf`, `node-groups.tf`, `addons.tf`, `alarms.tf`). |

Regras:

- Um módulo por recurso ou capacidade. Composição entre módulos acontece no root, via `outputs` e `depends_on`.
- Nenhum valor de ambiente dentro do módulo: nada de conta, região, CIDR ou nome fixo.
- Criptografia, logs e bloqueio de acesso público ligados por padrão; desligar exige variável explícita.
- Tags/labels recebidas por variável e aplicadas em todos os recursos que as suportam.

## Exemplo / root

Cada pasta em `examples/<caso>/` é um root module completo:

| Arquivo | Conteúdo |
|---|---|
| `main.tf` | Providers e a chamada ao módulo (`source = "../.."`). |
| `locals.tf` | Prefixo de nome, região, tags/labels usados pelo `main.tf`. |
| `backend.tf` | `terraform {}` com versões e o backend remoto, com chave própria por módulo e caso. |

Ambientes diferentes reutilizam o mesmo código e mudam só `backend.tf` e `*.tfvars`. Um state por recurso e ambiente
mantém ciclos de vida independentes e o raio de impacto pequeno.

## Testes

`tests/*.tftest.hcl` usa `mock_provider` para executar `terraform test` sem credenciais. Cada exemplo documentado vira um
`run`, garantindo que exemplos e validações continuem compatíveis.

## Diagramas

`diagram.drawio` usa os ícones oficiais de cada nuvem do draw.io (AWS Architecture Icons, Google Cloud e Azure),
linhas sem sobreposição, passos numerados e legenda. `diagram.png` é a prévia renderizada para o README.

## Valores de exemplo

Exemplos usam apenas valores fictícios: conta `123456789012`, IDs `vpc-0123456789abcdef0`, domínios `example.com`,
IPs de documentação (`203.0.113.0/24`) e projeto `demo-plataforma-dev`.
