---
name: media-editor
description: Transcript-driven video post-production — set up the toolchain, transcribe with whisper.cpp, and cut/speed/export with ffmpeg. Load the matching reference for detailed commands.
---

# Media editing

Reusable procedures for transcript-driven video editing. The end-to-end
workflow is: inspect → set up tools → transcribe → plan from the transcript →
cut/speed → export → re-transcribe → verify.

Load the reference for the step you are on:

- **Toolchain setup** — install and verify ffmpeg, ffprobe, whisper.cpp, and a
  whisper model (Homebrew, Nix, or apt). See
  [references/setup-tools.md](references/setup-tools.md).
- **Transcription** — extract 16 kHz mono audio and produce a timestamped
  SRT/JSON transcript with whisper.cpp. See
  [references/audio-transcribe.md](references/audio-transcribe.md).
- **Video editing & export** — inspect with ffprobe; cut, speed-adjust
  (setpts/atempo), concatenate, and export a publication-ready H.264 MP4. See
  [references/video-editing.md](references/video-editing.md).

## Core discipline (applies to every step)

- Never overwrite source recordings — write derived files (WAV, SRT, clips,
  finals) alongside them or into `output/`, keeping the source basename.
- Transcription and long renders take minutes — run whisper-cli and long
  ffmpeg jobs as background tasks and check results on completion.
- The transcript is the source of truth for edit decisions — cite timestamps
  when proposing cuts, and show the edit plan (segments, actions, estimated
  output length) before rendering the final export.
- Prefer stream copy (`-c copy`) for lossless cuts when keyframe alignment
  allows; re-encode only when a frame-accurate cut or a filter requires it.
