#!/bin/bash

# Claude tmux デモスクリプト（直接プロンプト版）
# バックグラウンドでtmuxセッションを作成し、Claudeに直接プロンプトを送信

echo "Claude tmux デモを開始します..."

# 1. バックグラウンドでtmuxセッションを作成
tmux new-session -d -s claude-demo

# 2. セッション確認
echo "セッション 'claude-demo' が作成されました"
tmux list-sessions

# 3. Claudeに直接プロンプトを送信して実行
echo "Claude に作業を指示します..."
# -p: 応答を印刷して終了（非対話モード）
# 引数として直接プロンプトを渡す
tmux send-keys -t claude-demo 'claude -p "現在のディレクトリにあるファイルを一覧表示して、その中から.mdファイルの数を教えて"' C-m

# 4. 別の作業を実行
echo "追加の作業を実行します..."
sleep 3
tmux send-keys -t claude-demo 'claude -p "今日の日付と時刻を教えて"' C-m

# 5. さらに別の作業
echo "最後の作業を実行します..."
tmux send-keys -t claude-demo 'claude -p "このディレクトリ構造を簡単に説明して"' C-m

# 6. セッションにアタッチ
echo "作業結果を確認するためにセッションに接続します..."
sleep 3
tmux attach-session -t claude-demo