<!-- SYNTHETIC DATA NOTICE -->
<!-- All names, companies, events, and details in this file are entirely fictional. -->
<!-- Created for the BriefingClaw demo at GACEP Spring 2026. Not real customer data. -->

# Strategic Advisory Board Meeting Notes

## Strategic Technology Advisory Board — Q1 2026

**Date**: February 12, 2026
**Location**: Virtual (Zoom)
**Facilitator**: Kristin Waitkus, VP Customer Engagement
**Attendees**: 14 of 18 active members

### Members Present
- Sarah Chen, CIO, Meridian Health Systems ✓
- David Park, SVP Technology, Apex Financial Group ✓
- Rachel Morrison, CTO, TerraScale Energy ✓ (Co-Chair)
- Pepper Minton, CTO, SnackStack Technologies ✓
- Luna Wavelength, Chief Innovation Officer, GalactiCorp Space Industries ✓ (Co-Vice-Chair)
- Max Bandwidth, SVP Digital Transformation, Thunderbolt Logistics ✓
- James Liu, VP Infrastructure, NovaTech Industries ✓
- Maria Santos, CISO, Pacific Coast Mutual ✓
- [... 6 additional members]

### Theme 1: AI Governance in Regulated Industries
**Discussion lead**: Sarah Chen (Meridian Health Systems)

Sarah Chen raised a critical question about how organizations in regulated industries can adopt AI while maintaining compliance and auditability. She shared that Meridian is piloting three AI projects but has paused two of them pending clearer governance frameworks.

Key points from Sarah:
- "We need AI governance that's as rigorous as our clinical governance, but we can't let perfect be the enemy of good."
- Interested in model transparency and explainability for clinical decision support
- Asked specifically about open-source model advantages for auditability
- Expressed frustration with vendor lock-in in the AI space

Rachel Morrison contributed to the governance discussion from the energy sector perspective:
- "In energy, a bad AI decision doesn't just cost money — it can take down a grid. We need governance frameworks that account for safety-critical systems, not just financial compliance."
- Shared TerraScale's internal AI review board model as an example for the group
- Offered to co-author a cross-industry governance framework paper with Sarah

David Park raised the financial services angle:
- "Our regulators are three years behind on AI guidance, but they'll catch up fast and retroactively. We need to build governance now that will survive future regulation."
- Asked whether open-source models would satisfy OCC and FINRA auditability requirements
- Noted that Apex is evaluating three vendors for AI governance tooling

Luna Wavelength contributed from the aerospace and defense perspective:
- "When your AI is controlling satellite ground station handoffs, explainability isn't a nice-to-have — it's a mission-critical requirement. Our CISO won't sign off on any AI deployment without a full audit trail."
- Shared GalactiCorp's internal AI review process for safety-critical systems
- Connected with Rachel Morrison on similarities between energy grid and satellite operations governance needs

Pepper Minton offered the scale-up perspective:
- "We went from zero to 50 million API calls a day when our recipe engine went viral. Governance was an afterthought — we're retrofitting it now. Learn from our mistakes."
- Asked about lightweight governance frameworks for fast-moving SaaS companies
- Noted that AI governance in food tech has fewer regulatory constraints but still needs consumer trust

Max Bandwidth connected AI governance to logistics:
- "Route optimization AI affects 2,000 truck drivers' daily schedules. If the model makes a bad call, people sit in traffic for hours. We need governance that accounts for human impact, not just financial risk."
- Shared that Thunderbolt's AI pilot includes a human-override mechanism for dispatcher review
- Asked whether Red Hat has benchmark data on AI ROI in logistics — wants ammunition for internal skeptics

**Board consensus**: Strong demand for governance frameworks that work in regulated environments. Multiple members echoed the need for explainable, auditable AI.

**Action item**: Share our AI governance reference architecture with board members (Assigned: Product Team, Due: March 1)
**Action item**: Rachel Morrison and Sarah Chen to collaborate on cross-industry governance framework paper (Assigned: Rachel & Sarah, Due: Q2 2026)

### Theme 2: Hybrid Cloud Migration — Year 3 Reality Check
**Discussion lead**: David Park (Apex Financial Group)

David led a candid discussion about the gap between hybrid cloud strategy promises and operational reality. Several members reported being "18 months behind" on their migration timelines.

