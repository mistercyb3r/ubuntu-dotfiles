# GitHub SSH

This laptop should talk to GitHub over SSH. Identity and keys stay on the machine, never in this repository.

## 1. Git identity

```bash
setup-git-identity
```

## 2. Create a key (if the installer did not)

```bash
ssh-keygen -t ed25519 -C "$(id -un)@$(hostname)" -f ~/.ssh/id_ed25519
```

Use a passphrase if the laptop might leave your desk. The installer can create an empty-passphrase key for convenience; you can replace it.

## 3. Copy the public key

```bash
sshpubkey
# or:
cat ~/.ssh/id_ed25519.pub
```

Add it at: GitHub → Settings → SSH and GPG keys → New SSH key.

Never paste the **private** key (`id_ed25519` without `.pub`).

## 4. Test

```bash
ssh -T git@github.com
```

Expected: a success message mentioning your GitHub username.

## 5. Clone

```bash
git clone git@github.com:YOUR_USER/YOUR_REPO.git
```

## 6. GitHub CLI (optional)

```bash
gh auth login
```

Choose SSH when asked. `gh` will store its token in the user account, not in this repo.

## Optional: rewrite HTTPS GitHub URLs to SSH

After SSH works, you may uncomment the `url.insteadOf` block in `git/gitconfig` and re-run `./install.sh`, or set:

```bash
git config --global url.git@github.com:.insteadOf https://github.com/
```
