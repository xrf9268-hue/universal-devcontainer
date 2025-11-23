# Contributing to Universal Dev Container

Thank you for your interest in contributing! This project aims to provide the best possible Dev Container experience with Claude Code integration.

## 🌟 Ways to Contribute

- 🐛 **Report bugs** - Help us identify issues
- 💡 **Suggest features** - Share your ideas
- 📝 **Improve documentation** - Make it clearer
- 🛠️ **Submit code** - Fix bugs or add features
- 🎨 **Add examples** - Share framework integrations
- 🔧 **Create features** - Build Dev Container Features
- 🌍 **Translate** - Help internationalize

## 🚀 Quick Start for Contributors

### 1. Set Up Development Environment

```bash
# Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/universal-devcontainer.git
cd universal-devcontainer

# Open in this Dev Container itself!
code .
# Reopen in Container

# All tools are pre-installed:
# - Claude Code for AI assistance
# - Node.js, Python, Go
# - All linting and validation tools
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

### 3. Make Changes

Follow our [coding standards](#coding-standards) below.

### 4. Test Your Changes

```bash
# Validate JSON files
jq empty .devcontainer/devcontainer.json
jq empty .claude/settings.local.json

# Check shell scripts
bash -n scripts/*.sh
bash -n .devcontainer/*.sh

# Run shellcheck (if available)
shellcheck scripts/*.sh .devcontainer/*.sh || true

# Test the dev container
# Rebuild and verify all features work
```

### 5. Commit Your Changes

```bash
git add .
git commit -m "feat: add amazing feature"
```

**Commit Message Format**:
```
<type>: <description>

[optional body]

[optional footer]
```

**Types**:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

**Examples**:
```
feat: add support for Rust development
fix: resolve firewall blocking npm registry
docs: update proxy configuration guide
refactor: simplify bootstrap-claude script
```

### 6. Push and Create PR

```bash
git push -u origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## 📋 Development Workflow

### Project Structure

```
universal-devcontainer/
├── .devcontainer/           # Dev Container configuration
│   ├── devcontainer.json    # Main configuration
│   ├── Dockerfile           # Custom image (if used)
│   ├── bootstrap-claude.sh  # Claude Code setup
│   └── init-firewall.sh     # Firewall configuration
├── .claude/                 # Claude Code settings
│   ├── settings.local.json  # Local settings
│   └── presets/            # Permission mode presets
├── scripts/                 # Helper scripts
│   ├── open-project.sh     # Project opener
│   ├── configure-claude-mode.sh
│   ├── create-project.sh   # Template generator
│   └── update-config.sh    # Update mechanism
├── src/                    # Dev Container Features
│   ├── claude-code/        # Claude Code feature
│   ├── firewall/           # Firewall feature
│   ├── toolset-*/          # Tool collections
│   └── compliance-*/       # Compliance features
├── examples/               # Usage examples
│   ├── react-app/
│   ├── nextjs-app/
│   ├── python-fastapi/
│   └── multi-container/
├── docs/                   # Documentation
│   ├── PROXY_SETUP.md
│   ├── SECURITY.md
│   └── UPDATES.md
└── README.md               # Main documentation
```

### Testing Checklist

Before submitting a PR:

- [ ] **JSON files valid**: `jq empty` on all JSON
- [ ] **Shell scripts valid**: `bash -n` on all scripts
- [ ] **ShellCheck passes**: Run on modified scripts
- [ ] **Documentation updated**: READMEs reflect changes
- [ ] **Examples work**: Test in clean container
- [ ] **No secrets committed**: Check .gitignore
- [ ] **Commit messages formatted**: Follow convention

## 💻 Coding Standards

### Shell Scripts

```bash
#!/bin/bash
# Always use bash shebang
set -e  # Exit on error

# Use meaningful variable names
CONTAINER_NAME="my-container"
PROJECT_PATH="/workspace"

# Quote variables
echo "Project: $PROJECT_PATH"
cd "$PROJECT_PATH"

# Use functions for clarity
setup_environment() {
    local env_file=$1
    # Function body
}

# Add error handling
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found"
    exit 1
fi
```

**Shell Script Guidelines**:
- Use `#!/bin/bash` (not sh)
- Add `set -e` for error handling
- Quote all variables: `"$VAR"`
- Use `[[` instead of `[` for conditionals
- Add comments for complex logic
- Use meaningful function names
- Handle errors gracefully

### JSON Files

```json
{
  "key": "value",
  "array": [
    "item1",
    "item2"
  ],
  "nested": {
    "property": true
  }
}
```

**JSON Guidelines**:
- Use 2-space indentation
- No trailing commas
- Validate with `jq empty`
- Use meaningful property names
- Add comments in README, not JSON

### Documentation

