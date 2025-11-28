# taiki-shell-tools

研究・開発作業をちょっと楽にする、小さな Linux シェルツール集です。

## コマンド一覧

外部コマンド（`bin/` 配置）

- `mkexp`     : 実験ディレクトリ生成ツール  
- `killport`  : 指定ポートを使っているプロセスを kill  
- `jn`        : 一行ジャーナル（時刻付きメモ）  
- `trash`     : `rm` の代わりにゴミ箱ディレクトリへ移動  

シェル関数（`functions.sh` 内）

- `please`    : 直前のコマンド or 任意のコマンドを sudo 付きで再実行  
- `cdf`       : ファイルを選んで、そのディレクトリに `cd`（`fzf` 利用）  
- `mkcdtmp`   : 一時ディレクトリ作成 + `cd`  
- `histgrep`  : シェル履歴 (`history`) を grep  

---

## インストール手順

### 1. リポジトリを clone

```bash
git clone https://github.com/TaaaKiii/taiki-shell-tools.git
cd taiki-shell-tools
```

SSH を使う場合:

```bash
git clone git@github.com:TaaaKiii/taiki-shell-tools.git
cd taiki-shell-tools
```

---

### 2. 外部コマンドの配置（mkexp / killport / jn / trash）

`~/.local/bin` にインストールする例です。

```bash
mkdir -p "$HOME/.local/bin"
cp bin/* "$HOME/.local/bin/"
```

`PATH` に `~/.local/bin` が含まれていない場合は、`~/.bashrc` か `~/.zshrc` に以下を追記してください。

```bash
export PATH="$HOME/.local/bin:$PATH"
```

設定を反映:

```bash
source ~/.bashrc    # または source ~/.zshrc
```

**インストール後の状態**

- `~/.local/bin/mkexp`
- `~/.local/bin/killport`
- `~/.local/bin/jn`
- `~/.local/bin/trash`

が作成されます。  
シェル再起動後（または `source` 後）、ターミナルからそれぞれのコマンドが直接叩けるようになります。

---

### 3. シェル関数の読み込み（please / cdf / mkcdtmp / histgrep）

`functions.sh` をシェルの設定ファイルから `source` します。

#### bash の場合

```bash
echo 'source "$HOME/taiki-shell-tools/functions.sh"' >> ~/.bashrc
source ~/.bashrc
```

#### zsh の場合

```bash
echo 'source "$HOME/taiki-shell-tools/functions.sh"' >> ~/.zshrc
source ~/.zshrc
```

**インストール後の状態**

- `~/.bashrc` または `~/.zshrc` に `source "$HOME/taiki-shell-tools/functions.sh"` が一行追加される  
- 新しいシェルを開いたとき、自動的に `functions.sh` が読み込まれ、  
  - `please`
  - `cdf`
  - `mkcdtmp`
  - `histgrep`  
  という関数が使えるようになります

---

## インストール後の動作まとめ

### 新しく使えるようになるコマンド / 関数

- コマンド: `mkexp`, `killport`, `jn`, `trash`
- 関数: `please`, `cdf`, `mkcdtmp`, `histgrep`

どれも「明示的に叩いたときだけ」動作するツールで、  
インストール後に勝手に常駐したり、バックグラウンドで動き続けたりはしません。

### 自動的に作成・更新されるファイル / ディレクトリ

実際にコマンドを使うと、以下のような場所にファイル・ディレクトリが作成されます（デフォルト設定の場合）。

- `mkexp`
  - 実験ディレクトリ:
    - デフォルト: `~/experiments/YYYYMMDD-HHMM-NAME/`
    - 中身: `notes.md`, `run.sh`
- `jn`
  - ジャーナルファイル:
    - デフォルト: `~/.journal.txt`
    - 1行に1エントリで追記される
- `trash`
  - ゴミ箱ディレクトリ:
    - デフォルト: `~/.trash/`
    - `trash` で指定したファイルがここに移動される
- `mkcdtmp`
  - 一時ディレクトリ:
    - デフォルト: `/tmp/tmpdir.xxxxxx`
    - その場限りの作業用ディレクトリとして利用

