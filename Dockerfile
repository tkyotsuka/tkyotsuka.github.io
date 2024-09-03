# ベースイメージとしてjekyll/jekyll:latestを使用
FROM jekyll/jekyll:latest

# 必要に応じて、Jekyllの依存パッケージをインストール
RUN gem install bundler

# 作業ディレクトリを指定
WORKDIR /srv/jekyll

# ホスト側のGemfileとGemfile.lockをコピー
COPY Gemfile* /srv/jekyll/

# 必要なGemパッケージをインストール
RUN bundle install

# ホスト側のJekyllサイトファイルをすべてコピー
COPY . /srv/jekyll

# サーバを起動するためのデフォルトのコマンド
CMD ["jekyll", "serve", "--watch", "--host", "0.0.0.0"]
