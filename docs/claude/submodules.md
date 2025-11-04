# Submodule Management

This document covers Git submodule management, branch structure, and workflows for the multi-repository KBS3 aggregate.

## Submodule Structure

The `kbs3-aggregate` is a **multi-repository aggregate** managed via Git submodules:

### Submodule List

| Submodule | Description | Type |
|-----------|-------------|------|
| `kbs3/` | Organization-specific KBS extensions | Application |
| `kbsx/` | Additional KBS extensions | Application |
| `modality-fork/` | Forked Modality booking system | Framework |
| `webfx-fork/` | WebFX platform fork | Framework |
| `webfx-platform-fork/` | WebFX platform services fork | Framework |
| `webfx-stack-fork/` | WebFX stack modules fork | Framework |
| `webfx-extras-fork/` | WebFX extras utilities fork | Framework |
| `webfx-parent-fork/` | WebFX parent POM fork | Build |
| `webfx-stack-parent-fork/` | WebFX stack parent POM fork | Build |
| `webfx-lib-javacupruntime-fork/` | JavaCup runtime fork | Library |

### Why Forks?

The aggregate uses forked versions of dependencies to:
- Maintain control over the full stack
- Apply custom patches and modifications
- Ensure version compatibility across all components
- Synchronize releases across all modules

## Branch Structure

All submodules follow a consistent branch structure:

### Main Branches

| Branch | Purpose | Environment |
|--------|---------|-------------|
| `main` | Development branch | Development |
| `staging` | Staging environment | Staging |
| `prod` | Production environment | Production |
| `sync` | Synchronization with upstream | Sync only |

### Branch Rules

1. **All submodules must be on the same branch** when building
   - If aggregate is on `staging`, all submodules must be on `staging`
   - If aggregate is on `prod`, all submodules must be on `prod`

2. **The `sync` branch** is used only for WebFX forks
   - Pull upstream changes into `sync`
   - Merge `sync` into `staging` or `prod` after testing

3. **Feature branches** should be created in both aggregate and affected submodules

## Initial Setup

### Clone with Submodules

```bash
git clone --recursive https://github.com/kadampabookings/kbs3-aggregate.git .
```

If you already cloned without `--recursive`:
```bash
git submodule update --init --recursive
```

### Checkout All Submodules to Staging

```bash
cd kbsx && git checkout staging && cd ..
cd kbs3 && git checkout staging && cd ..
cd modality-fork && git checkout staging && cd ..
cd webfx-extras-fork && git checkout staging && cd ..
cd webfx-fork && git checkout staging && cd ..
cd webfx-platform-fork && git checkout staging && cd ..
cd webfx-stack-fork && git checkout staging && cd ..
cd webfx-parent-fork && git checkout staging && cd ..
cd webfx-stack-parent-fork && git checkout staging && cd ..
cd webfx-lib-javacupruntime-fork && git checkout staging && cd ..
```

Or use a one-liner:
```bash
for dir in kbsx kbs3 modality-fork webfx-extras-fork webfx-fork webfx-platform-fork webfx-stack-fork webfx-parent-fork webfx-stack-parent-fork webfx-lib-javacupruntime-fork; do cd $dir && git checkout staging && cd ..; done
```

### Configure Git to Ignore Submodule Changes

This prevents the aggregate from tracking every commit in submodules:

```bash
git config submodule.kbsx.ignore all
git config submodule.kbs3.ignore all
git config submodule.modality-fork.ignore all
git config submodule.webfx-extras-fork.ignore all
git config submodule.webfx-fork.ignore all
git config submodule.webfx-platform-fork.ignore all
git config submodule.webfx-stack-fork.ignore all
git config submodule.webfx-parent-fork.ignore all
git config submodule.webfx-stack-parent-fork.ignore all
git config submodule.webfx-lib-javacupruntime-fork.ignore all
```

## Common Workflows

### Making Changes Within a Single Submodule

When changes are confined to one submodule:

```bash
# 1. Navigate to submodule
cd kbs3

# 2. Create feature branch
git checkout -b feature/my-feature

# 3. Make changes, commit
git add .
git commit -m "Add new feature"

# 4. Push to remote
git push origin feature/my-feature

# 5. Create pull request on GitHub for the submodule

# 6. After PR is merged to staging, update aggregate
cd ..
git add kbs3
git commit -m "Update kbs3 submodule reference"
git push
```

### Making Changes Across Multiple Submodules

When changes span multiple repositories:

```bash
# 1. Create feature branch in aggregate
git checkout -b feature/cross-module-feature

# 2. Create feature branch in affected submodules
cd kbs3
git checkout -b feature/cross-module-feature
cd ..

cd modality-fork
git checkout -b feature/cross-module-feature
cd ..

# 3. Make changes in each submodule
cd kbs3
# ... make changes ...
git add .
git commit -m "Part 1: Changes in kbs3"
git push origin feature/cross-module-feature
cd ..

cd modality-fork
# ... make changes ...
git add .
git commit -m "Part 2: Changes in modality"
git push origin feature/cross-module-feature
cd ..

# 4. Update aggregate submodule references
git add kbs3 modality-fork
git commit -m "Update submodule references for cross-module feature"
git push origin feature/cross-module-feature

# 5. Create PRs for each repository
# 6. Merge in dependency order (dependencies first, then dependents)
```

