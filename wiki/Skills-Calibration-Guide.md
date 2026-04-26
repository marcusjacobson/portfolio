# Skills Calibration Guide
**Internal reference — not published**
Last calibrated: April 2026

Use this guide to:
1. Re-assess ratings when new projects are published
2. Identify project ideas that would move specific ratings
3. Keep the inventory honest as the portfolio grows

---

## Rating scale (binding definitions)

| Stars | Label | What it means |
|---|---|---|
| ★☆☆☆☆ | Awareness | Can describe the feature, have used the portal, no production/lab configuration |
| ★★☆☆☆ | Foundational | Configured in lab or followed guided steps; template-based or narrowly scoped work |
| ★★★☆☆ | Practitioner | Designed and delivered end-to-end in real or production-equivalent lab; can explain decisions |
| ★★★★☆ | Advanced | Delivered across multiple scenarios, troubleshot edge cases, can advise others |
| ★★★★★ | Expert | Deep specialist command; extends, teaches, handles non-standard architectures |

**Tag definitions:**
- `Current` — demonstrated in a completed lab or production delivery
- `Developing` — understand the area conceptually; hands-on exposure is limited or incomplete

**Promotion rule:** a skill moves from Developing → Current when a project demonstrates end-to-end delivery (not just partial config or template-following). A rating increases when a new project adds a meaningfully different scenario, edge case, or depth dimension to what was previously demonstrated.

---

## Per-skill criteria and project ideas

---

### MICROSOFT PURVIEW

---

#### Sensitivity Label Taxonomy Design
**Current rating:** ★★★★☆ Current
**Evidence base:** Full taxonomy with sublabels and protection actions deployed in lab; Fabric label propagation.

**To reach ★★★★★:**
- Design a multi-jurisdiction taxonomy (e.g. GDPR + HIPAA labels coexisting with inheritance rules)
- Demonstrate label migration from a legacy AIP/MPIP deployment with versioning
- Document an advisory-grade taxonomy decision framework (why each label exists, scope, protection action rationale)

**Project ideas:**
- "Regulated industry label taxonomy" — design a taxonomy for a fictional financial services firm covering PCI, NYDFS, and internal classification tiers; document the design decisions, not just the config
- Label migration simulation — start with a flat legacy structure and migrate to a sublabel hierarchy without breaking existing content

---

#### Data Loss Prevention (DLP) Policy Design
**Current rating:** ★★★★☆ Current
**Evidence base:** Fabric DLP + M365 DLP across two labs; policy scoping and alert tuning confirmed.

**To reach ★★★★★:**
- Author DLP policies scoped to endpoint (MDE-enforced DLP, not just Exchange/SharePoint)
- Build policies with custom SITs (Sensitive Information Types) rather than built-in classifiers
- Show policy simulation mode → tuning cycle → production rollout with documented false positive reduction

**Project ideas:**
- "Custom SIT + DLP policy" lab — define a custom regex-based SIT for a fictional data type (e.g. internal project codes), build a DLP policy around it, run simulation, tune, document
- "Endpoint DLP" extension to existing lab — add MDE-enforced DLP policies covering USB, clipboard, and print scenarios

---

#### Auto-Labeling Policy Configuration
**Current rating:** ★★★☆☆ Current
**Evidence base:** Label propagation into Fabric items confirmed; auto-label policy authoring not explicitly confirmed as a separate exercise.

**To reach ★★★★☆:**
- Author both client-side and service-side auto-labeling policies with trainable classifiers or custom SITs
- Demonstrate simulation mode, review matched items, tune conditions
- Show auto-label interacting with DLP policy (label triggers DLP block)

**Project ideas:**
- "Auto-labeling pipeline" lab — configure service-side auto-label for SharePoint and Exchange using a custom SIT; run simulation; show before/after content scan results
- Extend existing Purview lab to add auto-label policies that feed into the existing DLP ruleset

---

#### Insider Risk Management
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** None. No project work confirmed.

**To reach ★★★☆☆ Current:**
- Configure an IRM policy (e.g. data theft by departing users) with indicator thresholds
- Review generated alerts and walk through the investigation workflow
- Connect IRM risk signal to a DLP policy or Defender XDR alert

