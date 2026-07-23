---
name: grafana-mcp-setup
description: Deploy the Grafana MCP server into a Kubernetes cluster securely — read-only Grafana credentials in Secrets, an authenticated nginx front, NetworkPolicy scoping, all as declarative config. Use when standing up, hardening, or re-keying Grafana MCP access for agents.
---

# Grafana MCP setup

Stand up [`grafana/mcp-grafana`](https://github.com/grafana/mcp-grafana) in a Kubernetes cluster so agents (for example `grafana-alert-investigator`) can query Loki, Prometheus, Tempo, and Pyroscope through one authenticated, least-privilege endpoint.

Classify the task before acting:

- **Fresh install** — follow all steps below.
- **Hardening an existing deployment** — audit against steps 3–5 and close the gaps.
- **Credential rotation** — steps 1 and 6 only; do not touch topology.

> A recommended Helm chart for this setup is forthcoming; once published, prefer referencing it (pinned) over hand-rolling the manifests below.

## 1. Grafana credentials, read-only, in a Secret

Create a Grafana service account with the **Viewer** role, generate a token, and store it as a Kubernetes Secret in the namespace the MCP server will run in. Never write the token to the repository, the `.agents` tree, or output; create the Secret from a local file or stdin and discard the source.

## 2. The MCP Deployment

Run `mcp-grafana` as a Deployment with a ClusterIP Service in a dedicated (or observability) namespace. The Grafana URL and the token come from the Secret via `env.valueFrom.secretKeyRef`. Set resource requests/limits and a liveness probe like any other workload.

## 3. Authentication in front

The MCP server itself is unauthenticated — never expose it bare. Put an authenticating reverse proxy in front, as an nginx sidecar (or separate Deployment) that terminates auth before proxying to the MCP port:

- **Basic auth** — an `htpasswd` Secret mounted into nginx (`auth_basic` + `auth_basic_user_file`); rotate alongside step 1.
- **OIDC** — `oauth2-proxy` in place of basic auth when the org has an IdP.

Consumers connect only through the proxy port; the MCP container listens on localhost within the pod where the topology allows.

```yaml
# Sketch: nginx sidecar auth in front of mcp-grafana
containers:
  - name: mcp-grafana # listens on 127.0.0.1:8000
  - name: nginx # listens on :8080, the only Service target
    volumeMounts:
      - name: htpasswd
        mountPath: /etc/nginx/auth
      - name: nginx-conf
        mountPath: /etc/nginx/conf.d
```

If anything must be reachable from outside the cluster, front it with the ingress controller and TLS; prefer keeping it ClusterIP-only.

## 4. NetworkPolicy scoping

Restrict ingress to the MCP pod to the namespaces that legitimately consume it (for example the agent namespaces the Link Operator provisions), and restrict egress to Grafana and the datasource endpoints. Default-deny everything else.

## 5. Keep it declarative

Commit every manifest — Deployment, Service, nginx config, NetworkPolicy, and (sealed or externalized) secret references — to the platform repository so the setup is reviewable and reproducible. Where the cluster uses GitOps, that repository is the change surface; hand `kubectl apply` is the fallback, not the norm.

## 6. Wire consumers and verify

Point consuming agents' MCP configuration at the authenticated endpoint with credentials from their own Secret mounts. Then verify:

1. A tools-list request through the proxy **with** credentials succeeds.
2. The same request **without** credentials is rejected.
3. A query for a known dashboard or metric returns data, confirming the Grafana token works and is read-only (a write attempt should fail).
