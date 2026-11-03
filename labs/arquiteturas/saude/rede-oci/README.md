# Rede híbrida na OCI

**Português** · [English](README.en.md)

> Plataforma AWS de uma operadora de saúde (2024)

Hub com firewalls por região, FastConnect a dois datacenters e peering remoto para DR.

## Desenho

Fonte editável: [`desenho.drawio`](desenho.drawio), com páginas em português e em inglês. Abra no draw.io para navegar.

O desenho original, anonimizado, está em [`original/`](original) como referência.

### Rede híbrida na OCI: hub por região

![Rede híbrida na OCI: hub por região](desenho-1.png)

## Componentes identificados no desenho

- Amazon VPC → módulo [`aws/vpc`](../../../../aws/vpc)
- Transit Gateway → módulo [`aws/transit-gateway-attachment`](../../../../aws/transit-gateway-attachment)

## Automação

Este desenho descreve processo, governança ou rede fora do escopo dos módulos do catálogo; serve de referência para as decisões e não tem automação própria.

## FinOps desta arquitetura

O que mais pesa na conta desta solução e a alavanca para cada item:

| Componente | O que pesa | Alavanca |
|---|---|---|
| Ambiente | tráfego entre nuvens e instâncias ociosas | tags de custo e revisão mensal de interconexão |

O ciclo de FinOps (informar, otimizar, operar) está no lab [Processo de FinOps](../../telecom/processo-finops).
