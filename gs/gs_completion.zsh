_gs_completion() {
    # Get available commands by calling gs() without arguments and parsing output
    local commands
    commands=($(gs 2>/dev/null | grep "^→" | sed 's/^→ \([^ ]*\).*/\1/'))
    
    compadd "$@" "${commands[@]}"
}

# Register the completion
compdef _gs_completion gs