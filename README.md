# funcaholic
## `gs`

The `gs` function is a tool for managing and executing symbolic link-based commands stored in `_gs` directories within a Git repository. Starting from the current directory, it traverses up the repository hierarchy, searching for `_gs` directories at each level. If a command name is provided as an argument, it executes the corresponding symbolic link within the nearest `_gs` directory. If no command is specified, it collects and lists all available symbolic links (representing commands) from the `_gs` directories encountered. This design allows for flexible, repository-specific command organization, enabling directory-scoped custom workflows while ensuring commands are managed via symbolic links for consistency and portability.
