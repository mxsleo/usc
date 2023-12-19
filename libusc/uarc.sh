#!/usr/bin/env bash

set -uo pipefail
if [[ -n "${DEBUG-}" ]]; then set -ex; fi


# Functions +++

_CMDS+=("uarc-tgz")
_CMD_OPTS["uarc-tgz"]="<archive> <files>"
_CMD_HINT["uarc-tgz"]="Pack files into archive (.tar.gz, .tar.bz2, .tar.xz, .zip, .rar, .7z)"
_CMD_FUNC["uarc-tgz"]="uarc_tgz"
function uarc_tgz()
{
    local _arc_name="${1-}"
    local _arc_files="${@:2}"


    if [[ -f "${_arc_name}" ]]
    then
        usc_pink "failure" "Conflicting output. Aborted"
        return
    fi

    if [[ "${_arc_name}" == *".tar.gz" ]]
    then
        usc_flowcon "tar --create --gzip --verbose --file ${_arc_name} ${_arc_files}" "Zip files: \"${_arc_files}\" -> \"${_arc_name}\""
    elif [[ "${_arc_name}" == *".tar.bz2" ]]
    then
        usc_flowcon "tar --create --bzip2 --verbose --file ${_arc_name} ${_arc_files}" "Zip files: \"${_arc_files}\" -> \"${_arc_name}\""
    elif [[ "${_arc_name}" == *".tar.xz" ]]
    then
        usc_flowcon "tar --create --xz --verbose --file ${_arc_name} ${_arc_files}" "Zip files: \"${_arc_files}\" -> \"${_arc_name}\""
    elif [[ "${_arc_name}" == *".zip" ]]
    then
        usc_flowcon "zip -r -9 ${_arc_name} ${_arc_files}" "Zip files: \"${_arc_files}\" -> \"${_arc_name}\""
    elif [[ "${_arc_name}" == *".rar" ]] && [[ "$(command -v rar)" ]]
    then
        usc_flowcon "rar -r a -m5 ${_arc_name} ${_arc_files}" "Zip files: \"${_arc_files}\" -> \"${_arc_name}\""
    elif [[ "${_arc_name}" == *".7z" ]]
    then
        usc_flowcon "7z a -t7z -mmt$(nproc --all) -mx9 ${_arc_name} ${_arc_files}" "Zip files: \"${_arc_files}\" -> \"${_arc_name}\""
    else
        usc_pink "failure" "Unknown extension. Aborted"
        return
    fi
}

_CMDS+=("uarc-untgz")
_CMD_OPTS["uarc-untgz"]="<archive> [<directory>]"
_CMD_HINT["uarc-untgz"]="Unpack archive (.tar.gz, .tar.bz2, .tar.xz, .zip, .rar, .7z) [to directory]"
_CMD_FUNC["uarc-untgz"]="uarc_untgz"
function uarc_untgz()
{
    local _arc_name="${1-}"
    local _arc_dir="${2-"${_arc_name%%.*}"}"

    if [[ -z "${_arc_dir}" ]]
    then
        _arc_dir="unpacked"
    fi


    if [[ -d "${_arc_dir}" ]]
    then
        local _arc_dir_pfix=1
        local _arc_dir_new="${_arc_dir}_${_arc_dir_pfix}"


        usc_pink "warning" "The same directory already exists. Postfix added"

        while [[ -d "${_arc_dir_new}" ]]
        do
            ((_arc_dir_pfix+=1))
            _arc_dir_new="${_arc_dir}_${_arc_dir_pfix}"
        done

        _arc_dir="${_arc_dir_new}"
    fi
    mkdir "${_arc_dir}"

    if [[ "${_arc_name}" == *".tar.gz" ]]
    then
        usc_flowcon "tar --extract --gzip --verbose --file ${_arc_name} --directory ${_arc_dir}" "Unip files: \"${_arc_name}\" -> \"${_arc_dir}\""
    elif [[ "${_arc_name}" == *".tar.bz2" ]]
    then
        usc_flowcon "tar --extract --bzip2 --verbose --file ${_arc_name} --directory ${_arc_dir}" "Unip files: \"${_arc_name}\" -> \"${_arc_dir}\""
    elif [[ "${_arc_name}" == *".tar.xz" ]]
    then
        usc_flowcon "tar --extract --xz --verbose --file ${_arc_name} --directory ${_arc_dir}" "Unip files: \"${_arc_name}\" -> \"${_arc_dir}\""
    elif [[ "${_arc_name}" == *".zip" ]]
    then
        usc_flowcon "unzip ${_arc_name} -d ${_arc_dir}" "Unip files: \"${_arc_name}\" -> \"${_arc_dir}\""
    elif [[ "${_arc_name}" == *".rar" ]]
    then
        usc_flowcon "unrar x ${_arc_name} ${_arc_dir}" "Unip files: \"${_arc_name}\" -> \"${_arc_dir}\""
    elif [[ "${_arc_name}" == *".7z" ]]
    then
        usc_flowcon "7z x ${_arc_name} -o${_arc_dir}" "Unip files: \"${_arc_name}\" -> \"${_arc_dir}\""
    else
        usc_pink "failure" "Unknown extension. Aborted"
        return
    fi
}

# Functions ---
