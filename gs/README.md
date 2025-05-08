# `gs` Function Guide

The `gs` function is a powerful utility for managing and executing symbolic link-based commands stored in `_gs` directories within a Git repository. This guide explains how to use it effectively.

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

You can add descriptions to commands by creating a JSON file with the same name as the command plus `.gs.json` extension. For example:

```
_gs/
├── build -> ../scripts/build.sh
└── build.gs.json
```

Where `build.gs.json` contains:

```json
{
  "description": "Build the project for production"
}
```

This description will appear in the command listing output.

### Examples

#### Example 1: List Available Commands

Assume the following directory structure:

```
repo/
├── src/
│   ├── utils/
│   │   ├── _gs/
│   │   │   ├── lint -> ../../scripts/lint.sh
│   │   │   ├── lint.gs.json
│   │   │   └── test -> ../../scripts/test.sh
│   └── _gs/
│       └── build -> ../../scripts/build.sh
└── _gs/
    └── deploy -> ../scripts/deploy.sh
```

Starting in `repo/src/utils/`:

```bash
cd repo/src/utils
```

Running `gs`:

```bash
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

The output now groups commands by their source directory, with the closest directories shown first. Commands with descriptions display them after the command name.

#### Example 2: Execute a Command

Starting in `repo/src/`:

```bash
cd repo/src
```

To execute the `build` command from the nearest `_gs` directory:

```bash
gs build --target production
```

This runs the symbolic link named `build` with the argument `--target production`.

---

## Best Practices

1. **Organize `_gs` Directories**:
   - Place `_gs` directories in logical locations, such as at the root or specific subdirectories of your repository.
   - Use descriptive names for symbolic links to indicate their purpose clearly.

2. **Add Descriptions**:
   - Create `.gs.json` files for your commands to provide helpful descriptions.
   - Keep descriptions concise but informative.

3. **Symbolic Links Only**:
   - Ensure that `_gs` directories contain only symbolic links pointing to the actual scripts or executables.

4. **Naming Conflicts**:
   - Use unique names for symbolic links to prevent unintended command executions.
   - Use existing names if you plan to create an override for something at a higher level in the repository.
   
5. **Test Commands**:
   - Regularly verify the behavior of commands to ensure they function correctly in their intended context.

---

## Command Resolution

The `gs` function follows a "shadowing" approach similar to how `PATH` resolution works:

1. The function searches `_gs` directories from the current directory up to the repository root.
2. The first occurrence of a command with a given name takes precedence.
3. Commands in closer directories override those with the same name in more distant directories.

This allows you to create local overrides of global commands when needed.

---

## Troubleshooting

1. **No `_gs` Commands Found**:
   - Ensure `_gs` directories exist and contain symbolic links.
   - Verify that you are inside a Git repository.

2. **Command Not Executing**:
   - Confirm that the symbolic link matches the command name provided.
   - Check for permissions or path issues with the target of the symbolic link.

3. **Missing Descriptions**:
   - Ensure your `.gs.json` files are valid JSON with a `description` field.
   - Check that you have `jq` installed for JSON parsing.

---

## Conclusion

The `gs` function simplifies repository-specific task management by leveraging `_gs` directories and symbolic links. By following the guidelines above, you can create a flexible and efficient workflow tailored to your project's structure.
