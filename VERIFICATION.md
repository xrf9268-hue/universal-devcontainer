# Verification Checklist: Plugin Removal Changes

This document provides a comprehensive checklist to verify that the pre-installed plugin removal changes were implemented correctly.

## Phase 2: Configuration Files ✅

### src/claude-code/devcontainer-feature.json
- [ ] Line 25: Default value is `""` (empty string)
- [ ] Line 26: Description mentions recommending `claude-code-plugins` feature
- [ ] JSON is valid (no syntax errors)

**Verify**:
```bash
jq '.options.installPlugins.default' src/claude-code/devcontainer-feature.json
# Expected output: ""

jq '.options.installPlugins.description' src/claude-code/devcontainer-feature.json
# Should contain: "Recommended: Use 'claude-code-plugins' feature"
```

### src/claude-code/install.sh
- [ ] Line 7: `PLUGINS="${INSTALLPLUGINS:-}"` (empty fallback)
- [ ] Line 161: Output message mentions "none (use claude-code-plugins feature...)"
- [ ] Script has no syntax errors

**Verify**:
```bash
bash -n src/claude-code/install.sh
# No output = no syntax errors

grep 'PLUGINS="${INSTALLPLUGINS:-}"' src/claude-code/install.sh
# Should find the line

grep 'none (use claude-code-plugins' src/claude-code/install.sh
# Should find the output message
```

## Phase 3: Example Configurations ✅

### examples/nextjs-app/.devcontainer/devcontainer.json
- [ ] Removed `installPlugins` from `claude-code` feature
- [ ] Added `claude-code-plugins` feature with `"installPlugins": "essential"`
- [ ] JSON is valid

**Verify**:
```bash
jq '.features."ghcr.io/xrf9268-hue/features/claude-code-plugins:1".installPlugins' examples/nextjs-app/.devcontainer/devcontainer.json
# Expected output: "essential"

jq '.features."ghcr.io/xrf9268-hue/features/claude-code:1".installPlugins' examples/nextjs-app/.devcontainer/devcontainer.json
# Expected output: null (field doesn't exist)
```

### examples/react-app/.devcontainer/devcontainer.json
- [ ] Removed `installPlugins` from `claude-code` feature
- [ ] Added `claude-code-plugins` feature with `"installPlugins": "essential"`
- [ ] JSON is valid

**Verify**:
```bash
jq '.features."ghcr.io/xrf9268-hue/features/claude-code-plugins:1".installPlugins' examples/react-app/.devcontainer/devcontainer.json
# Expected output: "essential"

jq '.features."ghcr.io/xrf9268-hue/features/claude-code:1".installPlugins' examples/react-app/.devcontainer/devcontainer.json
# Expected output: null (field doesn't exist)
```

### examples/with-advanced-plugins/.devcontainer/devcontainer.json
- [ ] Already has `installPlugins: ""` (no changes needed)
- [ ] Already has `claude-code-plugins` feature (no changes needed)
- [ ] Configuration remains valid

## Phase 4: Documentation Files ✅

### src/claude-code/README.md
- [ ] Line 47: Default shows `""` in options table
- [ ] Line 49: Mentions recommending community plugins
- [ ] Lines 83-121: Updated installPlugins section with deprecation notice
- [ ] Line 235-252: Updated example to use community plugins
- [ ] All markdown is properly formatted

**Verify**:
```bash
grep 'DEPRECATION NOTICE' src/claude-code/README.md
# Should find the notice

grep 'claude-code-plugins' src/claude-code/README.md | wc -l
# Should be several references
```

### src/features/claude-code-plugins/README.md
- [ ] Lines 195-210: Updated Example 5 title and content
- [ ] Lines 212-230: Added "Why Use Community Plugins" section
- [ ] Comparison table shows official vs community versions
- [ ] All markdown is properly formatted

**Verify**:
```bash
grep 'Why Use Community Plugins' src/features/claude-code-plugins/README.md
# Should find the section

grep 'enhanced versions' src/features/claude-code-plugins/README.md
# Should find the comparison
```

### examples/nextjs-app/README.md
- [ ] Line 41: Updated to mention "Community plugins (essential)"
- [ ] Lists correct plugins: commit-commands, code-review, security-guidance, context-preservation

**Verify**:
```bash
grep 'Community plugins' examples/nextjs-app/README.md
# Should find the mention
```

### examples/react-app/README.md
- [ ] Lines 38-63: Updated Claude Code Integration section
- [ ] Mentions community plugins (essential)
- [ ] Updated "Want More Plugins?" section
- [ ] All markdown is properly formatted

**Verify**:
```bash
grep 'Community plugins' examples/react-app/README.md
# Should find the mention
```

### examples/with-advanced-plugins/README.md
- [ ] Lines 1-3: Added "Recommended Standard" notice
- [ ] Mentions this is now best practice
- [ ] All markdown is properly formatted

**Verify**:
```bash
grep 'Recommended Standard' examples/with-advanced-plugins/README.md
# Should find the notice
```

