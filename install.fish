#!/usr/bin/env fish
#
# Dotfiles installer — Claude Code, Codex CLI, Cursor, Fish, Ghostty
# Copies configs into their expected locations.
# Run: fish install.fish
#
# Options:
#   --dry-run    Show what would be done without making changes
#   --claude     Install only Claude Code configs
#   --codex      Install only Codex CLI configs
#   --cursor     Install only Cursor configs
#   --fish       Install only Fish shell configs
#   --ghostty    Install only Ghostty configs
#

set DOTFILES_DIR (realpath (dirname (status filename)))
set DRY_RUN false
set INSTALL_ALL true
set INSTALL_CLAUDE false
set INSTALL_CODEX false
set INSTALL_CURSOR false
set INSTALL_FISH false
set INSTALL_GHOSTTY false

# Parse args
for arg in $argv
    switch $arg
        case --dry-run
            set DRY_RUN true
        case --claude
            set INSTALL_ALL false
            set INSTALL_CLAUDE true
        case --codex
            set INSTALL_ALL false
            set INSTALL_CODEX true
        case --cursor
            set INSTALL_ALL false
            set INSTALL_CURSOR true
        case --fish
            set INSTALL_ALL false
            set INSTALL_FISH true
        case --ghostty
            set INSTALL_ALL false
            set INSTALL_GHOSTTY true
    end
end

if test "$INSTALL_ALL" = true
    set INSTALL_CLAUDE true
    set INSTALL_CODEX true
    set INSTALL_CURSOR true
    set INSTALL_FISH true
    set INSTALL_GHOSTTY true
end

function copy_file
    set -l src $argv[1]
    set -l dst $argv[2]

    if test "$DRY_RUN" = true
        echo "  [dry-run] $src → $dst"
        return
    end

    set -l dst_dir (dirname $dst)
    mkdir -p $dst_dir
    cp $src $dst
    echo "  ✓ $dst"
end

