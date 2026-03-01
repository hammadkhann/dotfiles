#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$current_dir")

# Build status line components
status_parts=()

# Add git branch if in a git repo
if cd "$current_dir" 2>/dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git --no-optional-locks branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        status_parts+=("$(printf '\033[36m')$branch$(printf '\033[0m')")
    fi
fi

# Add directory name
status_parts+=("$(printf '\033[33m')$dir_name$(printf '\033[0m')")

# Add model name
status_parts+=("$(printf '\033[35m')$model_name$(printf '\033[0m')")

# Add context window usage with color coding (green → yellow → red)
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    size=$(echo "$input" | jq '.context_window.context_window_size')
    if [ "$current" != "null" ] && [ "$size" != "null" ] && [ "$size" -gt 0 ]; then
        pct=$((current * 100 / size))
        # Color based on usage: green < 50%, yellow 50-75%, red > 75%
        if [ "$pct" -lt 50 ]; then
            color="\033[32m"  # green
        elif [ "$pct" -lt 75 ]; then
            color="\033[33m"  # yellow
        else
            color="\033[31m"  # red
        fi
        status_parts+=("$(printf "$color")${pct}%$(printf '\033[0m')")
    fi
fi

# Add session duration
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
if [ "$duration_ms" != "null" ] && [ "$duration_ms" -gt 0 ]; then
    duration_sec=$((duration_ms / 1000))
    minutes=$((duration_sec / 60))
    seconds=$((duration_sec % 60))
    status_parts+=("$(printf '\033[94m')${minutes}m${seconds}s$(printf '\033[0m')")
fi

# Add lines changed (+/-)
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
    status_parts+=("$(printf '\033[32m')+${lines_added}$(printf '\033[0m')/$(printf '\033[31m')-${lines_removed}$(printf '\033[0m')")
fi

# Join all parts with separator
separator=" $(printf '\033[90m')•$(printf '\033[0m') "
printf "%s" "${status_parts[0]}"
for ((i=1; i<${#status_parts[@]}; i++)); do
    printf "%s%s" "$separator" "${status_parts[$i]}"
done
