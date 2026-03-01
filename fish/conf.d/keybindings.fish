# Fish Keybindings - Productivity Enhancements

if status is-interactive
    # Alt+S: Prepend sudo to current command
    function __fish_prepend_sudo
        set -l cmd (commandline)
        if test -n "$cmd"
            commandline -r "sudo $cmd"
            commandline -C (math (string length "sudo ") + (commandline -C))
        end
    end
    bind \es __fish_prepend_sudo

    # Alt+.: Insert last argument from previous command
    bind \e. history-token-search-backward

    # Ctrl+X Ctrl+E: Edit command in $EDITOR
    bind \cx\ce edit_command_buffer

    # Alt+C: Capitalize word
    bind \ec capitalize-word

    # Alt+L: Lowercase word
    bind \el downcase-word

    # Alt+U: Uppercase word
    bind \eu upcase-word

    # Ctrl+W: Delete word backward (more vim-like)
    bind \cw backward-kill-word

    # Alt+Backspace: Delete word backward (alternative)
    bind \e\x7f backward-kill-word

    # Ctrl+L: Clear screen and reprint prompt (already default, but ensure it)
    bind \cl 'clear; commandline -f repaint'
end
