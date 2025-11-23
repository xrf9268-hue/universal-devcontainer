# Testing Guide

This guide explains how to test the Universal DevContainer examples and verify that dependency updates don't break functionality.

## Overview

The project includes comprehensive test scripts for all Python examples:

- **Individual tests**: Each example has its own `test.sh` script
- **Integration tests**: Run all tests with `scripts/test-all-examples.sh`
- **Automated verification**: Tests dependencies, functionality, and security

---

## Quick Start

### Test All Examples

```bash
# Run all example tests
./scripts/test-all-examples.sh
```

### Test Individual Examples

```bash
# Test Django example
cd examples/python-django
./test.sh

# Test FastAPI example
cd examples/python-fastapi
./test.sh
```

---

## Test Scripts

### Python Django (`examples/python-django/test.sh`)

**What it tests:**
1. ✅ Virtual environment creation
2. ✅ Dependency installation from `requirements.txt`
3. ✅ Django installation verification
4. ✅ Django project creation (`django-admin startproject`)
5. ✅ System checks (`python manage.py check --deploy`)
6. ✅ Database migrations
7. ✅ manage.py commands
8. ✅ Security scan with Bandit
9. ✅ Vulnerability check with Safety

**Duration:** ~30-45 seconds

**Requirements:**
- Python 3.11+
- Internet connection (for pip)

**Example output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Testing Python Django Example
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  Creating virtual environment...
2️⃣  Installing dependencies...
   ✓ Django 5.1.14
   ✓ djangorestframework 3.15.2
...
✅ All Django example tests passed!
```

---

### Python FastAPI (`examples/python-fastapi/test.sh`)

**What it tests:**
1. ✅ Virtual environment creation
2. ✅ Dependency installation from `requirements.txt`
3. ✅ FastAPI installation verification
4. ✅ Syntax validation of `main.py`
5. ✅ Import tests
6. ✅ API endpoint tests (5 endpoints):
   - `GET /` - Root endpoint
   - `GET /api/users` - List users
   - `GET /api/users/{id}` - Get user by ID
   - `POST /api/users` - Create user
   - `GET /openapi.json` - OpenAPI schema
7. ✅ Application startup test
8. ✅ Security scan with Bandit
9. ✅ Vulnerability check with Safety

**Duration:** ~25-35 seconds

**Requirements:**
- Python 3.11+
- Internet connection (for pip)

**Example output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Testing Python FastAPI Example
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  Creating virtual environment...
2️⃣  Installing dependencies...
   ✓ FastAPI 0.109.0
   ✓ Uvicorn 0.27.0
...
7️⃣  Creating and running API endpoint tests...
   ✓ Root endpoint working
   ✓ GET /api/users working
   ✓ GET /api/users/{id} working
   ✓ POST /api/users working
   ✓ OpenAPI schema generation working
...
✅ All FastAPI example tests passed!
```

---

### Integration Test Runner (`scripts/test-all-examples.sh`)

**What it does:**
- Discovers all `test.sh` scripts in `examples/`
- Runs each test sequentially
- Tracks pass/fail status
- Provides comprehensive summary
- Calculates total duration

**Usage:**
```bash
./scripts/test-all-examples.sh

# Continue on failure (default)
CONTINUE_ON_FAILURE=true ./scripts/test-all-examples.sh

# Stop on first failure
CONTINUE_ON_FAILURE=false ./scripts/test-all-examples.sh
```

