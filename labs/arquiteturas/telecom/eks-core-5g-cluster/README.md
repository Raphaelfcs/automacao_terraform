# EKS core 5G — sub-redes por interface

**Português** · [English](README.en.md)

> CCoE, landing zone e plataforma de uma operadora de telecom (2025-2026)

Uma sub-rede por plano de tráfego via Multus.

## Desenho

Fonte editável: [`desenho.drawio`](desenho.drawio), com páginas em português e em inglês. Abra no draw.io para navegar.

O desenho original, anonimizado, está em [`original/`](original) como referência.

### EKS core 5G — sub-redes por interface

![EKS core 5G — sub-redes por interface](desenho-1.png)

## Componentes identificados no desenho

- Amazon EKS → módulo [`aws/eks-cluster`](../../../../aws/eks-cluster)
- Amazon VPC → módulo [`aws/vpc`](../../../../aws/vpc)

## Automação

Este desenho detalha o lab [`eks-core-5g`](../eks-core-5g), onde está a automação Terraform.

## FinOps desta arquitetura

O que mais pesa na conta desta solução e a alavanca para cada item:

| Componente | O que pesa | Alavanca |
|---|---|---|
| Ambiente | recursos sem dono e ambientes não produtivos ligados 24h | tags obrigatórias e desligamento fora do horário |

O ciclo de FinOps (informar, otimizar, operar) está no lab [Processo de FinOps](../../telecom/processo-finops).
Para fechar o ciclo nesta solução, aplique também: [`aws/tag-compliance`](../../../../aws/tag-compliance), [`aws/finops-cost-report`](../../../../aws/finops-cost-report), [`aws/cur-focus-export`](../../../../aws/cur-focus-export), [`aws/instance-scheduler`](../../../../aws/instance-scheduler).
