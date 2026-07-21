# Timestamped transcription with whisper.cpp

Use this reference when the user asks to transcribe a video or audio file,
wants subtitles, or when an editing task needs timestamped text to find cut
points.

## Requirements

- `ffmpeg` on PATH (audio extraction).
- `whisper-cli` (whisper.cpp) on PATH.
- A whisper model. Prefer the large model at `~/.cache/whisper/ggml-large.bin`
  (or `ggml-large-v3.bin`). If missing, ask before downloading — the large
  model is ~3 GB. `ggml-base.en.bin` is an acceptable fast fallback for
  English-only rough cuts. See [setup-tools.md](setup-tools.md) to install the
  toolchain and a model.

## Process

1. Extract the audio as 16 kHz mono WAV — this is what whisper.cpp expects:

   ```bash
   ffmpeg -y -loglevel error -i <input.(mp4|mkv|mov)> -vn -ar 16000 -ac 1 <basename>.wav
   ```

2. Transcribe with timestamped output. Run this as a **background task** —
   it takes several minutes for a few minutes of video:

   ```bash
   whisper-cli -m ~/.cache/whisper/ggml-large.bin -f <basename>.wav \
     --output-srt --output-json --output-file <basename>
   ```

3. Verify `<basename>.srt` exists, timestamps start at `00:00:00` and span
   the full media duration (compare against `ffprobe -show_format`), and
   spot-check a few segments against the audio content.

## Conventions

- Transcripts keep the same basename as the media file, with `.srt` and
  `.json` extensions written alongside it (e.g. `takes/single-prompt.mkv` →
  `takes/single-prompt.srt`).
- The intermediate WAV is disposable — write it next to the source or in a
  scratch directory, and don't commit it unless the project tracks WAVs in LFS.
- SRT is for humans and edit planning; the JSON output carries per-segment
  timestamps for programmatic use.

## Output

Standard SRT with sequential timestamped segments:

```
1
00:00:00,000 --> 00:00:05,200
You can see this is something we pulled out of the ground

2
00:00:05,200 --> 00:00:10,800
and it's basically just clay
```
