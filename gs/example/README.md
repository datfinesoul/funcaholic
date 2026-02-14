# gs Example Directory

This directory demonstrates how `gs` resolves commands using directory hierarchy and command shadowing.

## Directory Structure

```
example/
├── _gs/                          # Root commands (lowest priority)
│   ├── env -> ../_scripts/show-env.bash
│   ├── env.mod -> ../_scripts/env.source.bash
│   └── descriptions.toml
├── js/
│   ├── _gs/                      # JS-specific commands (override root)
│   │   ├── env -> show-env.bash          # Local override
│   │   ├── env.mod -> env.source.bash    # Local override
│   │   ├── lint -> lint-js.bash          # JS-specific
│   │   └── actual script files
│   └── project-b/
├── python/
│   ├── _gs/                      # Python-specific commands
│   │   ├── lint -> lint-py.bash          # Python-specific
│   │   └── actual script files
│   └── project-a/
└── _scripts/                     # Shared scripts
```

## Command Resolution (Closest Wins)

When running `gs` commands, closer `_gs` directories take precedence:

- **From `js/project-b/`**: Uses `js/_gs/` commands (overrides root)
- **From `python/project-a/`**: Uses `python/_gs/` commands
- **From `example/`**: Uses root `_gs/` commands

## Command Types

### Execute vs Source

- **`env`**: Executes in subprocess → displays variables but doesn't affect current shell
- **`env.mod`**: Sources into current shell → sets GIT_PWD and GIT_REL in your environment

### Language-Specific Commands

- **`lint`** in `js/_gs/`: Runs JavaScript linting
- **`lint`** in `python/_gs/`: Runs Python linting

Same command name, different implementations based on directory context.

## Docker-based Linting Examples

For real-world usage, the lint commands can use Docker to run language-specific tools without requiring local installation:

### JavaScript (Standard.js)
```bash
#!/usr/bin/env bash
docker run --rm \
  -v "$(pwd)":/app:ro \
  -w /app \
  --entrypoint '' \
  node:lts-alpine \
  sh -c "npx --yes standard --fix"
```

### Python (Ruff)
```bash
#!/usr/bin/env bash
docker run --rm \
  -v "$(pwd)":/app:ro \
  -w /app \
  --entrypoint '' \
  python:3-slim \
  sh -c "pip install -q ruff && ruff check --fix ."
```

This approach provides consistent linting environments across teams without requiring developers to install specific versions of Node.js, Python, or linting tools locally.