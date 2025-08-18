# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains the `gs` shell function - a Git repository-aware command runner that uses symbolic links in `_gs` directories to organize and execute project-specific commands. The function searches from the current directory up to the repository root, finding and executing commands while providing shell completion.

## Architecture

The project consists of 4 main shell scripts:

- **gs.bash** - Bash implementation of the `gs` function
- **gs.zsh** - Zsh implementation with minor syntax differences for zsh compatibility  
- **gs_completion.bash** - Bash completion script for the `gs` command
- **gs_completion.zsh** - Zsh completion script for the `gs` command

Both bash and zsh implementations share identical logic but use shell-specific syntax for array handling and string operations.

## Core Functionality

The `gs` function implements a "shadowing" system similar to PATH resolution:

1. **Directory Traversal**: Searches for `_gs` directories from current directory up to git repository root
2. **Command Resolution**: First occurrence of a command name takes precedence (closer directories override distant ones)
3. **Execution**: Executes symbolic links as commands, passing through arguments
4. **Listing**: When no command specified, lists all available commands grouped by directory
5. **Descriptions**: Supports `.gs.json` files alongside commands to provide descriptions

## Key Implementation Details

- **Git Integration**: Must be run within a git repository; uses `git rev-parse` for path resolution
- **Cross-Platform**: Handles macOS/BSD vs GNU/Linux differences in `find` command syntax
- **JSON Support**: Optional `jq` integration for command descriptions
- **Shell Completion**: Dynamic completion based on available commands in `_gs` directories

## Development Workflow

This is a pure shell script project with no build system, package managers, or test frameworks. The scripts are meant to be sourced directly into shell environments.

### Testing Changes

Since there are no automated tests, manual testing involves:
1. Source the function in your shell: `source gs.bash` or `source gs.zsh`
2. Create test `_gs` directories with symbolic links
3. Verify command listing and execution behavior
4. Test shell completion functionality

### File Structure Convention

The repository follows a simple flat structure with shell-specific implementations. When making changes:
- Keep bash and zsh implementations functionally identical
- Maintain compatibility with both macOS and Linux
- Preserve the command shadowing behavior (closest directory wins)