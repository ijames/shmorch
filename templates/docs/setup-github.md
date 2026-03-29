# GitHub Setup

Claude's `/rewind` covers 30 days. Git covers you permanently.

## Install Git
- Mac: `xcode-select --install`
- Windows: https://git-scm.com/download/win
- Linux: `sudo apt install git`

## Configure (once)
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## Create a GitHub repo
https://github.com → + → New repository → Private
Don't check "Initialize with README" → copy the URL

## Connect your project
```bash
cd ~/Projects/YourProject
git init && git add . && git commit -m "initial"
git remote add origin https://github.com/yourname/repo.git
git branch -M main && git push -u origin main
```
Password = Personal Access Token:
GitHub → Settings → Developer settings → Tokens (classic) → "repo" scope

## Daily use
```bash
bash tools/checkpoint.sh
```

| Situation | Use |
|---|---|
| Just broke something | `Esc Esc` or `/rewind` |
| Finished a feature | `bash tools/checkpoint.sh` |
| Backup / share | git push |
| Recover old work | `git log` then `git checkout` |
