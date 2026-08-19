---
name: slidev
description: >-
  Scaffold a minimal Slidev deck fast: one package.json, one slides.md,
  dev/build/PDF-export scripts. Setup only — the deck's argument and design
  are the author's work.
---

# Slidev

Scaffold a throwaway Slidev deck in one directory. The scaffold is meant to
be discarded or promoted into project tooling later.

## Setup

```json
// package.json
{
  "private": true,
  "scripts": {
    "dev": "slidev --port 3040 --remote",
    "build": "slidev build",
    "export": "slidev export --output deck.pdf"
  },
  "dependencies": {
    "@slidev/cli": "^52.0.0",
    "@slidev/theme-default": "^0.25.0"
  },
  "devDependencies": { "playwright-chromium": "^1.60.0" }
}
```

`npm install`, then `npm run dev`. PDF export needs the playwright-chromium
dependency.

## Minimal slides.md

```md
---
theme: default
title: Deck title
transition: fade
---

# The thesis, as one claim

---

# One claim per slide

<!-- Speaker notes go in the last HTML comment on the slide. -->
```

Slides separate with `---`. The first YAML block is deck headmatter. Static
assets go in `public/` and are referenced by root path (`/images/x.png`).

## Notes

- To preview from another machine on a trusted network, add a
  `vite.config.ts` with `server.allowedHosts: true`. Vite otherwise rejects
  non-localhost Host headers. Do not ship that setting anywhere that serves
  untrusted traffic.
- Keep one claim per slide; put the explanation in speaker notes.
