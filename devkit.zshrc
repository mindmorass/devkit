# devkit interactive shell config
export EDITOR=nvim
export GOPATH="$HOME/go"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null)" || true
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# aliases
alias ls='eza'
alias ll='eza -lah --git'
alias cat='bat --paging=never'
alias vi='nvim'

autoload -Uz compinit && compinit -u 2>/dev/null
PROMPT='%F{cyan}devkit%f %~ %# '

cat <<'BANNER'
 devkit — developer toolbox
   proxies: start-proxy            (PROXY_ENGINE=3proxy|gost; see `start-proxy` header)
   api:     newman hurl xh httpie grpcurl websocat
   sec:     trivy gitleaks semgrep nuclei nmap mitmproxy testssl.sh
   ai:      copilot  codex
BANNER