**Project ideas:**
- "IRM + DLP integration" lab — configure a departing user policy, trigger with simulated file exfiltration, review the alert, show how the IRM risk signal surfaces in XDR
- Add IRM as a module to the existing Purview Compliance capstone (planned project)

---

#### eDiscovery & Compliance Hold Workflows
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** None. No project work confirmed.

**To reach ★★★☆☆ Current:**
- Place a mailbox and SharePoint site on litigation hold
- Run a content search scoped to custodians, keywords, and date range
- Export results and document the chain of custody steps

**Project ideas:**
- "eDiscovery simulation" — simulate an HR investigation: place holds on relevant custodians, run a search, export results, document the workflow
- Fold into the Purview Compliance capstone as the eDiscovery module

---

#### Compliance Manager & Regulatory Mapping
**Current rating:** ★★★☆☆ Current
**Evidence base:** Azure Policy for compliance assignments + classification mapping in labs; Compliance Manager used adjacently.

**To reach ★★★★☆:**
- Complete a full improvement action cycle: identify a failing control, remediate, verify score change, document
- Map a real regulatory framework (NIST 800-53, NYDFS Part 500) to Compliance Manager assessments and identify gaps
- Build a custom assessment template for a framework not built-in

**Project ideas:**
- "NYDFS Part 500 Compliance Manager assessment" — build the assessment, walk through each domain, document gap findings and remediation actions
- "Custom assessment template" lab — create a Compliance Manager template for a fictional internal security policy framework

---

#### DSPM for AI & Data Security Posture
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** None confirmed. High strategic priority given AI Security Architect role profile.

**To reach ★★★☆☆ Current:**
- Run a DSPM for AI assessment against a tenant with M365 Copilot enabled (or simulated)
- Review oversharing exposure findings in Activity Explorer
- Connect findings to a Purview label/DLP remediation action

**Project ideas:**
- "DSPM for AI assessment" lab — enable DSPM for AI, review the Activity Explorer findings, document oversharing risk by data sensitivity tier, propose remediation using existing label taxonomy
- This is a direct unlock for the AI Security Architect role profile — high ROI project

---

#### Purview as Code (IaC / PowerShell)
**Current rating:** ★★★☆☆ Developing
**Evidence base:** In-progress project; Sentinel as Code Bicep experience transfers.

**To reach ★★★☆☆ Current (flip tag):**
- Ship a working pipeline that deploys at least one Purview artifact (label, DLP policy, or retention policy) via PowerShell or Graph API
- Version-control the config in GitHub with a basic PR workflow

**To reach ★★★★☆:**
- Full label taxonomy + DLP policy + retention policy deployed via pipeline
- Staging vs production tenant separation with validation step before apply

**Project ideas:**
- Complete the in-progress Purview as Code project — even partial (labels only) is enough to flip to Current
- "Purview config drift detection" — script that reads current Purview config, diffs against repo state, raises a GitHub issue on drift

---

### MICROSOFT ENTRA ID

---

#### Conditional Access Policy Design
**Current rating:** ★★★★☆ Current
**Evidence base:** MFA, compliant device, named location conditions confirmed hands-on.

**To reach ★★★★★:**
- Implement authentication strength policies (phishing-resistant MFA tiers)
- Design a full CA policy set with break-glass accounts, exclusion management, and policy conflict resolution
- Demonstrate CA policy testing in report-only mode with documented rollout plan

**Project ideas:**
- "CA policy framework" lab — design a complete policy set (baseline, privileged, legacy auth block, guest access) with documented exclusion strategy and break-glass account handling
- Entra as Code project (planned) — CA policies deployed via Terraform Entra provider with staging tenant validation

---

#### Privileged Identity Management (PIM)
**Current rating:** ★★★☆☆ Current
**Evidence base:** Role assignments and activation workflows confirmed.

**To reach ★★★★☆:**
- Configure PIM for Azure resource roles (not just Entra directory roles)
- Build PIM access reviews for privileged roles with documented reviewer workflow
- Configure PIM alerts and integrate into Sentinel for privileged activation monitoring