これらのパスは、環境変数でカスタマイズできます（後述「設定・カスタマイズ」参照）。

---

## 動作確認

インストール直後に、最低限以下を試すとちゃんと入っているか確認できます。

```bash
# コマンドが見つかるか確認
which mkexp
which killport
which jn
which trash

# 関数が定義されているか確認
type please
type cdf
type mkcdtmp
type histgrep
```

`which` でフルパスが表示され、`type` で `please is a function` のように出ていれば OK です。

---

## 設定・カスタマイズ

### 環境変数による設定一覧

| コマンド   | 環境変数          | デフォルト                     | 役割                                  |
|-----------|-------------------|--------------------------------|---------------------------------------|
| mkexp     | `EXPERIMENTS_DIR` | `"$HOME/experiments"`          | 実験ディレクトリを作成するベースパス |
| jn        | `JOURNAL_FILE`    | `"$HOME/.journal.txt"`         | ジャーナルの保存先ファイル           |
| trash     | `TRASH_DIR`       | `"$HOME/.trash"`               | ゴミ箱ディレクトリの場所             |
| mkcdtmp   | `TMPDIR`          | `"/tmp"`（未設定時）           | 一時ディレクトリを作る親ディレクトリ |

設定例：

```bash
# 実験ディレクトリを ~/lab/experiments 配下にしたい場合
export EXPERIMENTS_DIR="$HOME/lab/experiments"

# ジャーナルを Dropbox 配下に置きたい場合
export JOURNAL_FILE="$HOME/Dropbox/journal.txt"

# ゴミ箱ディレクトリを ~/.local/trash にしたい場合
export TRASH_DIR="$HOME/.local/trash"
```

これらの `export` は `~/.bashrc` や `~/.zshrc` に書いておくと、毎回自動で適用されます。

---

## コマンドごとの詳細な動き

### mkexp

**役割**  
実験用ディレクトリを日付・時刻付きで作成し、`notes.md` と `run.sh` のテンプレートを置きます。

**基本動作**

```bash
mkexp NAME
```

- 実行すると、以下のようなディレクトリが作成されます：

  ```text
  ${EXPERIMENTS_DIR:-$HOME/experiments}/YYYYMMDD-HHMM-NAME/
  ```

  例:

  ```text
  ~/experiments/20251128-1612-cnn-mnist/
  ```

- ディレクトリ内に以下のファイルを生成します：
  - `notes.md` : 実験の目的・設定・結果を書くための markdown テンプレート
  - `run.sh`   : 実験コマンドを書き込むためのシェルスクリプト（実行権限付き）

**設定**

- `EXPERIMENTS_DIR` を設定することで、作成先のベースディレクトリを変更できます：

  ```bash
  export EXPERIMENTS_DIR="$HOME/lab/experiments"
  ```

**インストール後に勝手にすること**  
→ 何もしません。  
コマンドを叩いたときだけ、上記のディレクトリとファイルを作成します。

---

### killport

**役割**  
指定したポートを利用しているプロセスを探して kill します。

**基本動作**

```bash
killport 8888
```

- 内部で `lsof -t -i :8888` を呼び出し、該当プロセスの PID を取得します
- 見つかった PID 全てに対して `kill` を実行します
- プロセスが見つからない場合は「No process using port 8888」と表示して終了

**設定**

- 特に環境変数による設定はありません
- root 権限が必要なプロセスを kill する場合は、`sudo killport 80` のように実行してください

---

### jn

**役割**  
テキストを一行、時刻付きでログファイルに追記する簡易ジャーナル。

**基本動作**

```bash
jn 実験42: lr=1e-4 が一番良さそう
```

- `JOURNAL_FILE`（未設定時は `~/.journal.txt`）に以下の形式で追記します：

  ```text
  [2025-11-28 16:12:34] 実験42: lr=1e-4 が一番良さそう
  ```

**設定**

- 保存先ファイルを変えたい場合：

  ```bash
  export JOURNAL_FILE="$HOME/Dropbox/journal.txt"
  ```

**インストール後の動作**

- 最初に `jn` を実行したとき、自動的にジャーナルファイルが作成されます
- その後は呼び出すたびにログが一行ずつ追記されていきます

