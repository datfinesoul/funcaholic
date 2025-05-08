gs() {
	# Exit if git isn't available
	if ! type git &> /dev/null; then return 1; fi

	# Get the top level git directory absolute path or exit if not a git repo
	local tld
	tld="$(git rev-parse --show-toplevel 2> /dev/null)" || return 1
	[[ -z "${tld}" ]] && return 1

	# Parse current repo-relative path into array
	# Example: if current path is project/src/utils, then dirs=["project","src","utils"]
	local -a dirs
	IFS=/ read -r -a dirs <<< "$(git rev-parse --show-prefix)"

	local gs_path index
	local command="${1:-}"
	local length="${#dirs[@]}"
	local found_dirs=0
	declare -A gs_dir_commands
	declare -A cmd_descriptions
	local -a dir_order

	# Check for jq availability
	local has_jq=0
	if type jq &> /dev/null; then
		has_jq=1
	fi

	# Commands are shadowed by closer directories (like PATH resolution)
	declare -A seen_commands

	# Traversal proceeds from current directory up to repo root
	# For project/src/utils, checks _gs dirs in this order:
	#  1. project/src/utils/_gs
	#  2. project/src/_gs
	#  3. project/_gs
	#  4. _gs (repo root)
	for (( index="${length}"; index>=0; index-- )); do
		gs_path="${tld}$(printf "/%s" "${dirs[@]:0:$index}")/_gs"
		gs_path="${gs_path//\/\//\/}"  # Normalize path

		if [[ -e "${gs_path}" ]]; then
			# Execute command if it exists
			if [[ -n "${command}" && -e "${gs_path}/${command}" ]]; then
				shift
				"${gs_path}/${command}" "$@"
				return
			fi

			# Convert absolute paths to repo-relative for display
			local display_path
			if [[ "${gs_path}" == "${tld}/_gs" ]]; then
				display_path="_gs/"
			else
				display_path="${gs_path#"${tld}/"}"
			fi

			# Store path for ordering
			dir_order+=("${display_path}")

			# Find executable symlinks and filter out already-seen commands
			local cmd_list=""
			while IFS= read -r cmd; do
				[[ -z "${cmd}" ]] && continue
				if [[ -z "${seen_commands["${cmd}"]}" ]]; then
					seen_commands["${cmd}"]=1

					# Check for description file (same name with .gs.json suffix)
					local desc_file="${gs_path}/${cmd}.gs.json"
					local desc=""
					if [[ -f "${desc_file}" ]]; then
						# Extract description using jq if available
						if [[ ${has_jq} -eq 1 ]]; then
							desc=$(jq -r '.description // empty' "${desc_file}" 2>/dev/null)
						fi
					fi

					# Store description for this command
					cmd_descriptions["${cmd}"]="${desc}"

					cmd_list+="${cmd}"$'\n'
				fi
			done < <(find "${gs_path}/" -type l ! -xtype l -perm -111 -exec basename {} \; | sort)

			# Remove trailing newline
			cmd_list="${cmd_list%$'\n'}"

			if [[ -n "${cmd_list}" ]]; then
				gs_dir_commands["${display_path}"]="${cmd_list}"
				found_dirs=1
			fi
		fi
	done

	# Display results or error
	if [[ ${found_dirs} -eq 0 ]]; then
		>&2 echo "[x] no _gs commands found"
	else
		# Determine padding length for aligned output
		local max_len=0
		for cmd in "${!cmd_descriptions[@]}"; do
			if [[ ${#cmd} -gt ${max_len} ]]; then
				max_len=${#cmd}
			fi
		done

		# Output directories closest-first with their unique commands
		for dir in "${dir_order[@]}"; do
			# Skip directories with no commands to display
			[[ -z "${gs_dir_commands["${dir}"]}" ]] && continue

			echo "${dir}"
			while IFS= read -r cmd; do
				[[ -z "${cmd}" ]] && continue

				local desc="${cmd_descriptions["${cmd}"]}"
				if [[ -n "${desc}" ]]; then
					printf "→ %-${max_len}s : %s\n" "${cmd}" "${desc}"
				else
					printf "→ %s\n" "${cmd}"
				fi
			done <<< "${gs_dir_commands["${dir}"]}"
		done
	fi
}
