# Local AI (optional)

```bash
./install.sh --ai
```

This does **not** download models and does **not** install CUDA.

On a Latitude 5400 (Intel UHD 620) the installer records the GPU as Intel and skips NVIDIA stacks.

## What you get

- `~/Projects/ai`
- `~/.local/share/ubuntu-dotfiles/ai/models`
- `~/.cache/ubuntu-dotfiles/ai`
- `~/.config/ubuntu-dotfiles/ai.env` (`OLLAMA_MODELS`, `HF_HOME`)

If Ubuntu’s archive has `ollama`, that package is installed. Otherwise install it yourself later. This repo will not pipe a remote script into the shell.

## After install

```bash
# only if ollama is on PATH
ollama serve
ollama pull llama3.2
```

Use small CPU models. Do not install the NVIDIA CUDA toolkit on this laptop.
