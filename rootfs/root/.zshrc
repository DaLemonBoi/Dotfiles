### Check for non-interactive shell then run zshrc if shell is interactive ###

if [[ $- != *i* ]] ; then
# Shell is non-interactive. Be done now!
return
fi

######################## The following lines were added by compinstall ########################

zstyle ':completion:*' completer _expand _complete _ignored _correct
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' menu select=0
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/root/.zshrc'

autoload -Uz compinit
compinit
### End of lines added by compinstall ###
### Lines configured by zsh-newuser-install ###
HISTFILE=~/.cache/histfile
HISTSIZE=999999999999999
SAVEHIST=999999999999999
setopt autocd extendedglob notify
unsetopt beep
bindkey -e

######################## My shit below ########################

### append into history file ###
setopt INC_APPEND_HISTORY

### make colorful shell and set shell prompt ###
autoload -U colors && colors
export PS1="%F{1}| ROOT: %/ | $%F{7} "

### aliases ###
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias rmd='rm -rf'
alias lsa='ls -a --color=auto'
