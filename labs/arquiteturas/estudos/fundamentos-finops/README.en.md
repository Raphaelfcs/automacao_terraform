# Study: cost visibility

[Português](README.md) · **English**

> Personal study drafts

Study draft of a cost portal with federated login.

## Diagram

Editable source: [`desenho.drawio`](desenho.drawio), with pages in Portuguese and English. Open it in draw.io to browse.

The original drawing, anonymized, is kept in [`original/`](original) for reference.

### Study: cost visibility for a portal

![Study: cost visibility for a portal](desenho-2.png)

## Components found in the diagram

- Azure Monitor → module [`azure/monitor-alerts`](../../../../azure/monitor-alerts)

## Automation

This drawing describes process, governance or network outside the scope of the catalog modules; it is a reference for decisions and has no automation of its own.

## FinOps for this architecture

What weighs most on the bill for this solution and the lever for each item:

| Component | Cost driver | Lever |
|---|---|---|
| Environment | subscriptions without an owner and idle VMs | tags by policy, Cost Management budgets and Advisor |

The FinOps cycle (inform, optimize, operate) is in the [FinOps process](../../telecom/processo-finops) lab.
