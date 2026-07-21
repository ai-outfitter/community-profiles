---
name: pyramid-principle
description: Use when refining or reviewing ideas, documents, and communications for clarity and logical structure.
---

Pyramid Principle
Barbara Minto's method for structuring communication so the reader gets the point in the first sentence, not the last paragraph. Governing rule: conclusion first, then support, top-down, one logic per group.
Applies equally to a Slack update, a design doc, a SKILL.md, a PR description, or a full report. Use it as an outlining step before drafting, or as a diagnostic when a draft feels muddled.
The core structure
A pyramid has three properties. Violating any one is the most common source of "why doesn't this land":

Every point is a summary of the points grouped below it. The top idea is the answer/conclusion. Each level down is support for the level above — never a list of loosely related facts.
Ideas in each grouping are always the same kind of idea (MECE). Mutually Exclusive, Collectively Exhaustive. Don't mix "reasons this failed" with "things we could try next" in the same group.
Ideas in each grouping are logically ordered — deductively (argument, argument, therefore), chronologically (do this, then this), or by structure/degree (biggest impact first, by component, by team).

Step 1: Find the governing thought
Before writing a word of the document, answer: what single sentence, if the reader read nothing else, captures the point? This is the top of the pyramid. If you can't state it in one sentence, you don't know what you're writing yet — stop and figure that out first, don't start drafting.
Test: could this sentence stand alone as the subject line of an email that fully informs the reader? If it's vague ("update on the migration") it's not a governing thought, it's a topic. Sharpen it into a claim ("the migration is blocked on X and needs a decision on Y by Friday").
Step 2: Open with SCQA
Before the governing thought lands, the reader needs just enough context to see why it matters. Use Situation–Complication–Question–Answer:

Situation: an uncontroversial statement of the state of the world the reader already agrees with. One or two sentences, no tension yet.
Complication: what changed, went wrong, or is at risk — the thing that makes this worth reading now.
Question: the question the complication raises in the reader's mind (often implicit, not literally written).
Answer: the governing thought from Step 1. This is the point of the whole document.

Keep S and C short. Most drafts fail by either skipping the complication (reader doesn't know why they should care) or burying the answer three paragraphs after it (reader has to dig for the point).
Step 3: Build the supporting layers
Under the governing thought, group the supporting arguments. For each group, ask two questions:

Vertically: does this group of points, read together, actually answer the question the point above it raises? ("Why?" / "How?" / "So what should I do?") If a reader could reasonably ask a follow-up that the next line down doesn't answer, the structure has a gap.
Horizontally: within one group, are all the points the same kind of point, and is there a real ordering to them (not just a bullet dump)? If you can't say whether the order is deductive, chronological, or by degree, the group probably needs to be split or re-sorted.

Repeat recursively — each supporting point can itself be a mini-governing-thought with its own supporting layer below it. Stop when a point is concrete enough to stand on its own (a fact, a number, an instruction) without further support.
Deductive vs. inductive grouping
Two ways to justify a point from what's below it — pick one per group, don't blend them:

Deductive (argument chain): A is true. A implies B. Therefore C. Reads like a chain; each link depends on the previous one. Good for persuasion and root-cause explanations.
Inductive (same-kind-of-thing): Reasons X, Y, Z are all independent evidence for the same conclusion — order doesn't chain, but they must be genuinely the same category (all "risks," all "cost drivers," all "steps"), not a junk drawer.

If a reader can't tell which one a section is doing, that's usually the actual bug in the draft, not the prose quality.
Applying it by format

Email / Slack update: subject line or first sentence = governing thought. One-line SCQA if the reader needs context. Body = grouped support, most important group first.
Doc / spec / report: governing thought as the opening paragraph or an explicit "Summary"/"TL;DR" section, not the ending. Headings should mirror the pyramid — each heading summarizes what's under it; a reader skimming only headings should get the argument.
PR description: governing thought = what changed and why, in the first line. Supporting groups = what/why/how-tested/risks, not an undifferentiated commit-log dump.
README / SKILL.md: governing thought = the one-line description of what this is for and when to use it, stated before any procedure. Sections below are grouped by the kind of decision the reader needs to make, in the order they need to make it.
Presentation: governing thought = the one slide someone would remember if they saw only one. Each section's lead slide is a summary of the slides behind it, same top-down/MECE rule.

Diagnostic checklist (for reviewing an existing draft)
Run a draft against these; each failure points to a specific fix:

Can you find one sentence early on that states the whole point? If it's missing or buried past the first paragraph → move it up, restate it as a claim not a topic.
Does every paragraph/section answer a question raised by the one above it? If not → either the section is misplaced, or there's a missing link the reader has to infer.
Within any bullet list or section, are all items really the same kind of thing? If it mixes causes with next-steps with caveats → split into separate, correctly-labeled groups.
Is there a real order to each group, or is it a shuffled bag? → reorder by argument logic, time, or magnitude — whichever actually applies.
Could you delete the last third of the document and still have the reader understand the point? If yes, the point wasn't at the top — it was building up to a reveal instead of leading with it.

Common failure modes

Narrative buildup: writing in the order you discovered the answer (chronology of investigation) instead of the order the reader needs it (answer first). This is the single most common violation — natural for the author, backwards for the reader.
Grab-bag grouping: bullets that are all "things I noticed" rather than one MECE category. Fix by naming the group first ("three things are blocking launch:") and testing whether each bullet actually fits that name.
Orphan support: a supporting point that doesn't answer the question its parent raises — usually a sign the point belongs somewhere else in the pyramid, or doesn't belong at all.
No governing thought at all: a status update that's just a log of activity. Force the one-sentence-summary test before drafting.