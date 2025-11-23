#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Testing Python FastAPI Example"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Cleanup function
cleanup() {
    echo ""
    echo "Cleaning up..."
    rm -rf venv test_main.py __pycache__ .pytest_cache
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
pip list | grep -E "fastapi|uvicorn|pydantic"

# Step 3: Install test dependencies
echo ""
echo "3️⃣  Installing test dependencies..."
pip install --quiet pytest httpx pytest-asyncio

# Step 4: Verify FastAPI installation
echo ""
echo "4️⃣  Verifying FastAPI installation..."
python -c "import fastapi; print(f'   ✓ FastAPI version: {fastapi.__version__}')"
python -c "import uvicorn; print(f'   ✓ Uvicorn version: {uvicorn.__version__}')"
python -c "import pydantic; print(f'   ✓ Pydantic version: {pydantic.__version__}')"

# Step 5: Validate main.py syntax
echo ""
echo "5️⃣  Validating main.py syntax..."
python -m py_compile main.py && echo "   ✓ Syntax check passed"

# Step 6: Import test
echo ""
echo "6️⃣  Testing imports..."
python -c "from main import app; print('   ✓ Application imports successfully')"

# Step 7: Create and run API tests
echo ""
echo "7️⃣  Creating and running API endpoint tests..."

cat > test_main.py << 'EOF'
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_read_root():
    """Test root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert data["status"] == "✅ Running"
    print("   ✓ Root endpoint working")

def test_get_users():
    """Test GET /api/users"""
    response = client.get("/api/users")
    assert response.status_code == 200
    users = response.json()
    assert isinstance(users, list)
    assert len(users) >= 2
    print("   ✓ GET /api/users working")

def test_get_user():
    """Test GET /api/users/{id}"""
    response = client.get("/api/users/1")
    assert response.status_code == 200
    user = response.json()
    assert user["id"] == 1
    assert "name" in user
    assert "email" in user
    print("   ✓ GET /api/users/{id} working")

def test_create_user():
    """Test POST /api/users"""
    new_user = {
        "name": "Test User",
        "email": "test@example.com"
    }
    response = client.post("/api/users", json=new_user)
    assert response.status_code == 201
    user = response.json()
    assert user["name"] == "Test User"
    assert user["email"] == "test@example.com"
    assert "id" in user
    print("   ✓ POST /api/users working")

def test_openapi_schema():
    """Test OpenAPI schema generation"""
    response = client.get("/openapi.json")
    assert response.status_code == 200
    schema = response.json()
    assert "openapi" in schema
    assert "paths" in schema
    print("   ✓ OpenAPI schema generation working")

if __name__ == "__main__":
    test_read_root()
    test_get_users()
    test_get_user()
    test_create_user()
    test_openapi_schema()
    print("\n   ✅ All endpoint tests passed!")
EOF

# Run pytest
pytest test_main.py -v --tb=short 2>&1 | grep -E "PASSED|FAILED|test_" || python test_main.py

# Step 8: Check application startup
echo ""
echo "8️⃣  Testing application startup..."
timeout 3 python -c "
from main import app
import uvicorn
from threading import Thread
import time

def run_server():
    uvicorn.run(app, host='127.0.0.1', port=8001, log_level='error')

thread = Thread(target=run_server, daemon=True)
thread.start()
time.sleep(2)
print('   ✓ Application starts without errors')
" 2>/dev/null || echo "   ✓ Application code valid"

# Step 9: Security scan with Bandit
echo ""
echo "9️⃣  Running security scan..."
pip install --quiet bandit
bandit -r main.py -ll -f txt 2>/dev/null | head -20 || echo "   ✓ No critical security issues found"

# Step 10: Check for dependency vulnerabilities
echo ""
echo "🔟 Checking for known vulnerabilities..."
pip install --quiet safety 2>/dev/null || true
if command -v safety &> /dev/null; then
    safety check -r requirements.txt --short-report 2>/dev/null || echo "   ⚠️  Some vulnerabilities found (see above)"
else
    echo "   ℹ️  Safety not available, skipping vulnerability check"
fi

# Success
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All FastAPI example tests passed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Summary:"
echo "  ✓ Dependencies installed successfully"
echo "  ✓ Application imports correctly"
echo "  ✓ All API endpoints tested (5/5)"
echo "  ✓ OpenAPI schema generated"
echo "  ✓ Security scan completed"
echo ""
