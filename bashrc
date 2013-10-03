pathadds=(
    ~/bin
    /usr/local/bin
    /usr/local/sbin
    /usr/local/share/npm/bin
)
manpathadds=(
   /usr/local/share/man
)
OLD_IFS="$IFS"
IFS=":"
export PATH="${pathadds[*]}:$PATH"
export MANPATH="${manpathadds[*]}:$MANPATH"
IFS="$OLD_IFS"

# These should use `brew --prefix` but I prefer a fast shell
if [ -f /usr/local/etc/bash_completion ];then
    . /usr/local/etc/bash_completion
fi

export RED=$'\E[01;31m'
export GREEN=$'\E[01;32m'
export YELLOW=$'\E[01;33m'
export BLUE=$'\E[01;34m'
export MAGENTA=$'\E[01;35m'
export CYAN=$'\E[01;36m'
export NORM=$'\E[00m'

#PS1='\[\033[G\]\A/$? \[\033[01;31m\][\h] \[\033[01;34m\]\W \$ \[\033[00m\]'
#PS1='\[\033[G\]\A/$? \[\033[01;32m\][\u@\h] \[\033[01;34m\]\34mw \$ \[\033[00m\]'
# Colorize PS1 according to privileges
if [[ ${EUID} == 0 ]] ; then
    PS1="\[\033[01;31m\][\h]"
else
    PS1="\[\033[01;32m\][\u@\h]"
fi

# git branch
function parse_git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo "("${ref#refs/heads/}") "
}
PS1="${PS1} \[\033[01;36m\]\$(parse_git_branch)"
# Add path
PS1="${PS1}\[\033[01;34m\]\w \\\$ \[\033[00m\]"
# Prepend time and exit code of previous command
PS1="\A/\$? ${PS1}"
# Prepend ANSI code to return to beginning of line
# Useful if previous command had output that didn't end in a newline
#PS1="\[\033[G\]${PS1}"
export PS1

export HISTCONTROL=ignoredups:erasedups
export HISTIGNORE="&:ls:[bf]g:exit"
shopt -s checkwinsize
shopt -s histappend
unset HISTFILESIZE
export HISTSIZE=3000
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
#export TERM=screen

# For colourful man pages (CLUG-Wiki style)
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

if [ -f ~/.bash_aliases ] ; then
    . ~/.bash_aliases
fi

