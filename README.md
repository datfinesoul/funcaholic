# funcaholic
## `epoch`

The `epoch()` function is a flexible bash utility that converts epoch timestamps to human-readable dates. It can generate the current epoch timestamp, convert a given timestamp, or read timestamps from stdin. By passing additional arguments, users can customize the date output format, timezone, and other date command parameters, making it a versatile tool for timestamp manipulation across different systems.

## `gs`

The `gs` function is a tool for managing and executing symbolic link-based commands stored in `_gs` directories within a Git repository. Starting from the current directory, it traverses up the repository hierarchy, searching for `_gs` directories at each level. If a command name is provided as an argument, it executes the corresponding symbolic link within the nearest `_gs` directory. If no command is specified, it collects and lists all available symbolic links (representing commands) from the `_gs` directories encountered. This design allows for flexible, repository-specific command organization, enabling directory-scoped custom workflows while ensuring commands are managed via symbolic links for consistency and portability.