**Example output:**
```
╔══════════════════════════════════════════════════════════════════╗
║          Universal DevContainer - Example Test Suite            ║
╚══════════════════════════════════════════════════════════════════╝

🔍 Discovering test scripts...
   Found: python-django
   Found: python-fastapi

📊 Total tests to run: 2

...

╔══════════════════════════════════════════════════════════════════╗
║                        Test Results Summary                      ║
╚══════════════════════════════════════════════════════════════════╝

📊 Statistics:
   Total:   2
   Passed:  2
   Failed:  0
   Skipped: 0

⏱️  Duration: 1m 12s

✅ Passed Tests:
   ✓ python-django (38s)
   ✓ python-fastapi (34s)

╔══════════════════════════════════════════════════════════════════╗
║  🎉 ALL TESTS PASSED!                                            ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## When to Run Tests

### Before Merging PRs
Always run tests before merging dependency updates:

```bash
./scripts/test-all-examples.sh
```

### After Updating Dependencies

When updating `requirements.txt`:

1. Update the version:
   ```bash
   # Update requirements.txt
   Django==5.1.14  # was 5.0.0
   ```

2. Run tests:
   ```bash
   cd examples/python-django
   ./test.sh
   ```

3. Check for breaking changes in output

### During Development

Test individual examples during development:

```bash
# Quick test after code changes
cd examples/python-fastapi
./test.sh
```

---

## CI/CD Integration

The test scripts are designed for CI/CD integration:

```yaml
# .github/workflows/test-python-examples.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test all examples
        run: ./scripts/test-all-examples.sh
```

---

## Test Script Features

### ✅ Safety Features
- Automatic cleanup on exit (trap)
- Isolated virtual environments
- No modification of system Python
- Temporary project creation for Django

### ✅ Security Scanning
- **Bandit**: Detects common security issues in Python code
- **Safety**: Checks for known vulnerabilities in dependencies

### ✅ Error Handling
- `set -e`: Fail fast on errors
- Cleanup on both success and failure
- Clear error messages

### ✅ Verbose Output
- Step-by-step progress
- Installed package versions
- Test results for each endpoint
- Summary at the end

---

## Troubleshooting

### Test Fails: "Command not found"

**Problem:** Python or pip not available

**Solution:**
```bash
# Ensure Python 3.11+ is installed
python3 --version

# Or run in devcontainer
code examples/python-django
```

### Test Fails: "pip install failed"

**Problem:** Network issues or package not available

**Solution:**
```bash
# Check internet connection
curl -I https://pypi.org

# Try manual install
pip install -r requirements.txt
```

### Test Fails: "Import error"

**Problem:** Dependency compatibility issue

**Solution:**
1. Check requirements.txt versions
2. Review dependency changelog
3. Test with compatible versions
4. Update code if needed

---

## Adding New Tests

To add a test for a new example:

1. **Create test script:**
   ```bash
   touch examples/my-example/test.sh
   chmod +x examples/my-example/test.sh
   ```

2. **Follow the template:**
   ```bash
   #!/bin/bash
   set -e

   echo "Testing My Example"

   # Setup
   cleanup() {
       # Cleanup code
   }
   trap cleanup EXIT

   # Tests
   echo "1️⃣  Test step 1..."
   # ... test code

   echo "✅ All tests passed!"
   ```

3. **Test it:**
   ```bash
   ./examples/my-example/test.sh
   ```

4. **Run integration tests:**
   ```bash
   ./scripts/test-all-examples.sh
   # Your new test will be automatically discovered!
   ```

---

## Best Practices

### 1. Test Before Committing
```bash
# Before: git commit
./scripts/test-all-examples.sh

# If passed: git commit
git add .
git commit -m "Update dependencies"
```

### 2. Document Breaking Changes

If tests fail after updates:
```bash
# In commit message:
fix(deps): update Django 5.0 → 5.1.14

Breaking changes:
- Deprecated feature X removed
- Changed behavior in Y

Migration steps:
- Update imports
- Modify configuration
```

### 3. Keep Tests Fast

- Use minimal test data
- Avoid unnecessary delays
- Clean up after tests
- Use virtual environments

### 4. Test in Isolation

Each test should:
- Create its own virtual environment
- Not depend on other tests
- Clean up completely
- Be idempotent (can run multiple times)

---

## Summary

The testing framework provides:

- ✅ **Automated testing** for all examples
- ✅ **Security scanning** with Bandit and Safety
- ✅ **Dependency verification** before merging
- ✅ **CI/CD ready** scripts
- ✅ **Clear reporting** with summaries

For questions or issues, see [CONTRIBUTING.md](../CONTRIBUTING.md) or open an issue.
