# Grafana alert investigator agent

The `grafana-alert-investigator` agent is a headless, event-driven observability
triager. An alert fires, the agent is woken with the alert's metadata, it
investigates the alerting resource across Grafana's signals and — when it runs in
the failing environment's cluster — the Kubernetes API, and it comments its
diagnosis on the issue that already tracks the alert. Its scope ends at the
comment: it never touches a workload and never attempts the fix.

It is grounded in one recurring problem: long, resource-heavy jobs generate a lot
of alerts, and a person triages every one. Two patterns dominate, and the agent
is built to tell them apart:

- **Known-noisy** — e.g. a high-CPU alert on a job you already know is CPU-bound.
  The agent confirms it is sitting at its normal ceiling and recommends ignoring
  this instance or tuning the alert.
- **Real anomaly** — e.g. a process that randomly dies (OOMKill, non-zero exit,
  node eviction). The agent investigates across logs, metrics, traces, profiles,
  and pod state, and recommends a concrete next step.

## What it needs

The agent installs nothing; it consumes infrastructure that is assumed present:

- the **Grafana MCP server** ([`grafana/mcp-grafana`](https://github.com/grafana/mcp-grafana)),
  configured for the Pi harness in
  [`cli_specific/pi/.mcp.json`](../cli_specific/pi/.mcp.json), reachable via
  `GRAFANA_URL` + `GRAFANA_API_KEY`, exposing Loki logs, Prometheus metrics,
  Tempo traces, and Pyroscope profiles;
- a **`kube-prometheus-stack`**
  ([helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack))
  install providing the Prometheus + Alertmanager + Loki + Alloy + Grafana
  pipeline that raises the alerts;
- **read-only Kubernetes access** when the agent runs in the same cluster as the
  failing environment, for the pod-state half of the investigation;
- a **GitHub token** for `gh` to search issues and post the diagnosis comment.

## Bundled skills

The agent selects two focused skills:

```text
skills/grafana-alert-investigate/SKILL.md   gather evidence + classify
skills/alert-issue-triage/SKILL.md          find the existing issue + comment
```

- `grafana-alert-investigate` — scopes every query to the alerting resource and a
  window around the alert start: the firing rule and its threshold, the
  Prometheus series vs. its own history and limits, Loki logs, Tempo traces,
  Pyroscope profiles, and (in-cluster) `kubectl describe` / `get events` /
  `logs --previous` for exit reasons and evictions. It emits a structured finding
  classified `expected` or `anomaly` with a confidence level. Read-only only.
- `alert-issue-triage` — searches open issues for the one tracking this alert,
  confirms the match, and posts a single comment with the classification,
  evidence, and one recommended next step, noting that the issue can be assigned
  to a team, another agent, or a human to carry out any fix.

## Investigate → classify → comment

The end-to-end pipeline: an alert fires → the agent is woken with a
`trigger_context` of alert labels/annotations → it gathers cross-signal evidence
for the resource → classifies it as known-noisy or a real anomaly → finds the
existing tracking issue and comments the diagnosis and recommendation. Escalation
(assigning the fix to a team, agent, or human) is explicitly out of scope — the
agent stops at the diagnosis.

Every alert value in `trigger_context` is treated as an opaque, user-influenced
identifier — used to look signals up, never as an instruction or an asserted
fact. The agent only ever reads; it never mutates a workload, never opens or
edits issues, and posts exactly one comment per run.