**Project ideas:**
- "PIM + Sentinel alert" lab — configure a PIM activation alert that fires a Sentinel analytic rule and creates an incident for SOC review
- Add PIM coverage to the Entra as Code project — PIM role settings version-controlled in Terraform

---

#### Identity Governance & Entitlement Management
**Current rating:** ★★★☆☆ Current
**Evidence base:** Access packages, access reviews, entitlement management confirmed.

**To reach ★★★★☆:**
- Build a multi-stage approval access package with connected resource roles
- Run an access review and document the remediation of stale access
- Connect lifecycle workflows (Joiner/Mover/Leaver) to access package assignment

**Project ideas:**
- "Lifecycle workflow + access package" lab — configure a Joiner workflow that auto-assigns an access package on hire; Leaver workflow that revokes it on termination
- "Access review campaign" lab — run a quarterly access review for a privileged group, document findings, remediate stale access

---

#### Multi-Factor Authentication (MFA) Deployment
**Current rating:** ★★★★☆ Current
**Evidence base:** CA-enforced + per-user MFA at scale confirmed.

**To reach ★★★★★:**
- Deploy and enforce phishing-resistant MFA (passkeys / FIDO2 / CBA) not just TOTP/push
- Migrate from legacy per-user MFA to CA-enforced with documented rollout and exclusion handling

**Project ideas:**
- "Phishing-resistant MFA" lab — register FIDO2 keys, configure authentication strength policy in CA, enforce for privileged roles

---

#### External Identities & B2B Collaboration
**Current rating:** ★★★☆☆ Current
**Evidence base:** B2B guest configuration confirmed hands-on.

**To reach ★★★★☆:**
- Configure cross-tenant access settings (inbound/outbound trust policies)
- Build an entitlement management access package scoped to external guests with auto-expiry
- Implement B2B direct connect for Teams shared channels

**Project ideas:**
- "B2B governance" lab — configure a guest access package with access reviews and auto-expiry; set cross-tenant trust policies limiting which external tenants can authenticate

---

#### Zero Trust Architecture (Identity Layer)
**Current rating:** ★★★★☆ Current
**Evidence base:** Breadth across CA, MFA, IaC, Identity Protection confirmed.

**To reach ★★★★★:**
- Produce an advisory-grade Zero Trust architecture document covering identity, device, and data layers with control mapping to NIST SP 800-207
- Demonstrate explicit verification across all three ZT pillars in a single lab environment

**Project ideas:**
- "Zero Trust E5 deployment" capstone (already in planned projects) — this is the direct path to ★★★★★ on this skill
- Produce a Zero Trust design document as a portfolio artifact (not just a lab — a written advisory deliverable)

---

#### Entra ID as Code (IaC / Graph API)
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** No Terraform Entra provider work done. Planned project not started.

**To reach ★★★☆☆ Current:**
- Deploy CA policies via Terraform Entra provider with a working pipeline
- Version-control at least named locations + MFA policy in addition to CA

**Project ideas:**
- Start the planned Entra as Code project — even CA policies only is enough to flip to Current
- "Graph API CA policy management" script — PowerShell that reads, diffs, and applies CA policy changes via Graph API as a lower-complexity entry point

---

#### Entra Permissions Management (CIEM)
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** None. No project work.

**To reach ★★★☆☆ Current:**
- Run a permissions discovery across Azure subscriptions
- Identify over-privileged identities and document remediation recommendations
- Right-size at least one set of permissions using the remediation workflow

**Project ideas:**
- "CIEM assessment" lab — run Permissions Management discovery, identify top 10 over-privileged identities, document and right-size
- Tie CIEM findings into the Zero Trust E5 capstone as the permissions hygiene module

---

### MICROSOFT SENTINEL

---

#### Workspace Architecture & Data Connector Setup
**Current rating:** ★★★★☆ Current
**Evidence base:** Workspace + multiple connector types confirmed across two projects.

**To reach ★★★★★:**
- Design and document a multi-workspace architecture (hub-spoke or regional separation)
- Implement workspace-level RBAC and table-level access control
- Configure cost management: auxiliary logs, basic logs, archive tiers

**Project ideas:**
- "Multi-workspace Sentinel architecture" lab — hub workspace for SOC + spoke workspace for a business unit; document the data flow and RBAC model
- Retention tiering lab — configure basic logs vs analytics logs vs archive tiers for a realistic connector mix; document cost impact

