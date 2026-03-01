# Fish Shell Configuration

# --- Homebrew ---
if test -d /opt/homebrew
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    fish_add_path -gP /opt/homebrew/bin /opt/homebrew/sbin
end

# --- PATH ---
set -l _clean_path
for p in $PATH
    if test $p = /Users/muhakhan/Library/Python/3.9/bin
        continue
    end
    if not contains -- $p $_clean_path
        set _clean_path $_clean_path $p
    end
end
set -l _preferred_paths ~/.local/bin /opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin
set -l _new_path
for p in $_preferred_paths
    if test -d $p
        set _new_path $_new_path $p
    end
end
for p in $_clean_path
    if not contains -- $p $_new_path
        set _new_path $_new_path $p
    end
end
set -gx PATH $_new_path

# --- Python (uv) ---
set -gx UV_PYTHON_PREFERENCE managed
set -gx UV_PYTHON 3.11

# --- Pager ---
set -gx PAGER less
set -gx LESS -FRX

# --- Claude Code / Bedrock ---
set -gx CLAUDE_CODE_USE_BEDROCK 1
set -gx AWS_PROFILE cc
set -gx ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION us-west-2
set -gx ANTHROPIC_MODEL us.anthropic.claude-opus-4-5-20251101-v1:0
set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL us.anthropic.claude-haiku-4-5-20251001-v1:0
set -gx ANTHROPIC_DEFAULT_SONNET_MODEL global.anthropic.claude-sonnet-4-5-20250929-v1:0
set -gx ANTHROPIC_DEFAULT_OPUS_MODEL us.anthropic.claude-opus-4-5-20251101-v1:0

# --- Conda (lazy load) ---
function __init_conda
    if test -f $HOME/miniconda3/bin/conda
        eval $HOME/miniconda3/bin/conda "shell.fish" hook | source
    else if test -f $HOME/miniconda3/etc/fish/conf.d/conda.fish
        source $HOME/miniconda3/etc/fish/conf.d/conda.fish
    end
end

function conda -d 'Lazy load conda'
    functions -e conda
    __init_conda
    conda $argv
end

