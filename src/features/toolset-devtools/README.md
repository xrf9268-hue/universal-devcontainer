# Developer Tools Feature

Essential CLI tools for modern development workflows including git UIs, better file viewers, fuzzy finders, and HTTP clients.

## Tools Included

### Always Available
- **jq** - JSON processor
- **curl/wget** - Download tools

### Configurable Tools

#### 🎯 Essential (default)
- **lazygit** - Beautiful terminal UI for git commands
- **bat** - `cat` with syntax highlighting and Git integration
- **fzf** - Fuzzy finder for files, history, and more
- **httpie** - User-friendly HTTP client (better than curl for APIs)
- **ripgrep (rg)** - Extremely fast grep alternative

#### 🚀 Additional (opt-in)
- **eza** - Modern replacement for `ls` with git awareness
- **delta** - Better git diff viewer with syntax highlighting

## Usage

### Option 1: Default (Essential Tools)
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-devtools:1": {}
  }
}
```

### Option 2: All Tools
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-devtools:1": {
      "includeTools": "all"
    }
  }
}
```

### Option 3: Minimal
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-devtools:1": {
      "includeTools": "minimal"
    }
  }
}
```

### Option 4: Custom Selection
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-devtools:1": {
      "installLazygit": true,
      "installBat": true,
      "installFzf": true,
      "installHttpie": false,
      "installRipgrep": true,
      "installEza": true,
      "installDelta": true
    }
  }
}
```

## Tool Usage Examples

### lazygit
```bash
lazygit  # Opens interactive git UI
```

### bat
```bash
bat README.md           # View file with syntax highlighting
bat src/**/*.js         # View multiple files
```

### fzf
```bash
vim $(fzf)              # Fuzzy find and open file
git checkout $(git branch | fzf)  # Fuzzy find git branch
```

### httpie
```bash
http GET api.github.com/users/octocat
http POST api.example.com/users name=John email=john@example.com
```

### ripgrep
```bash
rg "function" --type js    # Search in JS files
rg "TODO" -i               # Case-insensitive search
```

### eza (if installed)
```bash
eza -la --git              # List with git status
eza --tree                 # Tree view
```

### delta (if installed)
```bash
# Configure git to use delta
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
```

## Notes

- All tools are lightweight and fast
- No conflicts with existing system tools
- Tools enhance CLI productivity significantly
- Great for both beginners and power users
