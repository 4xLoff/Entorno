# Fix the Java Problem
export _JAVA_AWT_WM_NONREPARENTING=1
export GOPATH=$HOME/go
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

source  ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh



# Manual configuration



export PATH=root/.local/bin:/snap/bin:/usr/sandbox/:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/opt/nvim-linux64/bin:/usr/local/go/bin:$GOPATH/bin


export ORACLE_HOME=/usr/lib/oracle/21/client64/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib
export PATH=${ORACLE_HOME}bin:$PATH

# Manual aliases$

alias ll='lsd -lh --group-dirs=first'

alias la='lsd -a --group-dirs=first'

alias l='lsd --group-dirs=first'

alias lla='lsd -lha --group-dirs=first'

alias ls='lsd --group-dirs=first'

alias cat='bat'

alias vi='nvim'

alias vim='nvim'

alias vin='nvim'

alias htb='sudo openvpn TUVPN.ovpn'  # poner tu vpn

alias burp='sudo /opt/Burp-Suite/burp'  # poner tu ruta burpsuite

alias blackstone='nohup sudo /opt/BlackStone/xampp_installer/icon/simple_launch.sh > /dev/null 2>&1 &'
 

#Zsh
#Append this line to ~/.zshrc to enable fzf keybindings for Zsh:
source /usr/share/doc/fzf/examples/key-bindings.zsh
#Append this line to ~/.zshrc to enable fuzzy auto-completion for Zsh:
source /usr/share/doc/fzf/examples/completion.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh



# Plugins

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

source /usr/share/zsh-sudo/sudo.plugin.zsh



# Functions

function mkt(){

	mkdir {nmap,content,exploits,images}

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

function mann() {

    env \

    LESS_TERMCAP_mb=$'\e[01;31m' \

    LESS_TERMCAP_md=$'\e[01;31m' \

    LESS_TERMCAP_me=$'\e[0m' \

    LESS_TERMCAP_se=$'\e[0m' \

    LESS_TERMCAP_so=$'\e[01;44;33m' \

    LESS_TERMCAP_ue=$'\e[0m' \

    LESS_TERMCAP_us=$'\e[01;32m' \

    mann "$@"

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

	scrub -p dod $1

	shred -zun 10 -v $1

}



function settarget(){

  echo $1 > /tmp/target

  echo $2 > /tmp/name

}



function cleartarget(){

  echo Null > /tmp/target

  echo Null > /tmp/name

}



# Finalize Powerlevel10k instant prompt. Should stay at the bottom of ~/.zshrc.

(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize



bindkey "^[[H" beginning-of-line

bindkey "^[[F" end-of-line

bindkey "^[[3~" delete-char

bindkey "^[[1;3C" forward-word

bindkey "^[[1;3D" backward-word



source ~/powerlevel10k/powerlevel10k.zsh-theme

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off



# Created by `pipx` on 2023-10-07 23:27:25
export PATH="$PATH:/root/.local/bin"
export PATH=/opt/node-v20.10.0-linux-x64/bin:$PATH
