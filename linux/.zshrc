# Enable Powerlevel10k instant prompt. Should stay at the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# shellcheck shell=zsh
# open the config file and write
setopt HIST_IGNORE_SPACE
# Fix the Java Problem
export _JAVA_AWT_WM_NONREPARENTING=1


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
source ~/.powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Manual configuration

#export DOTNET_ROOT=$HOME/.dotnet
export PATH=/root/.local/bin:/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:$HOME/.bin:/opt/mssql-tools18/bin:/usr/share/dotnet:$HOME/.dotnet/tools:$HOME/go/bin

USER_BIN_PATH="$HOME/.local/bin/"
export PATH="$USER_BIN_PATH:$PATH"

# Start my alias

## ls alias
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='batcat'

## custom alias
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias sudo="sudo "
alias catnormal='/usr/bin/cat'
alias kittyprint='kitty +kitten icat'

## dotnet alias
function DotNetCoverageTests() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: DotNetCoverageTests <BaseDir> <TestProject> [TestProject2 ...]" >&2
    return 1
  fi

  local base_dir
  base_dir="$(realpath "$1")"
  shift

  if [[ ! -d "$base_dir" ]]; then
    echo "Error: BaseDir '$base_dir' does not exist or is not a directory." >&2
    return 1
  fi

  local test_result_dir="$base_dir/testresult"
  local lcov_in_base="$base_dir/lcov.info"
  local lcov_backup="$base_dir/lcov.info.bck"

  # Clean previous outputs
  [[ -d "$test_result_dir" ]] && rm -rf "$test_result_dir"
  mkdir -p "$test_result_dir"

  if [[ -f "$lcov_in_base" ]]; then
    [[ -f "$lcov_backup" ]] && rm -f "$lcov_backup"
    mv "$lcov_in_base" "$lcov_backup"
  fi

  local json_output="$test_result_dir/coverage.json"
  local lcov_output="$test_result_dir/coverage.info"

  local num_projects=$#
  local index=0
  local first=true
  for proj_path in "$@"; do
    (( index++ ))

    # Resolve path: if not absolute, make it relative to BaseDir
    local resolved_proj
    if [[ "$proj_path" = /* ]]; then
      resolved_proj="$proj_path"
    else
      resolved_proj="$base_dir/$proj_path"
    fi

    if [[ ! -e "$resolved_proj" ]]; then
      echo "Error: Test project path not found: '$resolved_proj'" >&2
      return 1
    fi

    local props=(
      "/p:CollectCoverage=true"
      "/p:CoverletOutput=${test_result_dir}/"
    )

    if [[ $num_projects -eq 1 ]]; then
      # Single project: lcov only
      props+=('/p:CoverletOutputFormat="lcov"')
    elif [[ "$first" == true ]]; then
      # First of multiple: json only (intermediate for merging)
      props+=('/p:CoverletOutputFormat="json"')
      first=false
    elif [[ $index -eq $num_projects ]]; then
      # Last of multiple: merge and output lcov
      props+=("/p:MergeWith=${json_output}")
      props+=('/p:CoverletOutputFormat="lcov"')
    else
      # Middle projects: merge and continue as json
      props+=("/p:MergeWith=${json_output}")
      props+=('/p:CoverletOutputFormat="json"')
    fi

    echo "Running tests with coverage for: $resolved_proj"
    dotnet test "$resolved_proj" "${props[@]}"
    if [[ $? -ne 0 ]]; then
      echo "Error: dotnet test failed for '$resolved_proj'" >&2
      return 1
    fi
  done

  if [[ -f "$lcov_output" ]]; then
    cp "$lcov_output" "$lcov_in_base"
    echo "Coverage LCOV written to: $lcov_in_base"
  else
    echo "Warning: Could not find '$lcov_output'. Ensure coverlet produced LCOV. Check test logs." >&2
  fi
}

## gpg alias
function get_git_key() {
  local github_key_path="/var/k3v1n/git.gpg"
  
  # Check if the encrypted key file exists
  if [[ ! -f "$github_key_path" ]]; then
    echo "Error: Github key file not found at $github_key_path" >&2
    echo "Please update the path in the function or create the encrypted key file." >&2
    return 1
  fi
  
  decrypt_file "$github_key_path"
}

function get_bitbucket_key() {
  local bitbucket_key_path="/var/k3v1n/bgit.gpg"
  
  # Check if the encrypted key file exists
  if [[ ! -f "$bitbucket_key_path" ]]; then
    echo "Error: BitBucket key file not found at $bitbucket_key_path" >&2
    echo "Please update the path in the function or create the encrypted key file." >&2
    return 1
  fi
  
  decrypt_file "$bitbucket_key_path"
}

function get_rovodev_key() {
  local rovodev_key_path="/var/k3v1n/rovodev.gpg"
  
  # Check if the encrypted key file exists
  if [[ ! -f "$rovodev_key_path" ]]; then
    echo "Error: RovoDev key file not found at $rovodev_key_path" >&2
    echo "Please update the path in the function or create the encrypted key file." >&2
    return 1
  fi
  
  decrypt_file "$rovodev_key_path"
}

function decrypt_file() {
  local file_path="$1"

  # Check if the file path is provided
  if [[ -z "$file_path" ]]; then
    echo "Error: File path is required." >&2
    return 1
  fi

  # Check if the file exists
  if [[ ! -f "$file_path" ]]; then
    echo "Error: The file $file_path does not exist." >&2
    return 1
  fi

  # Run the gpg decrypt command and capture the output
  local full_output
  full_output=$(gpg --decrypt "$file_path" 2>&1)
  local exit_code=$?

  # Check if there was an error
  if [[ $exit_code -ne 0 ]]; then
    echo "Error: Failed to decrypt the file. Check if the password is correct." >&2
    return 1
  fi

  # Get the last line (trimmed)
  local pwd_line
  pwd_line=$(echo "$full_output" | tail -n 1 | xargs)

  # Copy to clipboard (works on macOS, Linux with xclip, or Linux with xsel)
  if command -v pbcopy &> /dev/null; then
    # macOS
    echo -n "$pwd_line" | pbcopy
  elif command -v xclip &> /dev/null; then
    # Linux with xclip
    echo -n "$pwd_line" | xclip -selection clipboard
  elif command -v xsel &> /dev/null; then
    # Linux with xsel
    echo -n "$pwd_line" | xsel --clipboard --input
  else
    echo "Error: No clipboard utility found (pbcopy, xclip, or xsel)." >&2
    return 1
  fi

  echo "\033[32mDecrypted content has been copied to clipboard.\033[0m"
}

## copilot alias
alias '?'='copilot'
alias '??'='copilot -p'
alias '???'='copilot -i'

### End my alias

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

# Plugins
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-sudo/sudo.plugin.zsh
source /usr/share/zsh-vaayroon/VGitAliases/VGitAliases.zsh
source /usr/share/zsh-vaayroon/VClip/VClip.zsh
# source /usr/share/zsh-plugins/git.zsh
# for file in /usr/share/zsh-plugins/*.plugin.zsh; do
  # source "$file"
# done

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

# gpg agent for ssh
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

#export CLR_OPENSSL_VERSION_OVERRIDE=1.1

# Load Angular CLI autocompletion.
# source <(ng completion script)

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh --log-level quiet)"
fi

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# init zoxide
eval "$(zoxide init zsh)"

# Finalize Powerlevel10k instant prompt. Should stay at the bottom of ~/.zshrc.
(( ! ${+functions[p10k]} )) || p10k finalize
