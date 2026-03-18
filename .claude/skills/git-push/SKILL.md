---
name: git-push
description: Commit all changes and push to remote after a successful build. Use after confirming a build succeeds.
disable-model-invocation: true
allowed-tools: Bash
argument-hint: [short description of what changed]
---

Commit and push all current changes to the remote repository.

## Steps

1. Check git status and diff to understand what changed:
```bash
git -C /Users/bill/Documents/proj/eznap status
git -C /Users/bill/Documents/proj/eznap diff --stat
```

2. If no remote exists yet, initialize and create it:
```bash
cd /Users/bill/Documents/proj/eznap
git init && git add -A && ...
```

3. Stage all changes:
```bash
git -C /Users/bill/Documents/proj/eznap add -A
```

4. Write a short, emoji-prefixed commit message based on what changed. Use these prefixes:
   - ✨ new feature or UI
   - 🐛 bug fix
   - 🎨 design / styling change
   - ♻️ refactor
   - 🔧 config / tooling
   - 📦 project setup
   Use `$ARGUMENTS` if provided as additional context for the message.

5. Commit:
```bash
git -C /Users/bill/Documents/proj/eznap commit -m "$(cat <<'EOF'
<emoji> <short description>
)"
```

6. Push:
```bash
git -C /Users/bill/Documents/proj/eznap push
```
If no upstream is set: `git push -u origin main`

7. Report the commit hash and what was pushed.

## Rules
- Never skip commit hooks (no --no-verify)
- Never force push
- If remote doesn't exist, tell the user to run `gh repo create` first
