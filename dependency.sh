#!/bin/bash

# Enable unofficial "Strict mode"
set -euo pipefail;
IFS=$'\n\t';

# Exit Codes
readonly e_missing_dependencies=1;
readonly e_invalid_input=2;
readonly e_unsupported_operating_system=3;

usage() {
	cat <<-USAGE
		Checks if the given dependencies are currently installed.

		usage: $0 -d dependency [-h] [-i]
		    -d dependency   Dependency to check for. May be repeated.
		    -h              Display this help text and return.
		    -i              Try to install any missing dependencies.

		Relevant Environment Variables
		    NONE

		Side Effects
            If -i is present, will attempt to install missing dependencies.

		Exit Codes
		    $e_missing_dependencies                               At least one dependency was not installed.
		    $e_invalid_input                               Invalid input code
		    $e_unsupported_operating_system                               Unsupported operating system
USAGE
}

#=== FUNCTION ================================================================
# NAME: cleanup
# DESCRIPTION: Called when script exits.
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# DEPENDENCIES: None.
# SIDE EFFECTS: None.
# EXIT CODES: None.
#=============================================================================
cleanup() {
	return 0;
}
trap cleanup EXIT;

#=== FUNCTION ================================================================
# NAME: get_installer
# DESCRIPTION: Called when script exits.
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# DEPENDENCIES: None.
# SIDE EFFECTS: None.
# EXIT CODES: None.
#=============================================================================
get_installer() {
    local installer;

    local os;
    os="$(uname)";
    # TODO: Determine default installer by operating system for other operating systems
    case "$os" in
        'Darwin')
            echo "Running from a Mac" >&2;
            installer="brew install"
            ;;
        *)
            echo "No installer configured for operating system '$os'." >&2;
            usage >&2;
            return $e_unsupported_operating_system;
            ;;
    esac;

    if [ -z "$installer" ]; then
        echo "Unable to parse output from 'uname' (${os})" >&2;
        usage >&2;
        return $e_unsupported_operating_system;
    fi

    echo "$installer";

    return 0;
}

main() {
    local dependencies;
    declare -a dependencies;
    local install_missing_dependencies=false;
    # TODO: Add a -v option for verbose/debugging output
	while getopts "d:hio:" opt; do
		case $opt in
			d)
                dependencies+=("$OPTARG");
				;;
			h)
				usage;
				return 0;
				;;
			i)
                install_missing_dependencies=true;
				;;
			*)
				echo "Invalid argument!" >&2
				usage;
				return $e_invalid_input;
		esac;
	done;

	if [ ${#dependencies[@]} -le 0 ]; then
		echo "Missing required argument: -d" >&2;
		usage;
		return $e_invalid_input;
	fi

    local missing_dependencies;
    declare -a missing_dependencies;

    local dependency;
    for dependency in "${dependencies[@]}"; do
        if command -v "$dependency" >/dev/null; then
            echo "$dependency is already installed";
        else
            echo "$dependency is not installed";
            missing_dependencies+=("$dependency");
        fi
    done

    local uninstallable_dependencies;
    declare -a uninstallable_dependencies;
    if [ ${#missing_dependencies[@]} -gt 0 ]; then
        if $install_missing_dependencies; then
            local installer;
            installer="$(get_installer)";
            echo "Will try to install dependencies using: ${installer}";
            dependency=;
            for dependency in "${missing_dependencies[@]}"; do
                # TODO: Only add them here if the install command fails
                uninstallable_dependencies+=("$dependency");
            done
        else
            uninstallable_dependencies=("${missing_dependencies[@]}");
        fi
    fi

    if [ ${#uninstallable_dependencies[@]} -gt 0 ]; then
        echo "The following dependencies are $($install_missing_dependencies && echo "still ")not installed." >&2;
        echo "${uninstallable_dependencies[*]}";
        return $e_missing_dependencies;
    fi

	return 0;
}

main "$@";
