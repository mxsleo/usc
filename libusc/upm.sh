#!/usr/bin/env bash

set -uo pipefail
if [[ -n "${DEBUG-}" ]]; then set -ex; fi


# Functions +++

function upm_ota_pip()
{
    pip-review --user --no-cache-dir --auto
    pip cache purge
}

function upm_ota_vim()
{
    local _vim_runtime="${HOME}/.vim_runtime"


    local _back_dir="$(pwd)"
    cd "${_vim_runtime}"

    git reset --hard
    git clean -d --force
    git pull --rebase
    python update_plugins.py

    cd "${_back_dir}"
}

function upm_ota_omz()
{
    local _ZSH="${ZSH-"${HOME}/.oh-my-zsh"}"

    zsh "${_ZSH}/tools/upgrade.sh"
}

function upm_ota_usc()
{
    local _back_dir="$(pwd)"
    cd "$(dirname "${0}")"

    git pull --verbose

    cd "${_back_dir}"
}

_CMDS+=("upgrade")
_CMD_OPTS["upgrade"]=""
_CMD_HINT["upgrade"]="Perform complete system upgrade"
_CMD_FUNC["upgrade"]="upm_ota"
function upm_ota()
{
    usc_flowcon "upm_reindex" "Refresh packages index"
    usc_flowcon "upm_upgrade" "Upgrade packages"
    usc_flowcon "upm_autorem" "Remove old packages"
    usc_flowcon "upm_autoclr" "Clear packages cache"
    usc_flowcon "upm_ota_pip" "Upgrade python packages"
    usc_flowcon "upm_ota_vim" "Upgrade vimrc"
    usc_flowcon "upm_ota_omz" "Upgrade OMZ"
    usc_flowcon "upm_ota_usc" "Upgrade USC"
}

_CMDS+=("pkg-install")
_CMD_OPTS["pkg-install"]="<packages>"
_CMD_HINT["pkg-install"]="Install packages"
_CMD_FUNC["pkg-install"]="upm_pkg_install"
function upm_pkg_install()
{
    usc_flowcon "upm_reindex"       "Refresh packages index"
    usc_flowcon "upm_install ${*}"  "Install packages: \"${*}\""
    usc_flowcon "upm_autoclr"       "Clear packages cache"
}

_CMDS+=("pkg-purge")
_CMD_OPTS["pkg-purge"]="<packages>"
_CMD_HINT["pkg-purge"]="Remove packages with dependencies"
_CMD_FUNC["pkg-purge"]="upm_pkg_purge"
function upm_pkg_purge()
{
    usc_flowcon "upm_delpkgs ${*}"  "Remove packages: \"${*}\""
    usc_flowcon "upm_autorem"       "Remove old packages"
    usc_flowcon "upm_autoclr"       "Clear packages cache"
}

_CMDS+=("pip-install")
_CMD_OPTS["pip-install"]="<packages>"
_CMD_HINT["pip-install"]="Install pip packages"
_CMD_FUNC["pip-install"]="upm_pip_install"
function upm_pip_install()
{
    pip install --user --no-cache-dir ${@}
    pip cache purge
}

_CMDS+=("pip-purge")
_CMD_OPTS["pip-purge"]="<packages>"
_CMD_HINT["pip-purge"]="Remove pip packages with dependencies"
_CMD_FUNC["pip-purge"]="upm_pip_purge"
function upm_pip_purge()
{
    pip-autoremove ${@}
    pip cache purge
}

# Functions ---
