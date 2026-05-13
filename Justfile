# Justfile for mattpocock-skills fork

# Add upstream remote
remote-upstream:
    git remote add upstream https://github.com/mattpocock/mattpocock-skills.git 2>/dev/null || echo "upstream already exists"

# Sync skills from upstream (preserves local .gitignore)
sync:
    @echo "=== Syncing from upstream ==="
    
    # Stash local changes
    -git stash push -m "local-changes-before-sync" -- skills/.gitignore

    # Fetch and merge upstream main
    git fetch upstream
    git merge upstream/main --no-edit

    # Restore stashed changes
    -git stash pop

    echo "Sync complete. Check git status for any conflicts."

# Full update: remote + sync
update: remote-upstream sync

# Show remotes
remotes:
    @git remote -v

# Push to fork
push:
    git push origin main