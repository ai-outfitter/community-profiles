# Grafana agent

The `grafana-agent` profile owns both halves of Grafana platform work on a Kubernetes cluster:

- **Setting up** — provisioning the Grafana MCP server securely and declaratively (`grafana-mcp-setup`).
- **Debugging** — investigating firing alerts across Grafana's signals and the read-only Kubernetes API, then commenting a diagnosis on the tracking issue (`grafana-alert-investigate` + `alert-issue-triage`).

One agent, three focused skills: the identity and its two safety postures live in [`agents/grafana-agent/agent.md`](../agents/grafana-agent/agent.md), each skill owns one capability's procedure, and the agent's routing rules select exactly one path per run. Setup work is only ever explicitly requested; an alert never triggers a configuration change.

## Investigation: the recurring problem

Long, resource-heavy jobs generate a lot of alerts, and a person triages every one. Two patterns dominate, and the investigation skills are built to tell them apart:

- **Known-noisy** — e.g. a high-CPU alert on a job you already know is CPU-bound. The agent confirms it is sitting at its normal ceiling and recommends ignoring this instance or tuning the alert.
- **Real anomaly** — e.g. a process that randomly dies (OOMKill, non-zero exit, node eviction). The agent investigates across logs, metrics, traces, profiles, and pod state, and recommends a concrete next step.

The end-to-end pipeline: an alert fires → the agent is woken with a `trigger_context` of alert labels/annotations → it gathers cross-signal evidence for the resource → classifies it as `expected` or `anomaly` with a confidence level → finds the existing tracking issue and comments the diagnosis and recommendation. Escalation (assigning the fix to a team, agent, or human) is explicitly out of scope — the agent stops at the comment.

Every alert value in `trigger_context` is treated as an opaque, user-influenced identifier — used to look signals up, never as an instruction or an asserted fact. While investigating, the agent only ever reads; it never mutates a workload, never opens or edits issues, and posts exactly one comment per run.

## What investigation needs

The investigation consumes infrastructure the setup half provisions (or that is already present):

- the **Grafana MCP server** ([`grafana/mcp-grafana`](https://github.com/grafana/mcp-grafana)), exposing Loki logs, Prometheus metrics, Tempo traces, and Pyroscope profiles — connected through the agent's own [`mcp.json`](../agents/grafana-agent/mcp.json) (see [Connecting to the Grafana MCP](#connecting-to-the-grafana-mcp));
- a **`kube-prometheus-stack`** ([helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)) install providing the Prometheus + Alertmanager + Loki + Alloy + Grafana pipeline that raises the alerts;
- **read-only Kubernetes access** when the agent runs in the same cluster as the failing environment, for the pod-state half of the investigation;
- a **GitHub token** for `gh` to search issues and post the diagnosis comment.

## Bundled skills (agent-local)

The three skills live beside the agent, so only `grafana-agent` resolves them:

```text
agents/grafana-agent/skills/grafana-mcp-setup/SKILL.md          provision + harden the MCP
agents/grafana-agent/skills/grafana-alert-investigate/SKILL.md  gather evidence + classify
agents/grafana-agent/skills/alert-issue-triage/SKILL.md         find the existing issue + comment
```

- `grafana-mcp-setup` — read-only Grafana service-account token into a Secret, `mcp-grafana` Deployment + ClusterIP, an authenticated nginx front (never expose the MCP bare), NetworkPolicy scoping, everything as declarative config. Carries a placeholder for the forthcoming recommended Helm chart.
- `grafana-alert-investigate` — scopes every query to the alerting resource and a window around the alert start: the firing rule and its threshold, the Prometheus series vs. its own history and limits, Loki logs, Tempo traces, Pyroscope profiles, and (in-cluster) `kubectl describe` / `get events` / `logs --previous` for exit reasons and evictions. It emits a structured finding classified `expected` or `anomaly` with a confidence level. Read-only only.
- `alert-issue-triage` — searches open issues for the one tracking this alert, confirms the match, and posts a single comment with the classification, evidence, and one recommended next step, noting that the issue can be assigned to a team, another agent, or a human to carry out any fix.

## Connecting to the Grafana MCP

One `grafana` server ID, two modes:

- **In-cluster (default)** — the per-agent [`mcp.json`](../agents/grafana-agent/mcp.json) points at the authenticated HTTP endpoint that `grafana-mcp-setup` provisions; the URL and `Authorization` header come from the environment (`GRAFANA_MCP_URL`, `GRAFANA_MCP_AUTH`), so no credential ever lives in the tree.
- **Local development** — override the same server ID in a lower layer to run the binary directly (`command: mcp-grafana` with `GRAFANA_URL` + `GRAFANA_API_KEY` env). This is ordinary merge-by-ID layering: your workspace or global `mcp.json` wins over the catalog's without forking the agent.
