"""Placeholder bot entrypoint. Add discord.py or nextcord when you are ready."""

import os
import sys


def main():
    token = os.environ.get("DISCORD_TOKEN")
    if not token:
        print("Set DISCORD_TOKEN in .env (see .env.example). Refusing to start.", file=sys.stderr)
        sys.exit(1)
    print("Token is set. Install a Discord library and implement the bot here.")


if __name__ == "__main__":
    main()
