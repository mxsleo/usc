#!/usr/bin/env bash

set -uo pipefail
if [[ -n "${DEBUG-}" ]]; then set -ex; fi


# Functions +++

function upm_load_arch_aur()
{
    function upm_reindex()
    {
        sudo pacman --sync --refresh -y
    }
    function upm_upgrade()
    {
        sudo pacman --sync --sysupgrade
        yay --sync --aur --sysupgrade --devel --answerdiff None --removemake --cleanafter --batchinstall --sudoloop
    }
    function upm_autorem()
    {
        local _old_pkgs=($(sudo pacman --query --unrequired --deps --quiet))


        if [[ ${#_old_pkgs[@]} -gt 0 ]]
        then
            sudo pacman --remove --nosave --recursive ${_old_pkgs[@]}
        else
            usc_pink "warning" "No old packages found"
        fi

        yay -Y --clean
    }
    function upm_autoclr()
    {
        sudo pacman --sync --clean -c
    }
    function upm_install()
    {
        case "${1-}" in
            "aur")
                yay --sync --aur --answerdiff None --removemake --cleanafter --batchinstall --sudoloop ${@:2}
                ;;
            *)
                sudo pacman --sync --needed ${@}
                ;;
        esac
    }
    function upm_delpkgs()
    {
        case "${1-}" in
            "aur")
                yay --remove --aur --nosave --recursive --sudoloop ${@:2}
                ;;
            *)
                sudo pacman --remove --nosave --recursive ${@}
                ;;
        esac
    }
}

function upm_load_arch()
{
    function upm_reindex()
    {
        sudo pacman --sync --refresh -y
    }
    function upm_upgrade()
    {
        sudo pacman --sync --sysupgrade
    }
    function upm_autorem()
    {
        local _old_pkgs=($(sudo pacman --query --unrequired --deps --quiet))

        if [[ ${#_old_pkgs[@]} -gt 0 ]]
        then
            sudo pacman --remove --nosave --recursive ${_old_pkgs[@]}
        else
            usc_pink "warning" "No old packages found"
        fi
    }
    function upm_autoclr()
    {
        sudo pacman --sync --clean -c
    }
    function upm_install()
    {
        sudo pacman --sync --needed ${@}
    }
    function upm_delpkgs()
    {
        sudo pacman --remove --nosave --recursive ${@}
    }
}

function upm_load_msys2()
{
    function upm_reindex()
    {
        pacman --sync --refresh -y
    }
    function upm_upgrade_legacy()
    {
        winget upgrade ffmpeg
        rustup update
    }
    function upm_upgrade()
    {
        # Avoid pip bug
        pacman --sync --sysupgrade || pacman --sync --sysupgrade --overwrite '*'

        usc_flowcon "upm_upgrade_legacy" "Upgrade legacy packages"
    }
    function upm_autorem()
    {
        local _old_pkgs=($(pacman --query --unrequired --deps --quiet))

        if [[ ${#_old_pkgs[@]} -gt 0 ]]
        then
            pacman --remove --nosave --recursive ${_old_pkgs[@]}
        else
            usc_pink "warning" "No old packages found"
        fi
    }
    function upm_autoclr()
    {
        pacman --sync --clean -c
    }
    function upm_install()
    {
        pacman --sync --needed ${@}
    }
    function upm_delpkgs()
    {
        pacman --remove --nosave --recursive ${@}
    }
}

function upm_load_termux()
{
    function upm_reindex()
    {
        pkg update
    }
    function upm_upgrade()
    {
        pkg upgrade --yes
    }
    function upm_autorem()
    {
        apt autoremove --yes
    }
    function upm_autoclr()
    {
        pkg clean
    }
    function upm_install()
    {
        pkg install ${@}
    }
    function upm_delpkgs()
    {
        pkg uninstall ${*}
    }
}

function upm_load_debian()
{
    function upm_reindex()
    {
        sudo apt update
    }
    function upm_upgrade()
    {
        sudo apt full-upgrade --yes
        if [[ "$(command -v flatpak)" ]]
        then
            flatpak update
        fi
    }
    function upm_autorem()
    {
        sudo apt autoremove --yes
    }
    function upm_autoclr()
    {
        sudo apt autoclean
    }
    function upm_install()
    {
        sudo apt install ${@}
    }
    function upm_delpkgs()
    {
        sudo apt purge ${@}
    }
}

function upm_load_ubuntu()
{
    function upm_reindex()
    {
        sudo apt update
        sudo pkcon refresh
    }
    function upm_upgrade()
    {
        sudo apt full-upgrade --yes
        sudo pkcon update
        sudo snap refresh
    }
    function upm_autorem()
    {
        sudo apt autoremove --yes
    }
    function upm_autoclr()
    {
        sudo apt autoclean
    }
    function upm_install()
    {
        sudo apt install ${@}
    }
    function upm_delpkgs()
    {
        sudo apt purge ${@}
    }
}

function upm_load_unknown()
{
    function upm_reindex() { usc_pink "warning" "upm_reindex(): stub"; }
    function upm_upgrade() { usc_pink "warning" "upm_upgrade(): stub"; }
    function upm_autorem() { usc_pink "warning" "upm_autorem(): stub"; }
    function upm_autoclr() { usc_pink "warning" "upm_autoclr(): stub"; }
    function upm_install() { usc_pink "warning" "upm_install(): stub"; }
    function upm_delpkgs() { usc_pink "warning" "upm_delpkgs(): stub"; }
}

function upm_load()
{
    local _upm_os=""


    if [[ -f /etc/os-release ]]
    then
        _upm_os="$(cat /etc/os-release | grep "^NAME" | sed "s|.*=||" | sed "s|\"||g")"
    else
        _upm_os="$(uname -o)"
    fi

    case "${_upm_os}" in
        "Arch Linux")
            if [[ "$(command -v yay)" ]]
            then
                upm_load_arch_aur
            else
                upm_load_arch
            fi
            ;;
        "MSYS2")
            upm_load_msys2
            ;;
        "Android")
            upm_load_termux
            ;;
        "Debian GNU/Linux")
            upm_load_debian
            ;;
        "Ubuntu")
            upm_load_ubuntu
            ;;
        *)
            upm_load_unknown
            ;;
    esac
}

# Functions ---


# Main +++

upm_load

# Main ---
