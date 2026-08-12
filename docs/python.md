# Python

System Python comes from Ubuntu. Project dependencies never go into the system site-packages.

## Tools

| Tool | Role |
|------|------|
| `python3` | Interpreter from apt |
| `python3 -m venv` | Built-in virtualenvs |
| `pipx` | Isolated **CLI** tools for your user |
| `uv` | Fast venv + installer + lockfiles |

Never: `sudo pip install …`

## Create a project

```bash
new-project python my-lib
cd ~/Projects/python/my-lib
uv venv
source .venv/bin/activate
uv pip install -e ".[dev]"
```

Or without the helper:

```bash
mkdir -p ~/Projects/python/my-lib && cd ~/Projects/python/my-lib
uv init
```

## Virtual environments

```bash
uv venv
source .venv/bin/activate
```

`.venv/` is gitignored globally.

## Dependencies

```bash
uv pip install requests
uv pip install -e ".[dev]"
```

Prefer declaring deps in `pyproject.toml`.

## Tests

```bash
uv run pytest
```

## Format / lint

```bash
uv run ruff format .
uv run ruff check .
```

Ruff is listed in the Python template's `dev` extra. It is not installed globally.

## Environment variables

```bash
cp .env.example .env
```

Load them in the app (or with `set -a; source .env; set +a` in a throwaway shell). Never commit `.env`.
