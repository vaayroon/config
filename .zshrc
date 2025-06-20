# shellcheck shell=zsh
# open the config file and write
setopt HIST_IGNORE_SPACE
# Fix the Java Problem
export _JAVA_AWT_WM_NONREPARENTING=1

# Enable Powerlevel10k instant prompt. Should stay at the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

bindkey ' ' magic-space                           # do history expansion on space
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action


# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
source /home/k3v1n/.powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Manual configuration

#export DOTNET_ROOT=$HOME/.dotnet
export PATH=/root/.local/bin:/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:$HOME/.bin:/opt/mssql-tools18/bin:/usr/share/dotnet:$HOME/.dotnet/tools

# Manual aliases
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='batcat'

### My alias
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias sudo="sudo "
alias catnormal='/usr/bin/cat'
alias kittyprint='kitty +kitten icat'
alias gc='git commit -S'

## dotnet alias

function dotnetcoveragetests ()
{
  rm -r testresult/* || true
  rm -r testresult/* || true
  mv lcov.info lcov.info.bck || true
  dotnet test TACS4-QUMA.Tests /p:CollectCoverage=true /p:CoverletOutput="../testresult/"
  dotnet test TACS4.QUMA.Application.Tests /p:CollectCoverage=true /p:CoverletOutput="../testresult/" /p:MergeWith="../testresult/coverage.json"
  dotnet test TACS4.QUMA.Architecture.Tests /p:CollectCoverage=true /p:CoverletOutput="../testresult/" /p:MergeWith="../testresult/coverage.json" /p:CoverletOutputFormat=lcov
  cp testresult/coverage.info lcov.info
}

function dotnetcoveragetests-test ()
{
  rm -r testresult/* || true
  mv lcov.info lcov.info.bck || true
  dotnet test TACS4-QUMA.Tests /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura
  dotnet test TACS4.QUMA.Application.Tests /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura
  dotnet test TACS4.QUMA.Architecture.Tests /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura
  dotnet test TACS4-QUMA.Tests /p:CollectCoverage=true /p:CoverletOutput="../testresult/"
  dotnet test TACS4.QUMA.Application.Tests /p:CollectCoverage=true /p:CoverletOutput="../testresult/" /p:MergeWith="../testresult/coverage.json"
  dotnet-coverage collect 'dotnet test TACS4.QUMA.Architecture.Tests /p:CollectCoverage=true /p:CoverletOutput="../testresult/" /p:MergeWith="../testresult/coverage.json" /p:CoverletOutputFormat=lcov' -f xml -o 'coverage.xml'
  #cp testresult/coverage.info lcov.info
}

## git alias
function gitclean(){
	typeOfRemove="-d"
  if [[ -n "${1}" && ("${1}" == "-d" || "${1}" == "-D") ]]; then
    typeOfRemove="${1}"
  fi
	git remote prune origin
	git branch -vv | grep ': gone]'|  grep -v "\*" | awk '{ print $1; }' | xargs -r git branch "${1}"
}

### End my alias

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

# Plugins
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-sudo/sudo.plugin.zsh
source /usr/share/zsh-plugins/git.zsh
# Load custom VGitAliases module
source /usr/share/zsh-vaayroon/VGitAliases/VGitAliases.zsh
# Load custom VClip module
source /usr/share/zsh-vaayroon/VClip/VClip.zsh
for file in /usr/share/zsh-plugins/*.plugin.zsh; do
  source "$file"
done

# Functions
function mkt(){
	mkdir {nmap,content,exploits,scripts}
}

function mktk(){
	mkdir {nmap,content,exploits,scripts}
}

# Get information of a program from qtile config
function piqtile() {
  cat ~/.config/qtile/config.py | grep "$1" -A 3 -B 3
}

# Extract nmap information
function extractPorts(){
	ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
	echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
	echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
	echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
	echo $ports | tr -d '\n' | xclip -sel clip
	echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
	cat extractPorts.tmp; rm extractPorts.tmp
}

# Set 'man' colors
function man() {
    env \
    LESS_TERMCAP_mb=$'\e[01;31m' \
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    man "$@"
}

# fzf improvement
function fzf-lovely(){

	if [ "$1" = "h" ]; then
		fzf -m --reverse --preview-window down:20 --preview '[[ $(file --mime {}) =~ binary ]] &&
 	                echo {} is a binary file ||
	                 (bat --style=numbers --color=always {} ||
	                  highlight -O ansi -l {} ||
	                  coderay {} ||
	                  rougify {} ||
	                  cat {}) 2> /dev/null | head -500'

	else
	        fzf -m --preview '[[ $(file --mime {}) =~ binary ]] &&
	                         echo {} is a binary file ||
	                         (bat --style=numbers --color=always {} ||
	                          highlight -O ansi -l {} ||
	                          coderay {} ||
	                          rougify {} ||
	                          cat {}) 2> /dev/null | head -500'
	fi
}

function rmk(){
  local arrayToDelete=("$@")
  for file in "${arrayToDelete[@]}"; do
	  scrub -p dod $file
	  shred -zun 10 -v $file
  done
}

### My functions

#OpenAi

#export OPENAI_API_KEY=`cat $PATH_OPENAI_API_KEY`

function stopvpn(){
  sudo umount /W || true
  pgrep -f vpn | xargs sudo kill -9
}

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

#export CLR_OPENSSL_VERSION_OVERRIDE=1.1

# Finalize Powerlevel10k instant prompt. Should stay at the bottom of ~/.zshrc.
(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize

# Load Angular CLI autocompletion.
source <(ng completion script)

plugins=(docker docker-compose dotnet git)