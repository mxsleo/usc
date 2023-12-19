#!/usr/bin/env bash

set -uo pipefail
if [[ -n "${DEBUG-}" ]]; then set -ex; fi


# Functions +++

_CMDS+=("clear")
_CMD_OPTS["clear"]=""
_CMD_HINT["clear"]="Clear history and screen"
_CMD_FUNC["clear"]="systools_clear"
function systools_clear()
{
    local _histfile="${HISTFILE-"${HOME}/.zsh_history"}"


    if [[ -f "${_histfile}" ]]
    then
        rm --force ${_histfile}
    else
        usc_pink "warning" "History file has already been removed"
        echo ""
    fi

    usc_pink "pause"
    clear
}

_CMDS+=("hash")
_CMD_OPTS["hash"]="<files>"
_CMD_HINT["hash"]="Hash files recursively"
_CMD_FUNC["hash"]="systools_hash"
function systools_hash()
{
    find "${@}" -type f -print0 | sort --zero-terminated | xargs --null md5sum | md5sum | cut -d ' ' --fields=1
}

if [[ -d /opt/zapret ]]
then
    _CMDS+=("zapret-start")
    _CMD_OPTS["zapret-start"]=""
    _CMD_HINT["zapret-start"]="Start Zapret"
    _CMD_FUNC["zapret-start"]="systools_zapret_start"
    function systools_zapret_start()
    {
        if [[ "$(sudo systemctl is-active zapret)" == "inactive" ]]
        then
            sudo systemctl start zapret
        elif [[ "$(sudo systemctl is-active zapret)" == "active" ]]
        then
            usc_pink "warning" "Zapret is already started"
            echo ""
        else
            usc_pink "failure" "Zapret unit is not available"
        fi
    }

    _CMDS+=("zapret-stop")
    _CMD_OPTS["zapret-stop"]=""
    _CMD_HINT["zapret-stop"]="Stop Zapret"
    _CMD_FUNC["zapret-stop"]="systools_zapret_stop"
    function systools_zapret_stop()
    {
        if [[ "$(sudo systemctl is-active zapret)" == "active" ]]
        then
            sudo systemctl stop zapret
        elif [[ "$(sudo systemctl is-active zapret)" == "inactive" ]]
        then
            usc_pink "warning" "Zapret is already stopped"
            echo ""
        else
            usc_pink "failure" "Zapret unit is not available"
        fi
    }
fi

_CMDS+=("wgetsite")
_CMD_OPTS["wgetsite"]="<url> [slow]"
_CMD_HINT["wgetsite"]="Download site"
_CMD_FUNC["wgetsite"]="systools_wgetsite"
function systools_wgetsite()
{
    local _site_link="${1-}"
    local _wget_speed="${2-}"

    if [[ "${_wget_speed}" == "slow" ]]
    then
        wget -r -k -l 7 -p -E -nc --limit-rate=30k -w 30 --random-wait "${_site_link}"
    else
        wget -r -k -l 7 -p -E -nc "${_site_link}"
    fi
}

# Functions ---
