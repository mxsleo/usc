#!/usr/bin/env bash

set -uo pipefail
if [[ -n "${DEBUG-}" ]]; then set -ex; fi


# Global variables +++

_LIBUSC="$(dirname "${0}")/libusc"

# Global variables ---


# System variables +++

declare -a _CMDS
declare -A _CMD_OPTS
declare -A _CMD_HINT
declare -A _CMD_FUNC

# System variables ---


# Functions +++

function usc_pink()
{
    local _ink_head='\033[1;37;46m'
    local _ink_proc='\033[1;37;44m'
    local _ink_warn='\033[1;37;43m'
    local _ink_fail='\033[1;37;41m'
    local _ink_succ='\033[1;37;42m'
    local _ink_wait='\033[1;90;107m'
    local _ink_reset='\033[0m'

    local _pink_type="${1-}"
    local _pink_text="${*:2}"


    case "${_pink_type}" in
        "header")
            echo -e "${_ink_head} ${_pink_text} ${_ink_reset}"
            ;;
        "proceed")
            echo -e "${_ink_proc} Proceed: ${_pink_text} ${_ink_reset}"
            ;;
        "warning")
            echo -e "${_ink_warn} Warning: ${_pink_text} ${_ink_reset}"
            ;;
        "failure")
            echo -e "${_ink_fail} Failure: ${_pink_text} ${_ink_reset}\n"
            ;;
        "success")
            echo -e "${_ink_succ} Success: ${_pink_text} ${_ink_reset}\n"
            ;;
        "pause")
            echo -e "${_ink_wait} Press Enter to continue... ${_ink_reset}"
            read -rs
            ;;
        *)
            echo "${*}"
            ;;
    esac
}

function usc_flowcon()
{
    local _flow_func="${1-:}"
    local _flow_desc="${*:2}"

    usc_pink "proceed" "${_flow_desc}"
    eval "${_flow_func}" &&
        usc_pink "success" "${_flow_desc}" ||
        usc_pink "failure" "${_flow_func}"
}

_CMDS+=("help")
_CMD_OPTS["help"]="[<command>]"
_CMD_HINT["help"]="Print help message [for command]"
_CMD_FUNC["help"]="usc_help"
function usc_help()
{
    local _help_cmd="${*}"

    if [[ -v _CMD_FUNC["${_help_cmd}"] ]]
    then
        echo "${_CMD_HINT["${_help_cmd}"]}"
        echo ""
        echo "\$ usc ${_help_cmd} ${_CMD_OPTS["${_help_cmd}"]}"
    else
        if [[ -n "${_help_cmd}" ]]
        then
            usc_pink "failure" "No such command: \"${_help_cmd}\""
        fi
        usc_pink "header" "Universal Scripts Collection (USC)"
        echo ""
        echo "Usage:"
        echo "\$ usc <command> [<arguments>]"
        echo ""
        echo "Supported commands:"
        for _help_cmd in "${_CMDS[@]}"
        do
            printf "  %-44s %s\n" "${_help_cmd} ${_CMD_OPTS["${_help_cmd}"]}" "${_CMD_HINT["${_help_cmd}"]}"
        done
        echo ""
    fi
}

# Functions ---


# Main +++

_LIBUSC_PLUGINS_ARRAY=($(find "${_LIBUSC}" -name "*.sh" -type f))
for _LIBUSC_PLUGIN in "${_LIBUSC_PLUGINS_ARRAY[@]}"
do
    source "${_LIBUSC_PLUGIN}"
done

_CMDS=($(
    for _CMD_NAME in "${_CMDS[@]}"
    do
        echo "${_CMD_NAME}"
    done | sort
))


_USC_CMD="${1-"help"}"
_USC_ARGS=("${@:2}")


if [[ -v _CMD_FUNC["${_USC_CMD}"] ]]
then
    eval "${_CMD_FUNC["${_USC_CMD}"]} ${_USC_ARGS[@]@Q}"
else
    usc_pink "failure" "No such command: \"${_USC_CMD}\""
fi

# Main ---
