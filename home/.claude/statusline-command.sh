#!/usr/bin/env bash
# Claude Code statusLine command
# Reads JSON from stdin and outputs a formatted status line

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Get basename of cwd
dir=$(basename "$cwd")

# Get git branch (skip optional locks to avoid contention)
branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null)
fi

# Separator between segments (dim gray pipe)
sep="$(printf '\033[2m|\033[0m')"

# Build the status line with ANSI colors (dimmed-friendly)
parts=()

# Directory in cyan
if [ -n "$dir" ]; then
    parts+=("$(printf '\033[36m%s\033[0m' "$dir")")
fi

# Git branch in yellow
if [ -n "$branch" ]; then
    parts+=("$(printf '\033[33m %s\033[0m' "$branch")")
fi

# Model in magenta
if [ -n "$model" ]; then
    parts+=("$(printf '\033[35m%s\033[0m' "$model")")
fi

# Context usage in green (or red if >80%)
if [ -n "$used_pct" ]; then
    pct_int=$(printf '%.0f' "$used_pct")
    if [ "$pct_int" -ge 80 ]; then
        parts+=("$(printf '\033[31mctx %s%%\033[0m' "$pct_int")")
    else
        parts+=("$(printf '\033[32mctx %s%%\033[0m' "$pct_int")")
    fi
fi

# Claude.ai rate limit usage (5h / 7d) in blue (or red if >80%)
rate_str=""
if [ -n "$five_hour" ]; then
    five_int=$(printf '%.0f' "$five_hour")
    rate_str="5h ${five_int}%"
fi
if [ -n "$seven_day" ]; then
    seven_int=$(printf '%.0f' "$seven_day")
    if [ -n "$rate_str" ]; then
        rate_str="${rate_str} 7d ${seven_int}%"
    else
        rate_str="7d ${seven_int}%"
    fi
fi
if [ -n "$rate_str" ]; then
    max_pct=0
    [ -n "$five_int" ] && [ "$five_int" -gt "$max_pct" ] && max_pct=$five_int
    [ -n "$seven_int" ] && [ "$seven_int" -gt "$max_pct" ] && max_pct=$seven_int
    if [ "$max_pct" -ge 80 ]; then
        parts+=("$(printf '\033[31m%s\033[0m' "$rate_str")")
    else
        parts+=("$(printf '\033[34m%s\033[0m' "$rate_str")")
    fi
fi

# Join parts with separator
output=""
for part in "${parts[@]}"; do
    if [ -z "$output" ]; then
        output="$part"
    else
        output="${output} ${sep} ${part}"
    fi
done
printf '%s' "$output"
