#!/usr/bin/env bash

VERSION='1.0.0'

#------------------------------------------------------------------------------#
#
# MIT License
#
# Copyright (c) 2022 Tommy Miland
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#------------------------------------------------------------------------------#
## Uncomment for debugging purpose
#set -o errexit
#set -o pipefail
#set -o nounset
#set -o xtrace
# Include functions
# Get script filename
self=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_FILENAME=$(basename "$self")
SCRIPT_NAME=${SCRIPT_FILENAME}
# Info
SCRIPT_AUTHOR="tmiland"
SCRIPT_DESCRIPTION="A basic template for bash/shell scripts"
SCRIPT_REPO_URL="https://github.com/tmiland/template.sh"
# Icons
ARROW='➜'
DONE='✔'
INFO='ℹ'
PROGRESS='➟'
WARNING='⚠'
ERROR='✗'
FATAL='✘'

# scolors - Color constants
# canonical source http://github.com/swelljoe/scolors
# do we have tput?
if which 'tput' > /dev/null; then
  # do we have a terminal?
  if [ -t 1 ]; then
    # does the terminal have colors?
    ncolors=$(tput colors)
    if [ "$ncolors" -ge 8 ]; then
      RED=$(tput setaf 1)
      GREEN=$(tput setaf 2)
      YELLOW=$(tput setaf 3)
      BLUE=$(tput setaf 4)
      BBLUE=$(tput setaf 153)
      MAGENTA=$(tput setaf 5)
      CYAN=$(tput setaf 6)
      WHITE=$(tput setaf 7)
      # Background
      RED_BG=$(tput setab 1)
      GREEN_BG=$(tput setab 2)
      YELLOW_BG=$(tput setab 3)
      BLUE_BG=$(tput setab 4)
      MAGENTA_BG=$(tput setab 5)
      CYAN_BG=$(tput setab 6)
      WHITE_BG=$(tput setab 7)

      BOLD=$(tput bold)
      UNDERLINE=$(tput smul) # Many terminals don't support this
      NORMAL=$(tput sgr0)
      # Color functions
      red() { printf "%s\\n" "${RED}${1}${NORMAL}"; }
      green() { printf "%s\\n" "${GREEN}${1}${NORMAL}"; }
      yellow() { printf "%s\\n" "${YELLOW}${1}${NORMAL}"; }
      blue() { printf "%s\\n" "${BLUE}${1}${NORMAL}"; }
      bblue() { printf "%s\\n" "${BBLUE}${1}${NORMAL}"; }
      magenta() { printf "%s\\n" "${MAGENTA}${1}${NORMAL}"; }
      cyan() { printf "%s\\n" "${CYAN}${1}${NORMAL}"; }
      white() { printf "%s\\n" "${WHITE}${1}${NORMAL}"; }
      # bg color functions
      red_bg() { printf "%s\\n" "${RED_BG}${1}${NORMAL}"; }
      green_bg() { printf "%s\\n" "${GREEN_BG}${1}${NORMAL}"; }
      yellow_bg() { printf "%s\\n" "${YELLOW_BG}${1}${NORMAL}"; }
      blue_bg() { printf "%s\\n" "${BLUE_BG}${1}${NORMAL}"; }
      magenta_bg() { printf "%s\\n" "${MAGENTA_BG}${1}${NORMAL}"; }
      cyan_bg() { printf "%s\\n" "${CYAN_BG}${1}${NORMAL}"; }
      white_bg() { printf "%s\\n" "${WHITE_BG}${1}${NORMAL}"; }
      # bold/undeline functions
      bold() { printf "%s\\n" "${BOLD}${1}${NORMAL}"; }
      underline() { printf "%s\\n" "${UNDERLINE}${1}${NORMAL}"; }
    fi
  fi
else
  printf "tput not found, colorized output disabled."
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  BBLUE=''
  MAGENTA=''
  CYAN=''
  WHITE=''
  RED_BG=''
  GREEN_BG=''
  YELLOW_BG=''
  BLUE_BG=''
  MAGENTA_BG=''
  CYAN_BG=''
  WHITE_BG=''

  BOLD=''
  UNDERLINE=''
  NORMAL=''
fi

message() {
  if [ -z "${1}" ] || [ -z "${2}" ]; then
    return
  fi
  # Credit: deb-get
  MESSAGE_TYPE=""
  MESSAGE=""
  MESSAGE_TYPE="${1}"
  MESSAGE="${2}"

  case ${MESSAGE_TYPE} in
    info)     printf "%s\\n" "  [${GREEN}${ARROW}${NORMAL}] ${MESSAGE}" ;;
    progress) printf "%s\\n" "  [${BLUE}${PROGRESS}${NORMAL}] ${MESSAGE}" ;;
    recommend)printf "%s\\n" "  [${CYAN}${INFO}${NORMAL}] ${MESSAGE}" ;;
    warn)     printf "%s\\n" "  [${YELLOW}${WARNING}${NORMAL}] WARNING! ${MESSAGE}" ;;
    error)    printf "%s\\n" "  [${RED}${ERROR}${NORMAL}] ERROR! ${MESSAGE}" >&2 ;;
    fatal)    printf "%s\\n" "  [${RED}${FATAL}${NORMAL}] FATAL! ${MESSAGE}" >&2
      exit 1 ;;
    *) printf "%s\\n" "  [?] UNKNOWN: ${MESSAGE}" ;;
  esac
}