### README.md (Chinese)
- [ ] Lines 342-350: Updated section title and added important notice
- [ ] Changed "预装插件" to "Claude Code 插件"
- [ ] Added warning about v2.2.0+ changes
- [ ] Changed "高级插件（可选）" to "推荐：社区插件"

**Verify**:
```bash
grep '重要变更' README.md
# Should find the change notice

grep '社区插件' README.md
# Should find references to community plugins
```

### README.en.md (English)
- [ ] Lines 349-357: Updated section title and added important notice
- [ ] Changed "Pre-installed Plugins" to "Claude Code Plugins"
- [ ] Added warning about v2.2.0+ changes
- [ ] Changed "Advanced Plugins (Optional)" to "Recommended: Community Plugins"

**Verify**:
```bash
grep 'Important Change' README.en.md
# Should find the change notice

grep 'Community plugins are recommended' README.en.md
# Should find the recommendation
```

## Phase 5: Migration Guide and Changelog ✅

### MIGRATION.md
- [ ] File exists at root of repository
- [ ] Contains comprehensive migration guide
- [ ] Includes comparison tables
- [ ] Has FAQ section
- [ ] Explains all three migration options
- [ ] Well-formatted and complete

**Verify**:
```bash
test -f MIGRATION.md && echo "MIGRATION.md exists" || echo "MIGRATION.md missing"

grep 'Version 2.2.0 Breaking Change' MIGRATION.md
# Should find the title

grep 'Option 1: Switch to Community Plugins' MIGRATION.md
# Should find migration option
```

### CHANGELOG.md
- [ ] Lines 10-19: Added "Breaking Changes" section
- [ ] Lines 61-101: Added "Changed" section with details
- [ ] Lines 83-101: Added "Rationale" section
- [ ] Breaking change is clearly documented
- [ ] Migration guide is referenced
- [ ] All changes are listed

**Verify**:
```bash
grep 'Breaking Changes' CHANGELOG.md
# Should find the section

grep 'MIGRATION.md' CHANGELOG.md
# Should reference the migration guide

grep 'Default Plugin Installation Removed' CHANGELOG.md
# Should find the breaking change title
```

## Phase 6: Verification Tests ✅

### Configuration Validation

**Test 1: JSON Validity**
```bash
# Verify all JSON files are valid
for file in $(find . -name "devcontainer*.json" -o -name "*-feature.json"); do
  echo "Checking $file"
  jq empty "$file" 2>&1 || echo "ERROR in $file"
done
# Expected: No errors
```

**Test 2: Feature Schema**
```bash
# Verify claude-code feature has empty default
jq -r '.options.installPlugins.default' src/claude-code/devcontainer-feature.json
# Expected output: "" (empty string, not null)
```

**Test 3: Example Configurations**
```bash
# Verify examples use community plugins
grep -r 'claude-code-plugins' examples/*/
# Expected: Should find references in nextjs-app, react-app, with-advanced-plugins
```

### Documentation Validation

**Test 4: Deprecation Notices**
```bash
# Verify deprecation notices are present
grep -i 'deprecation' src/claude-code/README.md
grep -i 'important change' README.md README.en.md
# Expected: Should find notices in all files
```

**Test 5: Link Validation**
```bash
# Verify internal links work
test -f MIGRATION.md && echo "✓ MIGRATION.md exists"
test -f CHANGELOG.md && echo "✓ CHANGELOG.md exists"
test -f src/features/claude-code-plugins/README.md && echo "✓ Plugin README exists"
```

### Markdown Validation

**Test 6: Markdown Syntax**
```bash
# Check for common markdown issues
# (This is a basic check - consider using markdownlint for thorough validation)

# Check for broken links (basic)
grep -r '\[.*\](.*\.md)' *.md | while read line; do
  file=$(echo "$line" | sed 's/\[.*\](\(.*\.md\)).*/\1/')
  test -f "$file" || echo "Broken link: $line"
done
```

### Shell Script Validation

**Test 7: Shell Script Syntax**
```bash
# Verify install script has no syntax errors
bash -n src/claude-code/install.sh
# Expected: No output (means no errors)

bash -n src/features/claude-code-plugins/install.sh
# Expected: No output
```

## Manual Testing Checklist

### Build Test
- [ ] Clone repository fresh
- [ ] Build example: `examples/with-advanced-plugins/`
- [ ] Verify container builds successfully
- [ ] Verify no plugins installed by default in `~/.claude/settings.json`
- [ ] Verify community marketplace is configured

### Plugin Installation Test
- [ ] Build example with essential plugins
- [ ] Run `claude /plugins list` in container
- [ ] Verify essential plugins are installed:
  - commit-commands@community-plugins
  - code-review@community-plugins
  - security-guidance@community-plugins
  - context-preservation@community-plugins

