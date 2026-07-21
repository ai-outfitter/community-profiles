# Media editor agent

The `media-editor` agent is a video post-production setup for transcript-driven editing: whisper.cpp transcription, ffmpeg cuts/speed changes, and publication-ready exports.

## Bundled skill

The agent selects a single Dotagents skill, `media-editor`, which routes to
step references under `references/`:

```text
skills/media-editor/
  SKILL.md
  references/
    setup-tools.md
    audio-transcribe.md
    video-editing.md
```

- `references/setup-tools.md` - install and verify the toolchain (ffmpeg, whisper.cpp, whisper model) via Homebrew on macOS, Nix, or apt + source build on Debian/Ubuntu.
- `references/audio-transcribe.md` - extract 16 kHz mono audio with ffmpeg and produce timestamped SRT/JSON transcripts with whisper.cpp (`whisper-cli`).
- `references/video-editing.md` - inspect media with ffprobe, cut and speed-adjust clips (setpts/atempo), concatenate, and export publication-ready H.264 MP4s.

## Editing pipeline

The agent instructions describe the end-to-end pipeline: inspect → transcribe → plan the edit from the transcript → cut/speed with ffmpeg → export → re-transcribe the final render and verify.
