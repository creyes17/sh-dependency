#!/bin/bash

# Enable unofficial "Strict mode"
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail;
IFS=$'\n\t';

# Exit Codes
readonly e_missing_dependencies=1;
readonly e_invalid_input=2;
readonly e_unsupported_operating_system=3;

usage() {
	cat <<-USAGE
		Checks if the given dependencies are currently installed.

		usage: $0 -d dependency [-d dependency ...] [-h] [-i] [-v]
		    -d dependency   Dependency to check for. May be repeated.
		    -h              Display this help text and return.
		    -i              Try to install any missing dependencies.
		    -v              Add verbose output to STDERR

		Dependencies
		    If you want to use the -i flag, you'll need a package manager.
		    Currently supported package managers include:
		    - apt-get
		    - brew
		    - dnf
		    - yum

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
# NAME: get_installer
# DESCRIPTION: Gets the appropriate install command for the current OS
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# DEPENDENCIES: None.
# SIDE EFFECTS: None.
# EXIT CODES: None.
#=============================================================================
get_installer() {
    local installer;

    # TODO: Add a way to register other potential package managers
    if command -v apt-get >/dev/null; then
        installer="sudo apt-get install";
    elif command -v brew >/dev/null; then
        installer="brew install";
    elif command -v dnf >/dev/null; then
        installer="dnf install";
    elif command -v yum >/dev/null; then
        installer="yum install";
    fi

    if [ -z "$installer" ]; then
        echo "Unable to find a registered package manager." >&2;
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
    local verbose=false;
	while getopts "d:hio:v" opt; do
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
            v)
                verbose=true;
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
            $verbose && echo "$dependency is already installed" >&2;
        else
            $verbose && echo "$dependency is not installed" >&2;
            missing_dependencies+=("$dependency");
        fi
    done

    local uninstallable_dependencies;
    declare -a uninstallable_dependencies;
    if [ ${#missing_dependencies[@]} -gt 0 ]; then
        if $install_missing_dependencies; then
            local installer;
            installer="$(get_installer $verbose)";
            $verbose && echo "Will try to install dependencies using: ${installer}" >&2;
            dependency=;
            for dependency in "${missing_dependencies[@]}"; do
                eval "$installer" "$dependency" "$($verbose || echo "2>/dev/null 1>&2")" || true;
                if command -v "$dependency" >/dev/null; then
                    $verbose && echo "Successful";
                else
                    $verbose && echo "Could not install '$dependency'" >&2;
                    uninstallable_dependencies+=("$dependency");
                fi
            done
        else
            uninstallable_dependencies=("${missing_dependencies[@]}");
        fi
    fi

    if [ ${#uninstallable_dependencies[@]} -gt 0 ]; then
        echo "The following dependencies are $($install_missing_dependencies && echo "still ")not installed:" >&2;
        printf '%s\n' "${uninstallable_dependencies[@]}" | sort >&2;
        return $e_missing_dependencies;
    fi

	return 0;
}

main "$@";
