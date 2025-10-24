#!/bin/sh
export EDITOR="nvim"
export VISUAL="nvim"
export TERM="kitty"
export TERMINAL="kitty"
export MUSPLAYER="rmpc"
export BROWSER="zen-browser"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
# Use XDG dirs for completion and history files
[ -d "$XDG_STATE_HOME"/zsh ] || mkdir -p "$XDG_STATE_HOME/zsh"
HISTFILE="$XDG_STATE_HOME/zsh/history"
[ -d "$XDG_CACHE_HOME/zsh" ] || mkdir -p "$XDG_CACHE_HOME/zsh"
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# history files
export LESSHISTFILE="$XDG_CACHE_HOME/less_history"
export PYTHON_HISTORY="$XDG_DATA_HOME/python/history"

# moving other files and some other vars
export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"
export XPROFILE="$XDG_CONFIG_HOME/x11/xprofile"
export XRESOURCES="$XDG_CONFIG_HOME/x11/xresources"

[ -d "$XDG_CONFIG_HOME/gtk-2.0" ] || mkdir -p "$XDG_CONFIG_HOME/gtk-2.0"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0" # gtk 3 & 4 are XDG compliant
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"

[ -d "$XDG_DATA_HOME/gnupg" ] || mkdir -p "$XDG_DATA_HOME/gnupg"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export GOPATH="$XDG_DATA_HOME/go"
export GOBIN="$GOPATH/bin"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

[ -d "$XDG_DATA_HOME/android/sdk" ] || mkdir -p "$XDG_DATA_HOME/android/sdk"
export ANDROID_HOME="$XDG_DATA_HOME/android/sdk"
[ -d "$XDG_CONFIG_HOME/android" ] || mkdir -p "$XDG_CONFIG_HOME/android"
export ANDROID_USER_HOME="$XDG_CONFIG_HOME/android"

export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
mkdir -p "$XDG_CACHE_HOME/java-tmp"
export _JAVA_OPTIONS="-Dlanguageserver.boot.symbolCacheDir=$XDG_CACHE_HOME/sts4/symbolCache -Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java -Djava.io.tmpdir=$XDG_CACHE_HOME/java-tmp -Dlanguageserver.boot.symbolCacheDir=$XDG_CACHE_HOME/sts4/symbolCache"
export _JAVA_AWT_WM_NONREPARENTING=1
export MAVEN_OPTS="-Dmaven.repo.local=$XDG_DATA_HOME/maven/repository"
export MAVEN_ARGS="--settings $XDG_CONFIG_HOME/m2/settings.xml"
export MAVEN_REPOSITORY="$XDG_CONFIG_HOME/m2/repository"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export FFMPEG_DATADIR="$XDG_CONFIG_HOME/ffmpeg"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
export DATE=$(date "+%A, %B %e  %_I:%M%P")
export MINIKUBE_HOME="$XDG_DATA_HOME/minikube"
export NVM_DIR="$XDG_DATA_HOME/nvm"
alias yarn='yarn --use-yarnrc "$XDG_CONFIG_HOME/yarn/config"'
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite_history"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export KUBECONFIG="$XDG_CONFIG_HOME/kube" 
export KUBECACHEDIR="$XDG_CACHE_HOME/kube"

export FZF_DEFAULT_OPTS="--style minimal --color 16 --layout=reverse --height 30% --preview='bat -p --color=always {}'"
export FZF_CTRL_R_OPTS="--style minimal --color 16 --info inline --no-sort --no-preview" # separate opts for history widget
export MANPAGER="less -R --use-color -Dd+r -Du+b" # colored man pages

# colored less + termcap vars
export LESS="R --use-color -Dd+r -Du+b"
export LESS_TERMCAP_mb="$(printf '%b' '␛[1;31m')"
export LESS_TERMCAP_md="$(printf '%b' '␛[1;36m')"
export LESS_TERMCAP_me="$(printf '%b' '␛[0m')"
export LESS_TERMCAP_so="$(printf '%b' '␛[01;44;33m')"
export LESS_TERMCAP_se="$(printf '%b' '␛[0m')"
export LESS_TERMCAP_us="$(printf '%b' '␛[1;32m')"
export LESS_TERMCAP_ue="$(printf '%b' '␛[0m')"

export PATH="$PATH:$CARGO_HOME/bin"

# Ollama
[ -d "$XDG_DATA_HOME/ollama-models" ] || mkdir -p "$XDG_DATA_HOME/ollama-models"
export OLLAMA_MODELS="$XDG_DATA_HOME/ollama-models"

# Mise
eval "$(mise activate zsh --shims)"
