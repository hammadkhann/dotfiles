# dotfiles

Portable configuration for **Claude Code**, **OpenAI Codex CLI**, **Cursor**, **Fish shell**, and **Ghostty** — synced across machines.

## What's included

```
dotfiles/
├── claude/                     # ~/.claude/
│   ├── CLAUDE.md               # Global agent instructions
│   ├── settings.json           # Permissions, hooks, env, plugins, statusline
│   ├── mcp.json.example        # MCP servers (add your keys)
│   ├── statusline.sh           # Status bar: branch, model, context %, duration, lines
│   ├── agents/                 # 3 custom agents (code-reviewer, frontend-dev, python-expert)
│   ├── commands/               # 22 slash commands
│   ├── hooks/                  # Prompt injection defender, self-improvement, prompt linter, Claude Island
│   ├── plugins/                # Marketplace list + 30 installed plugins
│   └── scripts/                # Automation (weekly log generator)
│
├── codex/                      # ~/.codex/
│   ├── config.toml.example     # Model, features, MCP servers (customize paths)
│   ├── rules/                  # Shell command auto-approval rules
│   └── prompts/                # 19 slash command prompts
│
├── cursor/                     # ~/.cursor/ + ~/Library/Application Support/Cursor/
│   ├── settings.json           # Editor settings
│   ├── keybindings.json        # Key bindings (Cmd+I → agent mode)
│   ├── mcp.json.example        # MCP servers (add your URLs)
│   ├── hooks.json              # Hook registration
│   ├── hooks/                  # Implementation review hooks (mark edit + stop review)
│   ├── rules/                  # 11 .mdc rule files (Python, UI, design, learning, etc.)
│   ├── commands/               # 25 slash commands
│   └── extensions.txt          # 30+ extensions list
│
├── fish/                       # ~/.config/fish/
│   ├── config.fish             # Main config (PATH, aliases, functions, integrations)
│   ├── fish_plugins            # Fisher plugin list (7 plugins)
│   ├── conf.d/                 # Theme (Tokyo Night), keybindings, extras
│   └── functions/              # Custom functions (claude wrapper, sesh)
│
├── ghostty/                    # ~/.config/ghostty/
│   └── config                  # Tokyo Night theme, JetBrains Mono, SAND keybindings
│
├── install.fish                # Fish shell installer
└── .gitignore
```

## Quick start

```fish
# Clone
git clone https://github.com/hammadkhann/dotfiles.git ~/side-projects/dotfiles

# Preview changes
fish ~/side-projects/dotfiles/install.fish --dry-run

# Install everything
fish ~/side-projects/dotfiles/install.fish

# Or install one tool at a time
fish ~/side-projects/dotfiles/install.fish --claude
fish ~/side-projects/dotfiles/install.fish --codex
fish ~/side-projects/dotfiles/install.fish --cursor
fish ~/side-projects/dotfiles/install.fish --fish
fish ~/side-projects/dotfiles/install.fish --ghostty
```

## Manual steps after install

1. **Claude MCP servers** — Copy `claude/mcp.json.example` → `~/.claude/mcp.json` and add your API keys
2. **Codex config** — Copy `codex/config.toml.example` → `~/.codex/config.toml` and set project trust levels
3. **Cursor MCP servers** — Copy `cursor/mcp.json.example` → `~/.cursor/mcp.json` and customize URLs
4. **Claude plugins** — See `claude/plugins/plugin-list.md` for marketplace + plugin install commands
5. **Cursor extensions** — See `cursor/extensions.txt` for the full list
6. **Fish plugins** — Install Fisher, then `fisher update` to install from `fish_plugins`
7. **Oh My Posh** — Install and place your theme at `~/.config/ohmyposh/theme.json`
8. **Fonts** — Install [JetBrains Mono](https://www.jetbrains.com/lp/mono/)

## Key features

### Hooks

| Hook | Tool | Purpose |
|---|---|---|
| Prompt Injection Defender | Claude | Scans tool outputs for injection attempts (PostToolUse) |
| Self-Improvement | Claude | Suggests optimization hints after 8+ tool calls |
| Prompt Linter | Claude | Flags prompts >50 words to verify clarity |
| Claude Island | Claude | Sends session state to ClaudeIsland.app via Unix socket |
| Implementation Review | Cursor | Auto-reviews code on agent stop after edits |

### Shared commands

Many commands are shared across all three tools (alignment-chart, concept-analysis, contract-docstrings, hypothesis-tests, mutation-testing, pre-mortem, stub-package, tighten-types, try-except, etc.).

### CLAUDE.md as single source of truth

`CLAUDE.md` is the global agent instruction file. Codex symlinks it as `AGENTS.md`, and Cursor symlinks it into `rules/`. One file governs all three tools.

### Fish shell highlights

- **Tokyo Night** color scheme across fish, fzf, ghostty
- **Lazy-loaded** integrations: zoxide, conda (instant shell startup)
- **Auto-venv**: Activates `.venv` on `cd` into project directories
- **AWS SSO caching**: `claude` wrapper auto-refreshes SSO tokens every 8 hours
- **`sesh`**: Zellij session launcher for Claude/Codex/Amp with lazygit side pane
- **Fisher plugins**: autopair, sponge, puffer-fish, fzf.fish, done, sesh

### Ghostty highlights

- Tokyo Night palette with 90% opacity + background blur
- SAND keybinding scheme (Split/Across/Navigate/Destroy)
- 25MB scrollback for long AI coding sessions
- JetBrains Mono with thickened rendering

## Prerequisites

```fish
# Package manager
brew install fish ghostty neovim eza bat fd fzf zoxide direnv oh-my-posh

# Fisher (fish plugin manager)
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# Python
brew install uv

# Node (for Claude Code, Codex)
brew install node
npm install -g @anthropic-ai/claude-code @openai/codex
```

## Excluded from version control

- Credentials and auth tokens
- Session history and caches
- IDE lock files and state databases
- Audio files (hook sounds)
- `settings.local.json` (machine-specific overrides)
- Expedia-specific MCP servers and URLs

## Per-machine notes

- Status bar colors tuned for dark terminals — adjust ANSI codes in `statusline.sh` if needed
- Hook paths use `~` expansion — should work on any macOS machine
- Codex project trust levels are machine-specific — set them in your local `config.toml`
- Fish greeting says "Hammad" — customize in `config.fish` if needed
