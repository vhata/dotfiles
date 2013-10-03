alias ps='/bin/ps -wwwxo pid,ppid,ruser,nice,start,time,pcpu,pmem,rss,command'
alias psx='/bin/ps -wwwaxo pid,ppid,ruser,nice,start,time,pcpu,pmem,rss,command'
alias ls='ls -G'
alias ql='qlmanage -p 2>/dev/null'
alias top='top -F -R -o cpu'
alias newchrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --user-data-dir=$HOME/Library/Application\ Support/Google/OtherChrome"
alias pjson='python -mjson.tool | pygmentize -l javascript'
alias head='ghead'
#alias git=hub
alias pb=pythonbrew
#alias tac='python -c '\''import sys; print "".join(reversed(list(sys.stdin))),'\'''
#timestamp() { perl -e "print localtime($1).\"\n\"" ; }
alias where="python -c \"import sys; print ','.join([repr(l.strip()) for l in sys.stdin])\""
alias glances=~/.pythonbrew/venvs/Python-2.6.5/useful/bin/glances
alias oneline='paste -d" " -s -'
alias show-branches='git branch -a | grep -v HEAD | grep remote | while read f ; do git log -1 --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=relative $f ; done'

sniff() { int=`[ -z "$1" ] && echo en1 || echo "$1"` ; sudo ngrep -d $int -t '^(GET|HEAD|POST|PUT|DELETE|TRACE|OPTIONS) ' 'tcp and port 80' ; }
httpdump() { int=`[ -z "$1" ] && echo en1 || echo "$1"` ; sudo tcpdump -i $int -n -s 0 -w - | grep -a -o -E "Host\: .*|(GET|HEAD|POST|PUT|DELETE|TRACE|OPTIONS) \/.*" ; }
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

export VIRTUALENV_USE_DISTRIBUTE=1
alias penv='pythonbrew venv'

freshchrome() { /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --user-data-dir=~/Library/Application\ Support/Google/$1 ; }

findnewstuff() {
        where=`[ -z "$1" ] && echo "." || echo "$1"`
        many=`[ -z "$2" ] && echo "50" || echo "$2"`
        gfind $where -type f -printf "%T@ %p\n" | sort -n | tail -n $many | perl -pe 's/(\d{10})/scalar localtime($1)/e'
}
