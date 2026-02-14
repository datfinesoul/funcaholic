# `gs` Function Guide

If you work across multiple projects with different linting, testing, or build commands, and need those tools to adapt based on where you are in your repository, `gs` is for you. It organizes context-specific commands in `_gs` directories that shadow each other automatically, and unlike regular scripts, it can modify your shell environment directly.

## Installation

Add to your shell configuration file (`~/.bashrc` or `~/.zshrc`):

```bash
# For Bash
source /path/to/funcaholic/gs/gs.bash
source /path/to/funcaholic/gs/gs_completion.bash

# For Zsh
source /path/to/funcaholic/gs/gs.zsh
source /path/to/funcaholic/gs/gs_completion.zsh
```

Reload your shell or run `source ~/.bashrc` (or `~/.zshrc`).

---

## Command Types

`gs` supports two types of commands based on symlink naming:

| Command Type | Pattern | Behavior | Use Case |
|--------------|---------|----------|----------|
| **Execute** | `lint`, `build`, `test` | Runs in subprocess | Display output without affecting shell |
| **Source** | `env.mod`, `setup.mod` | Runs in current shell | Set variables, change directories, modify PATH |

> [!IMPORTANT]
> Regular executables run in isolation. Any environment changes disappear when they exit. Only sourced commands (`.mod`) can modify your active shell session.

---

## How It Works

The `gs` function:

1. Searches for `_gs` directories starting from the current directory and traversing up the Git repository hierarchy.
2. Executes a specified command if it matches a symbolic link in the nearest `_gs` directory.
3. Lists all available symbolic link commands grouped by their source directories if no command is specified.

This makes `gs` ideal for organizing and using directory-specific or repository-specific workflows.

---

## Usage

### Prerequisites

- You must be inside a Git repository.
- `_gs` directories must contain symbolic links representing the available commands.

### Syntax

```bash
gs [command] [arguments]
```

- **`command`**: The name of the symbolic link to execute within the `_gs` directory.
- **`arguments`**: Additional arguments to pass to the command being executed.

### Command Descriptions

You can add descriptions to commands by creating a `descriptions.toml` file inside a `_gs` directory. For example:

```
_gs/
├── build -> ../scripts/build.sh
├── descriptions.toml
└── env.mod -> ../scripts/dev-env.sh
```

Where `descriptions.toml` contains:

```toml
# Command descriptions
build = "Build the project for production"
env.mod = "Source repo environment variables into current shell"
```

These descriptions will appear in the command listing output.

### Examples

<details>
<summary>Example 1: List Available Commands</summary>

Assume the following directory structure:

```
repo/
├── src/
│   ├── utils/
│   │   ├── _gs/
│   │   │   ├── descriptions.toml
│   │   │   ├── lint -> ../../scripts/lint.sh
│   │   │   └── test -> ../../scripts/test.sh
│   └── _gs/
│       └── build -> ../../scripts/build.sh
└── _gs/
    └── deploy -> ../scripts/deploy.sh
```

Starting in `repo/src/utils/`:

```bash
cd repo/src/utils
gs
```

Output:

```
src/utils/_gs
→ lint    : Run linting checks on the codebase
→ test
src/_gs
→ build
_gs/
→ deploy
```

The output groups commands by their source directory, with the closest directories shown first. Commands with descriptions display them after the command name.

</details>

<details>
<summary>Example 2: Execute a Command</summary>

Starting in `repo/src/`:

```bash
cd repo/src
gs build --target production
```

This runs the symbolic link named `build` with the argument `--target production`.

</details>

<details>
<summary>Example 3: Source a Command</summary>

To source a `.mod` command that sets up your development environment:

```bash
gs env.mod
```

This sources the `env.mod` symlink into your current shell. If the script contains:

```bash
export PROJECT_ROOT=$(git rev-parse --show-toplevel)
export PATH="$PROJECT_ROOT/bin:$PATH"
```

These variables are now set in your current shell. Running `gs env` (without `.mod`) would execute in a subprocess and you'd see output but environment changes wouldn't affect your shell.

</details>

---

## Best Practices