---

### trash

**役割**  
ファイルを直接削除する代わりに、ゴミ箱ディレクトリに移動します。

**基本動作**

```bash
trash foo.txt bar.log
```

- `TRASH_DIR`（未設定時は `~/.trash`）を自動で作成し、指定されたファイルをそこに `mv` します
- 元の場所にはファイルが残りません（パスだけ変わります）

**設定**

- ゴミ箱の場所を変えたい場合：

  ```bash
  export TRASH_DIR="$HOME/.local/trash"
  ```

- `rm` の代わりに常に `trash` を使いたい場合（慎重に）：

  ```bash
  alias rm='trash'
  ```

**インストール後の動作**

- `trash` を実行するまでは何もしません
- 初回実行時に `TRASH_DIR` ディレクトリを作成します

---

### please（シェル関数）

**役割**  
直前のコマンド or 指定したコマンドを、`sudo` 付きで実行し直す。

**基本動作**

```bash
# 例1: sudo 付け忘れを救済
apt install xxx      # → Permission denied
please               # → sudo apt install xxx を自動実行

# 例2: 直接指定
please systemctl restart nginx
# → sudo systemctl restart nginx
```

**インストール後の動作**

- 新しいシェルを開いたときに `functions.sh` が読み込まれ、`please` 関数が定義されるだけです
- ユーザが `please` を実行しない限り、何もしません

---

### cdf（シェル関数）

**役割**  
`fzf` でファイルを選び、そのファイルが存在するディレクトリに `cd` する。

**基本動作**

```bash
cdf
# → fzf のインタラクティブ画面が開く
# → ファイルを選択
# → 選んだファイルのディレクトリに cd
```

**前提**

- `fzf` がインストールされていること
- `find` コマンドが使用可能であること（通常の Linux なら標準で入っています）

**インストール後の動作**

- `functions.sh` 読み込み時に `cdf` 関数が定義されるだけです
- `cdf` を叩いたときにのみ、`fzf` が起動してファイル検索・移動を行います

---

### mkcdtmp（シェル関数）

**役割**  
一時ディレクトリを作成し、そこに `cd` する。

**基本動作**

```bash
mkcdtmp
# → /tmp/tmpdir.xxxxxx が作成され、その中に移動
```

**設定**

- 一時ディレクトリの親ディレクトリは `TMPDIR` に従います：

  ```bash
  export TMPDIR="$HOME/tmp"
  mkcdtmp
  # → $HOME/tmp/tmpdir.xxxxxx に作成される
  ```

---

### histgrep（シェル関数）

**役割**  
シェル履歴（`history`）を指定したパターンで grep する。

**基本動作**

```bash
histgrep ssh
histgrep mkexp
```

**インストール後の動作**

- `functions.sh` 読み込み時に `histgrep` 関数が定義されます
- 実行時にのみ `history` コマンドを呼び出し、標準出力に結果を表示するだけです

---

## アンインストール

### コマンド類の削除

```bash
rm -f "$HOME/.local/bin/mkexp"       "$HOME/.local/bin/killport"       "$HOME/.local/bin/jn"       "$HOME/.local/bin/trash"
```

### シェル設定からの削除

`~/.bashrc` または `~/.zshrc` を開き、以下の行を削除してください。

```bash
source "$HOME/taiki-shell-tools/functions.sh"
```

その後、設定を再読み込み：

```bash
source ~/.bashrc    # または source ~/.zshrc
```

必要であれば、クローンしたリポジトリ自体も削除します：

```bash
rm -rf "$HOME/taiki-shell-tools"
```

---

## Requirements

- POSIX 互換シェル（Bash / Zsh など）
- `killport` 用:
  - `lsof`
- `cdf` 用:
  - `fzf`
  - `find`

---

## Directory structure

```text
taiki-shell-tools/
├── bin/
│   ├── mkexp
│   ├── killport
│   ├── jn
│   └── trash
├── functions.sh
├── README.md
└── LICENSE
```

---

## License

License  
Copyright (c) 2025 Chiba University, Taiki Matsumura
