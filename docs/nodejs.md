# Node.js

Node is installed with **nvm**, not with a system-wide apt Node package. That keeps Ubuntu's own Node-based tools separate from yours.

## First use in a new terminal

nvm is lazy-loaded so Zsh stays fast:

```bash
nvm --version
node --version
npm --version
```

Or: `loadnvm`

## LTS

The installer runs `nvm install --lts` if no `node` is on PATH.

```bash
nvm ls
nvm install --lts
nvm alias default 'lts/*'
```

## Project-local dependencies

```bash
new-project node my-cli
cd ~/Projects/web/my-cli
nvm use
npm install
```

Do **not** `npm install -g` unless the tool cannot work as a project devDependency or via `npx`.

## `.nvmrc`

Templates include `lts/*`. In a project:

```bash
nvm use
```