# --- Interactive only ---
if status is-interactive
    function fish_greeting
        set -l hour (date "+%H")
        set -l greeting
        if test $hour -lt 12
            set greeting "morning"
        else if test $hour -lt 17
            set greeting "afternoon"
        else
            set greeting "evening"
        end

        set_color 7aa2f7
        echo -n "λ "
        set_color c0caf5
        echo -n "Good $greeting, "
        set_color 7aa2f7 --bold
        echo -n "Hammad"
        set_color normal
        echo ""

        set -l parts
        set -a parts (set_color 565f89)(date "+%a %d %b, %H:%M")(set_color normal)

        if test -n "$VIRTUAL_ENV"
            set -a parts (set_color 9ece6a)"⬢ "(basename $VIRTUAL_ENV)(set_color normal)
        else if test -n "$CONDA_DEFAULT_ENV"
            set -a parts (set_color 9ece6a)"⬢ $CONDA_DEFAULT_ENV"(set_color normal)
        end

        if test -f .git/HEAD
            set -l branch (string replace 'ref: refs/heads/' '' < .git/HEAD)
            set -a parts (set_color bb9af7)" $branch"(set_color normal)
        else if test -d .git
            set -a parts (set_color bb9af7)" detached"(set_color normal)
        end

        set -a parts (set_color 7dcfff)(prompt_pwd)(set_color normal)

        echo (string join (set_color 3b4261)" │ "(set_color normal) $parts)
        echo
    end

    # cache dir for generated init snippets
    set -l __fish_cache_dir ~/.config/fish/.cache
    if not test -d $__fish_cache_dir
        mkdir -p $__fish_cache_dir
    end

    # Editor
    if command -q nvim
        set -gx EDITOR nvim
    else if command -q vim
        set -gx EDITOR vim
    end
    set -gx VISUAL cursor
    set -gx MANPAGER "less -R --use-color -Dd+r -Du+b"

    # pip -> uv pip (handle --version cleanly)
    function pip -d 'Use uv pip'
        if command -q uv
            if test (count $argv) -eq 0
                uv pip list
                return
            end
            if test $argv[1] = "--version" -o $argv[1] = "-V"
                python3 -m pip --version
                return
            end
            uv pip $argv
        else
            python3 -m pip $argv
        end
    end

    # code -> cursor
    function code -w cursor -d 'Open in Cursor'
        cursor $argv
    end

    # Conda activate (handles lazy loading)
    function act -d 'Activate conda env'
        if not functions -q __fish_conda_env
            __init_conda
        end
        conda activate $argv
    end

    # --- Better ls (eza if available) ---
    if command -q eza
        function ls -w eza -d 'List files (eza)'
            eza --icons --group-directories-first $argv
        end
        function ll -w eza -d 'Long list'
            eza -la --icons --group-directories-first --git $argv
        end
        function lt -w eza -d 'Tree view'
            eza -T --icons --group-directories-first -L 2 $argv
        end
        function llt -w eza -d 'Long tree view'
            eza -laT --icons --group-directories-first --git -L 2 $argv
        end
    else
        abbr -a ll 'ls -la'
        abbr -a la 'ls -A'
    end

    # --- Abbreviations ---
    # Navigation
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a .... 'cd ../../..'

    # Git
    abbr -a g git
    abbr -a gs 'git status -sb'
    abbr -a gp 'git push'
    abbr -a gpf 'git push --force-with-lease'
    abbr -a gl 'git pull --rebase'
    abbr -a gf 'git fetch --all --prune'
    abbr -a gd 'git diff'
    abbr -a gds 'git diff --staged'
    abbr -a gc 'git commit'
    abbr -a gca 'git commit --amend'
    abbr -a gcm 'git commit -m'
    abbr -a gco 'git checkout'
    abbr -a gsw 'git switch'
    abbr -a gsc 'git switch -c'
    abbr -a gb 'git branch'
    abbr -a gba 'git branch -a'
    abbr -a gbd 'git branch -d'
    abbr -a glog 'git log --oneline --graph --decorate -15'
    abbr -a gloga 'git log --oneline --graph --decorate --all -20'
    abbr -a gst 'git stash'
    abbr -a gstp 'git stash pop'
    abbr -a gstl 'git stash list'
    abbr -a grb 'git rebase'
    abbr -a grbc 'git rebase --continue'
    abbr -a grba 'git rebase --abort'
    abbr -a gcp 'git cherry-pick'
    abbr -a grs 'git restore'
    abbr -a grss 'git restore --staged'
    abbr -a gbl 'git blame'

    # Python / uv
    abbr -a py python3
    abbr -a ipy ipython
    abbr -a deact 'conda deactivate'
    abbr -a uvi 'uv pip install'
    abbr -a uvl 'uv pip list'
    abbr -a uva 'uv add'
    abbr -a uvr 'uv remove'
    abbr -a uvsync 'uv sync'
    abbr -a uvrun 'uv run'

    # Testing / Linting
    abbr -a pt pytest
    abbr -a ptv 'pytest -v'
    abbr -a ptx 'pytest -x'
    abbr -a ptf 'pytest -x --ff'
    abbr -a ptlf 'pytest --lf'
    abbr -a rf 'ruff check'
    abbr -a rff 'ruff check --fix'
    abbr -a rfmt 'ruff format'

    # Docker
    abbr -a dk docker
    abbr -a dkps 'docker ps'
    abbr -a dkc docker-compose
    abbr -a dkrm 'docker rm (docker ps -aq)'
    abbr -a dki 'docker images'
    abbr -a dkl 'docker logs -f'

    # Misc
    abbr -a c clear
    abbr -a h history
    abbr -a j jobs
    abbr -a q exit
    abbr -a v nvim
    abbr -a vi nvim

    # Updates
    abbr -a codex-update 'npm install -g @openai/codex@latest'
    abbr -a claude-update 'claude update'
    abbr -a brewup 'brew update && brew upgrade && brew cleanup'

    # --- Functions ---
    function mkcd -d 'Create dir and cd'
        mkdir -p $argv[1] && cd $argv[1]
    end
    function take -w mkcd -d 'Create dir and cd'; mkcd $argv; end

    function port -d 'Show process on port'
        if test (count $argv) -eq 0
            echo "Usage: port <port_number>"
            return 1
        end
        lsof -i :$argv[1]
    end

    function ports -d 'Show all listening ports'
        lsof -iTCP -sTCP:LISTEN -n -P
    end

    function path -d 'Print PATH'
        for i in (seq (count $PATH))
            printf "%3d  %s\n" $i $PATH[$i]
        end
    end

    function serve -d 'HTTP server'
        set -l port (test (count $argv) -gt 0; and echo $argv[1]; or echo 8000)
        echo "🌐 Serving at http://localhost:$port"
        python3 -m http.server $port
    end

    function reload -d 'Reload config'
        source ~/.config/fish/config.fish
        echo "✓ Config reloaded"
    end

    function pyclean -d 'Clean Python cache'
        find . -type f -name "*.py[co]" -delete
        find . -type d -name "__pycache__" -delete
        find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null
        find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null
        find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null
        find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null
        echo "✓ Python cache cleaned"
    end

    function pyinfo -d 'Python env info'
        set_color 7dcfff; echo "── Python Environment ──"; set_color normal
        echo "  Python:  "(python3 --version 2>/dev/null | string replace 'Python ' '')
        echo "  Path:    "(which python3 2>/dev/null)
        echo "  uv:      "(uv --version 2>/dev/null | string replace 'uv ' '')
        if test -n "$VIRTUAL_ENV"
            set_color 9ece6a; echo "  Env:     venv ("(basename $VIRTUAL_ENV)")"; set_color normal
        else if test -n "$CONDA_DEFAULT_ENV"
            set_color 9ece6a; echo "  Env:     conda ($CONDA_DEFAULT_ENV)"; set_color normal
        else
            set_color 565f89; echo "  Env:     system"; set_color normal
        end
    end

    function uvenv -d 'Create venv and activate'
        uv venv && source .venv/bin/activate.fish && echo "✓ venv activated"
    end

    function gquick -d 'Git add, commit, push'
        if test (count $argv) -eq 0
            echo "Usage: gquick <commit message>"
            return 1
        end
        git add -A && git commit -m "$argv" && git push
    end

    function gwip -d 'Git WIP commit'
        git add -A && git commit -m "🚧 WIP: $argv"
    end

    function gundo -d 'Undo last commit (keep changes)'
        git reset --soft HEAD~1
        echo "✓ Last commit undone, changes preserved"
    end

    function extract -d 'Extract any archive'
        if test (count $argv) -eq 0
            echo "Usage: extract <archive>"
            return 1
        end
        switch $argv[1]
            case '*.tar.gz' '*.tgz'
                tar xzf $argv[1]
            case '*.tar.bz2' '*.tbz2'
                tar xjf $argv[1]
            case '*.tar.xz' '*.txz'
                tar xJf $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "Unknown archive format: $argv[1]"
                return 1
        end
    end

    function sizeof -d 'Show size of file/dir'
        du -sh $argv 2>/dev/null | sort -h
    end

    function ip -d 'Show IP addresses'
        set_color 7dcfff; echo "── Network ──"; set_color normal
        echo "  Local:   "(ipconfig getifaddr en0 2>/dev/null; or echo "not connected")
        echo "  Public:  "(curl -s ifconfig.me 2>/dev/null; or echo "unavailable")
    end

    function proj -d 'Jump to project (fzf)'
        set -l search_dirs ~/expedia_projects ~/projects ~/code ~/src
        set -l dirs
        for d in $search_dirs
            if test -d $d
                for p in $d/*/
                    if test -d "$p.git" -o -f "$p/pyproject.toml" -o -f "$p/package.json"
                        set -a dirs $p
                    end
                end
            end
        end
        if test (count $dirs) -eq 0
            echo "No projects found"
            return 1
        end
        set -l choice (printf '%s\n' $dirs | sed "s|$HOME|~|" | fzf --prompt 'proj ∷ ' --height 40%)
        if test -n "$choice"
            cd (string replace '~' $HOME $choice)
        end
    end

    function weather -d 'Show weather'
        set -l loc (test (count $argv) -gt 0; and echo $argv[1]; or echo "")
        curl -s "wttr.in/$loc?format=3" 2>/dev/null
    end

    function json -d 'Pretty print JSON'
        if test (count $argv) -gt 0
            cat $argv[1] | python3 -m json.tool
        else
            python3 -m json.tool
        end
    end

    function fif -d 'Find in files'
        if test (count $argv) -lt 1
            echo "Usage: fif <pattern> [path]"
            return 1
        end
        set -l search_path (test (count $argv) -gt 1; and echo $argv[2]; or echo ".")
        grep -rn --color=auto $argv[1] $search_path
    end

    function help -d 'List custom commands'
        set_color 7dcfff; echo "── Custom Commands ──"; set_color normal
        echo
        set_color e0af68; echo "Navigation:"; set_color normal
        echo "  z/zi      Smart cd (zoxide)     mkcd/take  Create dir & cd"
        echo "  proj      Jump to project (fzf)"
        echo
        set_color e0af68; echo "Git:"; set_color normal
        echo "  gquick    Add, commit, push     gwip       WIP commit"
        echo "  gundo     Undo last commit      glog       Pretty log"
        echo
        set_color e0af68; echo "Python:"; set_color normal
        echo "  pyinfo    Show Python env       pyclean    Clean cache"
        echo "  uvenv     Create & activate     pip        Uses uv pip"
        echo
        set_color e0af68; echo "Files:"; set_color normal
        echo "  ll/lt     List (eza)            sizeof     Show sizes"
        echo "  extract   Extract archive       fif        Find in files"
        echo "  json      Pretty print JSON"
        echo
        set_color e0af68; echo "System:"; set_color normal
        echo "  port(s)   Show port usage       ip         Network info"
        echo "  serve     HTTP server           weather    Weather info"
        echo "  reload    Reload fish config    path       Show PATH"
        echo
        set_color e0af68; echo "FZF (patrickf1/fzf.fish):"; set_color normal
        echo "  Ctrl+Alt+F  File search          Ctrl+R     History search"
        echo "  Ctrl+Alt+L  Git log              Ctrl+Alt+S Git status"
        echo "  Ctrl+Alt+P  Process search"
        echo
        set_color 565f89; echo "Use 'abbr' to see all abbreviations"; set_color normal
    end

    # Safer operations
    function rm -w rm; command rm -i $argv; end
    function cp -w cp; command cp -i $argv; end
    function mv -w mv; command mv -i $argv; end

    # Auto-activate venv
    function __auto_venv --on-variable PWD
        if test -f .venv/bin/activate.fish -a -z "$VIRTUAL_ENV"
            source .venv/bin/activate.fish
        end
    end

    # --- Integrations ---
    # Direnv
    if command -q direnv
        direnv hook fish | source
    end

    # Lazy Zoxide (init on first use)
    if command -q zoxide
        function __zoxide_lazy_init
            functions --erase z zi __zoxide_lazy_init 2>/dev/null
            set -l _zoxide_init $__fish_cache_dir/zoxide-init.fish
            set -l _zoxide_bin (command -s zoxide)
            # Regenerate if cache missing or zoxide binary updated
            if not test -f $_zoxide_init; or test $_zoxide_bin -nt $_zoxide_init
                zoxide init fish > $_zoxide_init
            end
            source $_zoxide_init
        end
        function z --wraps zoxide -d 'zoxide (lazy init)'
            __zoxide_lazy_init
            z $argv
        end
        function zi --wraps zoxide -d 'zoxide interactive (lazy init)'
            __zoxide_lazy_init
            zi $argv
        end
    end

    # --- FZF defaults (fd backend, bat preview, Tokyo Night colors) ---
    if command -q fzf
        set -gx FZF_DEFAULT_OPTS "\
--height 60% --layout reverse --border rounded \
--color bg+:#283457,bg:#1a1b26,spinner:#7dcfff,hl:#7aa2f7 \
--color fg:#c0caf5,header:#7aa2f7,info:#bb9af7,pointer:#7dcfff \
--color marker:#9ece6a,fg+:#c0caf5,prompt:#bb9af7,hl+:#7aa2f7 \
--color border:#414868 \
--prompt '∷ ' --pointer '▶' --marker '✓'"

        if command -q fd
            set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
        end

        # patrickf1/fzf.fish plugin config
        set -g fzf_fd_opts --hidden --follow --exclude .git
        if command -q eza
            set -g fzf_preview_dir_cmd eza --all --color=always --icons
        end
        if command -q bat
            set -g fzf_preview_file_cmd bat --color=always --style=numbers --line-range=:200
        end
    end

    # Oh My Posh prompt (cached)
    if command -q oh-my-posh
        set -l _omp_init $__fish_cache_dir/omp-init.fish
        set -l _omp_bin (command -s oh-my-posh)
        set -l _omp_theme ~/.config/ohmyposh/theme.json
        if not test -f $_omp_init; or test $_omp_bin -nt $_omp_init; or test $_omp_theme -nt $_omp_init
            oh-my-posh init fish --config $_omp_theme > $_omp_init
        end
        source $_omp_init
    else if command -q starship
        # Fallback to Starship if Oh My Posh not available
        set -l _starship_init $__fish_cache_dir/starship-init.fish
        set -l _starship_bin (command -s starship)
        if not test -f $_starship_init; or test $_starship_bin -nt $_starship_init
            starship init fish --print-full-init > $_starship_init
        end
        source $_starship_init
    end
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
