# Justfile for mattpocock-skills fork

# Add upstream remote
remote-upstream:
    git remote add upstream https://github.com/timjonaswechler/mattpocock-skills.git 2>/dev/null || echo "upstream already exists"

# Sync skills from upstream (preserves local .gitignore and Justfile)
sync:
    @echo "=== Syncing from upstream ==="
    
    # Stash local changes (only if files exist and are modified)
    -git stash push -m "local-changes-before-sync" -- skills/.gitignore Justfile 2>/dev/null || true

    # Fetch and merge upstream main
    git fetch upstream
    git merge upstream/main --no-edit

    # Restore stashed changes
    -git stash pop 2>/dev/null || true

    echo "Sync complete."

# Full update: remote + sync
update: remote-upstream sync

# Show remotes
remotes:
    @git remote -v

# Push to fork
push:
    git push origin main