---

#### KQL — Analytic Rule Authoring
**Current rating:** ★★★☆☆ Current
**Evidence base:** Scheduled and NRT rules deployed to Sentinel confirmed.

**To reach ★★★★☆:**
- Author rules with entity mapping, custom alert details, and MITRE ATT&CK technique tagging
- Build a multi-step detection (join across two tables, time-window correlation)
- Tune a rule through at least one false-positive reduction cycle with documented threshold changes

**Project ideas:**
- KQL Detection Library project (planned) — completing this is the direct path to ★★★★☆; the YAML + MITRE mapping requirement forces the right level of rigor
- "Detection tuning log" — document a rule that had false positives, show the original query, the noise analysis, and the tuned version

---

#### SOAR Playbook Development (Logic Apps)
**Current rating:** ★★☆☆☆ Current
**Evidence base:** Playbook built and tested manually; not alert-triggered end-to-end.

**To reach ★★★☆☆:**
- Wire an automation rule in Sentinel that triggers the playbook on a specific analytic rule firing
- Test the full end-to-end flow: analytic rule fires → automation rule triggers → playbook executes → incident updated

**Project ideas:**
- Extend the existing Sentinel SIEM lab — add an automation rule that triggers the existing playbook on a real alert; document the trigger condition and playbook output
- "Triage playbook" — playbook that auto-enriches an incident with Entra sign-in risk score and GeoIP data on trigger

---

#### Sentinel as Code (Bicep / ARM / Terraform)
**Current rating:** ★★★★☆ Current
**Evidence base:** Workspace + connectors in Bicep, analytics rules as YAML/ARM, ADO pipeline confirmed.

**To reach ★★★★★:**
- Complete the full framework: workspace + connectors + analytics rules + automation rules + playbooks (Logic Apps as ARM) + watchlists — all pipeline-driven
- Add a drift detection step: pipeline validates deployed state matches repo

**Project ideas:**
- Resume and complete the Sentinel as Code project (on hold) — the roadmap already defines the scope; completing it is the direct path to ★★★★★

---

#### Incident Triage & Investigation Workflows
**Current rating:** ★★★☆☆ Current
**Evidence base:** Alert tuning and investigation confirmed in Sentinel lab.

**To reach ★★★★☆:**
- Document a structured investigation workflow: initial triage → entity investigation → pivot to related incidents → closure with documented findings
- Use Sentinel investigation graph and entity pages as part of a documented case
- Integrate Copilot for Security incident summary into the workflow

**Project ideas:**
- "Incident investigation playbook" document — a written advisory artifact describing a standard SOC investigation workflow using Sentinel, not just a lab config
- "Copilot-assisted triage" lab — document a Copilot for Security session used to investigate a Sentinel incident

---

#### Threat Hunting (KQL / MITRE ATT&CK)
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** No structured hunting queries authored; Advanced Hunting in Defender XDR used but not mapped to ATT&CK.

**To reach ★★★☆☆ Current:**
- Author at least 3 hunting queries mapped to specific ATT&CK techniques
- Run hunts against real data and document findings (even null results with rationale)
- Save queries as Sentinel hunting bookmarks with documented hypothesis

**Project ideas:**
- KQL Detection Library project (planned) — include a hunting query section alongside analytic rules; MITRE mapping is already in scope
- "Threat hunt report" — document a hunt for a specific ATT&CK technique (e.g. T1078 Valid Accounts), show the query, the data sources, and the findings

---

#### SIEM Migration (Splunk / QRadar → Sentinel)
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** None. No project work.

**To reach ★★★☆☆ Current:**
- Map a set of Splunk SPL or QRadar AQL rules to equivalent KQL analytic rules
- Document the migration methodology: inventory → prioritize → translate → validate → cutover
- Use Microsoft's SIEM migration tool or ASIM normalization

**Project ideas:**
- "SPL → KQL translation" lab — take 5–10 public Splunk detections, translate to KQL, deploy to Sentinel, document fidelity differences
- Build a migration methodology document as a portfolio artifact

---

### MICROSOFT DEFENDER XDR

---

