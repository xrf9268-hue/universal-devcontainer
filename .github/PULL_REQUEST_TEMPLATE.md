# Pull Request

## Description

<!-- Provide a clear and concise description of your changes -->

## Type of Change

<!-- Mark the relevant option with an "x" -->

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] **Dependency update**
- [ ] **Security fix**
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Performance improvement
- [ ] Test updates
- [ ] Chore (maintenance, dependencies, etc.)

## Related Issues

<!-- Link to related issues using #issue_number -->

Closes #
Relates to #

## Changes Made

<!-- List the specific changes made in this PR -->

-
-
-

## Dependency Update Checklist

<!-- Required if updating dependencies. Mark with "x" or "N/A" -->

- [ ] Reviewed package changelog for breaking changes
- [ ] Updated hash for hash-pinned dependencies (if applicable)
- [ ] Ran integration tests (`./scripts/test-all-examples.sh`)
- [ ] Tested specific examples (`cd examples/*/` && `./test.sh`)
- [ ] Checked for CVEs and documented in commit message
- [ ] Verified compatibility with other dependencies
- [ ] Updated install script checksums (if applicable)

**CVEs Fixed:**
<!--
List any CVEs fixed by this update:
- CVE-YYYY-XXXXX (SEVERITY): Description
-->

**Test Results:**
<!--
Example:
✅ python-django: All tests passed
✅ python-fastapi: All tests passed
✅ Integration tests: PASSED
-->

## Testing Checklist

<!-- Mark completed items with an "x" -->

### Code Quality
- [ ] All JSON files are valid (`jq empty` passes)
- [ ] All shell scripts have no syntax errors (`bash -n` passes)
- [ ] ShellCheck passes (or warnings documented)
- [ ] Code follows project coding standards

### Functionality
- [ ] Changes work as expected in a clean Dev Container
- [ ] **Integration tests pass** (`./scripts/test-all-examples.sh`)
- [ ] **Example tests pass** (individual `test.sh` scripts)
- [ ] All examples still work correctly
- [ ] New features have been tested
- [ ] Edge cases have been considered

### Documentation
- [ ] README updated (if applicable)
- [ ] Code comments added for complex logic
- [ ] New features documented
- [ ] [TESTING.md](docs/TESTING.md) updated (if changing tests)
- [ ] [CONTRIBUTING.md](CONTRIBUTING.md) updated (if changing workflow)
- [ ] CHANGELOG updated (if significant change)

### Security
- [ ] No secrets or credentials committed
- [ ] Dependencies pinned with versions/hashes
- [ ] Install scripts use checksum verification
- [ ] Curl commands use `-fsSL` flags
- [ ] **Security scans passed** (Bandit, Safety)
- [ ] .gitignore is up to date
- [ ] No security vulnerabilities introduced
- [ ] Compliance features still work (if applicable)

## Screenshots / Examples

<!-- If applicable, add screenshots or example output -->

```bash
# Example command output
```

## Additional Context

<!-- Add any other context about the PR here -->

## Checklist for Reviewers

<!-- For maintainers reviewing this PR -->

- [ ] Code quality is acceptable
- [ ] Changes are well-tested
- [ ] Documentation is clear and complete
- [ ] No breaking changes (or properly documented)
- [ ] Security considerations addressed
- [ ] Performance impact is acceptable

## Breaking Changes

<!-- If this PR introduces breaking changes, describe them here and provide migration steps -->

**Migration Guide:**
1.
2.
3.

---

**By submitting this pull request, I confirm that my contribution is made under the terms of the project's license.**
