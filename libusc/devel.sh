#!/usr/bin/env bash

set -uo pipefail
if [[ -n "${DEBUG-}" ]]; then set -ex; fi


# Functions +++

_CMDS+=("make")
_CMD_OPTS["make"]="<targets>"
_CMD_HINT["make"]="Multithread Make wrapper"
_CMD_FUNC["make"]="devel_make"
function devel_make()
{
    usc_pink "proceed" "Make \"${@}\""
    make ${@} --jobs $(nproc --all)
    if [[ $? -eq 0 ]]
    then
        usc_pink "success" "Make \"${@}\""
    else
        usc_pink "failure" "make ${@} --jobs \$(nproc --all)"
    fi
}

_CMDS+=("gpp")
_CMD_OPTS["gpp"]="\"<sources>\" <output> [fast|debug]"
_CMD_HINT["gpp"]="G++ presets wrapper"
_CMD_FUNC["gpp"]="devel_gpp"
function devel_gpp()
{
    local _gpp_src="${1-}"
    local _gpp_tgt="${2-}"
    local _gpp_opt="${3-}"

    case "${_gpp_opt}" in
        "fast")
            usc_flowcon "g++ ${_gpp_src} -Ofast -std=c++20 -Wall -o ${_gpp_tgt}" "Build with g++ (Ofast): \"${_gpp_src}\"->\"${_gpp_tgt}\""
            ;;
        "debug")
            usc_flowcon "g++ ${_gpp_src} -ggdb3 -std=c++20 -Wall -o ${_gpp_tgt}" "Build with g++ (ggdb3): \"${_gpp_src}\"->\"${_gpp_tgt}\""
            ;;
        *)
            usc_flowcon "g++ ${_gpp_src} -O2 -std=c++20 -Wall -o ${_gpp_tgt}" "Build with g++: \"${_gpp_src}\"->\"${_gpp_tgt}\""
            ;;
    esac
}

_CMDS+=("notebook")
_CMD_OPTS["notebook"]=""
_CMD_HINT["notebook"]="Jupyter Notebook wrapper"
_CMD_FUNC["notebook"]="devel_notebook"
function devel_notebook()
{
    local _notebook_dir="${HOME}/jupyter_notebook"


    if [[ ! -d "${_notebook_dir}" ]]
    then
        mkdir --parents "${_notebook_dir}"
    fi

    jupyter notebook --notebook-dir="${_notebook_dir}" >/dev/null 2>&1 &
}

# Functions ---