#### Defender for Endpoint — Deployment & Config
**Current rating:** ★★★☆☆ Current
**Evidence base:** Endpoint onboarding + telemetry verification confirmed. ASR rules and deep alert tuning not evidenced.

**To reach ★★★★☆:**
- Configure and test ASR rules with documented impact per rule
- Tune endpoint alerts — document at least one false positive suppression with rationale
- Configure device groups and role-based access for the MDE portal

**Project ideas:**
- "MDE hardening" lab — deploy ASR rules in audit mode, review findings, promote selected rules to block mode with documented risk/benefit
- "Device group RBAC" lab — configure device groups with scoped analyst access; document the access model

---

#### Defender for Identity — Lateral Movement Detection
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** Not confirmed hands-on. AD DS sensor not deployed.

**To reach ★★★☆☆ Current:**
- Deploy the MDI sensor on a domain controller (lab AD DS environment)
- Generate and review at least one lateral movement alert (Pass-the-Hash, Kerberoasting, etc.)
- Connect MDI alerts into XDR incident correlation

**Project ideas:**
- "MDI lab" — deploy AD DS in Azure VM, install MDI sensor, run ATT&CK simulation (e.g. using Purple Knight or manual techniques), review alerts in XDR
- Tie MDI into the Zero Trust E5 capstone as the identity threat detection module

---

#### Defender for Cloud Apps (CASB)
**Current rating:** ★★★☆☆ Current
**Evidence base:** Session controls, app discovery, Shadow IT confirmed.

**To reach ★★★★☆:**
- Configure app governance policies (OAuth app risk management)
- Build a conditional access app control policy (proxy-enforced session control for unmanaged devices)
- Connect MCAS alerts into Sentinel via data connector

**Project ideas:**
- "App governance" lab — discover OAuth apps, identify high-risk grants, configure a policy to alert or block based on risk score
- "CASB → Sentinel" integration — configure the Defender for Cloud Apps data connector in Sentinel, build an analytic rule on a CASB alert type

---

#### Defender for Office 365 — Anti-Phishing Config
**Current rating:** ★★★☆☆ Current
**Evidence base:** Safe links, safe attachments, anti-phishing policies confirmed.

**To reach ★★★★☆:**
- Configure and run Attack Simulation Training — design a phishing campaign, review click-through rates, assign training
- Tune anti-phishing policies based on simulation results with documented threshold changes
- Configure advanced delivery for SecOps mailbox exclusions

**Project ideas:**
- "Attack simulation" lab — run a phishing simulation, review results, assign targeted training, document the campaign design and outcome metrics

---

#### Microsoft Secure Score — Remediation Planning
**Current rating:** ★★★★☆ Current
**Evidence base:** Hands-on remediation work confirmed; consistent with Health Check role profile.

**To reach ★★★★★:**
- Produce an advisory-grade Secure Score remediation report: prioritized backlog with effort/impact scoring, implementation sequencing, and stakeholder narrative
- Demonstrate score delta before/after a remediation sprint

**Project ideas:**
- "Secure Score remediation report" — written portfolio artifact documenting a fictional client's baseline score, prioritized remediation backlog, and projected improvement
- Tie Secure Score into the Zero Trust E5 capstone as the baseline/post-deployment measurement

---

#### XDR Incident Correlation & Response
**Current rating:** ★★★☆☆ Current
**Evidence base:** Alert tuning and incident investigation confirmed.

**To reach ★★★★☆:**
- Document a full incident response lifecycle: detection → triage → investigation → containment → remediation → closure with timeline
- Use XDR attack story view and entity investigation as part of documented case work
- Configure custom detection rules in Advanced Hunting

**Project ideas:**
- "XDR incident case study" — document a simulated incident (e.g. credential theft + lateral movement) investigated through XDR; show the attack story, entities, and response actions taken

---

#### Defender for Cloud (CSPM / CWPP)
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** None confirmed. High priority for Cloud Security Posture Consultant role.

**To reach ★★★☆☆ Current:**
- Enable Defender for Cloud on an Azure subscription
- Review CSPM recommendations, remediate at least 5, document impact on Secure Score
- Configure a workload protection plan (servers or storage)

