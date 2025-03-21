# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/usr/games:/sbin:$HOME/bin"


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


