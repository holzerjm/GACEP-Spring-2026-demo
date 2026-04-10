# Enterprise Deployment Guide

How to take BriefingClaw from a conference demo to a production deployment in your organization.

> This guide is for teams who saw the GACEP demo and want to operationalize the system for real executive briefing workflows.

---

## Table of Contents

1. [What You're Deploying](#1-what-youre-deploying)
2. [Architecture Decisions](#2-architecture-decisions)
3. [Connecting Your CRM](#3-connecting-your-crm)
4. [Loading Your SAB Data](#4-loading-your-sab-data)
5. [Customizing Agent Personas](#5-customizing-agent-personas)
6. [Model Routing for Your Environment](#6-model-routing-for-your-environment)
7. [Integration Points](#7-integration-points)
8. [Security Considerations](#8-security-considerations)
9. [Operational Runbook](#9-operational-runbook)
10. [Production Checklist](#10-production-checklist)

---

## 1. What You're Deploying

The reference architecture demonstrated at GACEP is the same one you can deploy in production:

| Component | Demo | Production |
|-----------|------|-----------|
| Orchestrator agent | Oprah-tor (OpenClaw) | OpenClaw on OpenShift |
| Research agents | Sherlock Ohms, Bloom-borg (ZeroClaw native) | ZeroClaw on dedicated nodes or OpenShift sidecars |
| Local data agents | Déjà View, Draft Punk, Alfred Bitworth (OpenClaw) | OpenClaw on OpenShift, scaled by load |
| The Oddsfather | OpenClaw skill | Same |
| Local model | Granite 8B via Podman AI Lab | Granite served by OpenShift AI |
| Frontier model | Anthropic / OpenAI / Google (cloud) | Same — but consider OpenShift AI's own model serving for sovereign deployments |

The shift from "laptop demo" to "production" is mostly about **scale, governance, and integration** — the agent architecture stays the same.

---

## 2. Architecture Decisions

Before deploying, decide:

### 2.1 Where do the agents run?
- **Single-tenant cluster**: All agents on your own OpenShift cluster. Best for regulated industries.
- **Hybrid**: Local agents on your cluster, frontier agents call out to cloud APIs. Most common.
- **Fully cloud**: Local agents also call cloud-hosted Granite via OpenShift AI. Lowest ops burden.

### 2.2 Where does the data live?
- **Workspace files** (current demo approach): Markdown and JSON files mounted into containers. Simplest, but stale unless refreshed.
- **API integration** (recommended for production): Déjà View queries CRM, calendar, email, and SAB systems live.
- **Hybrid**: API for fresh data (CRM, calendar) + workspace files for slow-changing context (SAB notes).

### 2.3 Who triggers a briefing?
- Manual: A user types a request into the OpenClaw gateway UI
- Calendar-driven: System auto-detects an upcoming briefing and prepares a package 24 hours in advance
- Slack/Teams bot: User says "@briefingclaw prep for Sarah Chen tomorrow" in chat

---

## 3. Connecting Your CRM

The demo reads from `demo-data/crm-export.json`. In production, replace this with a live CRM connector.

### Salesforce Example

Add a CRM adapter to Déjà View. Modify `agents/sab-historian/SKILL.md` to reference an external tool:

```yaml
# In config/openclaw-config.yml
tools:
  crm_query:
    enabled: true
    type: api
    base_url: ${SFDC_INSTANCE_URL}
    auth:
      type: oauth2
      token_endpoint: ${SFDC_TOKEN_URL}
      client_id: ${SFDC_CLIENT_ID}
      client_secret: ${SFDC_CLIENT_SECRET}
    schema_mapping:
      account_name: Name
      annual_revenue: AnnualRevenue
      employees: NumberOfEmployees
      health_score: Account_Health__c
      contracts: Opportunities
```

Déjà View's prompt then references the tool: *"Query CRM for the visitor's account record. Use the `crm_query` tool with parameters: `name=${visitor_name}, company=${company_name}`."*

### HubSpot, Microsoft Dynamics, etc.
Same pattern — define a tool wrapper, map your fields to the schema BriefingClaw expects.

### Schema Requirements
At minimum, your CRM data must provide:
- Account: name, industry, revenue, employees, headquarters, health score
- Contact: name, title, email, role type, engagement score, last activity, executive sponsor
- Opportunities: name, stage, value, close date, notes
- Support escalations: severity, summary, status

If your CRM has different field names, the schema mapping config above translates them.

---

## 4. Loading Your SAB Data

The demo uses `demo-data/sab-meeting-notes.md` and `demo-data/engagement-history.md`. For production:

### Option A: Markdown sync (simplest)
Keep your SAB notes in markdown (Notion, Obsidian, GitHub) and sync them to the workspace volume nightly. No code changes needed.

### Option B: Database integration
If your SABs are tracked in a database (Confluence, Airtable, custom CMS), add a tool wrapper similar to the CRM example.

### Option C: Calendar + meeting transcript pipeline
- Calendar API tells you when an SAB meeting happens
- Meeting transcript service (Otter, Zoom AI, Granola) provides the transcript
- A pre-processor agent extracts themes, contributions, action items
- Output is written to the workspace as structured markdown

This gets you live SAB intelligence with zero manual logging.

---

## 5. Customizing Agent Personas

The 6 agent personas (Oprah-tor, Sherlock Ohms, Bloom-borg, Déjà View, Draft Punk, Alfred Bitworth) plus The Oddsfather and Sponsor Coach are templates. You can:

### Rename them
Edit `agents/<agent>/SKILL.md` and change the identity section. If your culture prefers more formal naming, replace "Oprah-tor" with "Orchestrator" and so on. The functionality is identical.

### Adjust their methodology
Each SKILL.md has a "Methodology" section. Tune it to your reality:
- Your Sherlock Ohms might need to query LinkedIn Sales Navigator instead of Tavily
- Your Bloom-borg might pull from Bloomberg Terminal instead of generic web search
- Your Alfred Bitworth might need to integrate with your room booking system

### Add new agents
The architecture is extensible. Examples of agents you might add:
- **Compliance Officer**: Checks if briefing topics raise regulatory concerns (relevant for healthcare, finance, defense)
- **Translation Assistant**: For international visitors, generates briefing materials in their native language
- **Diversity Advocate**: Suggests diverse presenters and perspectives for the briefing panel
- **Calendar Coordinator**: Pulls actual calendar availability for sponsor and CEO drop-ins

Add a new directory under `agents/`, write a SKILL.md, register it in `config/openclaw-config.yml`.

---

## 6. Model Routing for Your Environment

The demo uses dual-model routing: frontier (cloud) for research, local (Granite 8B) for data agents.

### Production options

| Deployment Model | Local Agents | Research Agents | Notes |
|------------------|--------------|-----------------|-------|
| Sovereign / air-gapped | Granite 8B on OpenShift AI | Granite 13B on OpenShift AI (no web search) | Slowest research, highest privacy |
| Hybrid (default) | Granite 8B on OpenShift AI | Claude / GPT / Gemini API | Balance of capability and privacy |
| Cloud-only | Granite 8B on OpenShift AI cloud | Frontier API | Lowest ops burden |
| Custom | Your fine-tuned model | Your fine-tuned model | If you've trained your own Granite variant on company data |

Configure the routing in `config/openclaw-config.yml` under `routing.overrides`.

---

## 7. Integration Points

A production BriefingClaw should connect to:

| System | Integration | Direction |
|--------|------------|-----------|
| CRM (Salesforce, HubSpot) | API | Read |
| Calendar (Google, Outlook) | API | Read (briefings, sponsor availability) |
| Email | Send via SMTP / Gmail API | Write (sponsor alerts) |
| Slack / Teams | Bot framework | Bidirectional (trigger + notify) |
| Document storage (SharePoint, Drive, Box) | API | Write (PDF deliverables) |
| Meeting notes (Otter, Zoom AI) | API | Read (post-briefing transcripts) |
| EBC scheduling system | API | Read (room bookings, catering) |
| SAB management system | API or markdown sync | Read |

Each integration is an OpenClaw or ZeroClaw "tool" added to the agent that needs it.

---

## 8. Security Considerations

Production deployments must address:

### Data classification
Customer data flowing through BriefingClaw is highly sensitive. Decide which model tier each data class can touch:
- **Public data** (company news, financials): OK for frontier APIs
- **Internal data** (CRM, account health, opportunities): Local model only
- **Regulated data** (PII, financial, medical): Local model + audit logging required

### API key rotation
The demo uses `.env` files. In production:
- Use OpenShift Secrets or external vault (HashiCorp Vault, AWS Secrets Manager)
- Rotate keys quarterly
- Use service accounts, not personal keys

### Audit logging
Every agent invocation should be logged with:
- Who triggered it (user identity)
- What was requested (briefing for whom)
- Which data sources were queried
- Which model was called
- What was returned (or a hash of it for sensitive data)

OpenShift AI provides this out of the box.

### Network egress controls
The frontier agents make outbound calls. Lock down:
- Allowed domains (api.anthropic.com, api.openai.com, etc.)
- Block all other outbound traffic from agent containers
- Monitor for unexpected traffic patterns

---

## 9. Operational Runbook

### Daily operations
- Verify model health: `/health` endpoint on OpenShift AI
- Verify agent gateway: `curl https://briefingclaw.your-domain.com/health`
- Review yesterday's audit log for anomalies

### Weekly operations
- Refresh SAB workspace files (if using markdown sync)
- Review Sponsor Coach recommendations that were dismissed
- Calibrate The Oddsfather: compare predicted vs. actual briefing outcomes

### Monthly operations
- Review agent prompt drift (are responses still high quality?)
- Rotate any expiring API keys
- Update demo-data templates if your relationship structure has evolved

### Quarterly operations
- Full agent prompt review with stakeholders
- Re-train any custom model variants on new data
- Compliance audit of data flows

---

## 10. Production Checklist

Before going live:

### Infrastructure
- [ ] OpenShift cluster provisioned with adequate compute (8 vCPU minimum per agent pod)
- [ ] OpenShift AI installed and Granite model deployed
- [ ] Network policies configured (egress controls)
- [ ] Persistent storage for workspace volumes
- [ ] Backup strategy for workspace data

### Configuration
- [ ] Frontier API keys stored in vault, injected via OpenShift Secrets
- [ ] CRM API credentials configured and tested
- [ ] Calendar API integrated
- [ ] Email/Slack integrations tested with non-prod accounts first
- [ ] Logging pipeline running (Splunk, ELK, OpenShift Logging)

### Agents
- [ ] All 8 agent SKILL.md files reviewed and customized
- [ ] Agent personas renamed if needed
- [ ] Sponsor Coach calibrated to your sponsor cadence expectations
- [ ] The Oddsfather scoring weights tuned to your sales motion

### Data
- [ ] Real CRM data flowing into Déjà View
- [ ] SAB notes synced from your source of truth
- [ ] Engagement history imported (or starting fresh from launch date)
- [ ] VVIP roster validated against current org chart

### Testing
- [ ] End-to-end test with a real upcoming briefing (in staging)
- [ ] Failure mode testing: model down, API down, slow response
- [ ] Load test: 5 concurrent briefings
- [ ] User acceptance: 3 EBC managers and 1 sponsor have tested it

### Governance
- [ ] Data classification policy documented
- [ ] Model usage policy approved by legal/compliance
- [ ] User training plan in place
- [ ] Feedback loop for agent improvement defined

---

## Support

For help adapting BriefingClaw to your environment:
- Open an issue: https://github.com/holzerjm/GACEP-Spring-2026-demo/issues
- Reference the agent SKILL.md files — they're the source of truth for what each agent does
- The demo data files are good templates for what your production data should look like

---

*BriefingClaw is open source under the MIT license. Use it, modify it, deploy it.*
