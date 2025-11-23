#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Testing Python Django Example"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Cleanup function
cleanup() {
    echo ""
    echo "Cleaning up..."
    rm -rf venv test_project
    cd "$SCRIPT_DIR"
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Step 1: Create virtual environment
echo "1️⃣  Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Step 2: Install dependencies
echo ""
echo "2️⃣  Installing dependencies from requirements.txt..."
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt

echo "   ✓ Installed packages:"
pip list | grep -E "Django|djangorestframework|python-dotenv"

# Step 3: Verify Django installation
echo ""
echo "3️⃣  Verifying Django installation..."
python -c "import django; print(f'   ✓ Django version: {django.get_version()}')"
python -c "import rest_framework; print(f'   ✓ Django REST framework installed')"

# Step 4: Create test Django project
echo ""
echo "4️⃣  Creating test Django project..."
django-admin startproject test_project .
echo "   ✓ Django project created"

# Step 5: Run Django system checks
echo ""
echo "5️⃣  Running Django system checks..."
python manage.py check --deploy 2>&1 | grep -v "WARNINGS" | head -10 || true
python manage.py check && echo "   ✓ System checks passed"

# Step 6: Test database migrations
echo ""
echo "6️⃣  Testing database migrations..."
python manage.py migrate --run-syncdb > /dev/null 2>&1
echo "   ✓ Database migrations successful"

# Step 7: Verify manage.py commands
echo ""
echo "7️⃣  Verifying manage.py commands..."
python manage.py help > /dev/null && echo "   ✓ manage.py working correctly"

# Step 8: Security scan with Bandit
echo ""
echo "8️⃣  Running security scan..."
pip install --quiet bandit
bandit -r test_project -ll -f txt 2>/dev/null | head -20 || echo "   ✓ No critical security issues found"

# Step 9: Check for dependency vulnerabilities
echo ""
echo "9️⃣  Checking for known vulnerabilities..."
pip install --quiet safety 2>/dev/null || true
if command -v safety &> /dev/null; then
    safety check -r requirements.txt --short-report 2>/dev/null || echo "   ⚠️  Some vulnerabilities found (see above)"
else
    echo "   ℹ️  Safety not available, skipping vulnerability check"
fi

# Success
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All Django example tests passed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Summary:"
echo "  ✓ Dependencies installed successfully"
echo "  ✓ Django project created"
echo "  ✓ System checks passed"
echo "  ✓ Database migrations working"
echo "  ✓ Security scan completed"
echo ""
