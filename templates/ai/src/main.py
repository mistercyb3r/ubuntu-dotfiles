"""PROJECT_NAME — load configuration from the environment, never from committed files."""

import os


def main():
    model = os.environ.get("MODEL", "(unset)")
    print(f"PROJECT_NAME ready. MODEL={model}")
    if not os.environ.get("OPENAI_API_KEY") and not os.environ.get("ANTHROPIC_API_KEY"):
        print("No API key in the environment. Copy .env.example to .env")


if __name__ == "__main__":
    main()
