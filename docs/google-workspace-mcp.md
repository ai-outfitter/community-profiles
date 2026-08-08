# Google Workspace MCP servers

The tree-root [`mcp.json`](../mcp.json) declares the official Google-hosted remote MCP servers (Developer Preview) for Gmail, Google Calendar, and Google Contacts:

| Server id | Endpoint |
| --- | --- |
| `google-gmail` | `https://gmailmcp.googleapis.com/mcp/v1` |
| `google-calendar` | `https://calendarmcp.googleapis.com/mcp/v1` |
| `google-contacts` | `https://people.googleapis.com/mcp/v1` |

An agent adopts a server when its loadout lists the server id in the `mcp` field. The [`founder` override](../agents/founder/config.json) in this catalog adopts all three by default.

## Prerequisites

You must complete this setup in Google Cloud before a connection succeeds:

1. Create or select a GCP project.
2. Enable the product API for each server: Gmail API, Google Calendar API, People API.
3. Enable each product's separate MCP API in the same project.
4. Configure an OAuth consent screen. Add the scopes the servers use: `gmail.readonly`, `gmail.compose`, `calendar.readonly`, `contacts.readonly`, as applicable.
5. Create a Web-application OAuth client. Add the MCP host's redirect URI to the client.
6. Enroll the account in the Google Workspace Developer Preview Program.

## Limits

- The servers are in Developer Preview. Google can change them.
- The servers are interactive-only. Each MCP host completes its own OAuth flow through a registered redirect URI. Do not use these servers for headless or cron work.

## Security

- The Gmail server has no send tool. It can create drafts (`gmail.compose`), but a human sends the mail.
- Treat inbox content as untrusted input. Mail can carry indirect prompt injection.
- The exfiltration boundary is the session's combined egress set. Read access to mail plus any outbound channel (browser, git push, another MCP server) forms a complete exfiltration path. Keep the loadout of a session that reads mail small.
