# PROJECT_NAME

Python project managed with [uv](https://docs.astral.sh/uv/).

## Setup

```bash
cd PROJECT_NAME
uv venv
source .venv/bin/activate
uv pip install -e ".[dev]"
cp .env.example .env
```

## Commands

```bash
uv run pytest
uv run ruff check .
uv run ruff format .
```

Do not use `sudo pip`. Dependencies live in this project, not the system Python.
