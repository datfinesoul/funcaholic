# `epoch` Function Guide

## Overview

The `epoch()` function is a versatile bash utility for converting epoch timestamps to human-readable dates and performing flexible date conversions. It supports multiple input methods and provides easy-to-use date formatting options.

## Features

- Convert epoch timestamps to formatted dates
- Support for different date command variations (GNU and macOS)
- Pipe or direct input support
- Optional help information
- Fallback to current timestamp if no input provided

## Usage Examples

### Basic Usage

```bash
# Get current epoch timestamp
epoch

# Convert a specific epoch timestamp
epoch 1656207017

# Convert timestamp with custom formatting
epoch 1656207017 "+%Y-%m-%d"

# Convert to UTC time
epoch 1656207017 -u

# Pipe input from another command
echo 1656207017 | epoch - "+%Y-%m-%d"
```

## Input Methods

1. **No Arguments**: Returns the current epoch timestamp
2. **Direct Input**: Provide epoch timestamp as an argument
3. **Pipe Input**: Use `-` to read timestamp from stdin
4. **Help**: Use `--help` to display usage examples

## Additional Date Command Parameters

Any arguments after the epoch timestamp are directly passed to the `date` command. This allows for extensive customization of the output:

```bash
# Custom date formatting
epoch 1656207017 "+%Y-%m-%d %H:%M:%S"

# Convert to specific timezone
TZ='Europe/London' epoch 1656207017 "+%Z"

# Use additional date command options
epoch 1656207017 -u "+%Y-%m-%dT%H:%M:%S%z"
```

## Compatibility

- Works with GNU date
- Compatible with macOS/BSD date variants
- Handles both positive and negative epoch timestamps