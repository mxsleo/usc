# usc
Universal Scripts Collection - Automate daily *nix routines in one click!

## Features
- [Coming soon] Easy installation
- Can be installed anywhere
- User-friendly colorful output
- Good standard functionality:
    - Universal package updater, supporting:
        - Arch Linux
        - Arch Linux w/yay
        - MSYS2
        - Termux
        - Debian
        - Ubuntu
    - Universal package manager wrapper
    - PIP wrapper
    - [Coming soon] Universal archiver
    - Recursive file hasher
    - [Coming soon] Tiny FFmpeg wrapper
    - Site downloader
    - ZSH histroy remover
    - Makefile + main.cpp generator and builder
    - Tiny Make wrapper
    - Tiny G++ wrapper
    - Tiny Jupyter Notebook wrapper
- Simple plugin engine:
    - Easy plugin development:
        - Add new functionality in four strings
        - Automated help generation
        - Optional execution control function
    - Safe arguments passing
    - Debugging support

## Requirements
- Bash
- Zsh with OMZ
- Git
- Vim
- Amix vimrc
- Wget
- FFmpeg
- Make
- G++
- Rust
- Python
- PIP
- pip-review
- pip-autoremove
- Jupyter Notebook
- Compression
    - tar
    - gzip
    - bzip2
    - xz
    - zip
    - unzip
    - 7z
    - rar
    - unrar

Optional:
- Zapret

[Coming soon] Bash only, everything else is optional

Note: in the case of MSYS2, Rust should be installed via the official script
```shell
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
and FFmpeg should be installed via WinGet
```shell
$ PATH=$PATH:/c/Users/${USERNAME}/AppData/Local/Microsoft/WindowsApps winget install ffmpeg
```

## Installation
For example, we will use ~/.local/bin/usc as a target directory:
```shell
$ mkdir -p ~/.local/bin
$ git clone --depth=1 https://github.com/mxsleo/usc ~/.local/bin/usc
```
Do not forget to mark .sh files as executables:
```shell
$ chmod +x ~/.local/bin/usc/usc.sh
$ chmod +x ~/.local/bin/usc/libusc/*.sh
```
If you have Zsh, add an alias to usc.sh to .zshrc:
```shell
$ echo -e "\nalias usc=\"\${HOME}/.local/bin/usc/usc.sh\"" >> ~/.zshrc
```
Or else add the alias to your sh rc file (i.e. to ~/.bashrc)

## Usage
```shell
$ usc <command> [<arguments>]
```
To print a help message [for a specified command], use
```shell
$ usc help [<command>]
```

## Plugin development
To add a new plugin, you should create a new .sh file inside libusc. For example, if USC is installed to ~/.local/bin/usc:
```shell
$ touch ~/.local/bin/usc/libusc/hellouser.sh
```
Fill it with a standard template:
```shell
#!/usr/bin/env bash

set -uo pipefail
if [[ -n "${DEBUG-}" ]]; then set -ex; fi


# Functions +++

_CMDS+=("")
_CMD_OPTS[""]=""
_CMD_HINT[""]=""
_CMD_FUNC[""]=""
function ()
{
    :
}

# Functions ---

```
Let's name our new command hello, our function - hello_user, and let it greet the user or a specified guy
```shell
...
_CMDS+=("hello")
_CMD_OPTS["hello"]="[guy_name]"
_CMD_HINT["hello"]="Greet the user or another guy"
_CMD_FUNC["hello"]="hello_user"
function hello_user()
{
    local _hello_name="${*-"$(whoami)"}"

    usc_pink "header" "Hello, ${_hello_name}!"
}
...
```
And now we can use our new functionality!
```shell
$ usc hello
Hello, mxsleo!
$ usc hello Max
Hello, Max!
```
And it will also be displayed when calling the help function!
```shell
$ usc help
...
Supported commands:
...
  usc hello [guy_name]                         Greet the user or another guy
...
$ usc help hello
Greet the user or another guy

\$ usc hello [guy_name]
```

## Supporting a new platform
To add support for a new platform, you should create a new upm_load_* function at libusc/upm_loader.sh before upm_load_unknown(). You can take upm_load_unknown() as an example. Your function should specify six other functions: upm_reindex(), upm_upgrade(), upm_autorem(), upm_autoclr(), upm_install() and upm_delpkgs()
- upm_reindex() should update package indexes of all present package managers (i.e. sudo apt update) or be a stub
- upm_upgrade() should upgrade packages with all present package managers (i.e. sudo apt upgrade)
- upm_autorem() should autoremove orphan packages with all present package managers (i.e. sudo apt autoremove)
- upm_autoclr() should clear packages cache of all present package managers (i.e. sudo apt autoclean) or be a stub
- upm_install() takes a list of packages to install as an argument (i.e. sudo apt install ${@})
- upm_delpkgs() takes a list of packages to remove as an argument (i.e. sudo apt purge ${@})

After you created the upm_load_* function, you should add it's call to a case inside the upm_load() function. For example, Ubuntu has /etc/os-release file with the following string:
```shell
NAME="Ubuntu"
```
so I've added the following case, whele upm_load_ubuntu is the Ubuntu upm_load_* function:
```shell
...
        "Ubuntu")
            upm_load_ubuntu
            ;;
        *)
...
```
And now your new platform is fully supported! You can use usc upgrade and pkg-* functions now!
