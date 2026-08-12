# PROJECT_NAME

AI application skeleton (Python). Keep API keys in `.env`.

## Setup

```bash
cd PROJECT_NAME
uv venv
source .venv/bin/activate
uv pip install -e ".[dev]"
cp .env.example .env
```

Do not commit model API keys. Prefer project-local virtualenvs over global packages.
