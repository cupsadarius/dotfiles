if status is-interactive
    # Commands to run in interactive sessions can go here
end

# aliases  
alias vim="nvim"
alias cat="bat"
alias grep='grep --colour=auto'
alias egrep='egrep--colour=auto'
alias scratch='nvim +noswapfile +"set buftype=nofile" +"set bufhidden=hide"'
alias la='ls -a'
alias ll='ls -l'
alias lal='ls -al'
alias dirs='dirs -v'
alias cat='bat'
alias simulator='open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'
alias scratch='nvim +noswapfile +"set buftype=nofile" +"set bufhidden=hide"'

# env variables
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
 
export GOPATH=$HOME/Incubator/golang
export GOROOT="/usr/local/opt/go/libexec"
#export GO111MODULE=on
export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.gcloud/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export CLOUDSDK_PYTHON=python3

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

export BAT_THEME="Catppuccin"

starship init fish | source
