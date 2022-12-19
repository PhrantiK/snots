[ -d ~/.cache/zsh ] || mkdir -p ~/.cache/zsh

for config (~/.config/zsh/*.zsh) source $config

[[ -f "${HOME}/.zgenom/zgenom.zsh" ]] ||
  git clone --depth 1 -- \
      https://github.com/jandamm/zgenom.git "${HOME}/.zgenom"
  source "${HOME}/.zgenom/zgenom.zsh"

zgenom autoupdate

if ! zgenom saved; then
  # plugins
  zgenom ohmyzsh plugins/git
  zgenom ohmyzsh plugins/docker-compose
  zgenom ohmyzsh --completion plugins/docker-compose
  zgenom load zdharma-continuum/fast-syntax-highlighting
  zgenom load zsh-users/zsh-autosuggestions
  zgenom load zsh-users/zsh-completions
  zgenom load zap-zsh/sudo

  # save all to init script
  zgenom save

  # Compile your zsh files
  zgenom compile $ZDOTDIR
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