### Syncing Upstream Changes (WebFX Forks)

For WebFX forks, use the `sync` branch to pull upstream changes:

```bash
# 1. Navigate to WebFX fork
cd webfx-platform-fork

# 2. Checkout sync branch
git checkout sync

# 3. Pull upstream changes
git fetch upstream
git merge upstream/main

# 4. Push sync branch
git push origin sync

# 5. Return to aggregate root
cd ..

# 6. Run merge script
./scripts/merge-sync-into-local-staging.sh

# 7. Test thoroughly

# 8. Push all staging branches
./scripts/push-all-staging-branches-to-remote.sh
```

## Submodule Scripts

The aggregate provides helper scripts for common operations:

### merge-sync-into-local-staging.sh

Merges the `sync` branch into local `staging` branches for all WebFX forks:

```bash
./scripts/merge-sync-into-local-staging.sh
```

**What it does**:
1. Iterates through all WebFX fork submodules
2. Checks out `staging` branch
3. Merges `sync` branch into `staging`
4. Reports conflicts if any

**After running**: Resolve any conflicts, test, then push.

### push-all-staging-branches-to-remote.sh

Pushes all `staging` branches to remote:

```bash
./scripts/push-all-staging-branches-to-remote.sh
```

**What it does**:
1. Pushes `staging` branch for all submodules
2. Pushes aggregate `staging` branch
3. Reports any failures

**When to use**: After merging changes, testing, and confirming all is working.

## Checking Submodule Status

### View All Submodule Branches

```bash
git submodule foreach 'echo "$name: $(git branch --show-current)"'
```

### View All Submodule Status

```bash
git submodule foreach 'git status'
```

### Check for Uncommitted Changes

```bash
git submodule foreach 'git diff --quiet || echo "$name has uncommitted changes"'
```

### Update All Submodules to Latest Remote Commit

```bash
git submodule update --remote
```

## Switching Branches Across All Submodules

### Switch All to Staging

```bash
git checkout staging
for dir in kbsx kbs3 modality-fork webfx-extras-fork webfx-fork webfx-platform-fork webfx-stack-fork webfx-parent-fork webfx-stack-parent-fork webfx-lib-javacupruntime-fork; do
  cd $dir && git checkout staging && cd ..;
done
```

### Switch All to Production

```bash
git checkout prod
for dir in kbsx kbs3 modality-fork webfx-extras-fork webfx-fork webfx-platform-fork webfx-stack-fork webfx-parent-fork webfx-stack-parent-fork webfx-lib-javacupruntime-fork; do
  cd $dir && git checkout prod && cd ..;
done
```

## Troubleshooting

### Issue: Submodule is in detached HEAD state

**Cause**: Submodule is pointing to a specific commit, not a branch.

**Solution**:
```bash
cd <submodule>
git checkout staging  # or appropriate branch
cd ..
git add <submodule>
git commit -m "Update submodule to branch"
```

### Issue: Cannot switch branches in aggregate

**Cause**: Uncommitted changes in submodules.

**Solution**:
```bash
# Check which submodules have changes
git submodule foreach 'git status'

# Commit or stash changes in each submodule
cd <submodule>
git stash  # or commit changes
cd ..
```

### Issue: Submodule shows modified but no changes

**Cause**: Submodule is pointing to different commit than expected.

**Solution**:
```bash
# Reset submodule to commit recorded in aggregate
git submodule update <submodule>

# Or update aggregate to current submodule commit
git add <submodule>
git commit -m "Update submodule reference"
```

### Issue: Build fails after switching branches

**Cause**: Submodules not updated, or parent POMs not installed.

**Solution**:
```bash
# Update all submodules
git submodule update --recursive

# Reinstall parent POMs
cd webfx-parent-fork && mvn install && cd ..
cd webfx-stack-parent-fork && mvn install && cd ..

# Rebuild
mvn clean package
```

## Best Practices

1. **Keep submodules on matching branches** - Avoid mismatched branches
2. **Use scripts for batch operations** - Reduces errors
3. **Test after syncing upstream** - Thoroughly test before pushing
4. **Commit submodule updates separately** - Keep aggregate commits focused
5. **Document cross-repo changes** - Reference related commits/PRs
6. **Configure submodule.ignore** - Prevents noise in aggregate status
7. **Use feature branches consistently** - Create in both aggregate and submodules

## Key Rules

1. **All submodules must be on the same branch** when building
2. **Never commit submodule changes directly from aggregate** - Always work in submodule directory
3. **Always test after merging sync branches** - Upstream changes may break compatibility
4. **Push submodules before pushing aggregate** - Ensures references are valid

---
[← Back to Main Documentation](../../CLAUDE.md)
