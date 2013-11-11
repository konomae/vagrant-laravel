# Vagrant-Laravel


## 利用条件

- VirtualBox 4.3.0 以上
- Vagrant 1.3.5 以上

上記をそれぞれインストールしてください。


## 構築する環境

- CentOS 6.4 x86_64
- PHP 5.3.3


## 仮想マシンの立ち上げ

以下を実行することで LAMP 環境が構築されます。
環境構築が実行されるのは初回の vagrant up 時のみです。次回以降は環境構築済みの仮想マシンが立ち上がります。
このセクションのコマンドは全てホスト OS で実行します。

    [host  ]$ git clone https://github.com/konomae/vagrant-laravel.git
    [host  ]$ cd vagrant-laravel
    [host  ]$ vagrant up

仮想マシンをシャットダウンするには以下を実行します。

    [host  ]$ vagrant halt

もし環境構築を任意のタイミングでもう一度実行する場合は以下を実行します。
但し、設定が上書きされる可能性があるのでご注意ください。
(詳しくは provision.sh を参照)

    [host  ]$ vagrant provision

環境が不要になった場合は以下のコマンドで破棄します。

    [host  ]$ vagrant destroy

以上が環境構築までです。


## Laravel のインストール

環境構築後、Laravel のインストール手順が画面に表示されます。Laravel のインストールは手動です。
なぜなら、構築した仮想マシンは Laravel 以外のフレームワークも動作するからです。
また、制作途中のプロジェクトで、環境だけ再構築する場合などもあるからです。

ホスト OS からゲスト OS にログインし、Laravel をインストールします。
ホスト OS で実行するコマンドとゲスト OS で実行するコマンドを区別してください。

    [host  ]$ vagrant ssh
    [guest ]$ cd /vagrant_data
    [guest ]$ composer create-project laravel/laravel --prefer-dist www

これを実行することで、ホスト OS 上から見ると `./vagrant_data/www` にプロジェクトが作成されています。
(上記相対パスはホスト OS の Vagrantfile が存在するディレクトリを基準としています)

ゲスト OS 側からは `/vagrant_data/www` を参照します。

実際のコーディング作業はホスト OS で行います。ファイルを保存するとゲスト OS 側に即反映されます。


## WEB アクセス

Laravel のインストールが終わったら `http://127.0.0.1:8080` にアクセスしてみてください。
Laravel のロゴとともに `You have arrived.` と表示されれば成功です。

Laravel の公開用フォルダ `/vagrant_data/www/public` がドキュメントルートになっています。


## MySQL について

mysql のデータベース `dev` を開発で利用する。必要であれば適宜データベースを追加する。
デフォルトではパスワードは特に設定していないので、`root / (パスワード無し)` で MySQL にログイン可能です。


## 開発用ドメインについて

`*.dev` ドメイン(開発専用のローカルでのみ利用可能なドメイン)でのアクセスにも対応しています。
`*.dev` ドメインの利用にはホストマシンの `/etc/hosts` の編集が必要です。
試しに以下を実行してみます。こうすることで、`www.dev` にアクセスした時に、`127.0.0.1` のサーバー(つまり自分自身)にアクセスするようになります。

    [host  ]$ sudo echo '127.0.0.1 www.dev'

上記を実行した後 `http://www.dev:8080/` にアクセスすると、Laravel の画面が表示されます。
(`http://127.0.0.1:8080` にアクセスした場合と同じファイルが見えています)

ディレクトリ名.dev という命名規則なので、例えば以下のように `test` ディレクトリを作成すると
`http://test.dev:8080` に `hello` と表示されます。
`vagrant_data/ディレクトリ名/public` の中身が実際に公開される点に注意します。

    [host  ]$ sudo echo '127.0.0.1 test.dev'
    [host  ]$ mkdir -p vagrant_data/test/public
    [host  ]$ echo 'hello' > vagrant_data/test/public/index.html

この開発用ドメインを使うことで、一つの仮想マシンで、複数のプロジェクトを同時に制作することができます。


## PHP 5.4 を利用したい場合

yum に remi レポジトリを登録しています。これはデフォルトでは無効です。
仮想マシンの立ち上げ後、ゲストマシンで以下を実行すると PHP 5.4 が入ります。
(PHP の他にも mysql などが比較的新しいバージョンに更新されます)
また、HTTP サーバーに反映するため、HTTP サーバーを再起動しています。

    [host  ]$ vagrant ssh
    [guest ]$ sudo yum update -y --enablerepo=remi
    [guest ]$ sudo service httpd restart
