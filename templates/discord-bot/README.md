# PROJECT_NAME

Discord bot skeleton (Python). Put the bot token in `.env` only.

## Setup

```bash
cd PROJECT_NAME
uv venv
source .venv/bin/activate
uv pip install -e ".[dev]"
cp .env.example .env
# set DISCORD_TOKEN in .env
```

Never commit the bot token. Never paste it into chat logs or GitHub issues.
