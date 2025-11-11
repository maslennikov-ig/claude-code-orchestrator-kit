# Branch Protection Rules Configuration

**Task**: T088 - Configure branch protection rules for main branch
**Status**: Configuration instructions (requires GitHub admin access)

## Required Configuration

Branch protection rules must be configured in GitHub repository settings for the `main` branch.

### Access Path
1. Go to repository Settings
2. Navigate to Branches → Branch protection rules
3. Click "Add rule" or edit existing rule for `main`

### Required Settings

#### 1. Branch Name Pattern
- Pattern: `main`

#### 2. Protect Matching Branches
Enable the following protections:

**Require status checks to pass before merging**
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- Required status checks:
  - `test / test (20.x)` - Test workflow must pass
  - `build / build (20.x)` - Build workflow must pass

**Require pull request reviews before merging**
- ✅ Require pull request reviews before merging
- Required number of approvals: 1
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require review from Code Owners (if CODEOWNERS file exists)

**Restrict who can push to matching branches**
- ✅ Restrict pushes that create matching branches
- Allowed to push: Repository administrators only

**Additional Protections**
- ✅ Require linear history (prevent merge commits)
- ✅ Require deployments to succeed before merging (when staging is configured)
- ❌ Allow force pushes (disabled)
- ❌ Allow deletions (disabled)

#### 3. Rules Applied to Administrators
- ✅ Include administrators (recommended for consistency)

## Validation Checklist

After configuration, verify:

- [ ] Push to `main` without PR is blocked
- [ ] PR cannot be merged with failing tests
- [ ] PR cannot be merged with failing build
- [ ] PR requires at least 1 approval
- [ ] Force push to `main` is blocked
- [ ] Branch deletion is blocked

## Testing Branch Protection

### Test 1: Direct Push (Should Fail)
```bash
# Try to push directly to main (should be blocked)
git checkout main
git commit --allow-empty -m "test: direct push"
git push origin main
# Expected: Error - branch protection rules prevent direct push
```

### Test 2: PR Without Approval (Should Block)
```bash
# Create feature branch and PR
git checkout -b test/branch-protection
git commit --allow-empty -m "test: pr without approval"
git push origin test/branch-protection
# Create PR via GitHub UI
# Try to merge without approval
# Expected: Merge button disabled until approved
```

### Test 3: PR With Failing Tests (Should Block)
```bash
# Create branch with failing test
git checkout -b test/failing-tests
# Modify code to break tests
git add . && git commit -m "test: failing tests"
git push origin test/failing-tests
# Create PR
# Expected: Status checks fail, merge blocked
```

### Test 4: Valid PR Flow (Should Succeed)
```bash
# Create valid feature branch
git checkout -b feature/valid-change
# Make valid changes
git add . && git commit -m "feat: valid change"
git push origin feature/valid-change
# Create PR, wait for tests to pass, get approval
# Expected: Can merge after all checks pass and approval received
```

## Automation via GitHub CLI (Alternative)

If you prefer to configure via CLI instead of UI:

```bash
# Install GitHub CLI if not already installed
# https://cli.github.com/

# Enable branch protection
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks[strict]=true \
  --field required_status_checks[contexts][]=test \
  --field required_status_checks[contexts][]=build \
  --field required_pull_request_reviews[required_approving_review_count]=1 \
  --field required_pull_request_reviews[dismiss_stale_reviews]=true \
  --field restrictions=null \
  --field enforce_admins=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field required_linear_history=true
```

## Notes

- **Stage 0 Scope**: Branch protection configuration is documented but may be applied later when repository is actively developed
- **Production Readiness**: Enable all protections before deploying to production
- **Team Size**: Adjust approval count based on team size (1 for small teams, 2+ for larger teams)

## Status

**Implementation Status**: ✅ Documented
**Configuration Status**: ⏳ Pending (requires repository admin to apply settings)
**Validation Status**: ⏳ Pending (test after configuration applied)