**Project ideas:**
- Defender for Cloud CSPM lab (already in roadmap) — completing this is the direct path to ★★★☆☆
- "CSPM posture report" — document findings from a Defender for Cloud assessment with prioritized remediation backlog; written advisory artifact

---

### MICROSOFT AZURE

---

#### Azure Policy & Regulatory Compliance
**Current rating:** ★★★☆☆ Current
**Evidence base:** Bicep for Policy/compliance assignments confirmed.

**To reach ★★★★☆:**
- Build a custom policy definition (not just assign built-ins)
- Configure a Policy initiative (policy set) scoped to a regulatory framework
- Implement remediation tasks and document auto-remediation vs manual remediation decisions

**Project ideas:**
- "Custom Azure Policy" lab — author a custom policy that enforces a security control not covered by built-ins (e.g. require Key Vault soft-delete, enforce diagnostic settings on all resources)
- "Regulatory initiative" lab — build a policy initiative mapped to NIST 800-53 controls; assign to a subscription; document compliance state

---

#### Bicep / ARM Template Authoring
**Current rating:** ★★★★☆ Current
**Evidence base:** Sentinel workspace, connectors, Azure Policy, Key Vault, networking confirmed.

**To reach ★★★★★:**
- Implement modules pattern (reusable Bicep modules with parameter files) rather than monolithic templates
- Add what-if deployment validation as a pipeline gate
- Implement Bicep linting and SARIF output in CI/CD

**Project ideas:**
- Refactor existing Sentinel Bicep into a modules pattern with a shared library
- Add what-if + linting as pipeline gates in the Sentinel as Code project

---

#### Azure DevOps Pipelines (CI/CD)
**Current rating:** ★★★★☆ Current
**Evidence base:** MSDO/GHAS security scanning in ADO pipelines confirmed; Sentinel as Code pipeline delivered.

**To reach ★★★★★:**
- Implement pipeline-enforced approval gates before production deployments
- Add SARIF results published to Defender for Cloud (not just pipeline artifacts)
- Build a multi-stage pipeline (dev → staging → prod) with environment-specific variable groups

**Project ideas:**
- Extend Sentinel as Code pipeline with multi-stage environments and approval gates
- "SARIF → Defender for Cloud" integration — publish MSDO scan results to Defender for Cloud as part of the pipeline

---

#### Landing Zone & Governance Design
**Current rating:** ★★★☆☆ Current
**Evidence base:** Supported by Policy + Bicep work; no explicit landing zone project.

**To reach ★★★★☆:**
- Deploy a documented landing zone with management group hierarchy, policy assignments at each level, and RBAC model
- Include networking baseline (hub-spoke or VWAN) with documented security decisions

**Project ideas:**
- "Security landing zone" lab — deploy a minimal landing zone (management groups + policy + RBAC) via Bicep; document the governance model as a written advisory artifact

---

#### Azure Key Vault & Secrets Management
**Current rating:** ★★★☆☆ Current
**Evidence base:** Bicep templates for Key Vault confirmed.

**To reach ★★★★☆:**
- Implement managed identity-based access (no key-based auth) for all consumers
- Configure Key Vault diagnostic logs → Sentinel data connector → analytic rule on suspicious access
- Implement key rotation with Event Grid-triggered automation

**Project ideas:**
- "Key Vault security hardening" lab — disable public access, enforce managed identity, configure alerting on failed access attempts, wire to Sentinel

---

#### Terraform (Azure Provider)
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** Not confirmed hands-on.

**To reach ★★★☆☆ Current:**
- Deploy at least one Azure resource set via Terraform with remote state in Azure Storage
- Implement a basic pipeline (GitHub Actions or ADO) for plan/apply with approval gate

**Project ideas:**
- "Terraform baseline" lab — deploy the Sentinel workspace (currently Bicep) in Terraform as a parallel exercise; compare the authoring experience
- Use Terraform for the Defender for Cloud CSPM lab (planned) — gets two skills evidenced in one project

---

#### GitHub Actions — Security Pipeline Automation
**Current rating:** ★★★☆☆ Current
**Evidence base:** Security gates and scanning steps confirmed hands-on.

