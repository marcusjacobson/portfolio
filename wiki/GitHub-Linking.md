# Linking GitHub Projects to the Security Compass

This document explains how to connect GitHub repository links to nodes in `ms_security_compass_v17.html` (or whichever version is current).

---

## How it works

Every node in the compass has a corresponding entry in the `D` object inside the `<script>` block at the bottom of the HTML file. To link one or more GitHub projects to a node, add a `github` array to that entry.

When the array is **empty or absent**, the modal shows a greyed-out *"No projects linked yet"* button.

When the array has **one or more entries**, the button becomes active. Clicking it expands an inline list of links inside the modal; clicking again collapses it.

---

## Step-by-step

### 1. Open the HTML file

Open `ms_security_compass_v17.html` in any text editor. Scroll to the bottom and find the `const D={` block inside the `<script>` tag.

### 2. Find the node you want to link

Each entry is keyed by a node ID. For example:

```js
'iac-sentinel':{label:'Sentinel as Code', ...}
```

The full list of node IDs is in the [Node ID reference](#node-id-reference) below.

### 3. Add the `github` array

Add a `github` property to the entry with one object per linked project:

```js
'iac-sentinel':{label:'Sentinel as Code',layer:'IaC / DevSecOps', ...,
  github:[
    {label:'Sentinel Analytics Rules Library', url:'https://github.com/yourname/sentinel-rules'},
    {label:'Sentinel Playbook Templates',      url:'https://github.com/yourname/sentinel-playbooks'}
  ]},
```

Each object takes exactly two fields:

| Field   | Description                                              |
|---------|----------------------------------------------------------|
| `label` | Display name shown in the expanded link list             |
| `url`   | Full URL to the GitHub repo, topic search, or tagged view |

### 4. Save and test

Save the file, open it in a browser, click the node, and verify the *"GitHub projects ↗"* button appears and expands your links correctly.

---

## Useful GitHub URL patterns

You are not limited to linking individual repos. Any GitHub URL works — here are patterns that may be useful as your tagging strategy matures:

| Use case | URL pattern |
|---|---|
| Single repository | `https://github.com/yourname/repo-name` |
| Topic/tag search across your repos | `https://github.com/yourname?tab=repositories&q=topic:purview` |
| Specific topic page | `https://github.com/topics/microsoft-sentinel` |
| Filtered repo search | `https://github.com/yourname?tab=repositories&q=sentinel&type=public` |

To make topic search work well, add topics to your repos via **Repository → Settings → Topics** on GitHub.

---

## Removing a link

Delete the object from the `github` array. If the array becomes empty (`github:[]`) or you remove the property entirely, the node reverts to showing the greyed-out *"No projects linked yet"* button automatically.

---

## Node ID reference

Use these IDs to find the right entry in the `D` object.

### Venn pillars and overlaps

| Node ID | Label |
|---|---|
| `ov-pu` | Microsoft Purview |
| `ov-de-solo` | Defender XDR |
| `ov-en-solo` | Microsoft Entra |
| `ov-pd` | Purview ∩ Defender XDR (Insider risk · DLP) |
| `ov-all` | Zero Trust (all three pillars) |
| `ov-pe` | Purview ∩ Entra (Label-aware access) |
| `ov-de` | Defender XDR ∩ Entra (Identity-driven) |

### Data services

| Node ID | Label |
|---|---|
| `svc-fabric` | Microsoft Fabric |
| `svc-synapse` | Azure Synapse |
| `svc-azuresql` | Azure SQL / Cosmos DB |
| `svc-databricks` | Azure Databricks |
| `svc-powerplatform` | Power Platform / Dataverse |
| `svc-azurestorage` | Azure Storage (Blob / ADLS) |
| `tp-signals` | Third-party & multi-cloud signals |

### Governance hubs

| Node ID | Label |
|---|---|
| `hub-data-map` | Purview Data Map |
| `dspm-hub` | DSPM for AI |
| `sec-copilot` | Security Copilot |

### Inputs

| Node ID | Label |
|---|---|
| `in-m365` | M365 content |
| `in-endpoint` | Endpoint file activity |
| `in-email` | Email / MDO |
| `in-cloudworkload` | Cloud workload alerts |
| `in-signin` | Sign-in signals |
| `in-pim` | PIM activations |

### Outputs

| Node ID | Label |
|---|---|
| `out-labels` | Sensitivity labels |
| `out-dlpalert` | DLP policy alerts |
| `out-incident` | Correlated incidents |
| `out-hunting` | Threat hunting |
| `out-access` | Access decisions |
| `out-risksig` | Risk signals → XDR |

### Compliance pillar

| Node ID | Label |
|---|---|
| `comp-ediscovery` | eDiscovery |
| `comp-records` | Records Management |
| `comp-commcomp` | Comm Compliance |
| `comp-audit` | Audit + DLM |
| `comp-manager` | Compliance Manager |

### AI agents

| Node ID | Label |
|---|---|
| `agent-studio` | Copilot Studio agents |
| `agent-foundry` | Azure AI Foundry agents |
| `agent-365` | Microsoft Agent 365 |
| `m365-copilot` | Microsoft 365 Copilot |
| `entra-agentid` | Entra Agent ID |

### Dependencies

| Node ID | Label |
|---|---|
| `dep-sentinel` | Microsoft Sentinel |
| `dep-azure` | Azure |
| `dep-mde` | Defender for Endpoint |
| `dep-dfc` | Defender for Cloud |
| `dep-intune` | Microsoft Intune |

### IaC / DevSecOps

| Node ID | Label |
|---|---|
| `iac-foundations` | IaC Foundations |
| `iac-purview` | Purview as Code |
| `iac-entra` | Entra as Code |
| `iac-sentinel` | Sentinel as Code |
| `iac-pipeline` | Pipeline Security |
| `iac-dfc` | Defender for Cloud as Code |

### Other

| Node ID | Label |
|---|---|
| `sfi-frame` | Secure Future Initiative |

---

## Example: fully linked entry

```js
'dep-sentinel':{label:'Microsoft Sentinel',layer:'Dependencies',
  color:'#E1F5EE',border:'#0F6E56',text:'#085041',
  what:[...],
  why:[...],
  flows:[...],
  github:[
    {label:'Sentinel-as-Code Deployment Framework', url:'https://github.com/yourname/sentinel-iac'},
    {label:'Custom KQL Detection Rules',            url:'https://github.com/yourname/kql-detections'},
    {label:'SOAR Playbook Library',                 url:'https://github.com/yourname/sentinel-playbooks'}
  ]},
```