if ((BASH_VERSINFO[0] < 4)); then
  message fatal "Sorry, you need bash 4.0 or newer to run $(basename "${0}")."
fi

if ! command -v lsb_release 1>/dev/null; then
  message fatal "lsb_release not detected. Quitting."
  message recommend "Install with 'apt install lsb-release' "

fi

# OS Detection
OS_ID=$(lsb_release --id --short)
OS_CODENAME=$(lsb_release --codename --short)
if [ -e /etc/os-release ]; then
  OS_RELEASE=/etc/os-release
elif [ -e /usr/lib/os-release ]; then
  OS_RELEASE=/usr/lib/os-release
else
  message fatal "os-release not found. Quitting"
fi

ID="$(grep "^ID=" ${OS_RELEASE} | cut -d'=' -f2)"

# Fallback to ID_LIKE if ID was not 'ubuntu' or 'debian'
if [ "${ID}" != ubuntu ] && [ "${ID}" != debian ]; then
  ID_LIKE="$(grep "^ID_LIKE=" ${OS_RELEASE} | cut -d'=' -f2 | cut -d \" -f 2)"

  if [[ " ${ID_LIKE} " =~ " ubuntu " ]]; then
    ID=ubuntu
  elif [[ " ${ID_LIKE} " =~ " debian " ]]; then
    ID=debian
  else
    message fatal "${OS_ID_PRETTY} ${OS_CODENAME^} is not supported because it is not derived from a supported Debian or Ubuntu release."
  fi
fi

CODENAME=$(grep "^UBUNTU_CODENAME=" ${OS_RELEASE} | cut -d'=' -f2)

if [ -z "${CODENAME}" ]; then
  CODENAME=$(grep "^DEBIAN_CODENAME=" ${OS_RELEASE} | cut -d'=' -f2)
fi

if [ -z "${CODENAME}" ]; then
  CODENAME=$(grep "^VERSION_CODENAME=" ${OS_RELEASE} | cut -d'=' -f2)
fi

# Debian 12+
if [ -z "${CODENAME}" ] && [ -e /etc/debian_version ]; then
  CODENAME=$(cut -d / -f 1 /etc/debian_version)
fi

case "${CODENAME}" in
  buster)   RELEASE="10" ;;
  bullseye) RELEASE="11" ;;
  bookworm) RELEASE="12" ;;
  sid)      RELEASE="unstable" ;;
  focal)    RELEASE="20.04" ;;
  jammy)    RELEASE="22.04" ;;
  kinetic)  RELEASE="22.10" ;;
  lunar)    RELEASE="23.04" ;;
  *) message error "${OS_ID_PRETTY} ${OS_CODENAME^} is not supported." ;;
esac

# Logo - Generated with: figlet -f slant "template.sh"
logo() {
  if [[ -n $(which figlet) ]]; then
    green "$(figlet -f slant "${SCRIPT_NAME}")"
  fi
}

help() {
  logo
  ## shellcheck disable=SC2046
  printf "Usage: %s %s [options]\\n" "${CYAN}" "${SCRIPT_NAME}${NORMAL}"
  printf "\\n"
  printf "%s\\n" "  If called without arguments, shows help."
  printf "\\n"
  printf "%s\\n" "  ${YELLOW}help    ${NORMAL}|-h|--help|-help      ${GREEN}display this help and exit${NORMAL}"
  printf "\\n"
  printf "%s\\n %s\\n" "  Script version: ${CYAN}${VERSION}${NORMAL}" " ${SCRIPT_DESCRIPTION}"
  printf "\\n"
  printf "%s\\n %s\\n" "Maintained by @${SCRIPT_AUTHOR}" "${SCRIPT_REPO_URL}"
  printf "\\n"
}

# if [[ ! $(which sudo) ]]; then
#   message error "Error: SUDO Not found! \n Please install sudo."
#   exit 1;
# fi
#
# sudo="sudo"

while [[ $# -gt 0 ]]; do
  case $1 in
    help|-h|--help|-help)
      help
      exit 0
      ;;
    *)
      printf "%s\\n\\n" "Unrecognized option: $1"
      help
      exit 0
      ;;
  esac
done

# Main script
main() {
  red "This is a colored test message"
  green "This is a colored test message"
  yellow "This is a colored test message"
  blue "This is a colored test message"
  bblue "This is a colored test message"
  magenta "This is a colored test message"
  cyan "This is a colored test message"
  white "This is a colored test message"
  red_bg "This is a colored test message"
  green_bg "This is a colored test message"
  yellow_bg "This is a colored test message"
  blue_bg "This is a colored test message"
  magenta_bg "This is a colored test message"
  cyan_bg "This is a colored test message"
  white_bg "This is a colored test message"
  bold "This is a colored test message"
  underline "This is a colored test message"
  message info "This is a info test message"
  message progress "This is a progress test message"
  message recommend "This is a recommend test message"
  message warn "This is a warn test message"
  message error "This is a error test message"
  message fatal "This is a fatal test message"
}

# Execute main
main "$@"