**To reach ★★★★☆:**
- Build a reusable composite action (not just workflow steps)
- Implement environment protection rules with required reviewers before production deploy
- Publish SARIF scan results to GitHub Security tab

**Project ideas:**
- "Reusable security action" — build a composite GitHub Action that runs MSDO/Trivy/PSScriptAnalyzer and publishes SARIF; reuse across multiple repos
- KQL Detection Library project (planned) — GitHub Actions is already the intended deployment mechanism; this is a natural double-dip

---

### CROSS-CUTTING SKILLS

---

#### KQL (Kusto Query Language)
**Current rating:** ★★★★☆ Current
**Evidence base:** Ad hoc investigation, analytic rules deployed, Advanced Hunting in Defender XDR — three distinct contexts.

**To reach ★★★★★:**
- Author hunting queries with documented ATT&CK mapping and hypothesis-driven methodology
- Build a complex multi-join/time-window detection that correlates across 3+ tables
- Build a KQL-based workbook (not just queries)

**Project ideas:**
- KQL Detection Library (planned) — the MITRE mapping + YAML deployment requirement is the right forcing function for ★★★★★ depth
- "KQL workbook" lab — build a Sentinel workbook for a specific use case (e.g. identity risk dashboard, data exfiltration monitoring)

---

#### PowerShell — Security Scripting & Automation
**Current rating:** ★★★☆☆ Current
**Evidence base:** Security config and automation scripts confirmed; no Graph API or complex module-level work evidenced.

**To reach ★★★★☆:**
- Author a reusable PowerShell module (not just scripts) with proper error handling, logging, and parameter validation
- Use Graph API via PowerShell for a security config task (CA policy read/write, Purview label management)
- Implement Pester tests for a security script

**Project ideas:**
- Purview as Code project — Graph API PowerShell for label/DLP deployment is the natural next step
- "Graph API security toolkit" — a PowerShell module that wraps common security Graph API calls (CA policy export, PIM assignment audit, sign-in log query)

---

#### Microsoft Graph API
**Current rating:** ★★★☆☆ Current
**Evidence base:** Supported by Entra and pipeline work.

**To reach ★★★★☆:**
- Author Graph API calls for write operations (not just read) — create/update CA policies, manage PIM assignments
- Implement delta queries for change detection
- Use Graph API in an automation pipeline (not just ad hoc scripts)

**Project ideas:**
- Entra as Code project — Graph API write operations for CA policies is the direct path
- "Graph change detector" — a scheduled script that queries Graph delta endpoint for CA policy changes and logs them to Sentinel

---

#### Zero Trust Framework (NIST SP 800-207)
**Current rating:** ★★★★☆ Current
**Evidence base:** Breadth across CA, MFA, IaC, identity layer confirmed.

**To reach ★★★★★:**
- Produce a written Zero Trust architecture document that maps controls to SP 800-207 pillars
- Demonstrate all five ZT pillars (identity, device, network, application, data) in a single environment

**Project ideas:**
- Zero Trust E5 capstone (planned) — completing this with a companion design document is the direct path
- "Zero Trust maturity assessment" framework — a written artifact mapping the ZT pillars to Secure Score and Compliance Manager findings

---

#### MITRE ATT&CK Framework
**Current rating:** ★★★☆☆ Current
**Evidence base:** Used in analytic rule context; no structured hunting or adversary emulation.

**To reach ★★★★☆:**
- Map a detection rule set to ATT&CK techniques with documented coverage gaps
- Run or simulate an adversary emulation exercise and map detections to observed TTPs
- Produce an ATT&CK navigator layer showing current detection coverage

**Project ideas:**
- KQL Detection Library (planned) — MITRE ATT&CK mapping is already in scope; add an ATT&CK navigator layer export as a deliverable
- "Detection coverage map" — produce a navigator layer showing which techniques your Sentinel rules currently cover vs gaps

---

#### Security Health Check & Gap Assessment
**Current rating:** ★★★★☆ Current
**Evidence base:** Consistent with role profiles; Secure Score work confirmed.

**To reach ★★★★★:**
- Produce a full advisory-grade health check report as a portfolio artifact: findings, risk ratings, prioritized remediation backlog, executive summary
- Cover at least three pillars (identity, information protection, threat detection)

