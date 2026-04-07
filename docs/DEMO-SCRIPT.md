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
> What if I told you that the connective tissue Kristin described — the thing that links your CAB, your EBC, and your Executive Sponsor program — could be automated by a team of AI agents running on your laptop? No cloud. No vendor lock-in. Open source."

### BEAT 2: Meet the Agents (2 minutes)
**[Switch to slide showing the multi-agent architecture diagram]**

> "I want to introduce you to BriefingClaw — a multi-agent system we built using open-source AI tools. It's six specialized agents, each with a specific job:
>
> **Oprah-tor** is the orchestrator — the air traffic controller. You give it a briefing request, and it coordinates everything else.
>
> **Sherlock Ohms** does executive research — think of it as your executive research analyst who reads everything and never sleeps.
>
> **Bloom-borg** handles company-level intelligence — financial signals, technology priorities, competitive dynamics.
>
> **Déjà View** is the connective tissue agent — it's the one that checks your CAB database, pulls past briefing records, and connects the dots between programs. This is the agent that makes the 'Program of Programs' actually work.
>
> **Draft Punk** assembles all the intelligence into polished deliverables — the dossier, the talking points, the agenda.
>
> **Alfred Bitworth** handles VVIP protocol — checklist, sponsor notifications, the whole operation.
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

> "Here's our scenario. You just got an email: Sarah Chen, CIO of Meridian Health Systems, is coming for a briefing tomorrow. She's a CAB member. Her executive sponsor is Maria Torres, our VP of Engineering. You need a full briefing package.
>
> Normally: 4-6 hours of research. Let's see what happens when I ask Oprah-tor."

### BEAT 5: Fire the Request (8-10 minutes)
**[Type into OpenClaw UI — or have it pre-typed and paste]**

```
I have a briefing tomorrow with Sarah Chen, CIO of Meridian Health Systems.
She is a CAB member on our Strategic Technology Advisory Board.
Her executive sponsor is Maria Torres, VP Engineering.

Please prepare a full briefing package:
1. Research Sarah Chen — recent activity, priorities, communication style
2. Research Meridian Health Systems — company context, news, tech landscape
3. Check our CAB records and past briefing history
4. Assemble executive dossier, backgrounder, sponsor talking points, and agenda
5. Run the VVIP protocol check and generate the checklist
```

**[As Oprah-tor processes, narrate what's happening]**

> "Watch — Oprah-tor is decomposing the request. It's dispatching to Sherlock Ohms for executive research... Bloom-borg is pulling company intelligence... and Déjà View is checking our CAB records and engagement history."

**[Split to terminal to show ZeroClaw agents working]**

> "Over here in the terminal, you can see Sherlock Ohms searching the web for Sarah Chen's recent activity. It's pulling news articles, conference appearances, published content. And Bloom-borg is doing the same for Meridian Health Systems — financial data, technology signals, competitive dynamics."

**[Switch back to OpenClaw UI as results come in]**

> "Now Déjà View is reporting back — and THIS is the magic. Déjà View knows that Sarah is an active CAB member since Q2 2024, that she led the AI Governance discussion at the last board meeting, that she visited our Boston EBC in September and gave us a 9 out of 10, and — watch this..."

**[Pause as Déjà View surfaces the flags]**

> "Déjà View just flagged that we have an OVERDUE action item. We promised Sarah an AI governance reference architecture at the February CAB meeting, due March 1st. It's March 29th. 
>
> [Look at the audience.]
>
> How many of you have walked into a briefing with an overdue commitment you didn't know about? That's a trust-destroying moment. Déjà View just saved us from it."

**[Continue narrating as Draft Punk assembles documents]**

> "Now Draft Punk is assembling the briefing package. Executive dossier... sponsor talking points for Maria Torres... recommended agenda — look at that, it's weaving the CAB themes directly into the agenda topics. AI governance and hybrid cloud reality — because that's what Sarah talked about at the last board meeting.
>
> And Alfred Bitworth is generating the VVIP checklist — Gold tier, executive suite, vegetarian catering, green tea preference... it even knows she prefers morning briefings."

### BEAT 6: The Reveal (2 minutes)
**[Show the completed package in the OpenClaw UI]**

> "So. Let's count. Executive dossier — done. Briefing backgrounder — done. Sponsor talking points — done. Recommended agenda — done. VVIP protocol checklist — done. Sponsor alert email draft — done. And two critical flags that would have blindsided us.
>
> Time elapsed: about 90 seconds.
>
> [Pause.]
>
> But here's what I really want you to take away. It's not the speed. Speed is nice. What matters is that this system connected the dots between our CAB, our EBC, and our Executive Sponsor program — automatically. It read the CAB meeting notes. It cross-referenced the briefing history. It checked the VVIP roster. It drafted talking points for the sponsor based on the CAB themes.
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
Switch to the pre-recorded video immediately. Don't wait. Say:
> "The conference WiFi is giving our model a workout — let me show you what this produced when I ran it this morning."

### If OpenClaw crashes
Switch to ZeroClaw CLI only. Run Sherlock Ohms's research command live — it's fast and visual. Skip the multi-agent orchestration and show the output documents you pre-generated.

### If nothing works
Go to slides with screenshots. You have the full output pre-captured. Walk through each document and narrate what the agents produced. The content is strong enough to stand on its own.

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
