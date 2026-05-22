---
name: git-commit
description: Create safe Conventional Commit messages and commits from git diffs with staging review, secret checks, and logical grouping. Use when user asks to commit changes, create a git commit, prepare a commit message, or mentions "/git-commit" or "/commit".
license: MIT
allowed-tools: Bash
---

# Git Commit
Create one safe, logical git commit using Conventional Commits. Prefer already-staged changes; stage files only when the user explicitly asks or approves the exact file list.

## Workflow
1. Verify repository state.

```bash
git rev-parse --is-inside-work-tree
git --no-optional-locks status --short --branch
git --no-optional-locks diff --cached --stat
git --no-optional-locks diff --stat
git ls-files --others --exclude-standard
```

2. Choose the commit target.
- If staged changes exist, treat the staged diff as the commit target.
- If staged and unstaged changes both exist, warn that unstaged changes will be excluded.
- If nothing is staged, review unstaged/untracked changes and ask what to stage; do not run broad `git add -A` without approval.
- If requested, stage only explicit paths or use `git add -p` for mixed changes.

3. Review the target diff.
```bash
git --no-optional-locks diff --cached --find-renames --find-copies --patch
# If nothing is staged and user wants advice before staging:
git --no-optional-locks diff --find-renames --find-copies --patch
```

Check for secrets, `.env` files, credentials, private keys, generated artifacts, debug logs, unrelated changes, and lockfile surprises.

4. Validate before committing.
```bash
git diff --cached --check
git status --short
```

If no staged changes exist, stop and ask what to stage.

5. Generate and confirm the message.
Use Conventional Commit format:

```text
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

Message rules:
- Description is imperative, present tense: "add", "fix", "update".
- Keep subject concise, ideally under 72 characters.
- Add a body when the why/risk is not obvious.
- Mark breaking changes with `!` or `BREAKING CHANGE:` footer.
- Use footers such as `Refs #123` or `Closes #123` when relevant.

6. Commit only after explicit confirmation.
Prefer a temp message file for multiline commits:

```bash
tmp="$(mktemp)"
cat > "$tmp" <<'EOF'
<type>(<scope>): <description>

<body if needed>
EOF
git commit --file "$tmp"
rm -f "$tmp"
```

## Output Before Running `git commit`

Show the user:
- files that will be committed
- files that will remain unstaged/untracked
- risks or warnings
- exact commit message
- exact `git commit` command to run

## Safety Rules

- Never run `git commit` without explicit user approval.
- Never run destructive commands like `git reset --hard`, `git clean`, or force push unless explicitly requested.
- Never update git config.
- Never use `--no-verify` unless explicitly requested.
- Do not amend commits unless the user specifically asks to amend.
- If hooks fail, report the failure and ask whether to fix issues and retry.
