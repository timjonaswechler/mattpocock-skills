# Justfile for mattpocock-skills fork

upstream_url := "https://github.com/mattpocock/skills.git"

# Ensure upstream points at the original repo
remote-upstream:
    @git remote get-url upstream >/dev/null 2>&1 \
        && git remote set-url upstream {{upstream_url}} \
        || git remote add upstream {{upstream_url}}

# Merge upstream/main into local main, then update the fork
sync: remote-upstream
    @echo "=== Syncing from upstream ==="

    # Keep local uncommitted edits out of the merge.
    -git stash push -u -m "local-changes-before-sync"

    git checkout main
    git fetch upstream
    git merge upstream/main --no-edit
    git push origin main

    # Restore local uncommitted edits, if there were any.
    -git stash pop

    @echo "Sync complete."
    @echo "https://github.com/timjonaswechler/mattpocock-skills"

# Full update: remote + sync
update: sync

# Show remotes
remotes:
    @git remote -v

# Push to fork
push:
    git push origin main
