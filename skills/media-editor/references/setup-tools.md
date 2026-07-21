# Install the media editing toolchain

Use this reference when `ffmpeg`, `ffprobe`, or `whisper-cli` is missing, when
the user asks to set up the media editing environment, or before starting a job
on a fresh machine.

## What's needed

| Tool | Provides | Check |
|------|----------|-------|
| ffmpeg | Cutting, speed filters, encoding, audio extraction | `ffmpeg -version` |
| ffprobe | Duration, chapters, stream metadata (bundled with ffmpeg) | `ffprobe -version` |
| whisper.cpp | `whisper-cli` — local timestamped speech-to-text | `whisper-cli --help` |
| whisper model | ggml model file for whisper-cli | `ls ~/.cache/whisper/ggml-*.bin` |

## Detect the environment first

1. `uname -s` — `Darwin` → Homebrew; `Linux` → check further.
2. On Linux: if `nix` is on PATH (or the project has a `flake.nix`), prefer
   Nix; else if `apt-get` exists → Debian/Ubuntu; else report what package
   managers are available and ask.
3. Check what's already installed before installing anything — only fill gaps.

## macOS (Homebrew)

```bash
brew install ffmpeg whisper-cpp
```

Homebrew's `whisper-cpp` formula ships `whisper-cli`. On Apple Silicon it is
built with Metal support — no extra flags needed.

## Nix (any OS)

Preferred when the project already has a devshell (the deepwork-demos repo
provides both tools in its root `flake.nix`):

```bash
nix develop            # inside a project with a flake providing ffmpeg + whisper-cpp
```

Ad hoc, without a project flake:

```bash
nix shell nixpkgs#ffmpeg nixpkgs#whisper-cpp
# or persistently:
nix profile install nixpkgs#ffmpeg nixpkgs#whisper-cpp
```

On NixOS with a GPU, prefer the Vulkan build (`whisper-cpp-vulkan`) — it uses
the Vulkan backend automatically, no extra flags needed.

## Debian/Ubuntu (apt)

ffmpeg is packaged; whisper.cpp is not — build it from source:

```bash
sudo apt-get update
sudo apt-get install -y ffmpeg build-essential cmake git

git clone https://github.com/ggml-org/whisper.cpp ~/.local/src/whisper.cpp
cmake -S ~/.local/src/whisper.cpp -B ~/.local/src/whisper.cpp/build -DCMAKE_BUILD_TYPE=Release
cmake --build ~/.local/src/whisper.cpp/build -j --config Release
sudo cp ~/.local/src/whisper.cpp/build/bin/whisper-cli /usr/local/bin/
```

(For NVIDIA GPUs, add `-DGGML_CUDA=1` to the first cmake call — requires the
CUDA toolkit.)

## Whisper model

whisper-cli needs a ggml model file. Convention: `~/.cache/whisper/`.

```bash
mkdir -p ~/.cache/whisper
# Large model — best accuracy for narration (~3 GB). Ask before downloading.
curl -L -o ~/.cache/whisper/ggml-large-v3.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin

# Fast English-only fallback for rough cuts (~140 MB)
curl -L -o ~/.cache/whisper/ggml-base.en.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin
```

Model downloads are large — run them as background tasks, and always ask the
user before pulling the large model.

## Verify

Quick quiet preflight — if this prints nothing, the media transcription
toolchain is present:

```bash
ffmpeg -version >/dev/null 2>&1 || echo "missing: ffmpeg"
ffprobe -version >/dev/null 2>&1 || echo "missing: ffprobe"
whisper-cli --help >/dev/null 2>&1 || echo "missing: whisper-cli"
ls ~/.cache/whisper/ggml-*.bin >/dev/null 2>&1 || echo "missing: whisper model in ~/.cache/whisper"
```

Verbose verification:

```bash
ffmpeg -version && ffprobe -version
command -v whisper-cli
whisper-cli --help >/tmp/whisper-help.txt 2>&1
ls -lh ~/.cache/whisper/ggml-*.bin
```

Optional end-to-end smoke test — generate 3 s of silence, extract audio,
transcribe it (should produce an empty/near-empty transcript without errors):

```bash
ffmpeg -y -f lavfi -i anullsrc=r=16000:cl=mono -t 3 /tmp/smoke.wav
whisper-cli -m ~/.cache/whisper/ggml-base.en.bin -f /tmp/smoke.wav --output-srt --output-file /tmp/smoke
```

Report what was installed, from where, and any tool that still needs manual
attention.
