# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


export PS1="\n[\t] \e[1;32;41m\] \u \e[m\]\e[1;30m\]@\e[m\]\e[01;32m\]\h\e[m\]:\e[01;34m\]\w #\e[m\] \n\$ "

# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto -hA --group-directories-first'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias l='ls $LS_OPTIONS -CF'
alias ll='l -l --time-style=long-iso'
alias lsd='ll | grep "^d"'
alias lc='echo "total objets" && ls -A |wc -l'

alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias logw='logwatch --format text'

# alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias df='df -h'                          # Tailles "humaines"
alias free='free -m'                      # Affiche en Mo

alias maj='apt-get update && apt-get upgrade'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# Easier navigation, thanks to josef jezek - http://alias.sh/control-cd-command-behavior
# a quick way to get out of current directory
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'
alias .7='cd ../../../../../../../'
alias .8='cd ../../../../../../../../'
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Tmux tips
alias tmuxn='tmux new-session -s '
alias tmuxx='tmux attach-session -t '

# Get rid of command not found
alias cd..='cd ..'
 
# Go back x directories
# thanks to benjy & eric lucas - http://alias.sh/go-back-n-directories
b() {
	str=""
	count=0
	if [ $# -eq 0 ]
		then
		cd ..
		else
			while [ "$count" -lt "$1" ];
			do
				str=$str"../"
				let count=count+1
			done
		cd $str
	fi
}

# Shortcuts
alias g="git"
alias h="history"
alias j="jobs"
alias n="nano"
alias v="vim"
alias m="mate ."
alias s="subl ."
alias o="open"
alias oo="open ."

# Enable aliases to be sudoâed
alias sudo='sudo '

# Gzip-enabled `curl`
alias gurl="curl --compressed"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
# alias ip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"

# Enhanced WHOIS lookups
alias whois="whois -h whois-servers.net"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# Trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Message
if [ "$TERM" != "dumb" ]; then
        cat <<-INFORMATION_ADMINS

	    >>> Informations relatives aux sauvegardes :
	        Pour lancer une sauvegarde incrémentale immédiate avant une intervention importante, utilisez la commande:
	        master-backup.sh --no-email --incremental

	        Pour restaurer un dossier ou un fichier, utilisez la commande:
	        master-backup-restore.sh [-f] [-t x[s|m|h|D]] chemin_vers_fichier_ou_dossier [chemin_à_restaurer]
	         Options:
	          -f: pour forcer la restauration si la cible existe
	          -t [délai]: pour restaurer la version dispo au délai spécifié (ex.: 1h pour une heure, 3D pour 3 jours)
	         Par défaut, la restauration se fait en place mais on peut indiquer un nouveau chemin pour la restauration.

	        Autres commandes liées à la gestion des sauvegardes:
	         - master-backup-status.sh  : Affiche l'état de la sauvegarde
	         - master-backup-verify.sh  : Vérifie l'état de la sauvegarde en listant les modifications en cours
	         - master-backup-listing.sh : Liste tous les fichiers inclus dans la sauvegarde

	        Commande pour déclencher une sauvegarde immédiate des bases MySQL:
	        mysql-backup.sh

	    >>> Quelques commandes utiles :
	        - Pour remonter dans l'arborescence, utilisez "cd .." ou "cd .3", "cd .4" etc. ou la fonction "b n" avec n=nombre de répertoire à remonter
	        - Pour connaître l'adressage réseau : "ip" = votre ip publique, "localip" = votre ip locale, "ips" = toutes vos adresses
	        - Quelques raccourcis utiles :
	            g="git", h="history", j="jobs", n="nano", v="vim", m="mate .", s="subl .", o="open"
	            l="ls -l", la="ls -la", lsd='ls -l | grep "^d"'
	            gurl="curl --compressed"
				
		INFORMATION_ADMINS

fi

# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
