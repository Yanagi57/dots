# ===== Colors =====
autoload -U colors && colors
autoload -U compinit; compinit
fpath=($XDG_CONFIG_HOME/zsh $fpath)
autoload -Uz prompt_purification; prompt_purification

# ===== History =====
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$XDG_CACHE_HOME/zsh_history"
export HISTCONTROL=ignoreboth  # ignore duplicates & commands starting with space

# ===== PATH =====
export PATH="$PATH:/home/$USER/apps:$XDG_DATA_HOME/npm/bin"

# ===== Plugins =====
[ -f $XDG_CONFIG_HOME/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source $XDG_CONFIG_HOME/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f $XDG_CONFIG_HOME/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source $XDG_CONFIG_HOME/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# ===== Options =====
setopt correct  # command auto-correction
setopt HIST_SAVE_NO_DUPS   # no duplicate entries in history
setopt AUTO_PUSHD # auto pushd on cd
setopt PUSHD_IGNORE_DUPS # ignore duplicate dirs in stack
setopt PUSHD_SILENT # don't print dir stack after pushd/popd

# ===== Directory stack shortcuts =====
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# ===== Vim Zsh =====
bindkey -v  # vi keybindings
export KEYTIMEOUT=1  # reduce delay for key sequences

cursor_mode() {
    # See https://ttssh2.osdn.jp/manual/4/en/usage/tips/vim.html for cursor shapes
    cursor_block='\e[2 q'
    cursor_beam='\e[6 q'

    function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]] ||
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
        fi
    }

    zle-line-init() {
        echo -ne $cursor_beam
    }

    zle -N zle-keymap-select
    zle -N zle-line-init
}

cursor_mode

zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# ===== Aliases =====
alias ll='ls -lah'
alias gs='git status'
alias gp='git push'
alias gl='git log --oneline --graph --all'
alias rm='rm -i'

# ===== Mise activation =====
eval "$(mise activate zsh)"

# ===== FZF =====
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh

# ===== Conda =====
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

. "$HOME/.local/share/../bin/env"
