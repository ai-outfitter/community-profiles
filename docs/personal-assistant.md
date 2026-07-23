# Personal assistant — one agent, many channels

These profiles turn the channel skills (`gmail`, `slack-responder`,
`signal-responder`) into **composable personal agents**. Each channel is published
as a profile that bundles its skill with the shared
[`link-pi-extension`](https://github.com/ai-outfitter/link) channel-events pi
extension; composing several gives one agent assigned to all of them.

## Why a profile per channel

A profile *combines a skill and an extension*. The skill is how the model reads and
answers on a channel; the extension is how that channel's **native push** wakes the
agent (JMAP EventSource, `signal-cli` daemon, …) so it runs only when there is real
work, instead of polling on a timer.

Publishing them separately means each is independently usable — assign an agent to
just email, or just Slack — and, because loadout entries are **slugs merged by ID
across layers**, selecting several de-duplicates the shared extension to a single
load.

## Composing a unified agent

`personal-assistant` is the ready-made composition:

```yaml
# agents/personal-assistant/agent.md
skills: [gmail, slack-responder, signal-responder]
extensions: [git:github.com/ai-outfitter/link-pi-extension]
```

To build your own in a `~/.agents` or org layer, select the channel skills you want
and the one extension. All channels feed a **single notification queue**: the
extension pushes one wake naming the channels with activity, and the agent drains
each with its skill before ending the turn.

Only channels whose **credentials are present** activate (the extension
auto-detects, or set `LINK_CHANNEL_EVENTS` explicitly), so adding a channel is
adding its Secret — no profile edit.

## Requirements

- The `link-pi-extension` package (Pi harness) must be resolvable by the extension
  ref — see that repo for publishing/pinning. Until it is published, the
  `extensions:` ref will not resolve at run time.
- Per-channel credentials as documented by each channel skill (`gmail`:
  `GMAIL_USER`/`GAMCFGDIR`; `slack-responder`: `SLACK_BOT_TOKEN`; `signal-responder`:
  `SIGNAL_NUMBER`/`SIGNAL_CLI_CONFIG`).
- A model from `models.json` (the profiles default to the catalog model; override
  per deployment in a lower layer).