Key points from David:
- "Let me be blunt — we attempted to migrate our core banking workloads to OpenShift in January, and it failed. Six hours of staging downtime before we rolled back. The technology works, but the migration tooling and assessment process let us down."
- Skill gaps remain the #1 blocker (not technology)
- Multi-cloud management complexity is increasing, not decreasing
- Day 2 operations cost more than expected
- Several members considering consolidation back to fewer platforms

David's direct challenge to the board: "We're all sitting here being polite, but how many of you have had a migration go sideways in the last 12 months?" — Five members raised their hands.

Sarah Chen contributed: "We're seeing the same thing at Meridian. We went multi-cloud and now we're spending more on management tooling than we saved on infrastructure."

Rachel Morrison added the energy sector perspective:
- "We've taken a different approach — we migrated non-critical workloads first and built confidence over 18 months before touching production trading systems. David, I'd be happy to share our phased migration playbook with your team."
- Offered to connect David with TerraScale's platform engineering lead for a peer exchange
- Noted that edge computing migrations for remote substations present a unique version of this challenge

Luna Wavelength shared the aerospace challenge:
- "Try doing hybrid cloud when half your clusters are air-gapped at classified facilities. Our migration challenge isn't just technical — it's regulatory. FedRAMP and ITAR add layers that most enterprises don't deal with."
- Offered to share GalactiCorp's air-gapped cluster management approach with interested members

Max Bandwidth brought the logistics angle:
- "We have 200 warehouses with edge nodes that need to sync with our central OpenShift clusters. Migration isn't a one-time event for us — it's continuous. Every new warehouse is a mini-migration."
- Asked about automated cluster provisioning for edge-to-core hybrid architectures
- Connected with Pepper Minton afterward on scaling challenges (both dealing with rapid growth scenarios)

Pepper Minton added: "We migrated to OpenShift in 6 months because we had no legacy to deal with — we were born cloud-native. But scaling is our version of the migration problem. When your traffic goes 40x overnight, your architecture gets stress-tested in ways no migration plan anticipates."

**Action item**: Develop a "Hybrid Cloud Reality" benchmarking survey for board members (Assigned: CTO Office, Due: Q2 2026)
**Action item**: Rachel Morrison to share TerraScale migration playbook with David Park's team (Assigned: Rachel, Due: March 2026)

### Theme 3: Platform Engineering & Developer Experience
Brief discussion on how platform engineering teams can improve developer productivity. Several members interested in internal developer platforms (IDPs).

Rachel Morrison (as Co-Chair) facilitated this segment:
- Framed the discussion around platform-as-a-product thinking
- "Your developers are your customers. If they're bypassing your platform to use shadow IT, that's a product feedback signal, not a compliance problem."
- Polled the group on IDP adoption maturity — 4 members in production, 6 evaluating, 4 not started

David Park commented: "We have three different internal platforms at Apex because no one agreed on standards. We need consolidation before we can talk about developer experience."

Pepper Minton was highly animated on this topic:
- "We built our IDP in 3 months with a team of 4 engineers. The secret? We treated it like a product — daily standups, user interviews with our own developers, and a public backlog. If your developers hate your platform, it's because you built it like an IT project, not a product."
- Offered to demo SnackStack's developer portal to any interested members

Max Bandwidth connected platform engineering to his AI scaling challenge:
- "My data science team bypasses the platform team because it's too slow to get GPU resources provisioned. That's a developer experience problem — if the platform doesn't serve the AI workflow, people go around it."

**Action item**: Schedule a deep-dive session on IDP maturity models for Q2 meeting (Assigned: Kristin Waitkus, Due: April 2026)

---

## Strategic Technology Advisory Board — Q4 2025

**Date**: November 8, 2025
**Location**: In-person, Raleigh Executive Briefing Center
**Facilitator**: Kristin Waitkus
**Attendees**: 16 of 18 active members

### Members Present
- Sarah Chen, CIO, Meridian Health Systems ✓
- David Park, SVP Technology, Apex Financial Group ✓
- Rachel Morrison, CTO, TerraScale Energy ✓ (Co-Chair)
- James Liu, VP Infrastructure, NovaTech Industries ✓
- Maria Santos, CISO, Pacific Coast Mutual ✓
- [... 11 additional members]

### Theme 1: Container Security in Production
Sarah Chen participated actively. She shared a case study from Meridian's container security implementation and asked detailed questions about supply chain security for container images.

