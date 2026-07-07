---
layout: post
title: "tmuxの使い方完全ガイド：ステップバイステップで学ぶターミナル多重化"
date: 2025-07-01 10:00:00 +0900
categories: [tech]
tags: [tmux, terminal, productivity, linux, unix]
---

# tmuxの使い方完全ガイド：ステップバイステップで学ぶターミナル多重化

tmux（Terminal Multiplexer）は、1つのターミナルで複数のセッションを管理できる強力なツールです。本記事では、初心者から上級者まで、tmuxを効果的に使いこなすための方法を段階的に解説します。

## 目次
1. [tmuxとは何か](#tmuxとは何か)
2. [インストール方法](#インストール方法)
3. [基本概念の理解](#基本概念の理解)
4. [セッション管理](#セッション管理)
5. [ウィンドウ管理](#ウィンドウ管理)
6. [ペイン管理](#ペイン管理)
7. [設定ファイルのカスタマイズ](#設定ファイルのカスタマイズ)
8. [実践的な使用例](#実践的な使用例)
9. [よくある問題と解決法](#よくある問題と解決法)

## tmuxとは何か

tmuxは「Terminal Multiplexer」の略で、以下の機能を提供します：

- **セッションの永続化**: SSH接続が切れてもプロセスが継続
- **画面分割**: 1つのターミナルを複数のペインに分割
- **複数ウィンドウ**: タブのようにウィンドウを切り替え
- **セッション共有**: 複数のユーザーで同一セッションを共有

### tmuxが解決する問題

- SSH接続が切れてもバックグラウンドプロセスが継続
- 複数のタスクを同時に監視・実行
- リモートサーバーでの作業効率向上
- ペアプログラミングやリモートサポート

## インストール方法

### macOS
```bash
# Homebrewを使用
brew install tmux

# MacPortsを使用
sudo port install tmux
```

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install tmux
```

### Linux (CentOS/RHEL)
```bash
sudo yum install tmux
# または
sudo dnf install tmux
```

### インストール確認
```bash
tmux -V
```

## 基本概念の理解

tmuxは階層構造で動作します：

```
Server
├── Session 1
│   ├── Window 1
│   │   ├── Pane 1
│   │   └── Pane 2
│   └── Window 2
│       └── Pane 1
└── Session 2
    └── Window 1
        └── Pane 1
```

### 重要な用語

- **Server**: tmuxのメインプロセス
- **Session**: 作業単位。複数のウィンドウを含む
- **Window**: セッション内のタブのような存在
- **Pane**: ウィンドウ内の分割された画面

### プレフィックスキー

tmuxのコマンドは「プレフィックスキー」+「コマンドキー」で実行します。
デフォルトのプレフィックスキーは `Ctrl+b` です。

## セッション管理

### 新しいセッションの作成

```bash
# 新しいセッションを作成
tmux

# 名前付きセッションを作成
tmux new-session -s mysession
# または
tmux new -s mysession
```

### セッションの一覧表示

```bash
# セッション一覧を表示
tmux list-sessions
# または
tmux ls
```

### セッションへの接続（アタッチ）

```bash
# 最後のセッションにアタッチ
tmux attach

# 特定のセッションにアタッチ
tmux attach -t mysession
# または
tmux a -t mysession
```

### セッションからの切断（デタッチ）

```bash
# セッション内で実行
Ctrl+b d
```

### セッションの終了

```bash
# セッション内で実行
exit
# または
Ctrl+d

# 外部から特定セッションを終了
tmux kill-session -t mysession
```

## ウィンドウ管理

### 基本的なウィンドウ操作

```bash
# 新しいウィンドウを作成
Ctrl+b c

# ウィンドウ一覧を表示
Ctrl+b w

# 次のウィンドウに移動
Ctrl+b n

# 前のウィンドウに移動
Ctrl+b p

# ウィンドウ番号で移動（0-9）
Ctrl+b 0-9

# ウィンドウの名前を変更
Ctrl+b ,
```

### ウィンドウの検索と移動

```bash
# ウィンドウを検索
Ctrl+b f

# 最後に使用したウィンドウに移動
Ctrl+b l
```

### ウィンドウの終了

```bash
# 現在のウィンドウを終了
Ctrl+b &
```

## ペイン管理

### ペインの分割

```bash
# 水平分割（上下に分割）
Ctrl+b "

# 垂直分割（左右に分割）
Ctrl+b %
```

### ペイン間の移動

```bash
# 次のペインに移動
Ctrl+b o

# 矢印キーでペイン移動
Ctrl+b ↑↓←→

# ペイン番号を表示して移動
Ctrl+b q
```

### ペインのサイズ調整

```bash
# ペインのサイズを調整（矢印キーで）
Ctrl+b Ctrl+↑↓←→

# より細かい調整
Ctrl+b Alt+↑↓←→
```

### ペインのレイアウト変更

```bash
# プリセットレイアウトを循環
Ctrl+b Space

# 特定のレイアウトに変更
Ctrl+b Alt+1  # even-horizontal
Ctrl+b Alt+2  # even-vertical
Ctrl+b Alt+3  # main-horizontal
Ctrl+b Alt+4  # main-vertical
Ctrl+b Alt+5  # tiled
```

### ペインの操作

```bash
# ペインを一時的に最大化/元に戻す
Ctrl+b z

# ペインを閉じる
Ctrl+b x

# ペインを別ウィンドウに移動
Ctrl+b !
```

## 設定ファイルのカスタマイズ

### 設定ファイルの場所

```bash
# ホームディレクトリに作成
~/.tmux.conf
```

### 基本的な設定例

```bash
# ~/.tmux.conf

# プレフィックスキーをCtrl+aに変更
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# 設定ファイルをリロード
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# マウスサポートを有効化
set -g mouse on

# ウィンドウ番号を1から開始
set -g base-index 1
set -g pane-base-index 1

# ペイン分割のキーバインドを変更
bind | split-window -h
bind - split-window -v

# ペイン移動をvimライクに
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# ウィンドウ移動をvimライクに
bind -r C-h select-window -t :-
bind -r C-l select-window -t :+

# ペインサイズ調整
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# ステータスバーの設定
set -g status-bg black
set -g status-fg white
set -g status-left '#[fg=green]#S '
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M'

# ウィンドウリストの設定
setw -g window-status-current-style bg=red,fg=white
```

### 設定の反映

```bash
# 設定ファイルをリロード
tmux source-file ~/.tmux.conf

# または設定したキーバインド（上記例ではCtrl+a r）
```

## 実践的な使用例

### 開発環境の構築

```bash
# 開発用セッションを作成
tmux new-session -d -s dev  # -d: デタッチ状態で作成、-s: セッション名を指定

# ウィンドウ1: エディタ
tmux rename-window -t dev:0 'editor'  # -t: ターゲット指定（セッション名:ウィンドウ番号）
# nvim: Neovim（テキストエディタ）
# .: 現在のディレクトリを指定
tmux send-keys -t dev:0 'nvim .' C-m  # C-m: Enterキーを表す

# ウィンドウ2: サーバー
tmux new-window -t dev:1 -n 'server'  # -n: 新しいウィンドウの名前を指定
# npm: Node.jsのパッケージマネージャー
# start: package.jsonで定義されたstartスクリプトを実行
tmux send-keys -t dev:1 'npm start' C-m

# ウィンドウ3: ログ監視
tmux new-window -t dev:2 -n 'logs'
# tail: ファイルの末尾を表示するコマンド
# -f: ファイルの変更を監視して新しい行を表示し続ける（follow）
# /var/log/app.log: アプリケーションのログファイル
tmux send-keys -t dev:2 'tail -f /var/log/app.log' C-m

# セッションにアタッチ
tmux attach-session -t dev  # 作成したセッションに接続
```

### モニタリングダッシュボード

```bash
# モニタリング用セッション
tmux new-session -d -s monitoring  # -d: デタッチ状態で作成、-s: セッション名を指定

# ペインを4分割
tmux split-window -h  # -h: 水平分割（左右に分割）
tmux split-window -v  # -v: 垂直分割（上下に分割）
tmux select-pane -t 0  # -t: ペイン番号を指定して選択
tmux split-window -v

# 各ペインでコマンドを実行
# htop: CPUとメモリ使用率をリアルタイムで表示するプロセス監視ツール（topの改良版）
tmux send-keys -t monitoring:0.0 'htop' C-m     # 0.0: ウィンドウ0のペイン0

# iostat: I/O（入出力）統計情報を表示するツール
# -x: 詳細な統計情報を表示、1: 1秒間隔で更新
tmux send-keys -t monitoring:0.1 'iostat -x 1' C-m  # 0.1: ウィンドウ0のペイン1

# nethogs: プロセス別のネットワーク使用量を表示するツール
tmux send-keys -t monitoring:0.2 'nethogs' C-m

# tail: ファイルの末尾を表示、-f: リアルタイムで新しい行を表示
# /var/log/syslog: システムログファイル
tmux send-keys -t monitoring:0.3 'tail -f /var/log/syslog' C-m

tmux attach-session -t monitoring
```

### バックアップとメンテナンス

```bash
# メンテナンス用セッション
tmux new-session -d -s maintenance  # -d: デタッチ状態で作成、-s: セッション名を指定

# ウィンドウ1: データベースバックアップ
tmux rename-window -t maintenance:0 'db-backup'  # -t: ターゲット指定（セッション名:ウィンドウ番号）
# 以下のコマンドの説明：
# while true; do ... done: 無限ループを実行
# mysqldump -u root -p mydb: MySQLデータベース'mydb'をダンプ（-u: ユーザー名、-p: パスワード入力）
# > backup_$(date +%Y%m%d_%H%M%S).sql: 現在日時をファイル名に含めてバックアップファイルを作成
# sleep 3600: 3600秒（1時間）待機
tmux send-keys -t maintenance:0 'while true; do mysqldump -u root -p mydb > backup_$(date +%Y%m%d_%H%M%S).sql; sleep 3600; done' C-m

# ウィンドウ2: ログローテーション
tmux new-window -t maintenance:1 -n 'log-rotation'  # -n: 新しいウィンドウの名前を指定
# logrotate: ログファイルの自動圧縮・削除・アーカイブを行うツール
# -f: 強制実行（設定ファイルの条件を無視して実行）
# /etc/logrotate.conf: システムのログローテーション設定ファイル
tmux send-keys -t maintenance:1 'logrotate -f /etc/logrotate.conf' C-m

tmux attach-session -t maintenance
```

## よくある問題と解決法

### 1. マウスが効かない

```bash
# ~/.tmux.conf に追加
set -g mouse on
```

### 2. 色が正しく表示されない

```bash
# ~/.tmux.conf に追加
set -g default-terminal "screen-256color"
```

### 3. コピー&ペーストが上手く動作しない

```bash
# macOSの場合
brew install reattach-to-user-namespace

# ~/.tmux.conf に追加
set-option -g default-command "reattach-to-user-namespace -l zsh"
```

### 4. セッションが予期せず終了する

```bash
# プロセスの確認
# ps: 現在実行中のプロセスを表示
# aux: a（全ユーザー）u（ユーザー詳細）x（端末に関連付けられていないプロセスも表示）
# grep: 文字列を検索するコマンド
ps aux | grep tmux  # プロセス一覧からtmuxを検索

# サーバーの状態確認
tmux info  # tmuxサーバーの詳細情報を表示
```

### 5. 設定が反映されない

```bash
# 設定ファイルの構文チェック
tmux source-file ~/.tmux.conf  # 設定ファイルを再読み込み

# tmuxサーバーを再起動
tmux kill-server  # 全てのセッションを含むサーバーを終了
tmux  # 新しいサーバーを起動
```

## 便利なtmuxプラグイン

### tmux plugin manager (TPM)

```bash
# インストール
# git clone: リモートリポジトリをローカルにコピー
# ~/.tmux/plugins/tpm: ホームディレクトリ内のtmuxプラグインディレクトリ
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm  # TPMをローカルにクローン

# ~/.tmux.conf に追加
set -g @plugin 'tmux-plugins/tpm'  # @plugin: プラグインを指定する設定
set -g @plugin 'tmux-plugins/tmux-sensible'  # 基本的な設定を提供
set -g @plugin 'tmux-plugins/tmux-resurrect'  # セッション保存・復元機能

run '~/.tmux/plugins/tpm/tpm'  # TPMを実行してプラグインを読み込み
```

### おすすめプラグイン

- **tmux-resurrect**: セッションの保存・復元
- **tmux-continuum**: 自動的にセッションを保存
- **tmux-yank**: 改良されたコピー機能
- **tmux-pain-control**: ペイン操作の改善

## 高度なtmuxコマンド集

基本操作を習得したら、さらに効率を上げる高度なコマンドを活用しましょう。

### セッション管理の高度なコマンド

```bash
# セッション名を変更
tmux rename-session -t old_name new_name

# 現在のセッション以外を全て終了
tmux kill-session -a  # -a: all others（現在のセッション以外）

# 特定のセッションの存在確認
tmux has-session -t mysession  # 存在すれば終了コード0、なければ1

# セッションをロック
tmux lock-session -t mysession  # パスワード入力が必要になる

# 全てのセッションを終了
tmux kill-server  # tmuxサーバー自体を終了

# セッション情報を詳細表示
tmux display-session -t mysession  # セッションの詳細情報を表示

# セッションのクライアント一覧
tmux list-clients -t mysession  # セッションに接続しているクライアント一覧
```

### ウィンドウ管理の高度なコマンド

```bash
# ウィンドウを強制終了
tmux kill-window -t mysession:1  # セッション名:ウィンドウ番号で指定

# ウィンドウの移動
tmux move-window -s source_session:1 -t target_session:2  # -s: 移動元、-t: 移動先

# ウィンドウの位置交換
tmux swap-window -s 1 -t 2  # ウィンドウ1と2を交換

# ウィンドウの番号を振り直し
tmux move-window -r  # -r: renumber（番号を詰める）

# ウィンドウのリンク作成
tmux link-window -s source_session:1 -t target_session:2  # ウィンドウを複数セッションで共有

# ウィンドウのリンク解除
tmux unlink-window -t target_session:2

# ウィンドウを新しいセッションに移動
tmux new-session -d -s newsession \; move-window -s oldsession:1

# ウィンドウのインデックスを変更
tmux move-window -t 5  # 現在のウィンドウを番号5に移動
```

### ペイン管理の高度なコマンド

```bash
# ペインを強制終了
tmux kill-pane -t mysession:1.2  # セッション:ウィンドウ.ペイン

# ペインの位置交換
tmux swap-pane -s 0 -t 1  # ペイン0と1を交換
tmux swap-pane -U  # -U: 上のペインと交換
tmux swap-pane -D  # -D: 下のペインと交換

# ペインサイズの詳細調整
tmux resize-pane -L 10  # -L: 左に10文字分縮小
tmux resize-pane -R 10  # -R: 右に10文字分拡大
tmux resize-pane -U 5   # -U: 上に5行分縮小
tmux resize-pane -D 5   # -D: 下に5行分拡大

# ペインを均等分割
tmux select-layout even-horizontal  # 水平に均等分割
tmux select-layout even-vertical    # 垂直に均等分割

# ペインの回転
tmux rotate-window  # ペインの配置を時計回りに回転
tmux rotate-window -D  # -D: 反時計回りに回転

# ペインを別のウィンドウに移動
tmux break-pane -t target_session:2  # 現在のペインを別ウィンドウに
tmux join-pane -s source_session:1.0 -t target_session:2  # ペインを結合

# ペインの境界表示
tmux display-panes -t mysession  # ペイン番号を表示

# ペインの情報取得
tmux display-panes -p  # -p: print（現在のペイン番号を出力）
```

### コピー&ペースト機能

```bash
# コピーモードに入る
tmux copy-mode  # viライクなコピーモード
tmux copy-mode -e  # -e: emacsライクなキーバインド

# バッファ操作
tmux paste-buffer  # 最新のバッファをペースト
tmux paste-buffer -b buffer1  # -b: 特定のバッファを指定

# バッファ一覧と管理
tmux list-buffers  # バッファ一覧を表示
tmux show-buffer -b buffer1  # 特定のバッファの内容を表示
tmux delete-buffer -b buffer1  # バッファを削除

# ファイルからバッファに読み込み
tmux load-buffer /path/to/file  # ファイル内容をバッファに読み込み
tmux save-buffer /path/to/file  # バッファ内容をファイルに保存

# 外部コマンドの出力をバッファに
tmux capture-pane -p | tmux load-buffer -  # ペイン内容をバッファに
```

### 環境変数とオプション設定

```bash
# グローバルオプション設定
tmux set-option -g option_name value  # -g: global
tmux set -g mouse on  # 短縮形

# セッション固有のオプション
tmux set-option -t mysession option_name value

# ウィンドウ固有のオプション
tmux set-window-option -t mysession:1 option_name value
tmux setw -t mysession:1 option_name value  # 短縮形

# オプション値の表示
tmux show-options -g  # グローバルオプション一覧
tmux show-options -t mysession  # セッション固有オプション

# 環境変数の設定
tmux set-environment -g MYVAR value  # グローバル環境変数
tmux set-environment -t mysession MYVAR value  # セッション固有

# 環境変数の表示
tmux show-environment -g  # グローバル環境変数一覧
tmux show-environment -t mysession  # セッション固有環境変数
```

### 情報表示とデバッグ

```bash
# サーバー情報
tmux info  # tmuxサーバーの詳細情報
tmux list-commands  # 利用可能なコマンド一覧
tmux list-keys  # キーバインド一覧

# セッション・ウィンドウ・ペイン情報
tmux display-message -p '#{session_name}'  # セッション名を表示
tmux display-message -p '#{window_name}'   # ウィンドウ名を表示
tmux display-message -p '#{pane_current_path}'  # 現在のパスを表示

# フォーマット変数の活用
tmux display-message -p 'Session: #{session_name}, Window: #{window_index}, Pane: #{pane_index}'

# ログ出力
tmux pipe-pane -o 'cat >> /tmp/tmux.log'  # ペイン出力をファイルに保存
tmux pipe-pane -o  # ログ出力を停止

# ペイン内容のキャプチャ
tmux capture-pane -p  # 現在のペイン内容を表示
tmux capture-pane -S -10 -E 10  # -S: 開始行、-E: 終了行
tmux capture-pane -J  # -J: 改行を保持
```

### 高度なキーバインド操作

```bash
# カスタムキーバインドの設定
tmux bind-key r source-file ~/.tmux.conf \; display-message "Reloaded!"

# キーバインドの削除
tmux unbind-key C-b  # デフォルトプレフィックスを削除

# 複数コマンドの連続実行
tmux bind-key S new-session \; split-window -h \; split-window -v

# 条件付きキーバインド
tmux bind-key -n C-Left if -F '#{s/off//:status}' 'send-keys C-Left' 'previous-window'

# キーテーブルの使用
tmux bind-key -T prefix t switch-client -T mytable
tmux bind-key -T mytable h select-pane -L
tmux bind-key -T mytable j select-pane -D
```

### スクリプト連携とオートメーション

```bash
# コマンドファイルの実行
tmux source-file /path/to/commands.tmux

# 外部スクリプトとの連携
tmux run-shell 'echo "Current time: $(date)"'  # シェルコマンド実行
tmux run-shell -b '/path/to/background_script.sh'  # -b: バックグラウンド実行

# 条件分岐
tmux if-shell '[ -f ~/.tmux.local.conf ]' 'source ~/.tmux.local.conf'

# セッション作成の自動化スクリプト例
tmux new-session -d -s work \; \
  rename-window -t work:0 'editor' \; \
  send-keys -t work:0 'nvim' C-m \; \
  new-window -t work:1 -n 'terminal' \; \
  new-window -t work:2 -n 'server' \; \
  send-keys -t work:2 'npm start' C-m \; \
  select-window -t work:0

# 複数セッションの一括操作
for session in $(tmux list-sessions -F '#{session_name}'); do
  tmux send-keys -t $session:0 'clear' C-m
done
```

### トラブルシューティングコマンド

```bash
# クライアントの強制切断
tmux detach-client -t /dev/pts/1  # 特定の端末を切断
tmux detach-client -a  # 全クライアントを切断

# 応答しないセッションの処理
tmux respawn-pane -t mysession:1.0  # ペインを再起動
tmux respawn-window -t mysession:1   # ウィンドウを再起動

# 画面のリフレッシュ
tmux refresh-client  # クライアント画面を更新
tmux refresh-client -S  # ステータスラインのみ更新

# セッションの修復
tmux attach-session -d -t mysession  # 強制的にデタッチしてからアタッチ

# ロックの解除
tmux unlock-session -t mysession  # セッションロックを解除
```

## まとめ

tmuxは習得すれば開発効率を大幅に向上させる強力なツールです。基本操作から高度なコマンドまで、段階的に学習していくことで、ターミナル作業の生産性を飛躍的に向上させることができます。

### 学習のポイント

1. **基本操作の習得**: セッション、ウィンドウ、ペインの操作を覚える
2. **設定のカスタマイズ**: 自分の作業スタイルに合わせて設定を調整
3. **実践的な使用**: 実際の開発作業でtmuxを使い続ける
4. **プラグインの活用**: 必要に応じてプラグインで機能を拡張
5. **高度なコマンドの習得**: 効率化のための応用テクニックをマスター

tmuxをマスターして、より効率的なターミナル作業環境を構築しましょう。