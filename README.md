# funcaholic
## `epoch`

The `epoch()` function is a flexible bash utility that converts epoch timestamps to human-readable dates. It can generate the current epoch timestamp, convert a given timestamp, or read timestamps from stdin. By passing additional arguments, users can customize the date output format, timezone, and other date command parameters, making it a versatile tool for timestamp manipulation across different systems.

## `gs`

The `gs` function is a Git-aware command discovery and execution tool that helps organize
repository-specific utilities through a hierarchical system of `_gs` directories. It traverses
from the current directory up to the repository root, finding executable symbolic links in `_gs`
directories and either executing a specified command or displaying an organized list of available
commands with optional descriptions. This approach allows for context-sensitive command overrides
and enables teams to create intuitive, location-aware workflows within their repositories without
polluting the global namespace.
