# BriefingClaw Demo Script — GACEP Spring 2026

## Session: "One Customer, Many Doors"
## Presenter: Jan Mark Holzer
## Duration: 15-20 minutes within the 90-minute session
## Position: After the Engagement Engine framework presentation (around minute 15-35)

> **See also:** [`USER-GUIDE.md`](../USER-GUIDE.md) for system operation and troubleshooting. [`BUILD-GUIDE.md`](BUILD-GUIDE.md) for initial setup.

---

## Pre-Demo Setup (30 minutes before session)

### Hardware Checklist
- [ ] MacBook Pro connected to projector (HDMI or USB-C adapter)
- [ ] External monitor resolution matched to projector (test text readability)
- [ ] Terminal font size: 18pt minimum (audience needs to read it)
- [ ] Browser zoom: 125-150%
- [ ] Mobile hotspot as backup network (tested)
- [ ] Power cable connected

### Software Checklist
- [ ] Podman Desktop running with AI Lab
- [ ] Granite 8B model loaded and serving on port 8001
- [ ] Verify model: `curl -s http://127.0.0.1:8001/v1/models | jq .`
- [ ] OpenClaw container running: `podman ps | grep briefingclaw`
- [ ] OpenClaw UI accessible: `open http://127.0.0.1:18789`
- [ ] ZeroClaw installed: `zeroclaw --version`
- [ ] Demo data files in workspace: `ls ~/.openclaw/workspace/`
- [ ] Dashboard tested: `open briefingclaw-dashboard.html` (works without live agents)
- [ ] Backup video loaded in media player (DON'T minimize — keep it one click away)

### Terminal Layout
```
┌──────────────────────────┬──────────────────────────┐
│                          │                          │
│    Terminal Tab 1        │    Terminal Tab 2         │
│    "Sherlock Ohms"            │    "Bloom-borg"             │
│    (Executive Research)  │    (Account Intel)        │
│                          │                          │
├──────────────────────────┴──────────────────────────┤
│                                                     │
│              Browser: OpenClaw Gateway UI            │
│              http://127.0.0.1:18789                  │
│              "Oprah-tor" Orchestrator                       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Demo Script

### BEAT 1: The Setup (2 minutes)
**[Slides still visible. Jan Mark at the podium.]**

> "So Kristin just walked us through the Engagement Engine — the three gears, the connective tissue, the flywheel. Beautiful framework. But here's the thing — frameworks don't execute themselves.
>
> Show of hands: how many hours does your team spend preparing a backgrounder for a VIP briefing? 
>
> [Pause. Let hands go up. React to answers.]
>
> Four hours? Six? I've heard eight from some teams. And that's for ONE briefing. Now multiply that by your annual briefing volume.
>
> What if I told you that the connective tissue Kristin described — the thing that links your SAB, your EBC, and your Executive Sponsor program — could be automated by a team of AI agents running on your laptop? No cloud. No vendor lock-in. Open source."

### BEAT 2: Meet the Agents (2 minutes)
**[Switch to slide showing the multi-agent architecture diagram]**

> "I want to introduce you to BriefingClaw — a multi-agent system we built using open-source AI tools. It's eight specialized agents, each with a specific job:
>
> **Oprah-tor** is the orchestrator — the air traffic controller. You give it a briefing request, and it coordinates everything else.
>
> **Sherlock Ohms** does executive research — think of it as your executive research analyst who reads everything and never sleeps.
>
> **Bloom-borg** handles company-level intelligence — financial signals, technology priorities, competitive dynamics.
>
> **Déjà View** is the connective tissue agent — it's the one that checks your SAB database, pulls past briefing records, and connects the dots between programs. This is the agent that makes the 'Program of Programs' actually work.
>
> **Draft Punk** assembles all the intelligence into polished deliverables — the dossier, the talking points, the agenda.
>
> **Alfred Bitworth** handles VVIP protocol — checklist, sponsor notifications, the whole operation.
>
> **Sponsor Coach** — the seventh agent — scores your executive sponsor's readiness for the drop-in and gives them a two-minute prep brief. It's the agent that prevents the sponsor from walking in cold.
>
> And **The Oddsfather** — the eighth agent, the one that runs last — reviews the full package and gives you a success probability verdict. It tells you the odds before you walk into the room.
>
> Now let me show you this in action."

### BEAT 3: Boot the Stack — The "Wow" Moment (2 minutes)
**[Switch to terminal. Full screen.]**

> "First, let me show you what's running on this laptop right now."

```bash
# Show Podman containers
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

> "There's our model server — IBM Granite 8B, an open-source model running locally through Podman. And there's OpenClaw, our agent framework, also in a container. No data leaves this laptop."

```bash
# Show ZeroClaw's footprint
zeroclaw status
```

> "And ZeroClaw — our lightweight agent runtime. Look at that: 4.2 megabytes of RAM. The entire agent binary is 3.4 megabytes. That's smaller than a PowerPoint template."
>
> [Pause for reaction. This usually gets a laugh or a "wow."]
>
> "Two weeks ago, I was at a hackathon in Boston where construction workers and project managers — not developers — were building agents like this in two hours. This is no longer a developer tool. It's a professional tool."

### BEAT 4: The Scenario (1 minute)
**[Switch to browser — OpenClaw Gateway UI]**

> "Here's our scenario. You just got an email: Sarah Chen, CIO of Meridian Health Systems, is coming for a briefing tomorrow. She's a SAB member. Her executive sponsor is Maria Torres, our VP of Engineering. You need a full briefing package.
>
> Normally: 4-6 hours of research. Let's see what happens when I ask Oprah-tor."

### BEAT 5: Fire the Request (8-10 minutes)
**[Type into OpenClaw UI — or have it pre-typed and paste]**

```
I have a briefing tomorrow with Sarah Chen, CIO of Meridian Health Systems.
She is a SAB member on our Strategic Technology Advisory Board.
Her executive sponsor is Maria Torres, VP Engineering.

Please prepare a full briefing package:
1. Research Sarah Chen — recent activity, priorities, communication style
2. Research Meridian Health Systems — company context, news, tech landscape
3. Check our SAB records and past briefing history
4. Assemble executive dossier, backgrounder, sponsor talking points, and agenda
5. Run the VVIP protocol check and generate the checklist
```

**[As Oprah-tor processes, narrate what's happening]**

> "Watch — Oprah-tor is decomposing the request. It's dispatching to Sherlock Ohms for executive research... Bloom-borg is pulling company intelligence... and Déjà View is checking our SAB records and engagement history."

**[Split to terminal to show ZeroClaw agents working]**

> "Over here in the terminal, you can see Sherlock Ohms searching the web for Sarah Chen's recent activity. It's pulling news articles, conference appearances, published content. And Bloom-borg is doing the same for Meridian Health Systems — financial data, technology signals, competitive dynamics."

**[Switch back to OpenClaw UI as results come in]**

> "Now Déjà View is reporting back — and THIS is the magic. Déjà View knows that Sarah is an active SAB member since Q2 2024, that she led the AI Governance discussion at the last board meeting, that she visited our Boston EBC in September and gave us a 9 out of 10, and — watch this..."

**[Pause as Déjà View surfaces the flags]**

> "Déjà View just flagged that we have an OVERDUE action item. We promised Sarah an AI governance reference architecture at the February SAB meeting, due March 1st. It's March 29th. 
>
> [Look at the audience.]
>
> How many of you have walked into a briefing with an overdue commitment you didn't know about? That's a trust-destroying moment. Déjà View just saved us from it."

**[Continue narrating as Draft Punk assembles documents]**

> "Now Draft Punk is assembling the briefing package. Executive dossier... sponsor talking points for Maria Torres... recommended agenda — look at that, it's weaving the SAB themes directly into the agenda topics. AI governance and hybrid cloud reality — because that's what Sarah talked about at the last board meeting.
>
> And Alfred Bitworth is generating the VVIP checklist — Gold tier, executive suite, vegetarian catering, green tea preference... it even knows she prefers morning briefings.
>
> Sponsor Coach is also running in parallel. It's scoring Maria Torres's readiness for her drop-in — she hasn't read the last SAB meeting notes, so Sponsor Coach generates a two-minute prep brief with the exact phrases she should use about the AI governance overdue item. That's the agent that stops the sponsor from walking in cold."

### BEAT 5b: The Oddsfather's Verdict (1 minute)
**[The Oddsfather node lights up as Phase 3 begins]**

> "And now — the final agent. The Oddsfather. It's reading the full package, the overdue action item, Sarah's relationship trajectory, Maria's sponsor readiness score — and it's going to tell us something nobody usually says out loud before a briefing.
>
> Here's what the Oddsfather predicts...
>
> [Pause for the verdict to appear]
>
> Seventy-two percent probability of a positive outcome. Top risk: the overdue AI governance architecture. Top lever: lead with the acknowledgement and show the updated commitment timeline.
>
> That is not a vibes check. That is a synthesis of every signal this pipeline surfaced, expressed as a number you can put in front of a sponsor before they step into the boardroom. That's what agentic AI does that a human briefing pack can't."

### BEAT 6: The Reveal (2 minutes)
**[Show the completed package in the OpenClaw UI]**

> "So. Let's count. Executive dossier — done. Briefing backgrounder — done. Sponsor talking points — done. Recommended agenda — done. VVIP protocol checklist — done. Sponsor alert email draft — done. And two critical flags that would have blindsided us.
>
> Time elapsed: about 90 seconds.
>
> [Pause.]
>
> But here's what I really want you to take away. It's not the speed. Speed is nice. What matters is that this system connected the dots between our SAB, our EBC, and our Executive Sponsor program — automatically. It read the SAB meeting notes. It cross-referenced the briefing history. It checked the VVIP roster. It drafted talking points for the sponsor based on the SAB themes.
>
> THAT is the connective tissue Kristin described. And it's running on open-source software on a laptop."

### BEAT 7: The Enterprise Bridge (1 minute)

> "Everything you just saw: the model is IBM Granite, open source. The agent frameworks are OpenClaw and ZeroClaw, open source. The container runtime is Podman, open source. If you wanted to scale this for your whole EBC team — across multiple centers, integrated with your CRM, with guardrails and governance — that's what Red Hat's OpenShift AI platform does.
>
> But the point is: you can start experimenting today. On your own laptop. For free."

### BEAT 8: Hand Back to Kristin (30 seconds)

> "Kristin, I believe you have an ecosystem mapping exercise for us?"

---

## Contingency Plans

### If the model is slow (>30 seconds per response)
Switch to the interactive dashboard immediately. Don't wait. Say:
> "Let me switch to the pipeline visualization so you can see the full flow."

Open `briefingclaw-dashboard.html` or `briefingclaw-dashboard-redhat.html` (depending on your audience) and click "Start Demo" (or press Space). Use the contact dropdown to pick the scenario that fits your narrative. The 42-second simulation shows the full agent pipeline with activity feed, critical flags, and deliverables clickable with formatted HTML content for all 8 contacts. If the dashboard is also not available, fall back to the pre-recorded video.

### If OpenClaw crashes
Switch to the dashboard for the visual pipeline demo, then use ZeroClaw CLI for live research. Run Sherlock Ohms's research command live — it's fast and visual. The dashboard shows the orchestration flow; ZeroClaw shows real agent output.

### If nothing works
Open the dashboard (`briefingclaw-dashboard.html?autostart` or `briefingclaw-dashboard-redhat.html?autostart`) — it runs entirely standalone with no backend dependencies. Eight scenarios via the dropdown. Walk through the animated pipeline, click any completed deliverable to show formatted content, and narrate what each agent produces. If even the browser fails, go to slides with screenshots.

### For pre-session rehearsal on the road
Use `./briefingclaw.sh preview` to boot the dashboards without running any infrastructure checks. This is the fastest way to practice the narration, the persona switching, and the Oddsfather reveal on a plane, in a hotel room, or five minutes before walking onstage — without needing Podman, the Granite model, or the OpenClaw gateway.

### If the audience asks "Can I try this?"
> "Yes. OpenClaw is on GitHub — 273,000 stars, it's the fastest-growing open-source project in history. ZeroClaw is a single binary you can install with Homebrew. Podman AI Lab is a free extension. I'll share links at the end, and I'm happy to talk after the session."

### If someone asks about data privacy / security
> "Great question. Everything I showed runs locally — no API calls to external services during the demo. In an enterprise deployment, you'd add guardrails: model governance through OpenShift AI, data classification policies, audit logging. ZeroClaw has built-in OS-level sandboxing. But the key architectural choice is that the AI runs where your data lives, not the other way around."

---

## Key Lines to Memorize

These are your "money lines" — practice until they're natural:

1. **"The connective tissue between your programs — automated."**
2. **"Déjà View just saved us from a trust-destroying moment."**
3. **"It's not the speed that matters. It's that it connected the dots."**
4. **"You can start experimenting today. On your own laptop. For free."**
5. **"At a hackathon two weeks ago, construction workers were building agents like this in two hours."**
6. **"Here's what the Oddsfather predicts..."**