**Project ideas:**
- "E5 Security Health Check" written artifact — document a fictional client assessment across Entra, Purview, and Defender XDR; format as a consulting deliverable
- Zero Trust E5 capstone (planned) — the health check is explicitly the starting point of that scenario

---

#### Python — Security Tooling & Scripting
**Current rating:** ★★☆☆☆ Developing
**Evidence base:** None confirmed.

**To reach ★★★☆☆ Current:**
- Author a working Python script that calls a Microsoft security API (Graph, Sentinel, Defender) and does something useful with the output
- e.g. a script that queries Sentinel incidents via REST API and generates a summary report

**Project ideas:**
- "Python → Sentinel API" script — query Sentinel incidents via the Azure REST API, filter by severity, output a formatted summary
- "Graph API Python client" — replicate a PowerShell Graph API task in Python; useful cross-language comparison artifact

---

#### Regulatory Frameworks (HIPAA · NYDFS · CMMC)
**Current rating:** ★★★★☆ Current
**Evidence base:** Azure Policy compliance assignments + Compliance Manager + classification mapping across labs.

**To reach ★★★★★:**
- Produce an advisory-grade regulatory gap assessment for a specific framework (NYDFS Part 500 is highest value given role profiles)
- Map Microsoft security controls to framework requirements with documented compliance evidence
- Present findings in a format suitable for a client or auditor

**Project ideas:**
- "NYDFS Part 500 gap assessment" — written advisory artifact; map Entra, Purview, Sentinel, and Defender XDR controls to NYDFS requirements; document gaps and remediation
- "CMMC Level 2 control mapping" — map Azure and M365 security controls to CMMC practices; identify gaps for a fictional defense contractor scenario

---

## Re-assessment checklist

When a new project is published, run through these questions before updating ratings:

1. **What was actually shipped?** (not planned, not template-followed — working configuration in a real or production-equivalent environment)
2. **What skills does it directly evidence?** (map to the skill IDs above)
3. **Does it add a new scenario or just repeat existing work?** (new scenario = potential rating increase; repeat = confirms existing rating)
4. **Does it push into a new depth tier?** (check the "To reach ★★★★☆" criteria above)
5. **Does it flip any Developing → Current?** (requires end-to-end delivery, not just exposure)
6. **Are there any internal inconsistencies introduced?** (e.g. if a new project raises KQL Analytic Rules, check that KQL overall is still consistent)

---

## High-ROI project targets (rating impact per effort)

These projects move the most ratings simultaneously:

| Project | Skills impacted | Current gap |
|---|---|---|
| **Zero Trust E5 capstone** | Zero Trust Framework ★5, Security Health Check ★5, Sentinel Incident Triage ★4, XDR Incident Response ★4, CA Policy ★5 | Multiple skills at ★★★★☆ with clear path to ★★★★★ |
| **KQL Detection Library** | KQL ★5, KQL Analytic Rules ★4, Threat Hunting ★3 Current, MITRE ATT&CK ★4, GitHub Actions ★4 | 5 skills, 3 of which currently have rating or tag gaps |
| **Sentinel as Code (resume)** | Sentinel as Code ★5, SOAR Playbook ★3, Azure DevOps ★5, Bicep ★5 | Direct continuation of existing on-hold work |
| **DSPM for AI assessment** | DSPM for AI ★3 Current, Sensitivity Labels ★5 potential, DLP ★5 potential | High strategic value for AI Security Architect role profile |
| **Entra as Code project** | Entra as Code ★3 Current, Graph API ★4, PowerShell ★4, GitHub Actions ★4 | Flips a key Developing skill to Current |
| **NYDFS gap assessment (written artifact)** | Regulatory Frameworks ★5, Compliance Manager ★4, Security Health Check ★5 | Advisory-grade written artifact; no new lab work required |
| **MDI lab** | Defender for Identity ★3 Current, MITRE ATT&CK ★4, XDR Incident Response ★4 | Fixes the one Defender skill that dropped to ★★☆☆☆ |
| **Purview Compliance capstone** | IRM ★3, eDiscovery ★3, Compliance Manager ★4, Purview as Code ★4 | Moves four Developing/★★☆☆☆ skills in one project |