function copy_dir
    set -l src $argv[1]
    set -l dst $argv[2]

    if test "$DRY_RUN" = true
        echo "  [dry-run] $src/ → $dst/"
        return
    end

    mkdir -p $dst
    cp -R $src/* $dst/ 2>/dev/null; or true
    echo "  ✓ $dst/"
end

# ─── Claude Code ────────────────────────────────────────
if test "$INSTALL_CLAUDE" = true
    echo ""
    echo "═══ Claude Code ═══"
    set CLAUDE_HOME $HOME/.claude

    copy_file $DOTFILES_DIR/claude/CLAUDE.md $CLAUDE_HOME/CLAUDE.md
    copy_file $DOTFILES_DIR/claude/settings.json $CLAUDE_HOME/settings.json
    copy_file $DOTFILES_DIR/claude/statusline.sh $CLAUDE_HOME/statusline.sh
    chmod +x $CLAUDE_HOME/statusline.sh 2>/dev/null

    # Agents
    copy_dir $DOTFILES_DIR/claude/agents $CLAUDE_HOME/agents

    # Commands
    copy_dir $DOTFILES_DIR/claude/commands $CLAUDE_HOME/commands

    # Hooks
    copy_dir $DOTFILES_DIR/claude/hooks $CLAUDE_HOME/hooks
    chmod +x $CLAUDE_HOME/hooks/self-improvement.sh 2>/dev/null
    chmod +x $CLAUDE_HOME/hooks/prompt-linter.sh 2>/dev/null

    # Plugins metadata
    copy_file $DOTFILES_DIR/claude/plugins/known_marketplaces.json $CLAUDE_HOME/plugins/known_marketplaces.json

    # Scripts
    copy_dir $DOTFILES_DIR/claude/scripts $CLAUDE_HOME/scripts
    chmod +x $CLAUDE_HOME/scripts/1on1-prep.sh 2>/dev/null

    # MCP (manual step — contains secrets)
    if not test -f $CLAUDE_HOME/mcp.json
        echo "  ⚠ Copy claude/mcp.json.example → ~/.claude/mcp.json and fill in your API keys"
    end

    echo "  → Install plugins: see claude/plugins/plugin-list.md"
end

# ─── Codex CLI ──────────────────────────────────────────
if test "$INSTALL_CODEX" = true
    echo ""
    echo "═══ Codex CLI ═══"
    set CODEX_HOME $HOME/.codex

    # Config (manual — contains project trust levels)
    if not test -f $CODEX_HOME/config.toml
        echo "  ⚠ Copy codex/config.toml.example → ~/.codex/config.toml and customize"
    else
        echo "  ℹ config.toml exists — review codex/config.toml.example for updates"
    end

    # Rules
    copy_dir $DOTFILES_DIR/codex/rules $CODEX_HOME/rules

    # Prompts
    copy_dir $DOTFILES_DIR/codex/prompts $CODEX_HOME/prompts

    # AGENTS.md symlink to CLAUDE.md
    if not test -L $CODEX_HOME/AGENTS.md
        if test "$DRY_RUN" = true
            echo "  [dry-run] symlink $CODEX_HOME/AGENTS.md → $HOME/.claude/CLAUDE.md"
        else
            ln -sf $HOME/.claude/CLAUDE.md $CODEX_HOME/AGENTS.md
            echo "  ✓ symlinked AGENTS.md → ~/.claude/CLAUDE.md"
        end
    end
end

# ─── Cursor ────────────────────────────────────────────
if test "$INSTALL_CURSOR" = true
    echo ""
    echo "═══ Cursor ═══"
    set CURSOR_HOME $HOME/.cursor
    set CURSOR_USER "$HOME/Library/Application Support/Cursor/User"

    # Editor settings
    copy_file $DOTFILES_DIR/cursor/settings.json "$CURSOR_USER/settings.json"
    copy_file $DOTFILES_DIR/cursor/keybindings.json "$CURSOR_USER/keybindings.json"

    # Hooks
    copy_file $DOTFILES_DIR/cursor/hooks.json $CURSOR_HOME/hooks.json
    copy_dir $DOTFILES_DIR/cursor/hooks $CURSOR_HOME/hooks

    # Rules
    copy_dir $DOTFILES_DIR/cursor/rules $CURSOR_HOME/rules

    # Symlink CLAUDE.md into cursor rules
    if not test -L $CURSOR_HOME/rules/CLAUDE.md
        if test "$DRY_RUN" = true
            echo "  [dry-run] symlink $CURSOR_HOME/rules/CLAUDE.md → $HOME/.claude/CLAUDE.md"
        else
            ln -sf $HOME/.claude/CLAUDE.md $CURSOR_HOME/rules/CLAUDE.md
            echo "  ✓ symlinked rules/CLAUDE.md → ~/.claude/CLAUDE.md"
        end
    end

    # Commands
    copy_dir $DOTFILES_DIR/cursor/commands $CURSOR_HOME/commands

    # MCP (manual — may contain org-specific URLs)
    if not test -f $CURSOR_HOME/mcp.json
        echo "  ⚠ Copy cursor/mcp.json.example → ~/.cursor/mcp.json and customize"
    end

    # Extensions
    echo "  → Install extensions: see cursor/extensions.txt"
end

# ─── Fish ──────────────────────────────────────────────
if test "$INSTALL_FISH" = true
    echo ""
    echo "═══ Fish Shell ═══"
    set FISH_HOME $HOME/.config/fish

    copy_file $DOTFILES_DIR/fish/config.fish $FISH_HOME/config.fish
    copy_file $DOTFILES_DIR/fish/fish_plugins $FISH_HOME/fish_plugins

    # conf.d (custom files only — plugin files are managed by Fisher)
    for f in $DOTFILES_DIR/fish/conf.d/*.fish
        copy_file $f $FISH_HOME/conf.d/(basename $f)
    end

    # Custom functions
    for f in $DOTFILES_DIR/fish/functions/*.fish
        copy_file $f $FISH_HOME/functions/(basename $f)
    end

    echo "  → Run 'fisher update' to install plugins from fish_plugins"
end

# ─── Ghostty ───────────────────────────────────────────
if test "$INSTALL_GHOSTTY" = true
    echo ""
    echo "═══ Ghostty ═══"
    set GHOSTTY_HOME $HOME/.config/ghostty

    copy_file $DOTFILES_DIR/ghostty/config $GHOSTTY_HOME/config

    echo "  → Restart Ghostty or press Cmd+Shift+, to reload"
end

echo ""
echo "Done! Review ⚠ items above for manual steps."
