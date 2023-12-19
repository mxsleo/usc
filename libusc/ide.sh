#!/usr/bin/env bash

set -uo pipefail
if [[ -n "${DEBUG-}" ]]; then set -ex; fi


# Functions +++

_CMDS+=("ide-new")
_CMD_OPTS["ide-new"]="\"[<directory>]\""
_CMD_HINT["ide-new"]="Create new project directory"
_CMD_FUNC["ide-new"]="ide_new"
function ide_new()
{
    # TODO: Review + main.cpp src/*.cpp + include/?
	# https://stackoverflow.com/questions/1079832/how-can-i-configure-my-makefile-for-debug-and-release-builds

    local _ide_makefile="$(
        cat <<- "EOF"
		CC := g++
		CFLAGS := -Wall -Wextra -Wpedantic -std=c++23
		CFLAGS_RELEASE := $(CFLAGS) -Ofast
		CFLAGS_DEBUG := $(CFLAGS) -ggdb3
		LDFLAGS :=


		##################################################
		SOURCES := main.cpp
		HEADERS :=
		EXECUTABLE := Untitled_Project
		default: debug
		##################################################


		DIR_OBJ := obj
		OBJECTS := $(addprefix $(DIR_OBJ)/, $(SOURCES:.cpp=.o))
		OBJECTS_DEBUG := $(OBJECTS:.o=.debug.o)
		EXECUTABLE_DEBUG := $(addsuffix _debug, $(EXECUTABLE))

		REM := rm --force
		MKDIR := mkdir --parents
		ifeq ($(OS), Windows_NT)
		EXECUTABLE := $(addsuffix .exe, $(EXECUTABLE))
		    EXECUTABLE_DEBUG := $(addsuffix .exe, $(EXECUTABLE_DEBUG))
		    ifneq ($(shell uname -o), Msys)
		        REM := del
		        MKDIR := mkdir
		    endif
		endif


		.PHONY: all debug clean

		.SUFFIXES: .cpp .o



		$(EXECUTABLE): $(OBJECTS)
		    $(CC) $(LDFLAGS) $(OBJECTS) -o $@

		$(DIR_OBJ)/%.o: %.cpp | $(HEADERS) $(DIR_OBJ)
		    $(CC) $(CFLAGS_RELEASE) -c $< -o $@


		$(EXECUTABLE_DEBUG): $(OBJECTS_DEBUG)
		    $(CC) $(LDFLAGS) $(OBJECTS_DEBUG) -o $@

		$(DIR_OBJ)/%.debug.o: %.cpp | $(HEADERS) $(DIR_OBJ)
		    $(CC) $(CFLAGS_DEBUG) -c $< -o $@



		all: release debug

		release: $(EXECUTABLE)

		debug: $(EXECUTABLE_DEBUG)

		clean:
		    $(REM) $(OBJECTS) $(OBJECTS_DEBUG) $(EXECUTABLE) $(EXECUTABLE_DEBUG)
		EOF
    )"

    local _ide_maincpp="$(
        cat <<- "EOF"
		#include <iostream>

		#if defined _WIN32
		#include <windows.h>
		#endif

		using std::cin;
		using std::cout;

		int main()
		{
		#if defined _WIN32
		    if (GetConsoleCP() != CP_UTF8)
		        SetConsoleCP(CP_UTF8);
		    if (GetConsoleOutputCP() != CP_UTF8)
		        SetConsoleOutputCP(CP_UTF8);
		#endif

		    std::ios_base::sync_with_stdio(false);
		    cin.tie(nullptr);

		    cout << "Hello, World!\n";
		    cout.flush();

		    return 0;
		}
		EOF
    )"

    local _ide_proj="${*-"Untitled Project"}"
    local _ide_exec="$(echo "${_ide_proj}" | sed "s| |_|g")"


    usc_pink "proceed" "Creating project: \"${_ide_proj}\""

    if [[ -d "${_ide_proj}" ]]
    then
        local _ide_proj_pfix=1
        local _ide_proj_new="${_ide_proj} ${_ide_proj_pfix}"


        usc_pink "warning" "The same directory already exists. Postfix added"

        while [[ -d "${_ide_proj_new}" ]]
        do
            ((_ide_proj_pfix+=1))
            _ide_proj_new="${_ide_proj} ${_ide_proj_pfix}"
        done

        _ide_proj="${_ide_proj_new}"
    fi

    mkdir --parents "${_ide_proj}"
    mkdir --parents "${_ide_proj}/obj"

    echo "${_ide_makefile}" | tee --append "${_ide_proj}/Makefile" > /dev/null
    sed -i "s|^EXECUTABLE := .*|EXECUTABLE := ${_ide_exec}|" "${_ide_proj}/Makefile"
    # Avoid Makefile imperfection
    sed -i "s|    |\t|g" "${_ide_proj}/Makefile"
    echo "${_ide_maincpp}" | tee --append "${_ide_proj}/main.cpp" > /dev/null

    usc_pink "success" "Created project: \"${_ide_proj}\""
}

_CMDS+=("ide-build")
_CMD_OPTS["ide-build"]="\"<directory>\" [<target>]"
_CMD_HINT["ide-build"]="Build project directory"
_CMD_FUNC["ide-build"]="ide_build"
function ide_build()
{
    # TODO: getopts

    local _ide_proj="${1-"Untitled Project"}"
    local _build_type="${2-"debug"}"
    local _ide_exec="$(echo "${_ide_proj}" | sed "s| |_|g")"

    if [[ -d "${_ide_proj}" ]]
    then
        local _back_dir="$(pwd)"
        cd "${_ide_proj}"

        devel_make "${_build_type}"
        _ide_exec="$(find . -name "${_ide_exec}*" -type f | head -n 1)"
        if [[ -n "${_ide_exec}" ]]
        then
            usc_flowcon "\"${_ide_exec}\"" "Execute binary"
        fi

        cd "${_back_dir}"
    else
        usc_pink "failure" "Failed to build: \"${_ide_proj}\""
    fi
}

_CMDS+=("ide-clean")
_CMD_OPTS["ide-clean"]="\"<directory>\""
_CMD_HINT["ide-clean"]="Clean project directory"
_CMD_FUNC["ide-clean"]="ide_clean"
function ide_clean()
{
    ide_build "${*}" clean
}

# Functions ---
