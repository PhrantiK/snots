[ -d ~/.cache/zsh ] || mkdir -p ~/.cache/zsh

[[ -f "${HOME}/.zgenom/zgenom.zsh" ]] ||
  git clone --depth 1 -- \
      https://github.com/jandamm/zgenom.git "${HOME}/.zgenom"
  source "${HOME}/.zgenom/zgenom.zsh"

zgenom autoupdate

if ! zgenom saved; then
  # plugins
  zgenom load zdharma-continuum/fast-syntax-highlighting
  zgenom load zsh-users/zsh-autosuggestions
  zgenom load zsh-users/zsh-completions
  zgenom load zap-zsh/sudo

  # save all to init script
  zgenom save

  # Compile your zsh files
  zgenom compile $ZDOTDIR
fi

for config (~/.config/zsh/*.zsh) source $config

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

(( $+commands[tcc] )) && tcc -run ~/.config/bin/bfetch.c
