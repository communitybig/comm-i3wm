# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/usr/games:/sbin:$HOME/bin"

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Cores - Substitua pelos códigos ANSI do seu terminal, se necessário
GREEN="\033[1;32m"   # Verde
RED="\033[1;31m"     # Vermelho
YELLOW="\033[1;33m"  # Amarelo
BLUE="\033[1;34m"    # Azul
MAGENTA="\033[1;35m" # Magenta
CYAN="\033[1;36m"    # Ciano
RESET="\033[0m"      # Resetar as cores

# Normal Colors
Black='\e[0;30m'  # Black
Red='\e[0;31m'    # Red
Green='\e[0;32m'  # Green
Yellow='\e[0;33m' # Yellow
Blue='\e[0;34m'   # Blue
Purple='\e[0;35m' # Purple
Cyan='\e[0;36m'   # Cyan
White='\e[0;37m'  # White

# Bold
BBlack='\e[1;30m'  # Black
BRed='\e[1;31m'    # Red
BGreen='\e[1;32m'  # Green
BYellow='\e[1;33m' # Yellow
BBlue='\e[1;34m'   # Blue
BPurple='\e[1;35m' # Purple
BCyan='\e[1;36m'   # Cyan
BWhite='\e[1;37m'  # White

# Background
On_Black='\e[40m'        # Black
On_Red='\e[41m'          # Red
On_Green='\e[42m'        # Green
On_Yellow='\e[43m'       # Yellow
On_Blue='\e[44m'         # Blue
On_Purple='\e[45m'       # Purple
On_Cyan='\e[46m'         # Cyan
On_White='\e[47m'        # White
NC="\e[m"                # Color Reset
ALERT=${BWhite}${On_Red} # Bold White on red background

# Função para obter o status do último comando
function get_exit_status() {
  local status="$?"
  if [ $status -eq 0 ]; then
    echo -e "${YELLOW}${status} ${GREEN}✔${RESET}"
  else
    echo -e "${YELLOW}${status} ${RED}✘${RESET}"
  fi
}

HISTCONTROL=ignoreboth # don't put duplicate lines or lines starting with space in the history.
shopt -s histappend    # append to the history file, don't overwrite it
HISTSIZE=1000          # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTFILESIZE=2000      # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#initialize fastfetch
fastfetch

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)