### Backward Compatibility Test
- [ ] Create config with explicit `installPlugins: "commit-commands,pr-review-toolkit,security-guidance"`
- [ ] Build container
- [ ] Verify official plugins are installed:
  - commit-commands@claude-code-plugins
  - pr-review-toolkit@claude-code-plugins
  - security-guidance@claude-code-plugins

### No Plugins Test
- [ ] Create config with `installPlugins: ""`
- [ ] Build container
- [ ] Verify no plugins installed
- [ ] Verify `claude /plugins list` shows empty or no enabled plugins

## Regression Testing

### File Changes Summary
```bash
# Verify expected files were modified
git status
# Should show:
# - Modified: src/claude-code/devcontainer-feature.json
# - Modified: src/claude-code/install.sh
# - Modified: src/claude-code/README.md
# - Modified: src/features/claude-code-plugins/README.md
# - Modified: examples/nextjs-app/.devcontainer/devcontainer.json
# - Modified: examples/react-app/.devcontainer/devcontainer.json
# - Modified: examples/nextjs-app/README.md
# - Modified: examples/react-app/README.md
# - Modified: examples/with-advanced-plugins/README.md
# - Modified: README.md
# - Modified: README.en.md
# - Modified: CHANGELOG.md
# - New: MIGRATION.md
# - New: VERIFICATION.md (this file)
```

### Line Count Check
```bash
# Verify no unexpected deletions
git diff --stat
# Review the stats to ensure changes are reasonable
```

## Success Criteria

All items below must be true for verification to pass:

### Configuration
- [x] Default `installPlugins` is empty string in feature schema
- [x] Install script uses empty fallback
- [x] All example configs updated to use community plugins
- [x] All JSON files are valid

### Documentation
- [x] Deprecation notices added to all relevant docs
- [x] Migration guide created and comprehensive
- [x] Changelog documents breaking change
- [x] All README files updated
- [x] Examples show best practice

### Testing
- [x] No syntax errors in shell scripts
- [x] No syntax errors in JSON files
- [x] All internal links work
- [x] Markdown is properly formatted

### Completeness
- [x] All 6 phases completed
- [x] All files from plan were modified
- [x] MIGRATION.md created
- [x] VERIFICATION.md created (this file)

## Final Verification Command

Run this command to perform automated checks:

```bash
#!/bin/bash
echo "=== Plugin Removal Verification ==="
echo ""

# Test 1: JSON validity
echo "Test 1: Validating JSON files..."
jq empty src/claude-code/devcontainer-feature.json && echo "✓ claude-code feature JSON valid" || echo "✗ Invalid JSON"
jq empty examples/nextjs-app/.devcontainer/devcontainer.json && echo "✓ nextjs-app JSON valid" || echo "✗ Invalid JSON"
jq empty examples/react-app/.devcontainer/devcontainer.json && echo "✓ react-app JSON valid" || echo "✗ Invalid JSON"

# Test 2: Default value
echo ""
echo "Test 2: Checking default plugin value..."
DEFAULT=$(jq -r '.options.installPlugins.default' src/claude-code/devcontainer-feature.json)
if [ "$DEFAULT" = "" ]; then
  echo "✓ Default is empty string"
else
  echo "✗ Default is not empty: '$DEFAULT'"
fi

# Test 3: Community plugins in examples
echo ""
echo "Test 3: Checking examples use community plugins..."
grep -q 'claude-code-plugins' examples/nextjs-app/.devcontainer/devcontainer.json && echo "✓ nextjs-app uses community plugins" || echo "✗ Missing"
grep -q 'claude-code-plugins' examples/react-app/.devcontainer/devcontainer.json && echo "✓ react-app uses community plugins" || echo "✗ Missing"

# Test 4: Migration guide exists
echo ""
echo "Test 4: Checking migration guide..."
test -f MIGRATION.md && echo "✓ MIGRATION.md exists" || echo "✗ MIGRATION.md missing"

# Test 5: Deprecation notices
echo ""
echo "Test 5: Checking deprecation notices..."
grep -q 'DEPRECATION NOTICE' src/claude-code/README.md && echo "✓ Deprecation notice in claude-code README" || echo "✗ Missing"
grep -q 'Important Change' README.en.md && echo "✓ Important change notice in English README" || echo "✗ Missing"
grep -q '重要变更' README.md && echo "✓ Important change notice in Chinese README" || echo "✗ Missing"

# Test 6: Shell script syntax
echo ""
echo "Test 6: Checking shell script syntax..."
bash -n src/claude-code/install.sh && echo "✓ install.sh has no syntax errors" || echo "✗ Syntax error found"

# Test 7: Changelog updated
echo ""
echo "Test 7: Checking changelog..."
grep -q 'Breaking Changes' CHANGELOG.md && echo "✓ Breaking changes documented in CHANGELOG" || echo "✗ Missing"

echo ""
echo "=== Verification Complete ==="
```

Save this as `verify.sh`, make it executable, and run it:
```bash
chmod +x verify.sh
./verify.sh
```

All tests should pass (show ✓) for successful verification.