**Markdown Guidelines**:
- Use clear headings (# ## ###)
- Add code blocks with language tags
- Include examples
- Keep line length reasonable
- Use bullet points for lists
- Add links where helpful

**README Structure**:
1. Title and description
2. Quick start
3. Features
4. Usage examples
5. Configuration
6. Troubleshooting
7. Contributing link

## 🎨 Adding Examples

Want to add a framework example?

### 1. Create Example Directory

```bash
mkdir -p examples/your-framework/{.devcontainer,src}
```

### 2. Required Files

```
your-framework/
├── .devcontainer/
│   └── devcontainer.json    # REQUIRED
├── README.md                # REQUIRED
├── package.json or equivalent  # Framework-specific
└── src/                     # Sample code
```

### 3. devcontainer.json Template

```json
{
  "name": "Your Framework with Claude Code",
  "image": "mcr.microsoft.com/devcontainers/...",

  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "host",
      "bypassPermissions": true
    }
  },

  "customizations": {
    "vscode": {
      "extensions": [
        // Framework-specific extensions
      ]
    }
  },

  "forwardPorts": [3000],
  "postCreateCommand": "# Install dependencies",
  "mounts": [
    "source=${localEnv:HOME}/.claude,target=/host-claude,type=bind,readonly"
  ],
  "postStartCommand": "bash ~/.claude/import-host-settings.sh 2>/dev/null || true"
}
```

### 4. README Template

```markdown
# Your Framework Example

Brief description of the framework and what this example demonstrates.

## Quick Start
[Steps to use this example]

## What's Included
[List of tools and features]

## Development
[How to run, build, test]

## Using Claude Code
[Example Claude commands for this framework]

## Next Steps
[What to do after getting started]
```

### 5. Update Main Examples README

Add your example to `examples/README.md`.

## 🔧 Creating Dev Container Features

### 1. Feature Structure

```
src/features/your-feature/
├── devcontainer-feature.json  # Metadata
├── install.sh                 # Installation script
└── README.md                  # Documentation
```

### 2. Feature Metadata

```json
{
  "id": "your-feature",
  "version": "1.0.0",
  "name": "Your Feature Name",
  "description": "What this feature does",
  "documentationURL": "https://github.com/.../your-feature",
  "options": {
    "option1": {
      "type": "boolean",
      "default": true,
      "description": "Option description"
    }
  }
}
```

### 3. Installation Script

```bash
#!/bin/bash
set -e

echo "Installing Your Feature..."

# Parse options (uppercase)
OPTION1="${OPTION1:-true}"

# Install dependencies
apt-get update
apt-get install -y your-package

# Configure
# ... your setup code ...

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✅ Feature installed successfully!"
```

### 4. Follow Feature Best Practices

- Idempotent installation
- Minimal dependencies
- Clear error messages
- Proper cleanup
- Comprehensive README

## 📝 Documentation Guidelines

### Adding Documentation

1. **In-code comments**: For complex logic
2. **README files**: For each component
3. **Main docs**: In `docs/` directory
4. **Examples**: Working code samples

### Translation

We support Chinese and English:

- `README.md` - Chinese (primary)
- `README.en.md` - English

When updating documentation:
- Update both versions
- Keep structure consistent
- Translate accurately
- Test all links

## 🐛 Reporting Bugs

### Before Reporting

1. **Search existing issues**: Check if already reported
2. **Update to latest**: Try latest version
3. **Minimal reproduction**: Create smallest failing example

### Bug Report Template

```markdown
**Describe the bug**
Clear description of what's wrong.

**To Reproduce**
Steps to reproduce:
1. Start with this devcontainer.json: '...'
2. Run command '....'
3. See error

**Expected behavior**
What should happen instead.

**Environment**
- OS: [e.g., macOS 13.0]
- VS Code version: [e.g., 1.85]
- Docker Desktop version: [e.g., 4.25]
- Dev Containers extension version: [e.g., 0.321]

**Additional context**
- Logs, screenshots, etc.
```

## 💡 Suggesting Features

### Feature Request Template

```markdown
**Problem**
What problem does this solve?

**Proposed Solution**
How should it work?

**Alternatives Considered**
What other solutions did you think about?

**Additional Context**
Examples, mockups, references
```

## 🔍 Code Review Process

### What We Look For

✅ **Functionality**: Does it work as intended?
✅ **Code Quality**: Is it clean and maintainable?
✅ **Testing**: Are changes tested?
✅ **Documentation**: Is it documented?
✅ **Security**: No vulnerabilities introduced?
✅ **Performance**: No significant slowdowns?

### Review Timeline

- **Initial review**: Within 3-5 days
- **Follow-up**: Within 2-3 days
- **Merge**: After approval from maintainers

## 🏆 Recognition

Contributors will be:
- Listed in README (optional)
- Mentioned in release notes
- Credited in commit messages

## 📞 Getting Help

- **Questions**: Open a Discussion
- **Bugs**: Open an Issue
- **Security**: See SECURITY.md
- **Complex Topics**: Tag maintainers

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

## 🙏 Thank You!

Every contribution helps make this project better. Whether it's a bug report, feature suggestion, or code contribution, we appreciate your time and effort!

Happy contributing! 🚀
