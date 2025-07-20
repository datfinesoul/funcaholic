#!/usr/bin/env bash

fragment() {
  # Check if project name was provided
  if [[ $# -lt 1 ]]; then
    echo "[x] Usage: fragment <project-name>"
    return 1
  fi

  local project_name="$1"
  local fragment_dir="${HOME}/.fragment/${project_name}"
  local config_file="${fragment_dir}/_fragment.config.json"

  # Check if project directory exists
  if [[ ! -d "${fragment_dir}" ]]; then
    echo "[x] Project '${project_name}' not found in ${HOME}/.fragment/"
    return 1
  fi

  # Check if config file exists
  if [[ ! -f "${config_file}" ]]; then
    echo "[x] Configuration file not found: ${config_file}"
    return 1
  fi

  # Check if required tools are available
  if ! command -v fzf &>/dev/null; then
    echo "[x] 'fzf' is required but not found in PATH"
    return 1
  fi

  if ! command -v jq &>/dev/null; then
    echo "[x] 'jq' is required but not found in PATH"
    return 1
  fi

  # Get all fragment files
  local fragment_files=()
  while IFS= read -r file; do
    # Extract the file name without the .fragment. part
    local display_name
    display_name=$(basename "$file" | sed -E 's/(.*)\.fragment\.(.*)/\1.\2/')
    fragment_files+=("$display_name:::$file")
  done < <(find "${fragment_dir}" -type f -name "*.fragment.*" | sort)

  if [[ ${#fragment_files[@]} -eq 0 ]]; then
    echo "[x] No fragment files found in ${fragment_dir}"
    return 1
  fi

  # Present files for selection using fzf
  local selected_files
  selected_files=$(printf "%s\n" "${fragment_files[@]}" | cut -d':' -f1 |
    fzf --multi --header="Select fragments to include (TAB to select multiple)")

  # Early exit if no files selected
  if [[ -z "${selected_files}" ]]; then
    echo "[i] No files selected. Exiting."
    return 0
  fi

  # Read order from config file
  local order_json
  order_json=$(jq -r '.order[]' "${config_file}" 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "[x] Failed to parse config file ${config_file}"
    return 1
  fi

  # Create ordered list of selected files
  local ordered_files=()
  local selected_array
  readarray -t selected_array <<< "${selected_files}"

  # First add files that are in the order array
  for ordered_file in ${order_json}; do
    for selection in "${selected_array[@]}"; do
      if [[ "${selection}" == "${ordered_file}" ]]; then
        # Find the matching full file path
        for fragment in "${fragment_files[@]}"; do
          local display=$(echo "${fragment}" | cut -d':' -f1)
          local file_path=$(echo "${fragment}" | cut -d':' -f3-)

          if [[ "${display}" == "${selection}" ]]; then
            ordered_files+=("${file_path}")
            break
          fi
        done
        break
      fi
    done
  done

  # Then add any selected files not in the order array (as failsafe)
  for selection in "${selected_array[@]}"; do
    local found=0
    for ordered_file in ${order_json}; do
      if [[ "${selection}" == "${ordered_file}" ]]; then
        found=1
        break
      fi
    done

    if [[ ${found} -eq 0 ]]; then
      # Find the matching full file path
      for fragment in "${fragment_files[@]}"; do
        local display=$(echo "${fragment}" | cut -d':' -f1)
        local file_path=$(echo "${fragment}" | cut -d':' -f3-)

        if [[ "${display}" == "${selection}" ]]; then
          ordered_files+=("${file_path}")
          break
        fi
      done
    fi
  done

  # Determine output file name from first selected file
  local first_file="${selected_array[0]}"
  local output_file="${first_file%.fragment.*}"
  local output_ext="${first_file##*.}"
  local output_path="${PWD}/${output_file}"

  # Combine files
  echo "[i] Creating ${output_path}..."

  # Clear or create the output file
  : > "${output_path}"

  # Add each file content
  for file in "${ordered_files[@]}"; do
    echo "[i] Adding $(basename "${file}")"
    cat "${file}" >> "${output_path}"
    echo "" >> "${output_path}" # Add a newline between fragments
  done

  echo "[i] Done! Output written to ${output_path}"
}

# Export the function so it's available in the shell
export -f fragment
