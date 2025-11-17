#!/usr/bin/env bash
#
# Release Automation Script
# Automated release management with version bumping and changelog generation
#
# Features:
# - Auto-syncs package.json versions with latest git tag (prevents version conflicts)
# - Auto-detects version bump from conventional commits
# - Generates CHANGELOG.md entries
# - Rollback support for failed releases
#
# Usage: ./release.sh [patch|minor|major] [--yes]
#        Leave empty for auto-detection from conventional commits
#        --yes: Skip confirmation prompt (for automation)

set -euo pipefail

# === CONFIGURATION ===
readonly DATE=$(date +%Y-%m-%d)
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# State tracking for rollback
CREATED_COMMIT=""
CREATED_TAG=""
declare -a MODIFIED_FILES=()

# Commit categorization arrays
declare -a ALL_COMMITS=()
declare -a FEATURES=()
declare -a FIXES=()
declare -a BREAKING_CHANGES=()
declare -a REFACTORS=()
declare -a PERF=()
declare -a OTHER_CHANGES=()

# === UTILITY FUNCTIONS ===

log_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

log_error() {
    echo -e "${RED}❌ $*${NC}" >&2
}

# === CLEANUP AND ROLLBACK ===

cleanup() {
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        echo ""
        log_error "Error occurred during release process"
        echo ""
        log_warning "Rolling back changes..."

        # Delete tag if created
        if [ -n "$CREATED_TAG" ]; then
            git tag -d "$CREATED_TAG" 2>/dev/null || true
            log_success "Deleted tag $CREATED_TAG"
        fi

        # Rollback commit using reset --soft to preserve working directory
        if [ -n "$CREATED_COMMIT" ]; then
            git reset --soft HEAD~1 2>/dev/null || true
            log_success "Rolled back commit (working directory preserved)"
        fi

        # Restore modified files only (not untracked files)
        if [ ${#MODIFIED_FILES[@]} -gt 0 ]; then
            git restore --staged "${MODIFIED_FILES[@]}" 2>/dev/null || true
            git restore "${MODIFIED_FILES[@]}" 2>/dev/null || true
            log_success "Restored modified package.json files"
        fi


        echo ""
        log_info "Rollback complete. Repository state restored."
        echo ""
        exit $exit_code
    fi
}

trap cleanup EXIT

# === PRE-FLIGHT CHECKS ===

run_preflight_checks() {
    log_info "Running pre-flight checks..."
    echo ""

    # Check if we're in the project root
    if [ ! -f "$PROJECT_ROOT/package.json" ]; then
        log_error "Not in project root. Could not find package.json"
        exit 1
    fi

    # Check if on a branch (not detached HEAD)
    BRANCH=$(git branch --show-current)
    if [ -z "$BRANCH" ]; then
        log_error "You are in detached HEAD state"
        echo "Checkout a branch first:"
        echo "  git checkout main"
        exit 1
    fi
    log_success "On branch: $BRANCH"

    # Auto-commit uncommitted changes before release
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log_info "Uncommitted changes detected. Auto-committing before release..."

        # Get file counts by status
        MODIFIED_COUNT=$(git diff --name-only | wc -l)
        STAGED_COUNT=$(git diff --cached --name-only | wc -l)
        UNTRACKED_COUNT=$(git ls-files --others --exclude-standard | wc -l)
        TOTAL_COUNT=$((MODIFIED_COUNT + STAGED_COUNT + UNTRACKED_COUNT))

        # Stage ALL changes (modified, deleted, new files)
        git add -A

        # Get detailed file list for commit body
        FILE_LIST=$(git diff --cached --name-status | sed 's/^/  /')

        # Generate commit message
        COMMIT_MSG="chore: auto-commit before release

Auto-committed ${TOTAL_COUNT} file(s) before creating release.

Files changed:
${FILE_LIST}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

        # Create commit
        git commit -m "$COMMIT_MSG" >/dev/null 2>&1 || {
            log_error "Failed to auto-commit changes"
            exit 1
        }

        log_success "Changes committed (${TOTAL_COUNT} files)"
    fi

    # Check if remote is configured
    if ! git remote -v | grep -q origin; then
        log_error "No remote 'origin' configured"
        exit 1
    fi
    log_success "Remote configured"

    # Check for Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed"
        exit 1
    fi
    log_success "Node.js available"

    # Get current version
    CURRENT_VERSION=$(node -p "require('$PROJECT_ROOT/package.json').version")
    if [ -z "$CURRENT_VERSION" ]; then
        log_error "Could not read current version from package.json"
        exit 1
    fi
    log_success "Current version: $CURRENT_VERSION"

    # Get last git tag (across all branches using --all)
    LAST_TAG=$(git tag --sort=-version:refname | head -n 1 || echo "")
    if [ -z "$LAST_TAG" ]; then
        log_warning "No previous git tags found (first release)"
        LAST_TAG="HEAD~999999" # Get all commits
        COMMITS_RANGE="HEAD"
    else
        log_success "Last tag: $LAST_TAG"
        COMMITS_RANGE="${LAST_TAG}..HEAD"

        # Sync package.json version with git tag if needed
        TAG_VERSION="${LAST_TAG#v}" # Remove 'v' prefix
        if [ "$CURRENT_VERSION" != "$TAG_VERSION" ]; then
            log_warning "Version mismatch: package.json ($CURRENT_VERSION) != tag ($TAG_VERSION)"
            log_info "Syncing package.json versions to $TAG_VERSION..."

            # Find and update all package.json files
            find "$PROJECT_ROOT" -name "package.json" -not -path "*/node_modules/*" -print0 | while IFS= read -r -d '' pkg_file; do
                if grep -q "\"version\"" "$pkg_file"; then
                    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$TAG_VERSION\"/" "$pkg_file"
                    MODIFIED_FILES+=("$pkg_file")
                fi
            done

            CURRENT_VERSION="$TAG_VERSION"
            log_success "Synced all package.json files to version $TAG_VERSION"
        fi
    fi

    # Check for commits since last tag
    COMMITS_COUNT=$(git rev-list $COMMITS_RANGE --count 2>/dev/null || echo "0")
    if [ "$COMMITS_COUNT" -eq 0 ]; then
        log_error "No commits since last release ($LAST_TAG)"
        echo "Nothing to release!"
        exit 1
    fi
    log_success "Found $COMMITS_COUNT commits since last release"

    echo ""
}

# === COMMIT PARSING ===

parse_commits() {
    log_info "Analyzing commits since ${LAST_TAG:-start}..."
    echo ""

    # Get all commits with hash
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            ALL_COMMITS+=("$line")
        fi
    done < <(git log --format="%h %s" $COMMITS_RANGE)

    # Parse and categorize each commit
    # Define regex patterns as variables for proper bash regex matching
    local breaking_pattern='^[a-z]+(\([^)]+\))?!:'
    local feat_pattern='^feat(\([^)]+\))?:'
    local fix_pattern='^fix(\([^)]+\))?:'
    local refactor_pattern='^refactor(\([^)]+\))?:'
    local perf_pattern='^perf(\([^)]+\))?:'

    for commit in "${ALL_COMMITS[@]}"; do
        local hash=$(echo "$commit" | awk '{print $1}')
        local message=$(echo "$commit" | cut -d' ' -f2-)

        # Check for breaking changes
        if [[ "$message" =~ $breaking_pattern ]] || echo "$message" | grep -q "BREAKING CHANGE:"; then
            BREAKING_CHANGES+=("$commit")
        # Check for features
        elif [[ "$message" =~ $feat_pattern ]]; then
            FEATURES+=("$commit")
        # Check for fixes
        elif [[ "$message" =~ $fix_pattern ]]; then
            FIXES+=("$commit")
        # Check for refactors
        elif [[ "$message" =~ $refactor_pattern ]]; then
            REFACTORS+=("$commit")
        # Check for performance improvements
        elif [[ "$message" =~ $perf_pattern ]]; then
            PERF+=("$commit")
        # Everything else
        else
            OTHER_CHANGES+=("$commit")
        fi
    done

    # Display commit summary
    log_info "Commit summary:"
    [ ${#BREAKING_CHANGES[@]} -gt 0 ] && echo "  🔥 ${#BREAKING_CHANGES[@]} breaking changes"
    [ ${#FEATURES[@]} -gt 0 ] && echo "  ✨ ${#FEATURES[@]} features"
    [ ${#FIXES[@]} -gt 0 ] && echo "  🐛 ${#FIXES[@]} bug fixes"
    [ ${#REFACTORS[@]} -gt 0 ] && echo "  ♻️  ${#REFACTORS[@]} refactors"
    [ ${#PERF[@]} -gt 0 ] && echo "  ⚡ ${#PERF[@]} performance improvements"
    [ ${#OTHER_CHANGES[@]} -gt 0 ] && echo "  📝 ${#OTHER_CHANGES[@]} other changes"
    echo ""
}

# === VERSION BUMP DETECTION ===

detect_version_bump() {
    local provided_bump="$1"

    # If bump type provided, validate and use it
    if [ -n "$provided_bump" ]; then
        if [[ ! "$provided_bump" =~ ^(patch|minor|major)$ ]]; then
            log_error "Invalid version bump type: $provided_bump"
            echo "Usage: ./release.sh [patch|minor|major]"
            exit 1
        fi
        BUMP_TYPE="$provided_bump"
        AUTO_DETECT_REASON="Manually specified"
        log_info "Using manual version bump: $BUMP_TYPE"
    else
        # Auto-detect from commits
        if [ ${#BREAKING_CHANGES[@]} -gt 0 ]; then
            BUMP_TYPE="major"
            AUTO_DETECT_REASON="Found ${#BREAKING_CHANGES[@]} breaking change(s)"
        elif [ ${#FEATURES[@]} -gt 0 ]; then
            BUMP_TYPE="minor"
            AUTO_DETECT_REASON="Found ${#FEATURES[@]} new feature(s)"
        elif [ ${#FIXES[@]} -gt 0 ]; then
            BUMP_TYPE="patch"
            AUTO_DETECT_REASON="Found ${#FIXES[@]} bug fix(es)"
        else
            BUMP_TYPE="patch"
            AUTO_DETECT_REASON="Default (no conventional commits detected)"
        fi
        log_success "Auto-detected version bump: $BUMP_TYPE ($AUTO_DETECT_REASON)"
    fi
    echo ""
}

# === VERSION CALCULATION ===

calculate_new_version() {
    local current="$CURRENT_VERSION"
    local IFS='.'
    read -ra parts <<< "$current"

    local major="${parts[0]}"
    local minor="${parts[1]}"
    local patch="${parts[2]}"

    case "$BUMP_TYPE" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
    esac

    NEW_VERSION="$major.$minor.$patch"
}

# === CHANGELOG GENERATION ===

generate_changelog_entry() {
    local version="$1"
    local date="$2"

    cat << EOF
## [$version] - $date

EOF

    # Added section (features)
    if [ ${#FEATURES[@]} -gt 0 ]; then
        echo "### Added"
        for commit in "${FEATURES[@]}"; do
            format_changelog_line "$commit"
        done
        echo ""
    fi

    # Changed section (breaking, refactor, perf)
    if [ ${#BREAKING_CHANGES[@]} -gt 0 ] || [ ${#REFACTORS[@]} -gt 0 ] || [ ${#PERF[@]} -gt 0 ]; then
        echo "### Changed"
        for commit in "${BREAKING_CHANGES[@]}"; do
            format_changelog_line "$commit" "⚠️ BREAKING: "
        done
        for commit in "${REFACTORS[@]}"; do
            format_changelog_line "$commit"
        done
        for commit in "${PERF[@]}"; do
            format_changelog_line "$commit"
        done
        echo ""
    fi

    # Fixed section
    if [ ${#FIXES[@]} -gt 0 ]; then
        echo "### Fixed"
        for commit in "${FIXES[@]}"; do
            format_changelog_line "$commit"
        done
        echo ""
    fi
}

format_changelog_line() {
    local commit="$1"
    local prefix="${2:-}"

    local hash=$(echo "$commit" | awk '{print $1}')
    local message=$(echo "$commit" | cut -d' ' -f2-)

    # Extract scope if present: "type(scope): message" -> "**scope**: message"
    local scope_pattern='^[a-z]+(\(([^)]+)\))?!?:[ ]+(.+)$'
    if [[ "$message" =~ $scope_pattern ]]; then
        local scope="${BASH_REMATCH[2]}"
        local msg="${BASH_REMATCH[3]}"

        if [ -n "$scope" ]; then
            echo "- ${prefix}**${scope}**: ${msg} (${hash})"
        else
            echo "- ${prefix}${msg} (${hash})"
        fi
    else
        # Not a conventional commit, use as-is
        echo "- ${prefix}${message} (${hash})"
    fi
}

# === PACKAGE.JSON UPDATES ===

update_package_files() {
    local version="$1"

    log_info "Updating package.json files..."
    echo ""

    # Find all package.json files
    local package_files=$(find "$PROJECT_ROOT" -name "package.json" \
        -not -path "*/node_modules/*" \
        -not -path "*/.next/*" \
        -not -path "*/dist/*" \
        -not -path "*/.turbo/*" \
        -not -path "*/build/*")

    while IFS= read -r pkg; do
        if [ -n "$pkg" ]; then
            # Track for rollback
            MODIFIED_FILES+=("$pkg")

            # Update version using Node.js for proper JSON handling
            node -e "
                const fs = require('fs');
                const path = '$pkg';
                const data = JSON.parse(fs.readFileSync(path, 'utf-8'));
                data.version = '$version';
                fs.writeFileSync(path, JSON.stringify(data, null, 2) + '\n');
            " || {
                log_error "Failed to update $pkg"
                exit 1
            }

            # Show relative path
            local rel_path="${pkg#$PROJECT_ROOT/}"
            echo "  ✓ $rel_path"
        fi
    done <<< "$package_files"

    echo ""
}

# === CHANGELOG UPDATE ===

update_changelog() {
    local version="$1"
    local date="$2"

    log_info "Updating CHANGELOG.md..."

    local changelog_file="$PROJECT_ROOT/CHANGELOG.md"

    # Track for rollback
    MODIFIED_FILES+=("$changelog_file")

    # Generate new entry
    local new_entry=$(generate_changelog_entry "$version" "$date")

    # Read existing changelog
    if [ -f "$changelog_file" ]; then
        local existing_content=$(<"$changelog_file")

        # Insert new entry after [Unreleased] section
        if echo "$existing_content" | grep -q "## \[Unreleased\]"; then
            # Find the line number of [Unreleased]
            local unreleased_line=$(echo "$existing_content" | grep -n "## \[Unreleased\]" | head -1 | cut -d: -f1)

            # Insert after [Unreleased] and its blank line
            {
                echo "$existing_content" | head -n $((unreleased_line))
                echo ""
                echo "$new_entry"
                echo "$existing_content" | tail -n +$((unreleased_line + 1))
            } > "$changelog_file"
        else
            # No [Unreleased] section, insert at the beginning after header
            {
                echo "$existing_content" | head -n 6
                echo ""
                echo "$new_entry"
                echo "$existing_content" | tail -n +7
            } > "$changelog_file"
        fi
    else
        # Create new CHANGELOG.md
        cat > "$changelog_file" << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

$new_entry
EOF
    fi

    log_success "CHANGELOG.md updated"
    echo ""
}

# === PREVIEW ===

show_preview() {
    cat << EOF
═══════════════════════════════════════════════════════════
                    RELEASE PREVIEW
═══════════════════════════════════════════════════════════

📌 Version: $CURRENT_VERSION → $NEW_VERSION (${BUMP_TYPE^^})
   Reason: $AUTO_DETECT_REASON

📊 Commits included: ${#ALL_COMMITS[@]}
EOF

    [ ${#BREAKING_CHANGES[@]} -gt 0 ] && echo "   🔥 ${#BREAKING_CHANGES[@]} breaking changes"
    [ ${#FEATURES[@]} -gt 0 ] && echo "   ✨ ${#FEATURES[@]} features"
    [ ${#FIXES[@]} -gt 0 ] && echo "   🐛 ${#FIXES[@]} bug fixes"
    [ ${#REFACTORS[@]} -gt 0 ] && echo "   ♻️  ${#REFACTORS[@]} refactors"
    [ ${#PERF[@]} -gt 0 ] && echo "   ⚡ ${#PERF[@]} performance improvements"
    [ ${#OTHER_CHANGES[@]} -gt 0 ] && echo "   📝 ${#OTHER_CHANGES[@]} other changes"

    cat << EOF

📦 Package Updates:
EOF

    find "$PROJECT_ROOT" -name "package.json" \
        -not -path "*/node_modules/*" \
        -not -path "*/.next/*" \
        -not -path "*/dist/*" \
        -not -path "*/.turbo/*" \
        -not -path "*/build/*" | while read -r pkg; do
        local rel_path="${pkg#$PROJECT_ROOT/}"
        echo "  ✓ $rel_path"
    done

    cat << EOF

📄 CHANGELOG.md Entry:
───────────────────────────────────────────────────────────
$(generate_changelog_entry "$NEW_VERSION" "$DATE")───────────────────────────────────────────────────────────

💬 Git Commit Message:
───────────────────────────────────────────────────────────
chore(release): v$NEW_VERSION

Release version $NEW_VERSION with ${#FEATURES[@]} features and ${#FIXES[@]} fixes

Includes commits from ${LAST_TAG:-start} to HEAD

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
───────────────────────────────────────────────────────────

🏷️  Git Tag: v$NEW_VERSION
🌿 Branch: $BRANCH

═══════════════════════════════════════════════════════════
EOF
}

# === USER CONFIRMATION ===

get_user_confirmation() {
    local auto_confirm="$1"

    echo ""

    # Skip confirmation if --yes flag provided
    if [ "$auto_confirm" = "true" ]; then
        log_info "Auto-confirming release (--yes flag provided)"
        echo ""
        return 0
    fi

    read -p "Proceed with release? [Y/n]: " confirm

    if [[ ! "$confirm" =~ ^[Yy]?$ ]]; then
        log_warning "Release cancelled by user"
        exit 0
    fi

    echo ""
}

# === EXECUTE RELEASE ===

execute_release() {
    log_info "Executing release..."
    echo ""

    # Stage all changes
    log_info "Staging changes..."
    git add -A

    # Create commit
    log_info "Creating release commit..."
    git commit -m "chore(release): v$NEW_VERSION

Release version $NEW_VERSION with ${#FEATURES[@]} features and ${#FIXES[@]} fixes

Includes commits from ${LAST_TAG:-start} to HEAD

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>" || {
        log_error "Failed to create commit"
        exit 1
    }
    CREATED_COMMIT="true"
    log_success "Commit created"

    # Create tag (check if exists first)
    log_info "Creating git tag..."

    # Check if tag already exists
    if git rev-parse "v$NEW_VERSION" >/dev/null 2>&1; then
        log_error "Tag v$NEW_VERSION already exists!"
        echo ""
        log_info "Existing tags:"
        git tag --sort=-version:refname | head -n 10
        echo ""
        log_info "Suggested actions:"
        echo "  1. Delete existing tag: git tag -d v$NEW_VERSION && git push origin :refs/tags/v$NEW_VERSION"
        echo "  2. Use different version: ./release.sh [patch|minor|major]"
        exit 1
    fi

    local tag_message="Release v$NEW_VERSION

$(generate_changelog_entry "$NEW_VERSION" "$DATE")"

    git tag -a "v$NEW_VERSION" -m "$tag_message" || {
        log_error "Failed to create tag"
        exit 1
    }
    CREATED_TAG="v$NEW_VERSION"
    log_success "Tag v$NEW_VERSION created"

    # Push to remote
    log_info "Pushing to remote..."
    git push origin "$BRANCH" --follow-tags || {
        log_error "Failed to push to remote"
        echo ""
        log_warning "Your changes are committed locally but push failed."
        echo ""
        echo "To retry push:"
        echo "  git push origin $BRANCH --follow-tags"
        echo ""
        echo "To rollback:"
        echo "  git reset --hard HEAD~1"
        echo "  git tag -d v$NEW_VERSION"
        echo ""
        exit 1
    }
    log_success "Pushed to origin/$BRANCH"

    echo ""
}

# === MAIN ===

main() {
    cd "$PROJECT_ROOT"

    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                    Release Automation                     ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""

    # Parse arguments
    local bump_arg=""
    local auto_confirm="false"

    for arg in "$@"; do
        case "$arg" in
            --yes|-y)
                auto_confirm="true"
                ;;
            patch|minor|major)
                bump_arg="$arg"
                ;;
            *)
                log_error "Unknown argument: $arg"
                echo "Usage: $0 [patch|minor|major] [--yes]"
                exit 1
                ;;
        esac
    done

    # Run workflow
    run_preflight_checks
    parse_commits
    detect_version_bump "$bump_arg"
    calculate_new_version

    # Show preview
    show_preview
    get_user_confirmation "$auto_confirm"

    # Execute release
    update_package_files "$NEW_VERSION"
    update_changelog "$NEW_VERSION" "$DATE"
    execute_release

    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              RELEASE SUCCESSFUL! 🎉                       ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    log_success "Released v$NEW_VERSION"
    log_success "Tag: v$NEW_VERSION"
    log_success "Branch: $BRANCH"
    echo ""
    log_info "Next steps:"
    echo "  • Verify release on GitHub: git remote -v"
    echo "  • Create GitHub Release from tag (optional)"
    echo "  • Notify team if applicable"
    echo ""
}

# Run main function
main "$@"