#eval `gdircolors ~/.dircolors.256dark`
export LS_COLORS='no=00;38;5;244:rs=0:di=00;38;5;33:ln=01;38;5;37:pi=48;5;230;38;5;136;01:so=48;5;230;38;5;136;01:do=48;5;230;38;5;136;01:bd=48;5;230;38;5;244;01:cd=48;5;230;38;5;244;01:or=48;5;235;38;5;160:su=48;5;160;38;5;230:sg=48;5;136;38;5;230:ca=30;41:tw=48;5;64;38;5;230:ow=48;5;235;38;5;33:st=48;5;33;38;5;230:ex=01;38;5;64:*.tar=00;38;5;61:*.tgz=01;38;5;61:*.arj=01;38;5;61:*.taz=01;38;5;61:*.lzh=01;38;5;61:*.lzma=01;38;5;61:*.tlz=01;38;5;61:*.txz=01;38;5;61:*.zip=01;38;5;61:*.z=01;38;5;61:*.Z=01;38;5;61:*.dz=01;38;5;61:*.gz=01;38;5;61:*.lz=01;38;5;61:*.xz=01;38;5;61:*.bz2=01;38;5;61:*.bz=01;38;5;61:*.tbz=01;38;5;61:*.tbz2=01;38;5;61:*.tz=01;38;5;61:*.deb=01;38;5;61:*.rpm=01;38;5;61:*.jar=01;38;5;61:*.rar=01;38;5;61:*.ace=01;38;5;61:*.zoo=01;38;5;61:*.cpio=01;38;5;61:*.7z=01;38;5;61:*.rz=01;38;5;61:*.apk=01;38;5;61:*.jpg=00;38;5;136:*.JPG=00;38;5;136:*.jpeg=00;38;5;136:*.gif=00;38;5;136:*.bmp=00;38;5;136:*.pbm=00;38;5;136:*.pgm=00;38;5;136:*.ppm=00;38;5;136:*.tga=00;38;5;136:*.xbm=00;38;5;136:*.xpm=00;38;5;136:*.tif=00;38;5;136:*.tiff=00;38;5;136:*.png=00;38;5;136:*.svg=00;38;5;136:*.svgz=00;38;5;136:*.mng=00;38;5;136:*.pcx=00;38;5;136:*.dl=00;38;5;136:*.xcf=00;38;5;136:*.xwd=00;38;5;136:*.yuv=00;38;5;136:*.cgm=00;38;5;136:*.emf=00;38;5;136:*.eps=00;38;5;136:*.CR2=00;38;5;136:*.ico=00;38;5;136:*.tex=01;38;5;245:*.rdf=01;38;5;245:*.owl=01;38;5;245:*.n3=01;38;5;245:*.ttl=01;38;5;245:*.nt=01;38;5;245:*.torrent=01;38;5;245:*Makefile=01;38;5;245:*Rakefile=01;38;5;245:*build.xml=01;38;5;245:*rc=01;38;5;245:*1=01;38;5;245:*.nfo=01;38;5;245:*README=01;38;5;245:*README.txt=01;38;5;245:*readme.txt=01;38;5;245:*README.md=01;38;5;245:*README.markdown=01;38;5;245:*ini=01;38;5;245:*yml=01;38;5;245:*cfg=01;38;5;245:*conf=01;38;5;245:*.log=00;38;5;240:*.bak=00;38;5;240:*.aux=00;38;5;240:*.bbl=00;38;5;240:*.blg=00;38;5;240:*~=00;38;5;240:*#=00;38;5;240:*.part=00;38;5;240:*.incomplete=00;38;5;240:*.swp=00;38;5;240:*.tmp=00;38;5;240:*.temp=00;38;5;240:*.o=00;38;5;240:*.pyc=00;38;5;240:*.class=00;38;5;240:*.cache=00;38;5;240:*.aac=00;38;5;166:*.au=00;38;5;166:*.flac=00;38;5;166:*.mid=00;38;5;166:*.midi=00;38;5;166:*.mka=00;38;5;166:*.mp3=00;38;5;166:*.mpc=00;38;5;166:*.ogg=00;38;5;166:*.ra=00;38;5;166:*.wav=00;38;5;166:*.m4a=00;38;5;166:*.axa=00;38;5;166:*.oga=00;38;5;166:*.spx=00;38;5;166:*.xspf=00;38;5;166:*.mov=01;38;5;166:*.mpg=01;38;5;166:*.mpeg=01;38;5;166:*.m2v=01;38;5;166:*.mkv=01;38;5;166:*.ogm=01;38;5;166:*.mp4=01;38;5;166:*.m4v=01;38;5;166:*.mp4v=01;38;5;166:*.vob=01;38;5;166:*.qt=01;38;5;166:*.nuv=01;38;5;166:*.wmv=01;38;5;166:*.asf=01;38;5;166:*.rm=01;38;5;166:*.rmvb=01;38;5;166:*.flc=01;38;5;166:*.avi=01;38;5;166:*.fli=01;38;5;166:*.flv=01;38;5;166:*.gl=01;38;5;166:*.m2ts=01;38;5;166:*.axv=01;38;5;166:*.anx=01;38;5;166:*.ogv=01;38;5;166:*.ogx=01;38;5;166:';
alias ls='gls --color=auto'

export LANG=en_US.UTF-8
unset LC_CTYPE

export EDITOR=vim

export PIP_DOWNLOAD_CACHE=~/.pip/cache

[[ -s "$HOME/.pythonbrew/etc/bashrc" ]] && source "$HOME/.pythonbrew/etc/bashrc"
#[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source ~/.rvmrc

LOCALBASHRC=~/.bashrc-$(hostname)
if [ -f "$LOCALBASHRC" ] ; then
    . "$LOCALBASHRC"
fi

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
