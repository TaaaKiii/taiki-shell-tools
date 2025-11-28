# ~/.bashrc or ~/.zshrc のどこかに追記
source "$HOME/taiki-shell-tools/functions.sh"

## Install

```bash
git clone https://github.com/TaaaKiii/taiki-shell-tools.git
cd taiki-shell-tools

# 外部コマンドをインストール (~/.local/bin を使う例)
mkdir -p "$HOME/.local/bin"
cp bin/* "$HOME/.local/bin/"

# パスが通っていない場合は ~/.bashrc 等に追加:
#   export PATH="$HOME/.local/bin:$PATH"

# シェル関数を有効化 (~/.bashrc or ~/.zshrc)
echo 'source "$HOME/taiki-shell-tools/functions.sh"' >> ~/.bashrc
# zsh の人は ~/.zshrc に同様に追記

##  License とクレジット
# Copyright (c) 2025 Chiba University, Taiki Matsumura