1. **Organize `_gs` Directories**:
   - Place `_gs` directories in logical locations, such as at the root or specific subdirectories of your repository.
   - Use descriptive names for symbolic links to indicate their purpose clearly.

2. **Add Descriptions**:
   - Create a `descriptions.toml` file in your `_gs` directory to provide helpful descriptions.
   - Keep descriptions concise but informative.

3. **Symbolic Links Only**:
   - Ensure that `_gs` directories contain only symbolic links pointing to the actual scripts or executables.
   - Use `.mod` suffix for symlinks that should be sourced rather than executed.

4. **Naming Conflicts**:
   - Use unique names for symbolic links to prevent unintended command executions.
   - Use existing names if you plan to create an override for something at a higher level in the repository.
   
5. **Test Commands**:
   - Regularly verify the behavior of commands to ensure they function correctly in their intended context.

---

## Comparison with Alternatives

There are several well-established project task runners. Here's how `gs` compares:

| Feature | gs | just | Task | mise | direnv | Make |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| Dir hierarchy traversal + shadowing | :white_check_mark: | :x: | :x: | :x: | :heavy_minus_sign: | :x: |
| Shell env sourcing | :white_check_mark: | :x: | :x: | :heavy_minus_sign: | :heavy_minus_sign: | :x: |
| Symlink-based (decoupled from config) | :white_check_mark: | :x: | :x: | :x: | :x: | :x: |
| Git-scoped | :white_check_mark: | :x: | :x: | :white_check_mark: | :x: | :x: |
| Shell completion | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | — | :heavy_minus_sign: |
| Config format | `_gs/` symlinks | justfile | Taskfile.yml | mise.toml | .envrc | Makefile |

### [just](https://github.com/casey/just) (~31k stars)

A Rust-based command runner using a `justfile`. The most popular dedicated command runner with a rich feature set (parameters, conditionals, multi-language recipes, shell completion). However, it uses a single flat file with no directory traversal or shadowing, and cannot source commands into the current shell.

### [Task](https://github.com/go-task/task) (~15k stars)

A Go-based runner using `Taskfile.yml`. Has dependency graphs, file-change detection, and parallel execution. Same single-file limitation as just — no hierarchy traversal and no shell sourcing.

### [mise](https://github.com/jdx/mise) (~25k stars)

A polyglot dev environment tool that combines version management, environment variables, and task running. Supports file-based tasks in a `mise/tasks/` directory and can modify the shell environment, but only for tool versions and env vars — not arbitrary sourcing. No directory shadowing.

### [direnv](https://github.com/direnv/direnv) (~15k stars)

Loads and unloads environment variables per-directory via `.envrc` files. The closest match to `gs`'s `.mod` feature — it traverses the directory hierarchy and modifies the current shell. But it's exclusively for environment variables, not command running or discovery.

### [GNU Make](https://www.gnu.org/software/make/)

Ubiquitous but fundamentally a build system with dependency tracking, not a command runner. No directory traversal, no shell sourcing, and its own idiosyncratic syntax (tab-sensitivity, `.PHONY` declarations).

### [Scripts to Rule Them All](https://github.com/github/scripts-to-rule-them-all) (~9k stars)

A convention from GitHub: standardized scripts in a `script/` directory (`script/bootstrap`, `script/test`, etc.). Not a tool — no automatic discovery, listing, completion, or shadowing.

### What makes `gs` different

The combination of **directory-hierarchy traversal with shadowing**, **symlink-based command organization** (decoupling the registry from the implementation), and **`.mod` sourcing** for shell environment modification is unique to `gs`. The closest equivalent would be combining direnv with just, but that still wouldn't provide the symlink-based shadowing system.

---

## Troubleshooting

1. **No `_gs` Commands Found**:
   - Ensure `_gs` directories exist and contain symbolic links.
   - Verify that you are inside a Git repository.

2. **Command Not Executing**:
   - Confirm that the symbolic link matches the command name provided.
   - Check for permissions or path issues with the target of the symbolic link.

3. **Missing Descriptions**:
   - Ensure your `descriptions.toml` file uses valid `key = "value"` syntax.
   - Check that keys match command names exactly (e.g., `env.mod` for a `.mod` command).