David Park raised financial services-specific concerns:
- "In financial services, container security isn't optional — it's a regulatory requirement. We need tamper-proof audit trails for every image that touches production."
- Asked about FIPS 140-2 compliance for container runtimes in regulated environments
- Shared that Apex had recently passed a FINRA examination partly based on their container security posture with Red Hat Advanced Cluster Security
- Requested a dedicated session on supply chain security for financial workloads

Rachel Morrison contributed from the critical infrastructure perspective:
- "Energy grid systems have NERC CIP compliance requirements that go beyond what most container security tools address. We need policy-as-code that understands OT environments, not just IT."
- Presented a 5-minute overview of TerraScale's container security model for SCADA-adjacent systems
- The presentation generated significant interest — three members requested follow-up calls

**Action item**: Schedule financial services container security deep-dive for David Park's team (Assigned: Security Product Team, Due: Q1 2026)
**Action item**: Rachel Morrison to share TerraScale's OT container security reference architecture (Assigned: Rachel, Due: December 2025 — completed)

### Theme 2: Edge Computing for Healthcare
Sarah Chen was the primary advocate for this topic. Meridian is exploring edge computing for medical device data processing and remote patient monitoring.

Key quote from Sarah: "Edge isn't optional for healthcare anymore. When you have a patient on a ventilator, you can't wait for a round trip to the cloud."

Rachel Morrison connected the edge discussion to energy use cases:
- "We have 200+ unmanned substations that need edge computing with zero-touch provisioning. The challenges are similar to healthcare — low latency, high reliability, intermittent connectivity."
- Proposed a joint edge computing working group with Sarah to share learnings across healthcare and energy sectors
- "If we can solve edge for a remote substation in West Texas with no reliable internet, the healthcare use case in a hospital with full connectivity should be straightforward."

David Park listened but noted financial services has different edge requirements:
- "Our edge is the trading floor, not the field. Latency is measured in microseconds, not milliseconds. But I'm interested in how edge security models might apply to our branch modernization."

**Action item**: Form cross-industry edge computing working group (Assigned: Rachel Morrison & Sarah Chen, Due: Q1 2026)

### Post-Meeting Notes

Rachel Morrison (as Co-Chair) stayed an additional 90 minutes after the formal meeting to debrief with Kristin Waitkus and Elena Vasquez on board health, member engagement, and Q1 2026 agenda planning. She proposed the AI Governance and Hybrid Cloud themes that were ultimately adopted.

David Park attended the post-meeting executive dinner at Angus Barn with 8 other members. Informal conversation topics included frustrations with cloud vendor pricing and interest in FinOps practices. David was notably more relaxed in the dinner setting and shared candid feedback about wanting more "real talk" in SAB sessions.

---

## Membership Roster — Active Members

| Name | Title | Company | Member Since | Board | Attendance (TTM) |
|------|-------|---------|-------------|-------|-------------------|
| Sarah Chen | CIO | Meridian Health Systems | Q2 2024 | Strategic Technology | 4/4 (100%) |
| David Park | SVP Technology | Apex Financial Group | Q1 2023 | Strategic Technology | 3/4 (75%) |
| Rachel Morrison | CTO | TerraScale Energy | Q3 2024 | Strategic Technology | 4/4 (100%) |
| James Liu | VP Infrastructure | NovaTech Industries | Q1 2024 | Strategic Technology | 3/4 (75%) |
| Pepper Minton | CTO | SnackStack Technologies | Q3 2024 | Strategic Technology | 3/4 (75%) |
| Luna Wavelength | Chief Innovation Officer | GalactiCorp Space Industries | Q1 2025 | Strategic Technology | 4/4 (100%) |
| Max Bandwidth | SVP Digital Transformation | Thunderbolt Logistics | Q1 2025 | Strategic Technology | 3/3 (100%) |
| Maria Santos | CISO | Pacific Coast Mutual | Q2 2025 | Strategic Technology | 2/2 (100%) |

## Membership Roster — Alumni

| Name | Title | Company | Member Since | Departed | Board | Reason |
|------|-------|---------|-------------|----------|-------|--------|
| Ziggy Stardust-Chen | VP Platform Engineering | Quantum Pretzel Corp | Q1 2024 | Q4 2025 | Strategic Technology | Stepped down — cited lack of responsiveness to feedback |
